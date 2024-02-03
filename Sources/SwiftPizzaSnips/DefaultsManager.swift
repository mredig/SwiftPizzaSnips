import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public class DefaultsManager {
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
		var newKey = Key<Value, StoredValue>(key.rawValue)

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
		let newKey = Key<Value, StoredValue>(key.rawValue)
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

	public subscript<Value, StoredValue: PropertyListCodable>(defaultValue key: KeyWithDefault<Value, StoredValue>) -> Value {
		key.defaultValue
	}

	public struct Key<Value, StoredValue: PropertyListCodable>: RawRepresentable {
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
			self.rawValue = key
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

	public struct KeyWithDefault<Value, StoredValue: PropertyListCodable>: RawRepresentable {
		public let rawValue: String
		public var key: String { rawValue }

		public let defaultValue: Value

		internal private(set) var transform: Transform<Value, StoredValue>?

		@available(*, deprecated, message: "Always fails. Use init(_:, defaultValue:)")
		public init?(rawValue: String) { nil }

		@available(*, deprecated, message: "Confusing. Use init(_:, defaultValue:, storedValueType:)")
		public init(rawValue: String, defaultValue: Value, storedValueType: StoredValue.Type) {
			self.init(rawValue, defaultValue: defaultValue)
		}

		public init(_ key: String, defaultValue: Value, storedValueType: StoredValue.Type) {
			self.rawValue = key
			self.defaultValue = defaultValue
			self.transform = nil
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

#if canImport(SwiftUI)
import SwiftUI
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager: ObservableObject {
	public subscript <Value, StoredValue: PropertyListCodable>(binding key: Key<Value, StoredValue>) -> Binding<Value?> {
		.init(
			get: {
				self[key]
			},
			set: {
				self[key] = $0
			})
	}

	public subscript <Value, StoredValue: PropertyListCodable>(binding key: KeyWithDefault<Value, StoredValue>) -> Binding<Value> {
		.init(
			get: {
				self[key]
			},
			set: {
				self[key] = $0
			})
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
