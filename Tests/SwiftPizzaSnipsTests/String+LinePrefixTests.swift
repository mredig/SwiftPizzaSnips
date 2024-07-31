import XCTest
import SwiftPizzaSnips

final class StringLinePrefixTests: XCTestCase {
	func testIndentation() {
		let original = """
			I like newlines
			Here's one.
			For example...
			"""

		let expected = """
				I like newlines
				Here's one.
				For example...
			"""

		let test = original.prefixingLines(with: "\t")
		XCTAssertEqual(test, expected)
	}
}
