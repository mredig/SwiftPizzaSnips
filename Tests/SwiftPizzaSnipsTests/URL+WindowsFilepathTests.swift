import XCTest
import SwiftPizzaSnips

final class URLWindowsFilepathTests: XCTestCase {
	func testURLWindowsFilepath() throws {
		let winFilepath = ##"C:\Users\Administrator\Documents\bitcoin key.docx"##

		let expectedURLPath = "/C/Users/Administrator/Documents/bitcoin key.docx"

		let url = URL(windowsFilepath: winFilepath)

		XCTAssertEqual(url?.path(percentEncoded: false), expectedURLPath)
	}
}
