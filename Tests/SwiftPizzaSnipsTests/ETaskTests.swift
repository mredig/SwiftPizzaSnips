import Testing
import SwiftPizzaSnips

struct ETaskTests {
	@Test func success() async throws {
		let task = ETask {
			try await Task.sleep(for: .seconds(0.01))

			return true
		}

		let result = try await task.value

		#expect(result == true)
	}

	@Test func failure() async throws {
		let expectedError = SimpleError(message: "Foo")

		let task = ETask { () async throws(SimpleError) -> Void in
			throw expectedError
		}

		await #expect(throws: expectedError, performing: {
			try await task.value
		})
	}

	@Test func cancel() async throws {
		let task = ETask {
			try await Task.sleep(for: .seconds(0.5))

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
}
