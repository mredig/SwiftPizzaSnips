import Foundation
#if canImport(CryptoKit)
import CryptoKit

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public struct PersistentHasher: HashFunction {
	public static var blockByteCount: Int {
		get { Insecure.MD5.blockByteCount }
		set { Insecure.MD5.blockByteCount = newValue }
	}

	private var internalHasher = Insecure.MD5()

	public init() {}

	public mutating func update(bufferPointer: UnsafeRawBufferPointer) {
		internalHasher.update(bufferPointer: bufferPointer)
	}

	public mutating func update<D: DataProtocol>(data: D) {
		internalHasher.update(data: data)
	}

	public mutating func update<D: DataProtocol>(_ data: D) {
		update(data: data)
	}

	public mutating func update<Num: FixedWidthFloatingPoint>(_ number: Num) {
		update(number: number)
	}

	public mutating func update<Num: FixedWidthInteger>(_ number: Num) {
		update(number: number)
	}

	public mutating func update(_ number: String) {
		update(string: number)
	}

	public mutating func update(_ bool: Bool) {
		update(bool: bool)
	}

	public mutating func update(_ bufferPointer: UnsafeRawBufferPointer) {
		update(bufferPointer: bufferPointer)
	}

	public func finalize() -> PersistentDigest {
		PersistentDigest(internalDigest: internalHasher.finalize())
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension PersistentHasher {
	public struct PersistentDigest: CryptoKit.Digest {
		private let internalDigest: Insecure.MD5Digest

		public static var byteCount: Int { Insecure.MD5Digest.byteCount }

		public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
			try internalDigest.withUnsafeBytes(body)
		}

		internal init(internalDigest: Insecure.MD5Digest) {
			self.internalDigest = internalDigest
		}
	}
}
#endif
