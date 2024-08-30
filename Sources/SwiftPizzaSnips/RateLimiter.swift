import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public enum RateLimiter {
	public enum Duration  {
		case seconds(Double)
		case milliseconds(Double)
		case microseconds(Double)
		case nanoseconds(UInt64)

		public var nanoseconds: UInt64 {
			switch self {
			case .seconds(let value):
				UInt64(abs(value) * 1_000_000_000)
			case .milliseconds(let value):
				UInt64(abs(value) * 1_000_000)
			case .microseconds(let value):
				UInt64(abs(value) * 1_000)
			case .nanoseconds(let value):
				value
			}
		}

		public var seconds: Double {
			switch self {
			case .seconds(let value):
				value
			case .milliseconds(let value):
				value / 1_000
			case .microseconds(let value):
				value / 1_000_000
			case .nanoseconds(let value):
				Double(value) / 1_000_000_000
			}
		}
	}

	public struct ID: RawRepresentable, Hashable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
		public let rawValue: String

		public init(rawValue: String) {
			self.rawValue = rawValue
		}

		public init(_ rawValue: String) {
			self.init(rawValue: rawValue)
		}

		public init(stringLiteral value: StringLiteralType) {
			self.init(value)
		}
	}

	private static let debounceLock = NSLock()
	private static var debounceTable: [ID: Task<Void, Error>] = [:]

	public static func debounce(id: ID, frequency: Duration = .milliseconds(100), _ action: @escaping () -> Void) {
		debounceLock.lock()
		defer { debounceLock.unlock() }

		debounceTable[id]?.cancel()
		debounceTable[id] = nil

		let newTask = Task {
			try Task.checkCancellation()
			try await Task.sleep(nanoseconds: UInt64(frequency.nanoseconds))
			try Task.checkCancellation()
			action()
			debounceLock.withLock {
				debounceTable[id] = nil
			}
		}
		debounceTable[id] = newTask
	}

	private static let throttleLock = NSLock()
	private static var throttleTimerTable: [ID: Task<Void, Error>] = [:]
	private static var throttleActionTable: [ID: () -> Void] = [:]

	public static func throttle(id: ID, frequency: Duration = .milliseconds(100), _ action: @escaping () -> Void) {
		throttleLock.lock()
		defer { throttleLock.unlock() }

		if throttleTimerTable[id] == nil {
			action()
			_createThrottleTimer(id: id, frequency: frequency)
		} else {
			throttleActionTable[id] = action
		}
	}

	private static func executeAction(id: ID, frequency: Duration) {
		throttleLock.withLock {
			if let action = throttleActionTable[id] {
				action()
				throttleActionTable[id] = nil
				_createThrottleTimer(id: id, frequency: frequency)
			} else {
				throttleTimerTable[id] = nil
			}
		}
	}

	private static func _createThrottleTimer(id: ID, frequency: Duration) {
		let newTask = Task {
			try Task.checkCancellation()
			try await Task.sleep(nanoseconds: frequency.nanoseconds)
			try Task.checkCancellation()

			executeAction(id: id, frequency: frequency)
		}
		throttleTimerTable[id] = newTask
	}
}
