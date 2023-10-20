import Foundation
import XCTest
@testable import SwiftPizzaSnips

final class CoreDataTests: XCTestCase {
	func testCoreDataRegisterModel() throws {
		class ExampleModel: NSManagedObject {}
		class SecondModel: NSManagedObject {}

		let bundle = Bundle(for: Self.self)
		let subBundleURL = try bundle
			.url(forResource: "SwiftPizzaSnips_SwiftPizzaSnipsTests", withExtension: "bundle")
			.unwrap()
		let subBundle = Bundle(url: subBundleURL)
		let modelURL = try subBundle
			.unwrap()
			.url(forResource: "Foo", withExtension: "momd")
			.unwrap()
		let stack = try CoreDataStack(modelURL: modelURL)

		XCTAssertTrue(stack.registeredModels.isEmpty)
		stack.registerModel(ExampleModel.self)
		XCTAssertEqual(1, stack.registeredModels.count)
		stack.registerModel(SecondModel.self)
		XCTAssertEqual(2, stack.registeredModels.count)
		stack.registerModel(ExampleModel.self)
		XCTAssertEqual(2, stack.registeredModels.count)
	}
}
