import XCTest
import SwiftPizzaSnips

#if !os(Linux)
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
					#if os(macOS)
					$0 = $0.withSymbolicTraits([.bold])
					#else
					$0 = $0.withSymbolicTraits([.traitBold]) ?? $0
					#endif
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
				#if os(macOS)
				ASComponent(bar)
					.withItalics()
					.withColor(.secondaryLabelColor)
				#else
				ASComponent(bar)
					.withItalics()
					.withColor(.secondaryLabel)
				#endif
			}
		})

		let runs = Array(attStr.runs)
		XCTAssertEqual(String(attStr.characters), "foobar")
		XCTAssertFalse(runs[0].description.contains("Font"))
		XCTAssertTrue(runs[1].description.contains("Oblique 13"))
		XCTAssertTrue(runs[1].description.contains("Catalog "))
	}
}
#endif
