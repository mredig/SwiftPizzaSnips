import Foundation
#if canImport(CryptoKit)
import CryptoKit

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
public extension HashFunction {
	mutating func update<Num: FixedWidthInteger>(number: Num) {
		let buffer = UnsafeMutableBufferPointer<Num>.allocate(capacity: 1)
		defer { buffer.deallocate() }
		buffer[0] = number.littleEndian
		let rawBuffer = UnsafeRawBufferPointer(buffer)
		update(bufferPointer: rawBuffer)
	}

	mutating func update<Num: FixedWidthFloatingPoint>(number: Num) {
		update(number: number.bitPattern)
	}

	mutating func update(string: String) {
		update(data: Data(string.utf8))
	}

	mutating func update(bool: Bool) {
		let val: UInt8 = bool ? 1 : 0
		update(data: [val])
	}
}

#endif
