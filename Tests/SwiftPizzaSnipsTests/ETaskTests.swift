import Testing
import SwiftPizzaSnips

struct ETaskTests {
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test(arguments: [true, false]) func success(detached: Bool) async throws {
		let task = createTask(detached: detached) {
			try await Task.sleep(for: .seconds(0.01))

			return true
		}

		let result = try await task.value

		#expect(result == true)
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test(arguments: [true, false]) func failure(detached: Bool) async throws {
		let expectedError = SimpleError(message: "Foo")

		let task = createTask(detached: detached) { () async throws(SimpleError) -> Void in
			throw expectedError
		}

		await #expect(throws: expectedError, performing: {
			try await task.value
		})
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test(arguments: [true, false]) func cancel(detached: Bool) async throws {
		let task = createTask(detached: detached) {
			try await Task.sleep(for: .seconds(2))

			throw SimpleError(message: "Cancel failed")
		}

		#expect(task.isCancelled == false)
		try await Task.sleep(for: .seconds(0.15))
		#expect(task.isCancelled == false)
		task.cancel()

		let result = await task.result

		#expect(throws: CancellationError.self, performing: {
			try result.get()
		})
		#expect(task.isCancelled == true)
	}

	private func createTask<Success: Sendable, Failure: Error>(
		detached: Bool,
		_ op: @escaping () async throws(Failure) -> Success
	) -> ETask<Success, Failure> {
		if detached {
			ETask.detached(operation: op)
		} else {
			ETask(operation: op)
		}
	}
}
