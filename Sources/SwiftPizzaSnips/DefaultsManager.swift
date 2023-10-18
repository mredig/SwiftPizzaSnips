import Foundation

@available(macOS 10.15, *)
public class DefaultsManager: ObservableObject {
	private static let defaults = UserDefaults.standard

	private var bag = Bag()

	public static let shared = DefaultsManager()
	private init() {
		NotificationCenter
			.default
			.publisher(for: UserDefaults.didChangeNotification)
			.receive(on: RunLoop.main)
			.sink(receiveValue: { [weak self] _ in
				self?.objectWillChange.send()
			})
			.store(in: &bag)
	}

	public func getValue<Value>(for key: Key<Value>) -> Value? {
		if let transform = key.transform {
			guard
				let data = Self.defaults.data(forKey: key.rawValue)
			else { return nil }
			do {
				return try transform.get(data)
			} catch {
				print("Error converting stored data for key: \(error)")
				return nil
			}
		} else {
			return Self.defaults.object(forKey: key.rawValue) as? Value
		}
	}

	public func getValue<Value>(for key: KeyWithDefault<Value>) -> Value {
		if let transform = key.transform {
			guard
				let data = Self.defaults.data(forKey: key.rawValue)
			else { return key.defaultValue }
			do {
				return try transform.get(data)
			} catch {
				print("Error converting stored data for key: \(error)")
				return key.defaultValue
			}
		} else {
			return (Self.defaults.object(forKey: key.rawValue) as? Value) ?? key.defaultValue
		}
	}

	public func setValue<Value>(_ value: Value?, for key: KeyWithDefault<Value>) {
		var newKey = Key<Value>(rawValue: key.rawValue)

		if let transform = key.transform {
			newKey = newKey.withTransform(transform)
		}

		setValue(value, for: newKey)
	}

	public func setValue<Value>(_ value: Value?, for key: Key<Value>) {
		guard let value else {
			Self.defaults.removeObject(forKey: key.rawValue)
			return
		}

		if let transform = key.transform {
			do {
				let data = try transform.set(value)
				Self.defaults.set(data, forKey: key.rawValue)
			} catch {
				print("Error converting value for key \(key) to data: \(error)")
			}
		} else {
			Self.defaults.set(value, forKey: key.rawValue)
		}
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
		internal private(set) var transform: Transform<Value>?

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

		internal private(set) var transform: Transform<Value>?

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

		public func withTransform(get: @escaping (Data) throws -> Value, set: @escaping (Value) throws -> Data) -> Self {
			let transform = Transform(get: get, set: set)
			return withTransform(transform)
		}
	}

	public struct Transform<T> {
		public let get: (Data) throws -> T
		public let set: (T) throws -> Data
	}
}
