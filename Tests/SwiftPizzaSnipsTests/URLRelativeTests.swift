import Testing
import Foundation
import SwiftPizzaSnips

struct URLRelativeTests {
	@available(iOS 16.0, *)
	@Test func testURLParentDirectoryPair() throws {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi")
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")
		let expectedParent = URL(filePath: "/Users/nobody/")

		let parent = try URL.deepestCommonDirectory(between: urlA, and: urlB)
		#expect(expectedParent == parent)
	}

	@Test
	@available(iOS 16.0, *)
	func testURLParentDirectoryFilePair() throws {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Planets.epub")
		let urlB = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Stars.epub")
		let expectedParent = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/")

		let parent = try URL.deepestCommonDirectory(between: urlA, and: urlB)
		#expect(expectedParent == parent)
	}

	@Test
	@available(iOS 16.0, *)
	func testURLParentWebURL() throws {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi")
		let urlB = URL(string: "https://foo.com")!

		#expect(
			performing: {
				try URL.deepestCommonDirectory(between: urlA, and: urlB)
			},
			throws: {
				guard let error = $0 as? URL.RelativePathError else { return false }
				return error == .mismatchedURLScheme
			}
		)
		#expect(
			performing: {
				try URL.deepestCommonDirectory(between: urlB, and: urlA)
			},
			throws: {
				guard let error = $0 as? URL.RelativePathError else { return false }
				return error == .mismatchedURLScheme
			}
		)
	}

	@Test
	@available(iOS 16.0, *)
	func testURLParentFileURL() throws {
		let urlA = URL(filePath: "/Users/nobody/Desktop/Stuff/Downloads/Books/SciFi/Spaceships.epub")
		let urlB = URL(filePath: "/Users/nobody/Documents/Work Docs/")
		let expectedParent = URL(filePath: "/Users/nobody/")

		let parent = try URL.deepestCommonDirectory(between: urlA, and: urlB)
		#expect(expectedParent == parent)
	}

	@Test
	@available(iOS 16.0, *)
	func testURLParentWithSimpleArray() throws {
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

		let parent = try URL.deepestCommonDirectory(from: urls)
		#expect(expectedParent == parent)
	}

	@Test
	@available(iOS 16.0, *)
	func testURLParentWithMoreComplicatedArray() throws {
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

		let parent = try URL.deepestCommonDirectory(from: urls)
		#expect(expectedParent == parent)
	}

	@Test
	@available(iOS 16.0, *)
	func testURLParentWithInvalidArray() throws {
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

		#expect(
			performing: {
				try URL.deepestCommonDirectory(from: urls)
			},
			throws: {
				guard let error = $0 as? URL.RelativePathError else { return false }
				return error == .mismatchedURLScheme
			}
		)
	}
}
