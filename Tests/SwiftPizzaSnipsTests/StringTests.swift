import XCTest
@testable import SwiftPizzaSnips
import AppKit

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


	func characterSetBitmapExperimentation() throws {
		let a: CharacterSet = .urlHostAllowed

		var accumulator = ""
		var str = ""
		let bitmap = a.bitmapRepresentation
		let mask: UInt8 = 1
		for (byteIndex, byte) in bitmap.enumerated() {
			guard byteIndex < 8192 else { break }
			let bitOffset = byteIndex * 8
			for offset in 0..<8 {
				let base = (byte >> offset) & mask
				if base > 0 {
					let totalBitOffset = bitOffset + offset
					guard
						let scalar = UnicodeScalar(totalBitOffset)
					else { fatalError("Invalid value") }
					let character = Character(scalar)
					accumulator.append(character)
					if accumulator.count.isMultiple(of: 40) {
						str.append(accumulator)
						str.append("\n")
						accumulator = ""
					}
//					print(character)
				}
			}
		}
		str.append(accumulator)
		print(str)

		_ = Unicode.Scalar(0x10000)

		var bSet = CharacterSet(charactersIn: str)
		bSet.remove(charactersIn: "\n")
		let bData = bSet.bitmapRepresentation

		print(bData[..<8192] == bitmap[..<8192])
	}

}
