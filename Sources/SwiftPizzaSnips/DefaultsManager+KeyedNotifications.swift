import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager {
	public typealias NotificationID = String
	public typealias RawKey = String

	private static let lock = NSLock()
	private static var keyedNotifications: [RawKey: [NotificationID: NotificationStore]] = [:]

	private struct NotificationStore {
		let id: NotificationID
		let block: AnyUpdateAction
		let key: AnyKey
	}

	public func registerNotifications<T, S: PropertyListCodable>(
		for key: Key<T, S>,
		withID id: NotificationID,
		_ block: @escaping (T?) -> Void
	) {
		let anyKey = AnyKey(key)
		registerNotifications(for: anyKey, withID: id, block)
	}

	public func registerNotifications<T, S: PropertyListCodable>(
		for key: KeyWithDefault<T, S>,
		withID id: String,
		_ block: @escaping (T) -> Void
	) {
		let newKey = AnyKey(key)
		registerNotifications(for: newKey, withID: id, block)
	}

	private func registerNotifications<T>(
		for key: AnyKey,
		withID id: NotificationID,
		_ block: @escaping (T) -> Void
	) {
		Self.lock.withLock {
			let updateAction = UpdateAction(action: block)
			let store = NotificationStore(id: id, block: updateAction, key: key)
			Self.keyedNotifications[key.rawValue, default: [:]][id] = store
		}
	}

	public func deregisterNotifications<T, S: PropertyListCodable>(for key: Key<T, S>, withID id: String) {
		Self.lock.withLock {
			Self.keyedNotifications[key.rawValue, default: [:]][id] = nil
		}
	}

	public func deregisterNotifications<T, S: PropertyListCodable>(for key: KeyWithDefault<T, S>, withID id: String) {
		let newKey = Key<T, S>(key.rawValue)
		deregisterNotifications(for: newKey, withID: id)
	}

	func getNotificationStores<T, S: PropertyListCodable>(for key: Key<T, S>) -> [(T?) -> Void] {
		Self.lock.withLock {
			let stores = Self.keyedNotifications[key.rawValue].map { Array($0.values) } ?? []
			let blocks = stores.map { store in
				let foo = { (new: T?) -> Void in
					store.block.performAction(with: new as Any)
				}
				return foo
			}
			return blocks
		}
	}

	protocol KeyProtocol {
		var key: String { get }
	}

	private struct AnyKey {
		var rawValue: String { key.key }
		let key: KeyProtocol

		init(_ key: KeyProtocol) {
			self.key = key
		}
	}

	private struct UpdateAction<Value>: AnyUpdateAction {
		let action: (Value) -> Void

		func performAction(with value: Any) {
			guard let value = value as? Value else { return }
			action(value)
		}
	}

	private protocol AnyUpdateAction {
		func performAction(with value: Any)
	}
}
