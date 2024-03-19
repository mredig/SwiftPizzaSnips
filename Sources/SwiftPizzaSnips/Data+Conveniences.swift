import Foundation

extension Data {
	public func toHexString() -> String {
		map { byte in
			String(format: "%02hhx", byte)
		}
		.joined()
	}

	public init(hexString: String) throws {
		let startingIndex: String.Index
		let charCount: Int
		if
			let firstTwoChar = hexString.index(hexString.startIndex, offsetBy: 2, limitedBy: hexString.endIndex),
			case let start = hexString[hexString.startIndex..<firstTwoChar].lowercased(),
			start == "0x" {

			startingIndex = firstTwoChar
			charCount = hexString.count - 2 //(remove 0x)
		} else {
			startingIndex = hexString.startIndex
			charCount = hexString.count
		}

		let hexSub = hexString[startingIndex..<hexString.endIndex]
		guard hexSub.isOccupied else {
			self.init()
			return
		}

		let byteCount: Int
		let hasImpliedLeading0: Bool
		if charCount.isMultiple(of: 2) {
			byteCount = charCount / 2
			hasImpliedLeading0 = false
		} else {
			byteCount = (charCount / 2) + 1
			hasImpliedLeading0 = true
		}

		self.init(count: byteCount)

		func strToByte(_ str: any StringProtocol) throws -> UInt8 {
			guard
				let byte = UInt8(str, radix: 16)
			else { throw DataHexError.invalidCharacterInHexString }
			return byte
		}

		var currentCount = 0
		var currentStringIndex = hexSub.startIndex
		if hasImpliedLeading0 {
			let firstCharacter = hexSub[currentStringIndex]
			let byte = try strToByte("\(firstCharacter)")
			self[currentCount] = byte
			currentCount += 1
			currentStringIndex = hexSub.index(after: currentStringIndex)
		}

		while currentStringIndex < hexSub.endIndex {
			let rangeEnd = hexSub.index(currentStringIndex, offsetBy: 2)
			defer {
				currentStringIndex = rangeEnd
				currentCount += 1
			}

			let byte = try strToByte(hexSub[currentStringIndex..<rangeEnd])
			self[currentCount] = byte
		}

		guard
			currentCount == byteCount
		else { throw DataHexError.invalidStringInput }
	}

	public enum DataHexError: Error {
		case mustStartWith0x
		case tooShort
		case invalidCharacterInHexString
		case invalidStringInput
	}
}

public extension Data {
	func write(to output: URL, options: WritingOptions = [], creatingIntermediateDirectories: Bool) throws {
		try FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
		try write(to: output, options: options)
	}
}
