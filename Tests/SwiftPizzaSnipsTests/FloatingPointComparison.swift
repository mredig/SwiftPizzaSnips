import XCTest
import SwiftPizzaSnips

final class FloatingPointComparison: XCTestCase {
	func testFloatExact() throws {
		let a: Float = 1.2345
		let b: Float = 1.2345

		XCTAssertTrue(a.isWithinTolerance(of: b, tolerance: 0.0001))
	}

	func testFloatWithinTolerance() throws {
		let a: Float = 1.2345
		let b: Float = 1.23456

		XCTAssertTrue(a.isWithinTolerance(of: b, tolerance: 0.0001))
	}

	func testFloatOutsideTolerance() throws {
		let a: Float = 1.33245
		let b: Float = 1.23456

		XCTAssertFalse(a.isWithinTolerance(of: b, tolerance: 0.0001))
	}

	func testDoubleExact() throws {
		let a: Double = 1.2345
		let b: Double = 1.2345

		XCTAssertTrue(a.isWithinTolerance(of: b, tolerance: 0.0001))
	}

	func testDoubleWithinTolerance() throws {
		let a: Double = 1.2345
		let b: Double = 1.23456

		XCTAssertTrue(a.isWithinTolerance(of: b, tolerance: 0.0001))
	}

	func testDoubleOutsideTolerance() throws {
		let a: Double = 1.33245
		let b: Double = 1.23456

		XCTAssertFalse(a.isWithinTolerance(of: b, tolerance: 0.0001))
	}

}
