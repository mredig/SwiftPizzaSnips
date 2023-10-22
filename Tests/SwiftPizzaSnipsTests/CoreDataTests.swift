import Foundation
import XCTest
@testable import SwiftPizzaSnips

final class CoreDataTests: XCTestCase {
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
}
