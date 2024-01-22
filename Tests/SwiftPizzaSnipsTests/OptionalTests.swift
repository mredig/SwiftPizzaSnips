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

	func testOptionalUnwrapAndCast() throws {
		let a: Any? = 0
		let b: Any? = nil

		XCTAssertNoThrow(try a.unwrapCast(as: Int.self))
		XCTAssertThrowsError(try b.unwrapCast(as: Int.self))
	}

	func testOptionalUnwrapCastOrFatalUnwraps() {
		let a: Any? = 0

		XCTAssertNotNil(a.unwrapCastOrFatalError(as: Int.self, message: "There should *definitely* be a value"))
//		XCTAssertThrowsError(try Optional<Int>.none.unwrapCastOrFatalError(as: Int.self, message: "It would be great to test this, but it would crash the tests. Oh well."))
	}
}
