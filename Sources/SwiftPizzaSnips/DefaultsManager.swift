import Foundation

public class DefaultsManager {
	private static let defaults = UserDefaults.standard

	public static let shared = DefaultsManager()

	public func getValue<Value>(for key: DefaultsKey<Value>) -> Value? {
		Self.defaults.object(forKey: key.rawValue) as? Value
	}

	public func getValue<Value>(for key: DefaultsKeyWithDefault<Value>) -> Value {
		(Self.defaults.object(forKey: key.rawValue) as? Value) ?? key.defaultValue
	}

	public func setValue<Value>(_ value: Value?, for key: DefaultsKeyWithDefault<Value>) {
		Self.defaults.set(value, forKey: key.rawValue)
	}

	public func setValue<Value>(_ value: Value?, for key: DefaultsKey<Value>) {
		Self.defaults.set(value, forKey: key.rawValue)
	}

	public subscript<Value>(key: DefaultsKey<Value>) -> Value? {
		get {
			getValue(for: key)
		}
		set {
			setValue(newValue, for: key)
		}
	}

	public subscript<Value>(key: DefaultsKeyWithDefault<Value>) -> Value {
		get {
			getValue(for: key)
		}
		set {
			setValue(newValue, for: key)
		}
	}
}

public struct DefaultsKey<Value>: RawRepresentable {
	public let rawValue: String

	public init(rawValue: String) {
		self.rawValue = rawValue
	}
}

public struct DefaultsKeyWithDefault<Value>: RawRepresentable {
	public let rawValue: String

	public let defaultValue: Value

	@available(*, deprecated, message: "Always fails. Use init(rawValue:, defaultValue:)")
	public init?(rawValue: String) { nil }

	public init(rawValue: String, defaultValue: Value) {
		self.rawValue = rawValue
		self.defaultValue = defaultValue
	}
}
