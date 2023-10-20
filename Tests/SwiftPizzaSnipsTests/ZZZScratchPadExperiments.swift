import Foundation
import XCTest
@testable import SwiftPizzaSnips

final class ZZZScratchPadExperiments: XCTestCase {
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
