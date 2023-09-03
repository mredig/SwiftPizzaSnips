import XCTest
@testable import SwiftPizzaSnips

final class OptionalTests: XCTestCase {
	func testOptionalUnwraps() {
		let a: Int? = 0
		let b: Int? = nil

		XCTAssertNoThrow(try a.unwrap())
		XCTAssertThrowsError(try b.unwrap())
	}
}
