import XCTest
@testable import SwiftPizzaSnips

final class OptionalBoolTests: XCTestCase {
	func testOptionalTrue() {
		let a: Bool? = true
		let b: Bool? = false
		let c: Bool? = nil

		XCTAssertTrue(a.nilIsTrue)
		XCTAssertFalse(b.nilIsTrue)
		XCTAssertTrue(c.nilIsTrue)
	}

	func testOptionalFalse() {
		let a: Bool? = true
		let b: Bool? = false
		let c: Bool? = nil

		XCTAssertTrue(a.nilIsFalse)
		XCTAssertFalse(b.nilIsFalse)
		XCTAssertFalse(c.nilIsFalse)
	}
}
