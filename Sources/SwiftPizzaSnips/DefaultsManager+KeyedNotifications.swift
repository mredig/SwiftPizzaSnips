import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager {
	public typealias NotificationID = UUID
	public typealias RawKey = String

	private static let lock = NSLock()
	private static var keyedNotifications: [RawKey: [NotificationID: NotificationStore]] = [:]
	private static var idsAndKeys: [NotificationID: RawKey] = [:]

	private struct NotificationStore {
		let id: NotificationID = .init()
		let block: AnyUpdateAction
		let key: AnyKey

		var handle: NotificationHandle {
			NotificationHandle(id: id)
		}
	}

	public struct NotificationHandle: Hashable {
		let id: NotificationID
	}

	@discardableResult
	public func registerNotifications<T, S: PropertyListCodable>(
		for key: Key<T, S>,
		_ block: @escaping (T?) -> Void
	) -> NotificationHandle {
		let anyKey = AnyKey(key)
		return registerNotifications(for: anyKey, block)
	}

	@discardableResult
	public func registerNotifications<T, S: PropertyListCodable>(
		for key: KeyWithDefault<T, S>,
		_ block: @escaping (T) -> Void
	) -> NotificationHandle {
		let newKey = AnyKey(key)
		return registerNotifications(for: newKey, block)
	}

	private func registerNotifications<T>(
		for key: AnyKey,
		_ block: @escaping (T) -> Void
	) -> NotificationHandle {
		Self.lock.withLock {
			let updateAction = UpdateAction(action: block)
			let store = NotificationStore(block: updateAction, key: key)
			let handle = store.handle
			Self.keyedNotifications[key.rawValue, default: [:]][handle.id] = store
			Self.idsAndKeys[handle.id] = key.rawValue
			return handle
		}
	}

	public func deregisterNotifications(for handle: NotificationHandle) {
		Self.lock.withLock {
			guard
				let rawKey = Self.idsAndKeys[handle.id]
			else { return }
			Self.keyedNotifications[rawKey]?[handle.id] = nil
		}
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
