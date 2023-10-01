import Foundation

/**
 Helps solve the problem where `String` keys are in a global space that makes dot notation difficult when creating
 constants for dictionary keys.

 Simply create a type that conforms to `RawRepresentable` with `String` as the `RawValue`, create all your keys as
 static values on that type, then wrap your dictionary in a `StringlyKeyedDictionary`
 */
public struct StringlyKeyedDictionary<StringlyKey, Value>
where StringlyKey: RawRepresentable, StringlyKey.RawValue == String {

	public var dictionary: [String: Value]

	init(dictionary: [String : Value], type: StringlyKey.Type) {
		self.dictionary = dictionary
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
