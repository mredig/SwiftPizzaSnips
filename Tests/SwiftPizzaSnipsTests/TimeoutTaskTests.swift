import Testing
import Foundation
import SwiftPizzaSnips

struct TimeoutTaskTests {
	@Test(arguments: [true, false]) func success(detached: Bool) async throws {
		let task = createTask(detached: detached, timeout: 3) { () async throws(TestingError) -> Bool in
			do {
				try await Task.sleep(for: .seconds(0.01))
			} catch {
				throw .failed
			}

			return true
		}

		let result = try await task.value

		#expect(result == true)
	}

	@Test(arguments: [true, false]) func failure(detached: Bool) async throws {
		let task = createTask(detached: detached, timeout: 5) { () async throws(TestingError) -> Void in
			throw .expected
		}

		await #expect(throws: TestingError.expected, performing: {
			try await task.value
		})
	}

	@Test(arguments: [true, false]) func cancel(detached: Bool) async throws {
		let task = createTask(detached: detached, timeout: 5) { () async throws(TestingError) -> Void in
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

		#expect(throws: TestingError.expected, performing: {
			try result.get()
		})
		#expect(task.isCancelled == true)
	}

	@Test(arguments: [true, false]) func timeoutReached(detached: Bool) async throws {
		let task = createTask(detached: detached, timeout: 0.2) { () async throws(TestingError) -> Void in
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
		timeout: TimeInterval,
		_ op: @escaping () async throws(Failure) -> Success
	) -> TimeoutTask<Success, Failure> {
		if detached {
			TimeoutTask.detached(timeout: .seconds(timeout), operation: op)
		} else {
			TimeoutTask(timeout: .seconds(timeout), operation: op)
		}
	}

	enum TestingError: TimedOutError {
		case timedOut
		case cancelled
		case failed
		case expected
	}
}
