import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
public class DefaultsManager: Withable {
	private static let defaults = UserDefaults.standard

	public static let shared = DefaultsManager()

	#if canImport(FoundationNetworking)
	private init() {}
	#else
	private var bag = Bag()
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
	#endif

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
				return try getTransform(storedValue).unwrap("Transform provided nil Optional")
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
		let newKey = Key<Value, StoredValue>(key.rawValue).with {
			if let transform = key.transform {
				$0 = $0.withTransform(transform)
			}
		}

		setValue(value, for: newKey)
	}

	public func setValue<Value, StoredValue: PropertyListCodable>(_ value: Value?, for key: Key<Value, StoredValue>) {
		let notifications = getNotificationStores(for: key)
		var success = true
		defer {
			if success {
				notifications.forEach { $0(value) }
			}
		}

		guard let value else {
			Self.defaults.removeObject(forKey: key.rawValue)
			return
		}

		if let setTransform = key.transform?.set {
			do {
				let data = try setTransform(value)
				Self.defaults.set(data, forKey: key.rawValue)
			} catch {
				success = false
				print("Error converting value for key \(key) to data: \(error)")
			}
		} else {
			Self.defaults.set(value, forKey: key.rawValue)
		}
	}

	@discardableResult
	public func reset<Value, StoredValue: PropertyListCodable>(key: KeyWithDefault<Value, StoredValue>) -> Value {
		setValue(key.reset.resetValue, for: key)
		return getValue(for: key)
	}

	public func removeValue<Value, StoredValue: PropertyListCodable>(for key: Key<Value, StoredValue>) {
		setValue(nil, for: key)
	}

	public func removeValue<Value, StoredValue: PropertyListCodable>(for key: KeyWithDefault<Value, StoredValue>) {
		let newKey = Key<Value, StoredValue>(key.rawValue)
		removeValue(for: newKey)
	}

	public subscript<Value, StoredValue: PropertyListCodable>(key: Key<Value, StoredValue>) -> Value? {
		get { getValue(for: key) }
		set { setValue(newValue, for: key) }
	}

	public subscript<Value, StoredValue: PropertyListCodable>(key: KeyWithDefault<Value, StoredValue>) -> Value {
		get { getValue(for: key) }
		set { setValue(newValue, for: key) }
	}

	public subscript<Value, StoredValue: PropertyListCodable>(defaultValue key: KeyWithDefault<Value, StoredValue>) -> Value {
		key.defaultValue
	}

	public subscript<Value, StoredValue: PropertyListCodable>(reset key: KeyWithDefault<Value, StoredValue>) -> Value {
		reset(key: key)
	}

	public struct Key<Value, StoredValue: PropertyListCodable>: RawRepresentable, KeyProtocol, Withable {
		public let rawValue: String
		public var key: String { rawValue }
		
		internal private(set) var transform: Transform<Value, StoredValue>?

		public init(_ key: String) {
			self.rawValue = key
		}

		@available(*, deprecated, message: "Confusing. Use init(_:)")
		public init(rawValue: String) {
			self.init(rawValue)
		}

		public init(_ key: String, storedValueType: StoredValue.Type) {
			self.init(key)
		}

		@available(*, deprecated, message: "Confusing. Use init(_:, storedValueType:)")
		public init(rawValue: String, storedValueType: StoredValue.Type) {
			self.init(rawValue, storedValueType: storedValueType)
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

	public struct KeyWithDefault<Value, StoredValue: PropertyListCodable>: RawRepresentable, KeyProtocol, Withable {
		public let rawValue: String
		public var key: String { rawValue }
		public var reset: DefaultsReset<Value, StoredValue> {
			DefaultsReset(resetValue: defaultValue, key: self)
		}

		public let defaultValue: Value

		internal private(set) var transform: Transform<Value, StoredValue>?

		@available(*, deprecated, message: "Always fails. Use init(_:, defaultValue:)")
		public init?(rawValue: String) { nil }

		@available(*, deprecated, message: "Confusing. Use init(_:, defaultValue:, storedValueType:)")
		public init(rawValue: String, defaultValue: Value, storedValueType: StoredValue.Type) {
			self.init(rawValue, defaultValue: defaultValue)
		}

		public init(_ key: String, defaultValue: Value, storedValueType: StoredValue.Type) {
			self.init(key, defaultValue: defaultValue)
		}

		@available(*, deprecated, message: "Confusing. Use init(_:, defaultValue:)")
		public init(rawValue: String, defaultValue: Value) {
			self.init(rawValue, defaultValue: defaultValue)
		}

		public init(_ key: String, defaultValue: Value) {
			self.rawValue = key
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

	public struct DefaultsReset<V, SV: PropertyListCodable> {
		let resetValue: V
		let key: KeyWithDefault<V, SV>
	}

	public struct Transform<Input, Stored: PropertyListCodable> {
		public typealias GetTransform = (Stored) throws -> Input?
		public typealias SetTransform = (Input) throws -> Stored?

		public let get: GetTransform?
		public let set: SetTransform?

		public init(get: GetTransform?, set: SetTransform?) {
			self.get = get
			self.set = set
		}
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension DefaultsManager.Key where Value: Codable, StoredValue == Data {
	public init(autoCodingValueWithKey key: String) {
		self.init(key)

		self = withTransform(
			get: {
				try DefaultsManager.defaultDecoder.decode(Value.self, from: $0)
			},
			set: {
				try DefaultsManager.defaultEncoder.encode($0)
			})
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension DefaultsManager.KeyWithDefault where Value: Codable, StoredValue == Data {
	public init(autoCodingValueWithKey key: String, defaultValue: Value) {
		self.init(key, defaultValue: defaultValue)

		self = withTransform(
			get: {
				try DefaultsManager.defaultDecoder.decode(Value.self, from: $0)
			},
			set: {
				try DefaultsManager.defaultEncoder.encode($0)
			})
	}
}

#if canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension DefaultsManager: ObservableObject {
	public subscript <Value, StoredValue: PropertyListCodable>(binding key: Key<Value, StoredValue>) -> Binding<Value?> {
		.init(
			get: { self[key] },
			set: { self[key] = $0 })
	}

	public subscript <Value, StoredValue: PropertyListCodable>(binding key: KeyWithDefault<Value, StoredValue>) -> Binding<Value> {
		.init(
			get: { self[key] },
			set: { self[key] = $0 })
	}
}
#endif

public protocol PropertyListCodable {}
extension String: PropertyListCodable {}
extension Data: PropertyListCodable {}
extension Bool: PropertyListCodable {}
extension Int: PropertyListCodable {}
extension Double: PropertyListCodable {}
extension Float: PropertyListCodable {}
extension Date: PropertyListCodable {}

extension Optional: PropertyListCodable where Wrapped: PropertyListCodable {}

extension Array: PropertyListCodable where Element: PropertyListCodable {}
extension Dictionary: PropertyListCodable where Key: PropertyListCodable, Value: PropertyListCodable {}

extension Int8: PropertyListCodable {}
extension Int16: PropertyListCodable {}
extension Int32: PropertyListCodable {}
extension Int64: PropertyListCodable {}

extension UInt8: PropertyListCodable {}
extension UInt16: PropertyListCodable {}
extension UInt32: PropertyListCodable {}
extension UInt64: PropertyListCodable {}
extension UInt: PropertyListCodable {}

// untested
//@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
//extension UInt128: PropertyListCodable {}
//@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
//extension Int128: PropertyListCodable {}
