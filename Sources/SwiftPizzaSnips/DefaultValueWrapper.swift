
@propertyWrapper
public struct DefaultValueWrapper<T> {
	public var wrappedValue: T?
	public var defaultValue: T

	public var projectedValue: T {
		wrappedValue ?? defaultValue
	}

	public init(wrappedValue: T? = nil, defaultValue: T) {
		self.wrappedValue = wrappedValue
		self.defaultValue = defaultValue
	}
}

extension DefaultValueWrapper: Encodable where T: Encodable {
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		if let wrappedValue {
			try container.encode(wrappedValue)
		} else {
			try container.encodeNil()
		}
	}
}

extension DefaultValueWrapper: Sendable where T: Sendable {}
extension DefaultValueWrapper: Equatable where T: Equatable {}
extension DefaultValueWrapper: Hashable where T: Hashable {}
extension DefaultValueWrapper: Withable where T: Withable {}
