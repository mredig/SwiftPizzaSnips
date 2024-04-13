#if os(macOS)
import Foundation
import IOKit.pwr_mgt

public protocol SleepStopperToken: AnyObject {
	func invalidate()
}

/// macOS utility symbol to prevent the computer from going to sleep. Call `diableSleepUntilTokenRelease()` to attain
/// a `SleepStopperToken` which will, for the entirety of its ARC retaining, prevent the computer from sleeping.
/// Alternatively, if you don't want to wait for the token to release, you can also call the `invalidate()` method
/// on the token to invalidate it prior to ARC releasing it.
///
/// This system allows for multiple areas of your app to prevent sleep independently of each other. As long as one
/// token is valid, sleep will be prevented, and conversely, once all tokens are invalidated/released, sleep will
/// once again be possible.
public enum SleepStopper {
	static private let sleepLock = NSLock()

	static private var assertionID: IOPMAssertionID = 0
	static private var _isIdleTimerDisabled = false

	/// Will tell you the current status of `SleepStopper`
	static public var isPreventingSleep: Bool { _isIdleTimerDisabled }

	private static var tokens: Set<Token> = [] {
		didSet {
			updateSleepAllowState()
		}
	}

	private class Token: Hashable, SleepStopperToken {
		let id = UUID()

		deinit {
			invalidate()
		}

		func invalidate() {
			SleepStopper.sleepLock.lock()
			defer { SleepStopper.sleepLock.unlock() }
			SleepStopper.tokens.remove(self)
		}

		static func == (lhs: Token, rhs: Token) -> Bool {
			lhs.id == rhs.id
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}

	/// Call this method and hold on to the token until you want to allow sleep to resume. If you can't release the
	/// object easily, you can also call `invalidate()` on the token when you're finished and sleep will,
	/// once again, be possible.
	///
	/// You can call this multiple times and have multiple active tokens. Sleep will be disabled until all tokens
	/// are released/invalidated.
	public func disableSleepUntilTokenRelease() -> SleepStopperToken {
		Self.sleepLock.lock()
		defer { Self.sleepLock.unlock() }
		let newToken = Token()
		Self.tokens.insert(newToken)
		return newToken
	}

	static private func updateSleepAllowState() {
		if tokens.isEmpty, _isIdleTimerDisabled == true {
			allowSleep()
		} else if tokens.isOccupied, _isIdleTimerDisabled == false {
			preventSleep()
		}
	}

	static private func preventSleep() {
		let success = IOPMAssertionCreateWithName(
			kIOPMAssertionTypeNoDisplaySleep as CFString,
			IOPMAssertionLevel(kIOPMAssertionLevelOn),
			"Prevent Sleep" as CFString,
			&assertionID)

		_isIdleTimerDisabled = success == kIOReturnSuccess
	}

	static private func allowSleep() {
		let success = IOPMAssertionRelease(assertionID)

		if success == kIOReturnSuccess {
			_isIdleTimerDisabled = false
		}
	}
}
#endif
