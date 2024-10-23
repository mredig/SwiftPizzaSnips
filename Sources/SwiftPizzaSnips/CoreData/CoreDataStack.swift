import Foundation
import CoreData

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8, *)
public class CoreDataStack: Withable {

	public static let didResetRegisteredTypesNotification = NSNotification.Name("pizzaSnips.didResetRegisteredTypesNotification")
	public static let didResetRegisteredTypeNotification = NSNotification.Name("pizzaSnips.didResetRegisteredTypeNotification")

	var modelFileName: String { modelURL.deletingPathExtension().lastPathComponent }
	var modelURL: URL {
		configuration.modelURL
	}
	/// If `configureContainer` is set to `false`, you must call `configureContainer()` prior to using `CoreDataStack`.
	/// This provides an opportunity for small configuration adjustments. Default is `true`. 
	/// Failure to follow this directive **may result in a crash**
	public convenience init(modelFileName: String, configureContainerImmediately: Bool = true) throws {
		let modelURL = try Bundle.main.url(forResource: modelFileName, withExtension: "momd").unwrap()
		try self.init(modelURL: modelURL, configureContainerImmediately: configureContainerImmediately)
	}

	/// If `configureContainer` is set to `false`, you must call `configureContainer()` prior to using `CoreDataStack`.
	/// This provides an opportunity for small configuration adjustments. Default is `true`. 
	/// Failure to follow this directive **may result in a crash**
	public convenience init(modelURL: URL, configureContainerImmediately: Bool = true) throws {
		let config = Configuration(modelURL: modelURL).with {
			$0.storeOption = .sqlDefaults
		}

		try self.init(configuration: config, configureContainerImmediately: configureContainerImmediately)
	}

	public init(configuration: Configuration, configureContainerImmediately: Bool = true) throws {
		guard
			try configuration.modelURL.checkResourceIsReachable()
		else { throw Error.noCoreDataModel(atPath: configuration.modelURL) }

		self._configuration = configuration

		if configureContainerImmediately {
			try self.configureContainer()
		}
	}

	private var _configuration: Configuration
	public var configuration: Configuration {
		get { _configuration }
		set {
			Self.containerLock.lock()
			defer { Self.containerLock.unlock() }
			guard _containerStore == nil else {
				print("Warning: Trying to update CoreDataStack configuration AFTER container has already been configured!")
				return
			}
			_configuration = newValue
		}
	}

	/// Access to the Persistent Container
	private static let containerLock = NSLock()
	private var _containerStore: NSPersistentContainer?
	@available(*, deprecated, message: "Use `configuredContainer`")
	public var container: NSPersistentContainer {
		Self.containerLock.lock()
		defer { Self.containerLock.unlock() }

		if let existing = _containerStore {
			return existing
		} else {
			return try! _configureContainer()
		}
	}

	/// Usage will call `configureContainer()` if not already configured.
	public var configuredContainer: NSPersistentContainer {
		get throws {
			Self.containerLock.lock()
			defer { Self.containerLock.unlock() }

			if let existing = _containerStore {
				return existing
			} else {
				return try _configureContainer()
			}
		}
	}

	/// Will cause a crash if `configureContainer()` is not called prior!
	public var mainContext: NSManagedObjectContext { try! configuredContainer.viewContext }

	/// Will cause a crash if `configureContainer()` is not called prior!
	public func newBackgroundContext() -> NSManagedObjectContext {
		try! configuredContainer.newBackgroundContext().with {
			$0.mergeConflictResolutionPolicy = configuration.newBackgroundContextDefaultMergePolicy
		}
	}

	@discardableResult
	private func _configureContainer() throws -> NSPersistentContainer {
		guard
			let model = NSManagedObjectModel(contentsOf: modelURL)
		else { throw Error.cantFindObjectModel(at: modelURL) }

		let container = NSPersistentContainer(name: modelFileName, managedObjectModel: model)

		switch configuration.storeOption {
		case .sql(config: let config):
			if let config {
				let options: [AnyHashable: Any]? = {
					var out: [String: Any] = [:]
					if let readOnly = config.readOnly {
						out[NSReadOnlyPersistentStoreOption] = readOnly
					}
					if let pragmas = config.pragmas {
						out[NSSQLitePragmasOption] = pragmas
					}
					if let analyze = config.analyze {
						out[NSSQLiteAnalyzeOption] = analyze
					}
					if let vacuum = config.vacuum {
						out[NSSQLiteManualVacuumOption] = vacuum
					}
					#if !os(macOS) && !os(Linux)
					if let protectionKey = config.protectionKey {
						out[NSPersistentStoreFileProtectionKey] = protectionKey
					}
					#endif

					guard out.isOccupied else { return nil }
					return out
				}()

				_ = try container.persistentStoreCoordinator.addPersistentStore(
					type: .sqlite,
					configuration: config.modelConfiguration,
					at: config.storeURL,
					options: options)
			} else {
				container.loadPersistentStores(completionHandler: { description, error in
					if let error = error {
						fatalError("Failed to load persistent store: \(error)")
					}
				})
			}
		case .inMemory:
			_ = try container.persistentStoreCoordinator.addPersistentStore(type: .inMemory, at: URL(string: "/dev/null")!)
		case .custom(let block):
			try block(container)
		}

		// May need to be disabled if dataset is too large for performance reasons
		container.viewContext.automaticallyMergesChangesFromParent = configuration.mainContextAutomaticallyMergeChanges
		container.viewContext.mergeConflictResolutionPolicy = configuration.mainContextDefaultMergePolicy

		_registerConsistentContext(container.newBackgroundContext(), forKey: .global, on: container)
		consistentContexts[.global]?.mergeConflictResolutionPolicy = configuration.newBackgroundContextDefaultMergePolicy
		_registerConsistentContext(container.viewContext, forKey: .main, on: container)

		_containerStore = container

		return container
	}
	public func configureContainer() throws {
		Self.containerLock.lock()
		defer { Self.containerLock.unlock() }

		try _configureContainer()
	}

