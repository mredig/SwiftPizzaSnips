import Foundation
#if canImport(Crypto)
import Crypto
#elseif canImport(CryptoKit)
import CryptoKit
#endif

#if canImport(CryptoKit) || canImport(Crypto)

@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
public protocol PersistentHashable {
	func hash(persistentlyInto hasher: inout PersistentHashable.Hasher)
}

@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
public extension PersistentHashable {
	typealias Hasher = PersistentHasher
	typealias Hash = Hasher.PersistentDigest

	func persistentHashValue() -> Hash {
		var hasher = Hasher()
		hash(persistentlyInto: &hasher)
		return hasher.finalize()
	}
}

@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Date: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(timeIntervalSinceReferenceDate)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Bool: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Int: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension UInt: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Int8: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension UInt8: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Int16: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension UInt16: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Int32: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension UInt32: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Int64: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension UInt64: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Float: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
#if arch(arm64) // see Float16 docs
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7, *)
extension Float16: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
#endif
// this causes the x86 build to fail and I cannot immediately figure out why
//#if arch(x86_64)
//@available(macOS 10.15, iO2 13.2, tvOS 13.0, *)
//extension Float80: PersistentHashable {
//	/// vulnerable to endianness flipping
//	public func hash(persistentlyInto hasher: inout PersistentHasher) {
//		let buffer = UnsafeMutableBufferPointer<Self>.allocate(capacity: 1)
//		defer { buffer.deallocate() }
//		buffer[0] = self
//		let rawBuffer = UnsafeRawBufferPointer(buffer)
//		update(rawBuffer)
//	}
//}
//#endif
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Double: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Decimal: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(description)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Range: PersistentHashable where Bound: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update("Range:")
		lowerBound.hash(persistentlyInto: &hasher)
		upperBound.hash(persistentlyInto: &hasher)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension ClosedRange: PersistentHashable where Bound: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update("ClosedRange:")
		lowerBound.hash(persistentlyInto: &hasher)
		upperBound.hash(persistentlyInto: &hasher)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension String: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Substring: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(String(self))
	}
}

@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Array: PersistentHashable where Element: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		self.forEach { $0.hash(persistentlyInto: &hasher) }
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Dictionary: PersistentHashable where Key: PersistentHashable & Comparable, Value: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		sorted(by: { $0.key < $1.key} )
			.forEach {
				$0.key.hash(persistentlyInto: &hasher)
				$0.value.hash(persistentlyInto: &hasher)
			}
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Set: PersistentHashable where Element: PersistentHashable & Comparable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		sorted()
			.forEach { $0.hash(persistentlyInto: &hasher) }
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Data: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		hasher.update(self)
	}
}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Slice: PersistentHashable where Base.Element: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		forEach { $0.hash(persistentlyInto: &hasher) }
	}
}

@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Optional: PersistentHashable where Wrapped: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHashable.Hasher) {
		switch self {
		case .none:
			hasher.update(Data([0]))
		case .some(let wrapped):
			wrapped.hash(persistentlyInto: &hasher)
		}
	}
}

#endif
