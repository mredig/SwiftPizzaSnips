import Foundation
import CoreData

// no events should be created from this, but observable object allows storing in environment object
@available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
public class CoreDataStack {

	var modelFileName: String { modelURL.deletingPathExtension().lastPathComponent }
	let modelURL: URL
	public convenience init(modelFileName: String) throws {
		let modelURL = try Bundle.main.url(forResource: modelFileName, withExtension: "momd").unwrap()
		try self.init(modelURL: modelURL)
	}
	public init(modelURL: URL) throws {
		guard
			try modelURL.checkResourceIsReachable()
		else { throw SimpleError(message: "No CoreData model at specified path") }

		self.modelURL = modelURL
	}

	/// A generic function to save any context we want (main or background)
	public func save(
		context: NSManagedObjectContext,
		// might be able to use `NSMergePolicy = .mergeByPropertyObjectTrump` instead
		withMergePolicy mergePolicy: AnyObject = NSMergeByPropertyObjectTrumpMergePolicy) throws {

		//Placeholder in case something doesn't work
		var closureError: Error?

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
				_container = container
				return container
			}
		}
	}

	public var mainContext: NSManagedObjectContext {
		return container.viewContext
	}

	public private(set) var registeredModels: [NSManagedObject.Type] = []
	public func registerModel(_ model: NSManagedObject.Type) {
		guard
			registeredModels.contains(where: { $0 === model }) == false
		else { return }
		registeredModels.append(model)
	}

	public func resetRegisteredTypesInContainer() throws {
		let bgContext = container.newBackgroundContext()

		for model in registeredModels {
			try bgContext.performAndWait {
				let fetchRequest = model.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
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
	}
}
