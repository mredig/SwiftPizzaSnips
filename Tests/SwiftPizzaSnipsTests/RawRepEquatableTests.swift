import XCTest
import SwiftPizzaSnips

final class RawRepEquatableTests: XCTestCase {
	struct NotAString: RawRepresentable, RawRepEquatable {
		var rawValue: String

		init(rawValue: String) {
			self.rawValue = rawValue
		}
	}

	func testEqualityComparisons() {
		let stringA = "abcdefg"
		let stringB = "zyxwvut"

		let notStringA = NotAString(rawValue: stringA)
		let notStringB = NotAString(rawValue: stringB)

		XCTAssertTrue(stringA == notStringA)
		XCTAssertTrue(notStringA == stringA)
		XCTAssertFalse(stringA != notStringA)
		XCTAssertFalse(notStringA != stringA)

		XCTAssertFalse(stringA == notStringB)
		XCTAssertFalse(notStringB == stringA)
		XCTAssertTrue(stringA != notStringB)
		XCTAssertTrue(notStringB != stringA)
	}
}
