import XCTest
import SwiftPizzaSnips
import Foundation

final class SequencePrioritySortTests: XCTestCase {
	func testSequencePriority() throws {
		let inputSequence = [
			URL(fileURLWithPath: "/Users/username/Documents/secondaryName.bar"),
			URL(fileURLWithPath: "/Users/username/Documents/anyname.bar"),
			URL(fileURLWithPath: "/Users/username/Documents/TARGETNAME.bar"), // but upper case
			URL(fileURLWithPath: "/Users/username/Documents/anotherAnyName.bar"),
			URL(fileURLWithPath: "/Users/username/Documents/targetName.bar"),
		]

		let priorityList = [
			"targetName",
			"secondaryName",
		]

		let sortedSequence = inputSequence
			.sorted(
				byPriority: { url in
					let filename = url.deletingPathExtension().lastPathComponent
					guard
						let index = priorityList.firstIndex(of: filename)
					else { return priorityList.count + Int(filename.first?.utf8.first ?? 0) }
					return index
				})

		XCTAssertEqual(sortedSequence[0].deletingPathExtension().lastPathComponent, priorityList[0])
		XCTAssertEqual(sortedSequence[1].deletingPathExtension().lastPathComponent, priorityList[1])
	}
}
