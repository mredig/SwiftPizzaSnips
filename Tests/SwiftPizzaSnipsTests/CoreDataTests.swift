#if !canImport(FoundationNetworking)
import Foundation
import XCTest
import SwiftPizzaSnips
import CoreData

/// Even though Apple Platforms should all work, `swift test` doesn't actually code gen CoreData files, so this will
/// fail to build on macos for that reason. Either use Xcode's UI or
/// `xcodebuild test -scheme SwiftPizzaSnips -destination 'platform=macOS'`
@available(iOS 15.0, *)
final class CoreDataTests: XCTestCase {
	override class func setUp() {
		super.setUp()
		ValueTransformer
			.setValueTransformer(
				CodableTransformer<[String]>(),
				forName: NSValueTransformerName(rawValue: "StringArrayTransformer"))
	}

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

	func testCoreDataRegisterModel() throws {
		class ExampleModel: NSManagedObject {}
		class SecondModel: NSManagedObject {}

		let stack = try testableCoreDataStack()

		XCTAssertEqual(1, stack.registeredModels.count)
		stack.registerModel(ExampleModel.self)
		XCTAssertEqual(2, stack.registeredModels.count)
		stack.registerModel(SecondModel.self)
		XCTAssertEqual(3, stack.registeredModels.count)
		stack.registerModel(ExampleModel.self)
		XCTAssertEqual(3, stack.registeredModels.count)
	}

	func testMergePolicySetterGetter() throws {
		let coreDataStack = try testableCoreDataStack()

		XCTAssertEqual(coreDataStack.mainContext.mergeConflictResolutionPolicy, .errorMergePolicyType)
		XCTAssertNotEqual(
			coreDataStack.mainContext.mergeConflictResolutionPolicy,
			.mergeByPropertyStoreTrumpMergePolicyType
		)
		XCTAssertNotEqual(
			coreDataStack.mainContext.mergeConflictResolutionPolicy,
			.mergeByPropertyObjectTrumpMergePolicyType
		)
		XCTAssertNotEqual(coreDataStack.mainContext.mergeConflictResolutionPolicy, .rollbackMergePolicyType)
		XCTAssertNotEqual(coreDataStack.mainContext.mergeConflictResolutionPolicy, .overwriteMergePolicyType)

		coreDataStack.mainContext.mergeConflictResolutionPolicy = .mergeByPropertyObjectTrumpMergePolicyType
		XCTAssertEqual(
			coreDataStack.mainContext.mergeConflictResolutionPolicy,
			.mergeByPropertyObjectTrumpMergePolicyType
		)

		coreDataStack.mainContext.mergeConflictResolutionPolicy = .mergeByPropertyStoreTrumpMergePolicyType
		XCTAssertEqual(
			coreDataStack.mainContext.mergeConflictResolutionPolicy,
			.mergeByPropertyStoreTrumpMergePolicyType
		)

		coreDataStack.mainContext.mergeConflictResolutionPolicy = .rollbackMergePolicyType
		XCTAssertEqual(coreDataStack.mainContext.mergeConflictResolutionPolicy, .rollbackMergePolicyType)

		coreDataStack.mainContext.mergeConflictResolutionPolicy = .overwriteMergePolicyType
		XCTAssertEqual(coreDataStack.mainContext.mergeConflictResolutionPolicy, .overwriteMergePolicyType)

		coreDataStack.mainContext.mergeConflictResolutionPolicy = .errorMergePolicyType
		XCTAssertEqual(coreDataStack.mainContext.mergeConflictResolutionPolicy, .errorMergePolicyType)
	}

	func testNoThrowSave() async throws {
		let coreDataStack = try testableCoreDataStack()
		let context = coreDataStack.mainContext

		let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Foo")
		fetchRequest.resultType = .countResultType
		let beforeCount = try await context.perform {
			let count = try context.fetch(fetchRequest) as? [Int] ?? []
			return count.first ?? 0
		}

		// create new item
		await context.perform {
			let newFoo = Foo(context: context)
			newFoo.id = UUID()
			newFoo.value = String.randomLoremIpsum(wordCount: 5)

			context.noThrowSave()
		}

		let afterCount = try await context.perform {
			let count = try context.fetch(fetchRequest) as? [Int] ?? []
			return count.first ?? 0
		}

		XCTAssertEqual(beforeCount + 1, afterCount)
	}

	func testTransformer() async throws {
		let coreDataStack = try testableCoreDataStack()
		let context = coreDataStack.mainContext

		coreDataStack.registerModel(Baz.self)

		let expected = ["G.O.B.", "Motley", "Quixote"]

		try await context.perform {
			let bazzer = Baz(context: context)
			bazzer.fools = expected

			try context.save()
		}
		addTeardownBlock {
			try coreDataStack.resetRegisteredTypesInContainer()
		}

		let fetchRequest = Baz.fetchRequest()
		let retrieved = try await context.perform {
			fetchRequest.fetchLimit = 1
			return try context.fetch(fetchRequest).first.unwrap()
		}

		XCTAssertEqual(expected, retrieved.fools)
	}

	func testCoreDataConsistentGlobalContext() throws {
		let coreDataStack = try testableCoreDataStack()

		let contextA = try coreDataStack.context(.global)
		let contextB = try coreDataStack.context(.global)

		XCTAssertEqual(contextA, contextB)
	}

	func testCoreDataConsistentMainContext() throws {
		let coreDataStack = try testableCoreDataStack()

		let contextA = try coreDataStack.context(.main)
		let contextB = try coreDataStack.context(.main)
		let contextC = coreDataStack.mainContext

		XCTAssertEqual(contextA, contextB)
		XCTAssertEqual(contextA, contextC)
	}

	func testCreateContsistentContext() throws {
		let coreDataStack = try testableCoreDataStack()

		let contextA = coreDataStack.registerConsistentContext(forKey: .myCustomContext)
		let contextB = coreDataStack.registerConsistentContext(
			coreDataStack.container.newBackgroundContext(),
			forKey: .myOtherCustomContext)

		let contextARetrieve = try coreDataStack.context(.myCustomContext)
		let contextBRetrieve = try coreDataStack.context(.myOtherCustomContext)

		XCTAssertEqual(contextA, contextARetrieve)
		XCTAssertEqual(contextB, contextBRetrieve)
		XCTAssertNotEqual(contextA, contextB)

		let contextASecondRegister = coreDataStack.registerConsistentContext(forKey: .myCustomContext)
		XCTAssertEqual(contextA, contextASecondRegister)
	}

	func testDeregisterConsistentContext() throws {
		let coreDataStack = try testableCoreDataStack()

		let contextA = coreDataStack.registerConsistentContext(forKey: .myCustomContext)

		XCTAssertNoThrow(try coreDataStack.context(.myCustomContext))

		coreDataStack.deregisterConsistentContext(forKey: .myCustomContext)

		XCTAssertThrowsError(try coreDataStack.context(.myCustomContext))
	}
}

@available(iOS 15.0, *)
extension CoreDataStack.ContextKey {
	static let myCustomContext: Self = "my custom context"
	static let myOtherCustomContext: Self = "my other custom context"
}
#endif
