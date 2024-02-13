import XCTest
import SwiftPizzaSnips

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
