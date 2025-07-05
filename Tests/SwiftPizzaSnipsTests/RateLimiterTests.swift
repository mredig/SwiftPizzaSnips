import Testing
import Foundation
import SwiftPizzaSnips

struct RateLimiterTests {
	@available(*, deprecated)
	@Test func testDurationSeconds() throws {
		let twoSeconds: RateLimiter.Duration = .seconds(2)
		let twoMilliSeconds: RateLimiter.Duration = .milliseconds(2)
		let twoMicroSeconds: RateLimiter.Duration = .microseconds(2)
		let twoNanoSeconds: RateLimiter.Duration = .nanoseconds(2)

		#expect(twoSeconds.seconds == 2)
		#expect(twoMilliSeconds.seconds == 0.002)
		#expect(twoMicroSeconds.seconds == 0.000_002)
		#expect(twoNanoSeconds.seconds == 0.000_000_002)
	}

	@available(*, deprecated)
	@Test func testDurationNanoSeconds() throws {
		let twoSeconds: RateLimiter.Duration = .seconds(2)
		let twoMilliSeconds: RateLimiter.Duration = .milliseconds(2)
		let twoMicroSeconds: RateLimiter.Duration = .microseconds(2)
		let twoNanoSeconds: RateLimiter.Duration = .nanoseconds(2)

		#expect(twoSeconds.nanoseconds == 2_000_000_000)
		#expect(twoMilliSeconds.nanoseconds == 2_000_000)
		#expect(twoMicroSeconds.nanoseconds == 2_000)
		#expect(twoNanoSeconds.nanoseconds == 2)
	}

	@available(*, deprecated)
	@available(iOS 15, tvOS 15, watchOS 10, *)
	@Test func testRateLimitDebounce() async throws {
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

		await withKnownIssue(
			"Fails occasionally, usually when running all tests. Individual usually passes",
			isIntermittent: true
		) {
			#expect(runTimes.isEmpty)

			try await Task.sleep(nanoseconds: RateLimiter.Duration.milliseconds(200).nanoseconds)
			#expect(runTimes.count == 1)
			print("iterations: \(iterations)")
		}
	}

	@available(iOS 15, tvOS 15, watchOS 10, *)
	@available(*, deprecated)
	@Test func testRateLimitThrottle() async throws {
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

		#expect(runTimes.count == 2)

		try await Task.sleep(nanoseconds: RateLimiter.Duration.milliseconds(500).nanoseconds)
		#expect(runTimes.count == 3)

		try await Task.sleep(nanoseconds: RateLimiter.Duration.milliseconds(500).nanoseconds)
		#expect(runTimes.count == 3)
		print("iterations: \(iterations)")
	}
}
