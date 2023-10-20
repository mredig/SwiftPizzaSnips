import XCTest
@testable import SwiftPizzaSnips

final class URLRelativeTests: XCTestCase {

	@available(iOS 13.0, *)
	func testURLRelativeFilePaths() throws {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Junk/Don't look in here/Secret stuff/")
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")

		let pathComponents = [
			"..",
			"..",
			"..",
			"..",
			"Documents",
			"Work Docs",
		]
		let path = pathComponents.joined(separator: "/")

		let urlResult = URL(filePath: path, relativeTo: urlA)

		try XCTAssertEqual(pathComponents, URL.relativeComponents(from: urlA, to: urlB))
		try XCTAssertEqual(path, URL.relativePath(from: urlA, to: urlB))
		try XCTAssertEqual(urlResult, URL.relativeFileURL(from: urlA, to: urlB))
	}

	func testURLRelativeMismatchScheme() throws {
		let urlA = URL(string: "https://he.ho.hum/api/v1/login")!
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")

		XCTAssertThrowsError(try URL.relativeComponents(from: urlA, to: urlB)) { error in
			XCTAssertEqual(URL.RelativePathError.mismatchedURLScheme, error as? URL.RelativePathError)
		}
	}
}
