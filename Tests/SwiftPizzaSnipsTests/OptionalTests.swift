import XCTest
import SwiftPizzaSnips

final class OptionalTests: XCTestCase {
	func testOptionalUnwraps() {
		let a: Int? = 0
		let b: Int? = nil

		XCTAssertNoThrow(try a.unwrap())
		XCTAssertThrowsError(try b.unwrap())
	}

	func testOptionalOrFatalUnwraps() {
		let a: Int? = 0

		XCTAssertNotNil(a.unwrapOrFatalError(message: "There should *definitely* be a value"))
//		XCTAssertThrowsError(try Optional<Int>.none.unwrapOrFatalError(message: "It would be great to test this, but it would crash the tests. Oh well."))
	}
}
