import XCTest
import SwiftPizzaSnips

@available(iOS 15, *)
final class AttributedStringBuilderTests: XCTestCase {
	func testAttributedStringBuilder() throws {

		let attStr = AttributedString(builder: {
			ASComponent("foo")

			ASComponent("bar")
				.withItalics(true)

			ASComponent("baz")
				.withColor(.brown)
				.withFontDescriptor {
					$0 = $0.withSymbolicTraits([.bold])
				}
		})

		let runs = Array(attStr.runs)
		XCTAssertEqual(String(attStr.characters), "foobarbaz")
		XCTAssertTrue(runs[0].description.contains("Regular 13"))
		XCTAssertTrue(runs[1].description.contains("RegularItalic 13"))
		XCTAssertTrue(runs[2].description.contains("Bold "))
		XCTAssertTrue(runs[2].description.contains("sRGB "))
	}
}
