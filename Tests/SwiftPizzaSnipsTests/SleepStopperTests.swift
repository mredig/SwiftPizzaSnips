#if os(macOS)
import XCTest
@testable import SwiftPizzaSnips

/// I'm not even sure if it's possible to test whether sleep is being prevented or not, but I can at least check if the coded logic is behaving as expected
final class SleepStopperTests: XCTestCase {
	func testSleepStopperNaturalReleaseOne() throws {
		XCTAssertFalse(SleepStopper.isPreventingSleep)
		autoreleasepool {
			let token = SleepStopper.disableSleepUntilTokenRelease()
			XCTAssertTrue(SleepStopper.isPreventingSleep)
			print(token) // silence unused warning
		}

		XCTAssertFalse(SleepStopper.isPreventingSleep)
	}

	func testSleepStopperNaturalReleaseMany() throws {
		XCTAssertFalse(SleepStopper.isPreventingSleep)
		autoreleasepool {
			var tokens: [SleepStopperToken] = []
			for _ in 0..<2 {
				let token = SleepStopper.disableSleepUntilTokenRelease()
				XCTAssertTrue(SleepStopper.isPreventingSleep)
				tokens.append(token)
			}
			XCTAssertTrue(SleepStopper.isPreventingSleep)
			tokens.removeAll()
		}

		XCTAssertFalse(SleepStopper.isPreventingSleep)
	}

	func testSleepStopperInvalidateOne() throws {
		XCTAssertFalse(SleepStopper.isPreventingSleep)
		let token = SleepStopper.disableSleepUntilTokenRelease()
		XCTAssertTrue(SleepStopper.isPreventingSleep)
		token.invalidate()

		XCTAssertFalse(SleepStopper.isPreventingSleep)
	}

	func testSleepStopperInvalidateMany() throws {
		XCTAssertFalse(SleepStopper.isPreventingSleep)

		var tokens: [SleepStopperToken] = []
		for _ in 0..<2 {
			let token = SleepStopper.disableSleepUntilTokenRelease()
			XCTAssertTrue(SleepStopper.isPreventingSleep)
			tokens.append(token)
		}
		XCTAssertTrue(SleepStopper.isPreventingSleep)
		tokens.removeAll()
		tokens.forEach { $0.invalidate() }

		XCTAssertFalse(SleepStopper.isPreventingSleep)
	}
}
#endif
