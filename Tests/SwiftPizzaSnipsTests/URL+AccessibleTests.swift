import XCTest
import SwiftPizzaSnips

@available(iOS 16, tvOS 16, watchOS 10, *)
final class URLAccessibleTests: XCTestCase {
	func testURLAccessible() throws {
		let url = Bundle.module.resourceURL!.appending(component: "sample").appendingPathExtension("bin")
		XCTAssertTrue(url.checkResourceIsAccessible())
	}

	func testURLInaccessible() throws {
		let url = Bundle.module.resourceURL!.appending(component: "fakesample").appendingPathExtension("bin")
		XCTAssertFalse(url.checkResourceIsAccessible())
	}
}
