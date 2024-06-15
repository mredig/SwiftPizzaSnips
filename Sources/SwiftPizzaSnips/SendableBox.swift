import Foundation

public class SendableBox<T>: @unchecked Sendable {
	private let lock: NSLock

	private var _value: T
	public var value: T {
		get { lock.withLock { _value } }
		set { lock.withLock { _value = newValue } }
	}

	public init(value: T, lock: NSLock = NSLock()) {
		lock.lock()
		defer { lock.unlock() }
		self._value = value
		self.lock = lock
	}
}

extension SendableBox where T: ExpressibleByNilLiteral {
	public convenience init() {
		self.init(value: nil)
	}
}
