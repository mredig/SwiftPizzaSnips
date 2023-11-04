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

	func testThrowingWithable() throws {
		let url = try Bundle.module.url(forResource: "sample", withExtension: "bin").unwrap()

		let prog = try Progress().with {
			$0.totalUnitCount = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize.map(Int64.init) ?? 0
		}

		XCTAssertEqual(10240, prog.totalUnitCount)
	}

	func testAsyncWithable() async throws {
		let url = try Bundle.module.url(forResource: "sample", withExtension: "bin").unwrap()

		let prog = try await Progress().asyncWith {
			$0.totalUnitCount = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize.map(Int64.init) ?? 0
			try await Task.sleep(nanoseconds: 100)
		}

		XCTAssertEqual(10240, prog.totalUnitCount)
	}
}