	public private(set) var consistentContexts: [ContextKey: NSManagedObjectContext] = [:]

	/// Will trigger a call to `configureContainer()` if not already configured.
	@discardableResult
	public func registerConsistentContext(
		_ context: NSManagedObjectContext? = nil,
		forKey key: ContextKey
	) throws -> NSManagedObjectContext {
		Self.containerLock.lock()
		defer { Self.containerLock.unlock() }

		let container = try _containerStore ?? _configureContainer()

		return _registerConsistentContext(context, forKey: key, on: container)
	}

	@discardableResult
	private func _registerConsistentContext(
		_ context: NSManagedObjectContext? = nil,
		forKey key: ContextKey,
		on container: NSPersistentContainer
	) -> NSManagedObjectContext {
		if let existing = consistentContexts[key] {
			return existing
		}

		let theContext = context ?? container.newBackgroundContext()
		consistentContexts[key] = theContext
		return theContext
	}

	public func deregisterConsistentContext(forKey key: ContextKey) throws {
		guard _containerStore != nil else { throw Error.coreDataStackNeverConfigured }
		Self.containerLock.lock()
		defer { Self.containerLock.unlock() }

		guard key != .main else {
			print("Cannot deregister main (view) context")
			return
		}

		consistentContexts.removeValue(forKey: key)
	}

	public func context(_ key: ContextKey) throws -> NSManagedObjectContext {
		guard _containerStore != nil else { throw Error.coreDataStackNeverConfigured }
		Self.containerLock.lock()
		defer { Self.containerLock.unlock() }

		guard
			let context = consistentContexts[key]
		else { throw Error.noContextRegistered(forKey: key) }
		return context
	}

	public private(set) var registeredModels: [NSManagedObject.Type] = []
	public func registerModel(_ model: NSManagedObject.Type) {
		guard
			registeredModels.contains(where: { $0 === model }) == false
		else { return }
		registeredModels.append(model)
	}

	/// A generic function to save any context we want (main or background)
	public func save(
		context: NSManagedObjectContext,
		withMergePolicyOverride mergePolicy: NSMergePolicyType? = nil
	) throws {
		//Placeholder in case something doesn't work
		var closureError: Swift.Error?

		let previousPolicy: NSMergePolicyType?
		defer {
			if let previousPolicy {
				context.mergeConflictResolutionPolicy = previousPolicy
			}
		}
		if let mergePolicy {
			previousPolicy = context.mergeConflictResolutionPolicy
			context.mergeConflictResolutionPolicy = mergePolicy
		} else {
			previousPolicy = nil
		}

		context.performAndWait {
			do {
				try context.save()
			} catch {
				print("error saving context: \(error)")
				closureError = error
			}
		}
		if let error = closureError {
			throw error
		}
	}

	/// Deletes all instances of the given type in the primary container
	///
	/// See `registerModel(_:)`
	///
	/// Will trigger a call to `configureContainer()` if not already configured.
	public func resetRegisteredTypeInContainer(_ type: NSManagedObject.Type) throws {
		defer {
			NotificationCenter.default.post(name: Self.didResetRegisteredTypeNotification, object: self, userInfo: ["ResetType": type])
		}
		let container = try configuredContainer
		let bgContext = container.newBackgroundContext()

		try bgContext.performAndWait {
			let fetchRequest = type.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
			fetchRequest.resultType = .managedObjectIDResultType
			let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
			deleteRequest.resultType = .resultTypeObjectIDs

			if
				let deleteResult = try bgContext.execute(deleteRequest) as? NSBatchDeleteResult,
				let objectIDs = deleteResult.result as? [NSManagedObjectID] {

				NSManagedObjectContext.mergeChanges(
					fromRemoteContextSave: [NSDeletedObjectIDsKey: objectIDs],
					into: [bgContext, mainContext])
			}
		}
	}

	/// Deletes all instances of all registered types in the primary container
	///
	/// See `registerModel(_:)`
	///
	/// Will trigger a call to `configureContainer()` if not already configured.
	public func resetRegisteredTypesInContainer() throws {
		defer { NotificationCenter.default.post(name: Self.didResetRegisteredTypesNotification, object: self) }

		for model in registeredModels {
			try resetRegisteredTypeInContainer(model)
		}
	}

	public enum Error: Swift.Error {
		case containerAlreadyConfigured
		case noCoreDataModel(atPath: URL)
		case noContextRegistered(forKey: ContextKey)
		case cantFindObjectModel(at: URL)
		case coreDataStackNeverConfigured
	}
}
