import XCTest
import SwiftPizzaSnips

@available(iOS 16.0, *)
final class URLRelativeTests: XCTestCase {

	func testURLRelativeFilePaths() throws {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi")
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

	func testURLParentDirectoryPair() {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi")
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")
		let expectedParent = URL(filePath: "/Users/nobody/")

		let parent = URL.commonParentDirectoryURL(between: urlA, and: urlB)
		XCTAssertEqual(expectedParent, parent)
	}

	func testURLParentDirectoryFilePair() {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Planets.epub")
		let urlB = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Stars.epub")
		let expectedParent = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/")

		let parent = URL.commonParentDirectoryURL(between: urlA, and: urlB)
		XCTAssertEqual(expectedParent, parent)
	}

	func testURLParentWebURL() {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi")
		let urlB = URL(string: "https://foo.com")!

		let parentA = URL.commonParentDirectoryURL(between: urlA, and: urlB)
		XCTAssertNil(parentA)

		let parentB = URL.commonParentDirectoryURL(between: urlB, and: urlA)
		XCTAssertNil(parentB)
	}

	func testURLParentFileURL() {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Spaceships.epub")
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")
		let expectedParent = URL(filePath: "/Users/nobody/")

		let parent = URL.commonParentDirectoryURL(between: urlA, and: urlB)
		XCTAssertEqual(expectedParent, parent)
	}

	func testURLParentWithSimpleArray() {
		let urls = [
			URL(filePath: "/Users/nobody/Documents", directoryHint: .isDirectory),
			URL(filePath: "/Users/nobody/Downloads", directoryHint: .isDirectory),
			URL(filePath: "/Users/nobody/Pictures", directoryHint: .isDirectory),
			URL(filePath: "/Users/nobody/Music", directoryHint: .isDirectory),
			URL(filePath: "/Users/nobody/WorkProjects", directoryHint: .isDirectory),
			URL(filePath: "/Users/nobody/Personal", directoryHint: .isDirectory),
			URL(filePath: "/Users/nobody/TravelPhotos", directoryHint: .isDirectory),
			URL(filePath: "/Users/nobody/Programming", directoryHint: .isDirectory),
		]

		let expectedParent = URL(filePath: "/Users/nobody/")

		let parent = URL.commonParentDirectoryURL(from: urls)
		XCTAssertEqual(expectedParent, parent)
	}

	func testURLParentWithMoreComplicatedArray() {
		let urls = [
			URL(filePath: "/Users/nobody/Desktop/Stuff/WorkProjects/2022/Q1/Design"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/TravelPhotos/Europe/Italy/Rome"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Music/Playlists/Workout"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Documents/School/Physics/Homework"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Programming/Swift/PersonalProjects/App1"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Pictures/Family/2021/Christmas"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Personal/Finance/2022/Taxes"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/WorkProjects/2022/Q1/Design/Logo.ai"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/TravelPhotos/Europe/Italy/Rome/Colosseum.jpg"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Music/Playlists/Workout/Track1.mp3"),
			URL(filePath: "/Users/nobody/Desktop/Documents/School/Physics/Homework/Assignment1.docx"),
		]

		let expectedParent = URL(filePath: "/Users/nobody/Desktop/")

		let parent = URL.commonParentDirectoryURL(from: urls)
		XCTAssertEqual(expectedParent, parent)
	}

	func testURLParentWithInvalidArray() {
		let urls = [
			URL(filePath: "/Users/nobody/Desktop/Stuff/WorkProjects/2022/Q1/Design"),
			URL(string: "https://foo.com")!,
			URL(filePath: "/Users/nobody/Desktop/Stuff/TravelPhotos/Europe/Italy/Rome"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Music/Playlists/Workout"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Documents/School/Physics/Homework"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Programming/Swift/PersonalProjects/App1"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Pictures/Family/2021/Christmas"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Personal/Finance/2022/Taxes"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/WorkProjects/2022/Q1/Design/Logo.ai"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/TravelPhotos/Europe/Italy/Rome/Colosseum.jpg"),
			URL(filePath: "/Users/nobody/Desktop/Stuff/Music/Playlists/Workout/Track1.mp3"),
			URL(filePath: "/Users/nobody/Desktop/Documents/School/Physics/Homework/Assignment1.docx"),
		]

		let parent = URL.commonParentDirectoryURL(from: urls)
		XCTAssertNil(parent)
	}

	func testParentCheck() {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Spaceships.epub")
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")
		let urlC = URL(filePath: "/Users/nobody/")
		let urlD = URL(filePath: "/Users/nobody")
		let urlE = URL(filePath: "/Users/nobody/file.txt")
		let urlF = URL(filePath: "/Users/nobody/De")

		XCTAssertFalse(urlB.isAParentOf(urlA), "urlB.isAParentOf(urlA) failed")
		XCTAssertTrue(urlC.isAParentOf(urlA), "urlC.isAParentOf(urlA) failed")
		XCTAssertFalse(urlA.isAParentOf(urlB), "urlA.isAParentOf(urlB) failed")
		XCTAssertFalse(urlA.isAParentOf(urlC), "urlA.isAParentOf(urlC) failed")
		XCTAssertFalse(urlA.isAParentOf(urlD), "urlA.isAParentOf(urlD) failed")
		XCTAssertTrue(urlD.isAParentOf(urlA), "urlD.isAParentOf(urlA) failed")
		XCTAssertFalse(urlE.isAParentOf(urlA), "urlE.isAParentOf(urlA) failed")
		XCTAssertFalse(urlF.isAParentOf(urlA), "urlF.isAParentOf(urlA) failed")
	}
}
