import Foundation
#if canImport(CryptoKit)
import CryptoKit

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public protocol PersistentHashable {
	func hash(persistentlyInto hasher: inout Insecure.MD5)
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public extension PersistentHashable {
	func persistentHashValue() -> Insecure.MD5Digest {
		var hasher = Insecure.MD5()
		hash(persistentlyInto: &hasher)
		return hasher.finalize()
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Date: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: timeIntervalSinceReferenceDate)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Bool: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(bool: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Int: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension UInt: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Int8: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension UInt8: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Int16: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension UInt16: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Int32: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension UInt32: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Int64: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension UInt64: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Float: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
#if arch(arm64) // see Float16 docs
@available(macOS 11.0, iOS 14.0, tvOS 14.0, *)
extension Float16: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
#endif
#if arch(x86_64)
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Float80: PersistentHashable {
	/// vulnerable to endianness flipping
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		let buffer = UnsafeMutableBufferPointer<Self>.allocate(capacity: 1)
		defer { buffer.deallocate() }
		buffer[0] = self
		let rawBuffer = UnsafeRawBufferPointer(buffer)
		update(bufferPointer: rawBuffer)
	}
}
#endif
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Double: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(number: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Decimal: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(string: description)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Range: PersistentHashable where Bound: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(string: "Range:")
		lowerBound.hash(persistentlyInto: &hasher)
		upperBound.hash(persistentlyInto: &hasher)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension ClosedRange: PersistentHashable where Bound: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(string: "ClosedRange:")
		lowerBound.hash(persistentlyInto: &hasher)
		upperBound.hash(persistentlyInto: &hasher)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension String: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(string: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Substring: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(string: String(self))
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Array: PersistentHashable where Element: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		self.forEach { $0.hash(persistentlyInto: &hasher) }
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Dictionary: PersistentHashable where Key: PersistentHashable & Comparable, Value: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		sorted(by: { $0.key < $1.key} )
			.forEach {
				$0.key.hash(persistentlyInto: &hasher)
				$0.value.hash(persistentlyInto: &hasher)
			}
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Set: PersistentHashable where Element: PersistentHashable & Comparable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		sorted()
			.forEach { $0.hash(persistentlyInto: &hasher) }
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Data: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		hasher.update(data: self)
	}
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Slice: PersistentHashable where Base.Element: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		forEach { $0.hash(persistentlyInto: &hasher) }
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension Optional: PersistentHashable where Wrapped: PersistentHashable {
	public func hash(persistentlyInto hasher: inout Insecure.MD5) {
		switch self {
		case .none:
			hasher.update(data: Data([0]))
		case .some(let wrapped):
			wrapped.hash(persistentlyInto: &hasher)
		}
	}
}

#endif
