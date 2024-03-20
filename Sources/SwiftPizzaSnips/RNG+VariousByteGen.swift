import Foundation

public extension Data {
	static func random(count: Int, using rng: inout RandomNumberGenerator) -> Data {
		guard
			let bytes = UnsafeMutableRawBufferPointer.randomBytes(count: count, using: &rng).baseAddress
		else { fatalError("Error allocating memory") }
		return Data(bytesNoCopy: bytes, count: count, deallocator: .custom({ pointer, _ in
			pointer.deallocate()
		}))
	}
}

public extension UnsafeMutableRawBufferPointer {
	/// Remember YOU are responsible for deallocating this buffer!
	static func randomBytes(count: Int, using rng: inout RandomNumberGenerator) -> UnsafeMutableRawBufferPointer {
		let pointer = UnsafeMutableRawBufferPointer.allocate(byteCount: count, alignment: 16)
		pointer.fillRandomBytes(from: 0, to: count, using: &rng)

		return pointer
	}

	func fillRandomBytes(from startOffset: Int = 0, to endOffset: Int? = nil, using rng: inout RandomNumberGenerator) {
		guard let baseAddress else { return }
		let endOffset = endOffset ?? count
		baseAddress.fillRandomBytes(from: startOffset, count: endOffset - startOffset, using: &rng)
	}
}

public extension UnsafeMutableRawPointer {
	func fillRandomBytes(from startOffset: Int, count: Int, using rng: inout RandomNumberGenerator) {
		_fillRandomBytes(from: startOffset, count: count, using: &rng)
	}

	@inline(__always)
	private func _fillRandomBytes(from startOffset: Int, count: Int, using rng: inout RandomNumberGenerator) {
		guard count > 0 else { return }
		let singleByteStartOffset: Int

		if count > 16 {
			let longUIntCount = (count / 8) - 1
			singleByteStartOffset = (longUIntCount * 8) - 4

			for offsetAmount in stride(from: startOffset, to: singleByteStartOffset, by: 4) {
				let offset = self.advanced(by: offsetAmount)
				offset.storeBytes(of: UInt64.random(in: 0...(.max), using: &rng), as: UInt64.self)
			}
		} else {
			singleByteStartOffset = startOffset
		}

		for offsetAmount in singleByteStartOffset..<(startOffset + count) {
			let offset = self.advanced(by: offsetAmount)
			offset.storeBytes(of: UInt8.random(in: 0...(.max), using: &rng), as: UInt8.self)
		}
	}
}

public class RandomInputStream: InputStream {
	public override var hasBytesAvailable: Bool { true }

	public private(set) var rng: RandomNumberGenerator

	public init(using rng: inout RandomNumberGenerator) {
		self.rng = rng
		super.init(data: Data())
	}

	public override func open() {}

	public override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
		let point = UnsafeMutableRawPointer(buffer)
		point.fillRandomBytes(from: 0, count: len, using: &rng)
		return len
	}

	public override func getBuffer(
		_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
		length len: UnsafeMutablePointer<Int>
	) -> Bool { false }
}
