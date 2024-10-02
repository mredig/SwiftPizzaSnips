import Foundation


@propertyWrapper
/// Provides encoding and decoding of `null` values. The catch is that it requires that the raw json MUST have the entry as `null`, unless
/// you want to override the containing type's `init(from: Decoder)` method to allow omitted values (which kind of defeats the purpose
/// of this convenience, but now you can choose your poison)
public struct NullCodable<T> {
	public var wrappedValue: T?

	public init(wrappedValue: T? = nil) {
		self.wrappedValue = wrappedValue
	}
}

extension NullCodable: Encodable where T: Encodable {
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		if let wrappedValue {
			try container.encode(wrappedValue)
		} else {
			try container.encodeNil()
		}
	}
}

extension NullCodable: Decodable where T: Decodable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		self.wrappedValue = try? container.decode(T.self)
	}
}

extension NullCodable: Sendable where T: Sendable {}
extension NullCodable: Equatable where T: Equatable {}
extension NullCodable: Hashable where T: Hashable {}
extension NullCodable: Withable where T: Withable {}
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension NullCodable: PersistentHashable where T: PersistentHashable {
	public func hash(persistentlyInto hasher: inout PersistentHasher) {
		hasher.update(wrappedValue)
	}
}


extension NullCodable: ExpressibleByUnicodeScalarLiteral where T: ExpressibleByUnicodeScalarLiteral {
	public init(unicodeScalarLiteral value: T.UnicodeScalarLiteralType) {
		self.init(wrappedValue: T(unicodeScalarLiteral: value))
	}
}

extension NullCodable: ExpressibleByExtendedGraphemeClusterLiteral where T: ExpressibleByExtendedGraphemeClusterLiteral {
	public init(extendedGraphemeClusterLiteral value: T.ExtendedGraphemeClusterLiteralType) {
		self.init(wrappedValue: T(extendedGraphemeClusterLiteral: value))
	}
}

extension NullCodable: ExpressibleByStringLiteral where T: ExpressibleByStringLiteral {
	public init(stringLiteral value: T.StringLiteralType) {
		self.init(wrappedValue: T(stringLiteral: value))
	}
}

extension NullCodable: ExpressibleByStringInterpolation where T: ExpressibleByStringInterpolation {
	public init(stringInterpolation: T.StringInterpolation) {
		self.init(wrappedValue: T(stringInterpolation: stringInterpolation))
	}
}

extension NullCodable: ExpressibleByNilLiteral where T: ExpressibleByNilLiteral {
	public init(nilLiteral: ()) {
		self.init(wrappedValue: T(nilLiteral: nilLiteral))
	}
}

extension NullCodable: ExpressibleByFloatLiteral where T: ExpressibleByFloatLiteral {
	public init(floatLiteral value: T.FloatLiteralType) {
		self.init(wrappedValue: T(floatLiteral: value))
	}
}

extension NullCodable: ExpressibleByBooleanLiteral where T: ExpressibleByBooleanLiteral {
	public init(booleanLiteral value: T.BooleanLiteralType) {
		self.init(wrappedValue: T(booleanLiteral: value))
	}
}

extension NullCodable: ExpressibleByIntegerLiteral where T: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: T.IntegerLiteralType) {
		self.init(wrappedValue: T(integerLiteral: value))
	}
}
