import XCTest
import SwiftPizzaSnips
#if canImport(FoundationNetworking)
import SPSLinuxSupport
#endif

/// These tests all pass on macOS and should replicate functionality on Linux
final class URLLinuxSupportTests: XCTestCase {

	func testFilePathInit() throws {
		let binPath = "/bin"

		var binURL = URL(filePath: binPath, directoryHint: .inferFromPath)
		XCTAssertEqual("/bin", binURL.path())
		XCTAssertFalse(binURL.hasDirectoryPath)

		binURL = URL(filePath: binPath, directoryHint: .checkFileSystem)
		XCTAssertEqual("/bin/", binURL.path())
		XCTAssertTrue(binURL.hasDirectoryPath)

		binURL = URL(filePath: binPath, directoryHint: .isDirectory)
		XCTAssertEqual("/bin/", binURL.path())
		XCTAssertTrue(binURL.hasDirectoryPath)

		binURL = URL(filePath: binPath, directoryHint: .notDirectory)
		XCTAssertEqual("/bin", binURL.path())
		XCTAssertFalse(binURL.hasDirectoryPath)
	}

	func testPathMethod() throws {
		var samplePath = "/Users/nobody/Documents/My Stuff/"

		let samplePathEncoded = samplePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)

		let sampleURL = URL(filePath: samplePath)
		XCTAssertEqual(sampleURL.path(), samplePathEncoded)
		XCTAssertEqual(sampleURL.path(percentEncoded: true), samplePathEncoded)
		XCTAssertEqual(sampleURL.path(percentEncoded: false), samplePath)
		samplePath.removeLast()
		XCTAssertEqual(sampleURL.path, samplePath)
	}

	func testAppending() throws {
		let baseURL = URL(filePath: "/Users/nobody")
		var url = baseURL

		let oneDirExpected = "/Users/nobody/Desktop"
		let moreDirExpected = "/Users/nobody/Desktop/Junk/Other Stuff/Not In Here"
		let moreDirExpectedEncoded = "/Users/nobody/Desktop/Junk/Other Stuff/Not In Here/"
			.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
		let fileExpected = "/Users/nobody/Desktop/Junk/Other Stuff/Not In Here/secrets.txt"
		let fileExpectedEncoded = "/Users/nobody/Desktop/Junk/Other Stuff/Not In Here/secrets.txt"
			.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)

		let queryItems = "/Users/nobody?foo=1&bar=2"

		url.append(component: "Desktop")
		XCTAssertEqual(url.path, oneDirExpected)
		XCTAssertEqual(url.path(), oneDirExpected)

		url = baseURL
		url.append(components: "Desktop", "Junk", "Other Stuff", "Not In Here/")
		XCTAssertEqual(url.path, moreDirExpected)
		XCTAssertEqual(url.path(percentEncoded: false), moreDirExpected + "/")
		XCTAssertEqual(url.path(percentEncoded: true), moreDirExpectedEncoded)

		url = baseURL
		url.append(components: "Desktop", "Junk", "Other Stuff", "Not In Here", "secrets.txt")
		XCTAssertEqual(url.path, fileExpected)
		XCTAssertEqual(url.path(percentEncoded: false), fileExpected)
		XCTAssertEqual(url.path(percentEncoded: true), fileExpectedEncoded)

		url = baseURL
		url.append(queryItems: [
			URLQueryItem(name: "foo", value: "1"),
			URLQueryItem(name: "bar", value: "2"),
		])
		XCTAssertEqual(url.absoluteString, "file://" + queryItems)
		XCTAssertEqual(url.path, baseURL.path)
		XCTAssertEqual(url.path(), baseURL.path)
	}
}
