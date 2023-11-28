import XCTest
import SwiftPizzaSnips

final class StringRandomGenerationTests: XCTestCase {
	func testLoremGeneration() {
		let genA = String.randomLoremIpsum(wordCount: 30)
		let genB = String.randomLoremIpsum(wordCount: 30)

		XCTAssertNotEqual(genA, genB)
		let genASplit = genA.split(separator: " ")
		let genBSplit = genB.split(separator: " ")
		XCTAssertEqual(genASplit.count, 30)
		XCTAssertEqual(genBSplit.count, 30)
	}

	func testRandomCharacterGeneration() {
		let hexSet = CharacterSet(charactersIn: "0123456789abcdef")
		let genA = String.random(characterCount: 30, from: hexSet)
		let genB = String.random(characterCount: 30, from: hexSet)

		XCTAssertNotEqual(genA, genB)
		let genAClean = genA.components(separatedBy: hexSet).joined()
		let genBClean = genB.components(separatedBy: hexSet).joined()
		XCTAssertEqual(genAClean, "")
		XCTAssertEqual(genBClean, "")
	}
}
