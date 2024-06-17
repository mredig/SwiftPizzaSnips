import Foundation

/**
 Helps solve the problem where `String` keys are in a global space that makes dot notation difficult when creating
 constants for dictionary keys.

 Simply create a type that conforms to `RawRepresentable` with `String` as the `RawValue`, create all your keys as
 static values on that type, then wrap your dictionary in a `StringlyKeyedDictionary`
 */
public struct StringlyKeyedDictionary<StringlyKey, Value>: ExpressibleByDictionaryLiteral, Withable
where StringlyKey: RawRepresentable, StringlyKey.RawValue == String {

	public var dictionary: [String: Value]

	public init(dictionary: [String: Value], type: StringlyKey.Type) {
		self.dictionary = dictionary
	}

	public init(dictionary: [String: Value]) {
		self.init(dictionary: dictionary, type: StringlyKey.self)
	}

	public init(dictionaryLiteral elements: (StringlyKey, Value)...) {
		let dictionary = elements.reduce(into: [String: Value]()) {
			$0[$1.0.rawValue] = $1.1
		}
		self.init(dictionary: dictionary)
	}

	public subscript(key: StringlyKey) -> Value? {
		get {
			dictionary[key.rawValue]
		}
		set {
			dictionary[key.rawValue] = newValue
		}
	}
}

extension StringlyKeyedDictionary: Codable where Value: Codable {}
extension StringlyKeyedDictionary: Equatable where Value: Equatable {}
extension StringlyKeyedDictionary: Hashable where Value: Hashable {}
extension StringlyKeyedDictionary: Sendable where Value: Sendable {}
