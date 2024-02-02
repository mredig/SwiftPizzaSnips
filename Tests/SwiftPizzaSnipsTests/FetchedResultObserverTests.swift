#if !canImport(FoundationNetworking)
import Foundation
import XCTest
import SwiftPizzaSnips
import CoreData

/// Even though Apple Platforms should all work, `swift test` doesn't actually code gen CoreData files, so this will
/// fail to build on macos for that reason. Either use Xcode's UI or
/// `xcodebuild test -scheme SwiftPizzaSnips -destination 'platform=macOS'`
@available(iOS 15.0, *)
final class FetchedResultObserverTests: XCTestCase {

	private func testableCoreDataStack() throws -> CoreDataStack {
		let bundle = Bundle(for: Self.self)
		let subBundleURL = try bundle
			.url(forResource: "SwiftPizzaSnips_SwiftPizzaSnipsTests", withExtension: "bundle")
			.unwrap()
		let subBundle = Bundle(url: subBundleURL)
		let modelURL = try subBundle
			.unwrap()
			.url(forResource: "Foo", withExtension: "momd")
			.unwrap()

		let cds = try CoreDataStack(modelURL: modelURL)

		cds.registerModel(Foo.self)
		try cds.resetRegisteredTypesInContainer()
		return cds
	}

	func testResultObserver() async throws {
		let coreDataStack = try testableCoreDataStack()
		coreDataStack.registerModel(Foo.self)
		let existing = Foo(context: coreDataStack.mainContext)
		existing.id = UUID()
		existing.value = "foooooo"

		addTeardownBlock {
			try coreDataStack.resetRegisteredTypesInContainer()
		}

		try coreDataStack.mainContext.save()

		let fooRequest = Foo.fetchRequest()
		fooRequest.sortDescriptors = [
			.init(keyPath: \Foo.value, ascending: true)
		]

		let resultObserver = try FetchedResultObserver(fetchRequest: fooRequest, managedObjectContext: coreDataStack.mainContext)

		let streamCreatedExp = expectation(description: "Stream created")
		let hasExpectedStartCount = expectation(description: "expected start Count")
		let hasExpectedFinishCount = expectation(description: "expected finish Count")
		Task {
			let stream = resultObserver.resultStream
			streamCreatedExp.fulfill()

			for await snapshot in stream {
				print(snapshot)

				if snapshot.numberOfItems == 1 {
					hasExpectedStartCount.fulfill()
				}

				if snapshot.numberOfItems == 3 {
					hasExpectedFinishCount.fulfill()
				}
			}
		}
		try resultObserver.start()

		await fulfillment(of: [streamCreatedExp, hasExpectedStartCount], timeout: 5)

		print("Created result observer and started monitoring")

		let newA = Foo(context: coreDataStack.mainContext)
		newA.id = UUID()
		newA.value = "newa"

		let newB = Foo(context: coreDataStack.mainContext)
		newB.id = UUID()
		newB.value = "newb"
		try coreDataStack.mainContext.save()

		await fulfillment(of: [hasExpectedFinishCount], timeout: 5)
	}

	func testThrowsWithNoSortDescriptor() throws {
		let coreDataStack = try testableCoreDataStack()

		let fooRequest = Foo.fetchRequest()
		XCTAssertThrowsError(try FetchedResultObserver(fetchRequest: fooRequest, managedObjectContext: coreDataStack.mainContext))
	}
}
#endif
