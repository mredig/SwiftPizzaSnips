import XCTest
@testable import SwiftPizzaSnips

final class WithableTests: XCTestCase {
	
	@available(iOS 13.0, *)
	func testWithable() {
		let str = "fee fie fo fum"
		let attStr = NSMutableAttributedString(string: str).with {
			$0.addAttribute(
				.underlineColor,
				value: CGColor(srgbRed: 0.5, green: 0.5, blue: 0.5, alpha: 1),
				range: NSRange(location: 0, length: $0.length))
		}

		let attributes = attStr.attributes(at: 0, effectiveRange: nil)
		XCTAssertTrue(attributes.keys.contains(.underlineColor))
	}
}
