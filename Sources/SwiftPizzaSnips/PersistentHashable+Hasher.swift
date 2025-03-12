import Foundation
#if canImport(CryptoKit)
import CryptoKit
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
// This is a stupid workaround because `Digest` alone won't build and therefore needs its module defined... But since the module names differ we need to do this workaround.
fileprivate typealias CryptoDigest = CryptoKit.Digest
#elseif canImport(Crypto)
import Crypto
// This is a stupid workaround because `Digest` alone won't build and therefore needs its module defined... But since the module names differ we need to do this workaround.
fileprivate typealias CryptoDigest = Crypto.Digest
#endif

#if canImport(CryptoKit) || canImport(Crypto)

@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
public struct PersistentHasher: HashFunction, Withable {
	public static var blockByteCount: Int {
		Insecure.MD5.blockByteCount
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

	public mutating func update<T: PersistentHashable>(_ optional: T?) {
		guard let optional else { return }
		optional.hash(persistentlyInto: &self)
	}

	public mutating func update(_ bufferPointer: UnsafeRawBufferPointer) {
		update(bufferPointer: bufferPointer)
	}

	public func finalize() -> PersistentDigest {
		PersistentDigest(internalDigest: internalHasher.finalize())
	}
}

@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension PersistentHasher {
	public struct PersistentDigest: CryptoDigest {
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
