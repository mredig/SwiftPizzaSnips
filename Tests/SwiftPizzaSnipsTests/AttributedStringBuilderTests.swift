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
		XCTAssertFalse(runs[0].description.contains("Font"))
		XCTAssertTrue(runs[1].description.contains("Oblique 13"))
		XCTAssertTrue(runs[2].description.contains("Bold "))
		XCTAssertTrue(runs[2].description.contains("sRGB "))
	}

	func testAttributedStringBuilderOptional() throws {
		let bar: String? = "bar"

		let attStr = AttributedString(builder: {
			ASComponent("foo")

			if let bar {
				ASComponent(bar)
					.withItalics()
					.withColor(.secondaryLabelColor)
			}
		})

		let runs = Array(attStr.runs)
		XCTAssertEqual(String(attStr.characters), "foobar")
		XCTAssertFalse(runs[0].description.contains("Font"))
		XCTAssertTrue(runs[1].description.contains("Oblique 13"))
		XCTAssertTrue(runs[1].description.contains("Catalog "))
	}
}
