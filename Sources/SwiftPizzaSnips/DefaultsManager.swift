import Foundation

public class DefaultsManager {
	private static let defaults = UserDefaults.standard

	public static let shared = DefaultsManager()

	public func getValue<Value>(for key: Key<Value>) -> Value? {
		Self.defaults.object(forKey: key.rawValue) as? Value
	}

	public func getValue<Value>(for key: KeyWithDefault<Value>) -> Value {
		(Self.defaults.object(forKey: key.rawValue) as? Value) ?? key.defaultValue
	}

	public func setValue<Value>(_ value: Value?, for key: KeyWithDefault<Value>) {
		Self.defaults.set(value, forKey: key.rawValue)
	}

	public func setValue<Value>(_ value: Value?, for key: Key<Value>) {
		Self.defaults.set(value, forKey: key.rawValue)
	}

	public subscript<Value>(key: Key<Value>) -> Value? {
		get {
			getValue(for: key)
		}
		set {
			setValue(newValue, for: key)
		}
	}

	public subscript<Value>(key: KeyWithDefault<Value>) -> Value {
		get {
			getValue(for: key)
		}
		set {
			setValue(newValue, for: key)
		}
	}

	public struct Key<Value>: RawRepresentable {
		public let rawValue: String
		private var transform: Transform<Value>?

		public init(rawValue: String) {
			self.rawValue = rawValue
		}

		public func withTransform(_ transform: Transform<Value>) -> Self {
			var new = self
			new.transform = transform
			return new
		}

		public func withTransform(get: @escaping (Data) throws -> Value, set: @escaping (Value) -> Data) -> Self {
			let transform = Transform(get: get, set: set)
			return withTransform(transform)
		}
	}

	public struct KeyWithDefault<Value>: RawRepresentable {
		public let rawValue: String

		public let defaultValue: Value

		private var transform: Transform<Value>?

		@available(*, deprecated, message: "Always fails. Use init(rawValue:, defaultValue:)")
		public init?(rawValue: String) { nil }

		public init(rawValue: String, defaultValue: Value) {
			self.rawValue = rawValue
			self.defaultValue = defaultValue
			self.transform = nil
		}

		public func withTransform(_ transform: Transform<Value>) -> Self {
			var new = self
			new.transform = transform
			return new
		}

		public func withTransform(get: @escaping (Data) throws -> Value, set: @escaping (Value) -> Data) -> Self {
			let transform = Transform(get: get, set: set)
			return withTransform(transform)
		}
	}

	public struct Transform<T> {
		public let get: (Data) throws -> T
		public let set: (T) throws -> Data
	}
}
