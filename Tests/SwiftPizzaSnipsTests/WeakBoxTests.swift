import XCTest
import SwiftPizzaSnips

final class WeakBoxTests: XCTestCase {
	func testWeakBox() throws {
		var test: NSObject? = NSObject()

		let box = WeakBox(content: test)

		XCTAssertNotNil(box.content)

		test = nil

		XCTAssertNil(box.content)
	}
}
