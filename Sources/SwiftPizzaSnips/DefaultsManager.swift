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

	public static let defaultDecoder = PropertyListDecoder()
	public static let defaultEncoder = PropertyListEncoder()

	public func getValue<Value, StoredValue: PropertyListCodable>(for key: Key<Value, StoredValue>) -> Value? {
		if let getTransform = key.transform?.get {
			guard
				let storedValue = Self.defaults.object(forKey: key.rawValue) as? StoredValue
			else { return nil }
			do {
				return try getTransform(storedValue)
			} catch {
				print("Error converting stored data for key: \(error)")
				return nil
			}
		} else {
			return Self.defaults.object(forKey: key.rawValue) as? Value
		}
	}

	public func getValue<Value, StoredValue: PropertyListCodable>(for key: KeyWithDefault<Value, StoredValue>) -> Value {
		if let getTransform = key.transform?.get {
			guard
				let storedValue = Self.defaults.object(forKey: key.rawValue) as? StoredValue
			else { return key.defaultValue }
			do {
				return try getTransform(storedValue)
			} catch {
				print("Error converting stored data for key: \(error)")
				return key.defaultValue
			}
		} else {
			let defaultsValue = Self.defaults.object(forKey: key.rawValue) as? Value
			return defaultsValue ?? key.defaultValue
		}
	}

	public func setValue<Value, StoredValue: PropertyListCodable>(_ value: Value?, for key: KeyWithDefault<Value, StoredValue>) {
		var newKey = Key<Value, StoredValue>(rawValue: key.rawValue)

		if let transform = key.transform {
			newKey = newKey.withTransform(transform)
		}

		setValue(value, for: newKey)
	}

	public func setValue<Value, StoredValue: PropertyListCodable>(_ value: Value?, for key: Key<Value, StoredValue>) {
		guard let value else {
			Self.defaults.removeObject(forKey: key.rawValue)
			return
		}

		if let setTransform = key.transform?.set {
			do {
				let data = try setTransform(value)
				Self.defaults.set(data, forKey: key.rawValue)
			} catch {
				print("Error converting value for key \(key) to data: \(error)")
			}
		} else {
			Self.defaults.set(value, forKey: key.rawValue)
		}
	}

	public func removeValue<Value, StoredValue: PropertyListCodable>(for key: Key<Value, StoredValue>) {
		setValue(nil, for: key)
	}

	public func removeValue<Value, StoredValue: PropertyListCodable>(for key: KeyWithDefault<Value, StoredValue>) {
		let newKey = Key<Value, StoredValue>(rawValue: key.rawValue)
		removeValue(for: newKey)
	}

	public subscript<Value, StoredValue: PropertyListCodable>(key: Key<Value, StoredValue>) -> Value? {
		get {
			getValue(for: key)
		}
		set {
			setValue(newValue, for: key)
		}
	}

	public subscript<Value, StoredValue: PropertyListCodable>(key: KeyWithDefault<Value, StoredValue>) -> Value {
		get {
			getValue(for: key)
		}
		set {
			setValue(newValue, for: key)
		}
	}

	public struct Key<Value, StoredValue: PropertyListCodable>: RawRepresentable {
		public let rawValue: String
		internal private(set) var transform: Transform<Value, StoredValue>?

		public init(rawValue: String) {
			self.rawValue = rawValue
		}

		public init(rawValue: String, storedValueType: StoredValue.Type) {
			self.rawValue = rawValue
		}

		public func withTransform(_ transform: Transform<Value, StoredValue>) -> Self {
			var new = self
			new.transform = transform
			return new
		}

		public func withTransform(get: Transform<Value, StoredValue>.GetTransform? = nil, set: Transform<Value, StoredValue>.SetTransform? = nil) -> Self {
			let transform = Transform(get: get, set: set)
			return withTransform(transform)
		}
	}

	public struct KeyWithDefault<Value, StoredValue: PropertyListCodable>: RawRepresentable {
		public let rawValue: String

		public let defaultValue: Value

		internal private(set) var transform: Transform<Value, StoredValue>?

		@available(*, deprecated, message: "Always fails. Use init(rawValue:, defaultValue:)")
		public init?(rawValue: String) { nil }

		public init(rawValue: String, defaultValue: Value, storedValueType: StoredValue.Type) {
			self.rawValue = rawValue
			self.defaultValue = defaultValue
			self.transform = nil
		}

		public init(rawValue: String, defaultValue: Value) {
			self.rawValue = rawValue
			self.defaultValue = defaultValue
			self.transform = nil
		}


		public func withTransform(_ transform: Transform<Value, StoredValue>) -> Self {
			var new = self
			new.transform = transform
			return new
		}

		public func withTransform(get: Transform<Value, StoredValue>.GetTransform? = nil, set: Transform<Value, StoredValue>.SetTransform? = nil) -> Self {
			let transform = Transform(get: get, set: set)
			return withTransform(transform)
		}
	}

	public struct Transform<Input, Stored: PropertyListCodable> {
		public typealias GetTransform = (Stored) throws -> Input
		public typealias SetTransform = (Input) throws -> Stored

		public let get: GetTransform?
		public let set: SetTransform?

		public init(get: GetTransform?, set: SetTransform?) {
			self.get = get
			self.set = set
		}
	}
}

public protocol PropertyListCodable {}
extension String: PropertyListCodable {}
extension Data: PropertyListCodable {}
extension Bool: PropertyListCodable {}
extension Int: PropertyListCodable {}
extension Double: PropertyListCodable {}
extension Float: PropertyListCodable {}
extension Date: PropertyListCodable {}
extension Array: PropertyListCodable where Element: PropertyListCodable {}
extension Dictionary: PropertyListCodable where Key: PropertyListCodable, Value: PropertyListCodable {}
