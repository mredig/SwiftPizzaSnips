import Testing
import Foundation
import SwiftPizzaSnips

struct TimeoutTaskTests {
	// This test is expected to take the whole 1 second
	@Test(arguments: [true, false]) func asyncUnawareTimesOutStructured(detached: Bool) async throws {
		let timerStart = Date()
		let task = createTask(detached: detached, structured: true, timeout: 0.01) { () async throws(TestingError) -> Bool in
			usleep(1_000_000)
			// It is expected that this will always print, delaying the timeout.
			print("🤬🤬🤬 (Task.isCancelled was ignored and execution continued (\(#function))")
            throw TestingError.failed
        }

        await #expect(throws: TestingError.timedOut, performing: {
            try await task.value
        })
		let timerEnd = Date()

		#expect(timerEnd.timeIntervalSince(timerStart) >= 1)
    }

	// This test is expected to only take the 0.01 ±a bit timeout duration
	@Test(arguments: [true, false]) func asyncUnawareTimesOutUnstructured(detached: Bool) async throws {
		let task = createTask(detached: false, structured: false, timeout: 0.01) { () async throws(TestingError) -> Bool in
			usleep(1_000_000)
			// It is generally expected that this won't always print out as the timeout should ignore that the code is still
			// executing and finish. However, if the *overall program* continues long enough for the `usleep` to complete,
			// the print statement will still execute. Think of the potential secondary side effects that could happen in
			// unpure functions passed to TimeoutTask.
			print("🤬🤬🤬 (Task.isCancelled was ignored and execution continued (\(#function))")
			throw TestingError.failed
		}

		await #expect(throws: TestingError.timedOut, performing: {
			try await task.value
		})
	}

	@Test(arguments: [true, false]) func success(detached: Bool) async throws {
		let timerStart = Date()
		let task = createTask(detached: detached, structured: true, timeout: 3) { () async throws(TestingError) -> Bool in
			do {
				try await Task.sleep(for: .seconds(0.01))
			} catch {
				throw .failed
			}

			return true
		}

		let result = try await task.value
		let timerEnd = Date()

		#expect(result == true)
		#expect(timerEnd.timeIntervalSince(timerStart) < 0.5)
	}

	@Test(arguments: [true, false]) func failure(detached: Bool) async throws {
		let task = createTask(detached: detached, structured: true, timeout: 5) { () async throws(TestingError) -> Void in
			throw .expected
		}

		await #expect(throws: TestingError.expected, performing: {
			try await task.value
		})
	}

	@Test(arguments: [true, false]) func cancel(detached: Bool) async throws {
		let task = createTask(detached: detached, structured: true, timeout: 5) { () async throws(TestingError) -> Void in
			do {
				try await Task.sleep(for: .seconds(2))
			} catch {
				throw .expected
			}

			throw .failed
		}

		#expect(task.isCancelled == false)
		try await Task.sleep(for: .seconds(0.15))
		#expect(task.isCancelled == false)
		task.cancel()

		let result = await task.result

        #expect(throws: Error.self, performing: {
			try result.get()
		})
		#expect(task.isCancelled == true)
	}

	@Test(arguments: [true, false]) func timeoutReached(detached: Bool) async throws {
		let task = createTask(detached: detached, structured: true, timeout: 0.2) { () async throws(TestingError) -> Void in
			do {
				try await Task.sleep(for: .seconds(2))
			} catch {
				throw .failed
			}

			throw .failed
		}

		let result = await task.result

		#expect(throws: TestingError.timedOut, performing: {
			try result.get()
		})
	}


	private func createTask<Success: Sendable, Failure: TimedOutError>(
		detached: Bool,
		structured: Bool,
		timeout: TimeInterval,
		_ op: @escaping () async throws(Failure) -> Success
	) -> TimeoutTask<Success, Failure> {
		if detached {
			TimeoutTask.detached(timeout: .seconds(timeout), shouldUseStructuredTasks: structured, operation: op)
		} else {
			TimeoutTask(timeout: .seconds(timeout), shouldUseStructuredTasks: structured, operation: op)
		}
	}

	enum TestingError: TimedOutError {
		case timedOut
		case cancelled
		case failed
		case expected
	}
}
