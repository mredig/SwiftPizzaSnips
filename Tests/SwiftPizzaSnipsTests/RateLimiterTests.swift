import XCTest
import SwiftPizzaSnips

final class RateLimiterTests: XCTestCase {
	func testDurationSeconds() throws {
		let twoSeconds: RateLimiter.Duration = .seconds(2)
		let twoMilliSeconds: RateLimiter.Duration = .milliseconds(2)
		let twoMicroSeconds: RateLimiter.Duration = .microseconds(2)
		let twoNanoSeconds: RateLimiter.Duration = .nanoseconds(2)

		XCTAssertEqual(twoSeconds.seconds, 2)
		XCTAssertEqual(twoMilliSeconds.seconds, 0.002)
		XCTAssertEqual(twoMicroSeconds.seconds, 0.000_002)
		XCTAssertEqual(twoNanoSeconds.seconds, 0.000_000_002)
	}

	func testDurationNanoSeconds() throws {
		let twoSeconds: RateLimiter.Duration = .seconds(2)
		let twoMilliSeconds: RateLimiter.Duration = .milliseconds(2)
		let twoMicroSeconds: RateLimiter.Duration = .microseconds(2)
		let twoNanoSeconds: RateLimiter.Duration = .nanoseconds(2)

		XCTAssertEqual(twoSeconds.nanoseconds, 2_000_000_000)
		XCTAssertEqual(twoMilliSeconds.nanoseconds, 2_000_000)
		XCTAssertEqual(twoMicroSeconds.nanoseconds, 2_000)
		XCTAssertEqual(twoNanoSeconds.nanoseconds, 2)
	}

	@available(iOS 15, tvOS 15, watchOS 10, *)
	func testRateLimitDebounce() async throws {
		let id = RateLimiter.ID("foo")

		let start = Date()
		let end = start.addingTimeInterval(0.5)

		var runTimes: [Date] = []
		var iterations = 0

		while .now < end {
			RateLimiter.debounce(id: id, frequency: .milliseconds(100)) {
				runTimes.append(.now)
			}
			iterations += 1
		}

		XCTAssertTrue(runTimes.isEmpty)

		try await Task.sleep(nanoseconds: RateLimiter.Duration.milliseconds(200).nanoseconds)
		XCTAssertEqual(runTimes.count, 1)
		print("iterations: \(iterations)")
	}

	@available(iOS 15, tvOS 15, watchOS 10, *)
	func testRateLimitThrottle() async throws {
		let id = RateLimiter.ID("foo")

		let start = Date()
		let end = start.addingTimeInterval(0.5)

		var runTimes: [Date] = []
		var iterations = 0

		while .now < end {
			RateLimiter.throttle(id: id, frequency: .milliseconds(400)) {
				runTimes.append(.now)
			}
			iterations += 1
		}

		XCTAssertEqual(runTimes.count, 2)

		try await Task.sleep(nanoseconds: RateLimiter.Duration.milliseconds(500).nanoseconds)
		XCTAssertEqual(runTimes.count, 3)

		try await Task.sleep(nanoseconds: RateLimiter.Duration.milliseconds(500).nanoseconds)
		XCTAssertEqual(runTimes.count, 3)
		print("iterations: \(iterations)")
	}
}
