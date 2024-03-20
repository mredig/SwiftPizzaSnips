import Foundation
import CoreData

// no events should be created from this, but observable object allows storing in environment object
@available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
public class CoreDataStack: Withable {

	public static let didResetRegisteredTypesNotification = NSNotification.Name("pizzaSnips.didResetRegisteredTypesNotification")
	public static let didResetRegisteredTypeNotification = NSNotification.Name("pizzaSnips.didResetRegisteredTypeNotification")

	var modelFileName: String { modelURL.deletingPathExtension().lastPathComponent }
	let modelURL: URL
	public convenience init(modelFileName: String) throws {
		let modelURL = try Bundle.main.url(forResource: modelFileName, withExtension: "momd").unwrap()
		try self.init(modelURL: modelURL)
	}
	public init(modelURL: URL) throws {
		guard
			try modelURL.checkResourceIsReachable()
		else { throw Error.noCoreDataModel(atPath: modelURL) }

		self.modelURL = modelURL
	}

	/// A generic function to save any context we want (main or background)
	public func save(
		context: NSManagedObjectContext,
		// might be able to use `NSMergePolicy = .mergeByPropertyObjectTrump` instead
		withMergePolicy mergePolicy: AnyObject = NSMergeByPropertyObjectTrumpMergePolicy
	) throws {
		//Placeholder in case something doesn't work
		var closureError: Swift.Error?

		context.mergePolicy = mergePolicy

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

	/// Access to the Persistent Container
	private static let containerLock = NSLock()
	private var _container: NSPersistentContainer?
	public var container: NSPersistentContainer {
		get {
			Self.containerLock.lock()
			defer { Self.containerLock.unlock() }

			if let _container = _container {
				return _container
			} else {
				guard
					let model = NSManagedObjectModel(contentsOf: modelURL)
				else { fatalError("can't find object model: \(modelFileName)") }

				let container = NSPersistentContainer(name: modelFileName, managedObjectModel: model)

				container.loadPersistentStores(completionHandler: { description, error in
					if let error = error {
						fatalError("Failed to load persistent store: \(error)")
					}
				})
				// May need to be disabled if dataset is too large for performance reasons
				container.viewContext.automaticallyMergesChangesFromParent = true

				_registerConsistentContext(container.newBackgroundContext(), forKey: .global, on: container)
				_registerConsistentContext(container.viewContext, forKey: .main, on: container)

				_container = container
				return container
			}
		}
	}

	public var mainContext: NSManagedObjectContext { container.viewContext }

	public func newBackgroundContext() -> NSManagedObjectContext { container.newBackgroundContext() }

	public private(set) var consistentContexts: [ContextKey: NSManagedObjectContext] = [:]

	@discardableResult
	public func registerConsistentContext(
		_ context: NSManagedObjectContext? = nil,
		forKey key: ContextKey
	) -> NSManagedObjectContext {
		let container = container
		Self.containerLock.lock()
		defer { Self.containerLock.unlock() }

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

	public func deregisterConsistentContext(forKey key: ContextKey) {
		_ = container
		Self.containerLock.lock()
		defer { Self.containerLock.unlock() }

		guard key != .main else {
			print("Cannot deregister main (view) context")
			return
		}

		consistentContexts.removeValue(forKey: key)
	}

	public func context(_ key: ContextKey) throws -> NSManagedObjectContext {
		_ = container
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

	public func resetRegisteredTypeInContainer(_ type: NSManagedObject.Type) throws {
		defer {
			NotificationCenter.default.post(name: Self.didResetRegisteredTypeNotification, object: self, userInfo: ["ResetType": type])
		}
		let bgContext = container.newBackgroundContext()

		try bgContext.performAndWait {
			let fetchRequest = type.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
			fetchRequest.resultType = .managedObjectIDResultType
			let imageDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

			if
				let deleteResult = try bgContext.execute(imageDeleteRequest) as? NSBatchDeleteResult,
				let objectIDs = deleteResult.result as? [NSManagedObjectID] {

				NSManagedObjectContext.mergeChanges(
					fromRemoteContextSave: [NSDeletedObjectIDsKey: objectIDs],
					into: [bgContext, mainContext])
			}
		}
	}

	public func resetRegisteredTypesInContainer() throws {
		defer { NotificationCenter.default.post(name: Self.didResetRegisteredTypesNotification, object: self) }

		for model in registeredModels {
			try resetRegisteredTypeInContainer(model)
		}
	}

	public enum Error: Swift.Error {
		case noCoreDataModel(atPath: URL)
		case noContextRegistered(forKey: ContextKey)
	}
}
