import XCTest
import SwiftPizzaSnips

@available(iOS 16, tvOS 16, watchOS 10, *)
final class URLWindowsFilepathTests: XCTestCase {
	func testURLWindowsFilepath() throws {
		let winFilepath = ##"C:\Users\Administrator\Documents\bitcoin key.docx"##

		let expectedURLPath = "/C/Users/Administrator/Documents/bitcoin key.docx"

		let url = URL(windowsFilepath: winFilepath)

		XCTAssertEqual(url?.path(percentEncoded: false), expectedURLPath)
	}

	func testNonWindowsFilepath() throws {
		let regularPath1 = "/foo/bar"
		let regularPath2 = "../foo/bar"
		let regularPath3 = "./baz"
		let regularPath4 = "bar/foo.doc"

		XCTAssertNil(URL(windowsFilepath: regularPath1))
		XCTAssertNil(URL(windowsFilepath: regularPath2))
		XCTAssertNil(URL(windowsFilepath: regularPath3))
		XCTAssertNil(URL(windowsFilepath: regularPath4))
	}
}
