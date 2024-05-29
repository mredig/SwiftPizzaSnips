import Foundation

/// A wrapped around `NSCache` that allows the use of value types and first class Swift Generics
public class NSwiftCache<Key: Hashable, Value> {
	private let wrappedCache: NSCache<Box<Key>, Box<Value>>

	private class TheDelegate: NSObject, NSCacheDelegate {
		var onEvict: (Value) -> Void

		init(onEvict: @escaping (Value) -> Void) {
			self.onEvict = onEvict
		}

		func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
			guard
				let value = obj as? Box<Value>
			else {
				print("💔 Error! Cached Value is not in a Box!")
				return
			}

			onEvict(value.wrapped)
		}
	}

	private let wrappedDel: TheDelegate

	public var onEvict: (Value) -> Void {
		get { wrappedDel.onEvict }
		set { wrappedDel.onEvict = newValue }
	}

	public var name: String {
		get { wrappedCache.name }
		set { wrappedCache.name = newValue }
	}

	public var countLimit: Int {
		get { wrappedCache.countLimit }
		set { wrappedCache.countLimit = newValue }
	}

	public var evictsObjectsWithDiscardedContent: Bool {
		get { wrappedCache.evictsObjectsWithDiscardedContent }
		set { wrappedCache.evictsObjectsWithDiscardedContent = newValue }
	}

	public init(name: String? = nil, countLimit: Int? = nil, onEvict: @escaping (Value) -> Void = { _ in }) {
		let wrappedCache = NSCache<Box<Key>, Box<Value>>()
		wrappedCache.name = name ?? "Cache for [\(Key.self) : \(Value.self)]"
		if let countLimit {
			wrappedCache.countLimit = countLimit
		}
		self.wrappedCache = wrappedCache
		let wrappedDel = TheDelegate(onEvict: onEvict)
		self.wrappedDel = wrappedDel
		wrappedCache.delegate = wrappedDel
	}

	/// `cost` only has any effect when setting a value.
	public subscript(key: Key, cost: Int? = nil) -> Value? {
		get { value(forKey: key) }
		set {
			guard
				let newValue
			else { return removeValue(forKey: key) }

			setValue(newValue, forKey: key, cost: cost)
		}
	}

	public func value(forKey key: Key) -> Value? {
		wrappedCache.object(forKey: Box(wrapped: key))?.wrapped
	}

	public func setValue(_ value: Value, forKey key: Key, cost: Int? = nil) {
		let valueBox = Box(wrapped: value)
		let keyBox = Box(wrapped: key)
		if let cost {
			wrappedCache.setObject(valueBox, forKey: keyBox, cost: cost)
		} else {
			wrappedCache.setObject(valueBox, forKey: keyBox)
		}
	}

	public func removeValue(forKey key: Key) {
		let box = Box(wrapped: key)
		wrappedCache.removeObject(forKey: box)
	}

	public func removeAllObjects() {
		wrappedCache.removeAllObjects()
	}
}

private class Box<T> {
	let wrapped: T

	init(wrapped: T) {
		self.wrapped = wrapped
	}
}

extension Box: Equatable where T: Equatable {
	static func == (lhs: Box<T>, rhs: Box<T>) -> Bool {
		lhs.wrapped == rhs.wrapped
	}
}
extension Box: Hashable where T: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(wrapped)
	}
}
