import Foundation
import CoreData
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import Combine

@available(macOS 10.15.1, iOS 13.0, tvOS 13.0, *)
public class FetchedResultObserver<Result: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {

	private var frc: NSFetchedResultsController<Result>

	public typealias DiffableDataSourceType = NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
	public let updatePublisher = PassthroughSubject<DiffableDataSourceType, Never>()
	#if canImport(SwiftUI)
	@Published
	#endif
	public private(set) var latestSnapshot: DiffableDataSourceType = .init()

	public typealias StreamType = AsyncStream<DiffableDataSourceType>
	public var resultStream: StreamType {
		_resultStream
	}
	private var _resultStream: StreamType!
	private var streamContinuation: StreamType.Continuation?
	public var finishStreamOnDeallocate: Bool

	public private(set) var managedObjectContext: NSManagedObjectContext
	public private(set) var sectionNameKeyPath: String?
	public private(set) var cacheName: String?

	private static func createFRC(
		fetchRequest: NSFetchRequest<Result>,
		managedObjectContext: NSManagedObjectContext,
		sectionNameKeyPath: String?,
		cacheName: String?
	) -> NSFetchedResultsController<Result> {
		NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: managedObjectContext,
			sectionNameKeyPath: sectionNameKeyPath,
			cacheName: cacheName)
	}

	public init(
		fetchRequest: NSFetchRequest<Result>,
		managedObjectContext: NSManagedObjectContext,
		sectionNameKeyPath: String? = nil,
		cacheName: String? = nil,
		finishStreamOnDeallocate: Bool = true
	) throws {
		guard
			fetchRequest.sortDescriptors?.isOccupied == true
		else { throw ResultObserverError.fetchedResultsControllerRequiresSortDescriptors }

		self.managedObjectContext = managedObjectContext
		self.sectionNameKeyPath = sectionNameKeyPath
		self.cacheName = cacheName
		self.frc = Self.createFRC(
			fetchRequest: fetchRequest,
			managedObjectContext: managedObjectContext,
			sectionNameKeyPath: sectionNameKeyPath,
			cacheName: cacheName)
		self.finishStreamOnDeallocate = finishStreamOnDeallocate

		super.init()

		self._resultStream = AsyncStream { continuation in
			self.streamContinuation = continuation
		}

		frc.delegate = self
	}

	deinit {
		if finishStreamOnDeallocate {
			streamContinuation?.finish()
		}
	}

	public func start() throws {
		try frc.performFetch()
	}

	public func updateFetchRequest(_ request: NSFetchRequest<Result>) throws {
		guard
			request.sortDescriptors?.isOccupied == true
		else { throw ResultObserverError.fetchedResultsControllerRequiresSortDescriptors }

		let frc = Self.createFRC(
			fetchRequest: request,
			managedObjectContext: managedObjectContext,
			sectionNameKeyPath: sectionNameKeyPath,
			cacheName: cacheName)
		self.frc = frc

		try start()
	}

	public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
		let snap = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
		latestSnapshot = snap
		streamContinuation?.yield(snap)
		updatePublisher.send(snap)
	}

	public func object(for objectID: NSManagedObjectID, on context: NSManagedObjectContext? = nil) throws -> Result {
		let context = context ?? managedObjectContext

		let object = try context.existingObject(with: objectID)

		return try (object as? Result).unwrap("Object either doesn't exist or isn't of \(Result.self) type.")
	}

	public func maybeObject(for objectID: NSManagedObjectID, on context: NSManagedObjectContext? = nil) -> Result? {
		try? object(for: objectID, on: context)
	}

	public enum ResultObserverError: Error {
		case fetchedResultsControllerRequiresSortDescriptors
	}
}

#if canImport(SwiftUI)
@available(macOS 10.15.1, iOS 13.0, tvOS 13.0, *)
extension FetchedResultObserver: ObservableObject {}
#endif
