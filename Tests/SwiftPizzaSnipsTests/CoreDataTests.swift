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
		return try CoreDataStack(modelURL: modelURL)
	}

	func testCoreDataRegisterModel() throws {
		class ExampleModel: NSManagedObject {}
		class SecondModel: NSManagedObject {}

		let stack = try testableCoreDataStack()

		XCTAssertTrue(stack.registeredModels.isEmpty)
		stack.registerModel(ExampleModel.self)
		XCTAssertEqual(1, stack.registeredModels.count)
		stack.registerModel(SecondModel.self)
		XCTAssertEqual(2, stack.registeredModels.count)
		stack.registerModel(ExampleModel.self)
		XCTAssertEqual(2, stack.registeredModels.count)
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
}
