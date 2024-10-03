import Testing
import Foundation
import SwiftPizzaSnips

struct URLRelativeTestsOld {

	@Test
	@available(iOS 16.0, *)
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

		#expect(try pathComponents == URL.relativeComponents(from: urlA, to: urlB))
		#expect(try path == URL.relativePath(from: urlA, to: urlB))
		#expect(try urlResult == URL.relativeFileURL(from: urlA, to: urlB))
	}

	@Test
	@available(iOS 16.0, *)
	func testURLRelativeMismatchScheme() throws {
		let urlA = URL(string: "https://he.ho.hum/api/v1/login")!
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")

		#expect(
			performing: {
				try URL.relativeComponents(from: urlA, to: urlB)
		},
			throws: {
				guard let error = $0 as? URL.RelativePathError else { return false }
				return URL.RelativePathError.mismatchedURLScheme == error
		})
	}

	@Test
	@available(iOS 16.0, *)
	func testURLParentDirectoryPair() {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi")
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")
		let expectedParent = URL(filePath: "/Users/nobody/")

		let parent = URL.commonParentDirectoryURL(between: urlA, and: urlB)
		#expect(expectedParent == parent)
	}

	@Test
	@available(iOS 16.0, *)
	func testURLParentDirectoryFilePair() {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Planets.epub")
		let urlB = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Stars.epub")
		let expectedParent = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/")

		let parent = URL.commonParentDirectoryURL(between: urlA, and: urlB)
		#expect(expectedParent == parent)
	}

	@Test
	@available(iOS 16.0, *)
	func testURLParentWebURL() {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi")
		let urlB = URL(string: "https://foo.com")!

		let parentA = URL.commonParentDirectoryURL(between: urlA, and: urlB)
		#expect(parentA == nil)

		let parentB = URL.commonParentDirectoryURL(between: urlB, and: urlA)
		#expect(parentB == nil)
	}

	@Test
	@available(iOS 16.0, *)
	func testURLParentFileURL() {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Spaceships.epub")
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")
		let expectedParent = URL(filePath: "/Users/nobody/")

		let parent = URL.commonParentDirectoryURL(between: urlA, and: urlB)
		#expect(expectedParent == parent)
	}

	@Test
	@available(iOS 16.0, *)
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
		#expect(expectedParent == parent)
	}

	@Test
	@available(iOS 16.0, *)
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
		#expect(expectedParent == parent)
	}

	@Test
	@available(iOS 16.0, *)
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
		#expect(parent == nil)
	}

	@Test
	@available(iOS 16.0, *)
	func testParentCheck() {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Spaceships.epub")
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")
		let urlC = URL(filePath: "/Users/nobody/")
		let urlD = URL(filePath: "/Users/nobody")
		let urlE = URL(filePath: "/Users/nobody/file.txt")
		let urlF = URL(filePath: "/Users/nobody/De")

		#expect(false == urlB.isAParentOf(urlA), "urlB.isAParentOf(urlA) failed")
		#expect(true == urlC.isAParentOf(urlA), "urlC.isAParentOf(urlA) failed")
		#expect(false == urlA.isAParentOf(urlB), "urlA.isAParentOf(urlB) failed")
		#expect(false == urlA.isAParentOf(urlC), "urlA.isAParentOf(urlC) failed")
		#expect(false == urlA.isAParentOf(urlD), "urlA.isAParentOf(urlD) failed")
		#expect(true == urlD.isAParentOf(urlA), "urlD.isAParentOf(urlA) failed")
		#expect(false == urlE.isAParentOf(urlA), "urlE.isAParentOf(urlA) failed")
		#expect(false == urlF.isAParentOf(urlA), "urlF.isAParentOf(urlA) failed")
	}
}
