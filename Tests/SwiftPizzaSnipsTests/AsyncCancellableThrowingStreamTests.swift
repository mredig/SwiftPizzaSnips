import Testing
import SwiftPizzaSnips

struct AsyncCancellableThrowingStreamTests {
	@Test func simple() async throws {
		let input = [0, 1, 2, 3, 4, 5, 6]

		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream()

		Task {
			for num in input {
				try await Task.sleep(for: .milliseconds(20))
				continuation.yield(num)
			}
			continuation.finish()
		}

		var out: [Int] = []

		for try await num in stream {
			out.append(num)
		}

		#expect(input == out)
	}

	@Test func throwsError() async throws {
		let input = [0, 1, 2, 3, 4, 5, 6]

		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream()

		Task {
			for num in input {
				try await Task.sleep(for: .milliseconds(20))
				guard num < 4 else {
					continuation.finish(throwing: SimpleError(message: "Error"))
					return
				}
				continuation.yield(num)
			}
			fatalError("Reaching here should be impossible")
		}

		var out: [Int] = []

		await #expect(throws: SimpleError.self, performing: {
			for try await num in stream {
				out.append(num)
			}
		})

		#expect([0, 1, 2, 3] == out)
	}

	@Test func cancelViaAbandon() async throws {
		try await confirmation { terminatedExpectation in
			_ = Task {
				let input = [0, 1, 2, 3, 4, 5, 6]

				let (_, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream()

				continuation.onTermination = { reason in
					terminatedExpectation()
					print("Terminated: \(reason)")
				}

				for num in input {
					try await Task.sleep(for: .milliseconds(20))
					guard num < 4 else { return }
					continuation.yield(num)
					print(num)
				}
			}

			// If we don't wait a bit for the `onTermination` to complete, then `confirmation` will conclude that the
			// expectation is never called.
			try await Task.sleep(for: .milliseconds(500))
		}
	}
}
