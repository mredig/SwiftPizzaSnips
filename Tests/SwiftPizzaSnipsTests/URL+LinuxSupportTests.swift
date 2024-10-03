import Foundation
import Testing
import SwiftPizzaSnips
#if canImport(FoundationNetworking)
import SPSLinuxSupport
#endif

/// These tests all pass on macOS and should replicate functionality on Linux
struct URLLinuxSupportTests {

	@available(iOS 16, tvOS 16, watchOS 10, *)
	@Test func testFilePathInit() throws {
		let binPath = "/bin"

		var binURL = URL(filePath: binPath, directoryHint: .inferFromPath)
		#expect("/bin" == binURL.path())
		#expect(binURL.hasDirectoryPath == false)

		binURL = URL(filePath: binPath, directoryHint: .checkFileSystem)
		#expect("/bin/" == binURL.path())
		#expect(binURL.hasDirectoryPath)

		binURL = URL(filePath: binPath, directoryHint: .isDirectory)
		#expect("/bin/" == binURL.path())
		#expect(binURL.hasDirectoryPath)

		binURL = URL(filePath: binPath, directoryHint: .notDirectory)
		#expect("/bin" == binURL.path())
		#expect(binURL.hasDirectoryPath == false)
	}

	@available(iOS 16, tvOS 16, watchOS 10, *)
	@Test func testPathMethod() throws {
		var samplePath = "/Users/nobody/Documents/My Stuff/"

		let samplePathEncoded = samplePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)

		let sampleURL = URL(filePath: samplePath)
		#expect(sampleURL.path() == samplePathEncoded)
		#expect(sampleURL.path(percentEncoded: true) == samplePathEncoded)
		#expect(sampleURL.path(percentEncoded: false) == samplePath)
		samplePath.removeLast()
		#expect(sampleURL.path == samplePath)
	}

	@available(iOS 16, tvOS 16, watchOS 10, *)
	@Test func testAppending() throws {
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
		#expect(url.path == oneDirExpected)
		#expect(url.path() == oneDirExpected)

		url = baseURL
		url.append(components: "Desktop", "Junk", "Other Stuff", "Not In Here/")
		#expect(url.path == moreDirExpected)
		#expect(url.path(percentEncoded: false) == moreDirExpected + "/")
		#expect(url.path(percentEncoded: true) == moreDirExpectedEncoded)

		url = baseURL
		url.append(components: "Desktop", "Junk", "Other Stuff", "Not In Here", "secrets.txt")
		#expect(url.path == fileExpected)
		#expect(url.path(percentEncoded: false) == fileExpected)
		#expect(url.path(percentEncoded: true) == fileExpectedEncoded)

		url = baseURL
		url.append(queryItems: [
			URLQueryItem(name: "foo", value: "1"),
			URLQueryItem(name: "bar", value: "2"),
		])
		#expect(url.absoluteString == "file://" + queryItems)
		#expect(url.path == baseURL.path)
		#expect(url.path() == baseURL.path)
	}
}
