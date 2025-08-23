import Testing
import SwiftPizzaSnips

struct AsyncCancellableThrowingStreamTests {
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func simple() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		Task {
			for num in input {
				try await Task.sleep(for: .milliseconds(20))
				try continuation.yield(num)
			}
			try continuation.finish()
		}

		var out: [Int] = []

		for try await num in stream {
			out.append(num)
		}

		#expect(input == out)
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func throwsError() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		Task {
			for num in input {
				try await Task.sleep(for: .milliseconds(20))
				guard num < 4 else {
					try continuation.finish(throwing: SimpleError(message: "Error"))
					return
				}
				try continuation.yield(num)
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

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func cancelViaAbandon() async throws {
		try await confirmation { terminatedExpectation in
			_ = Task {
				let input = (0..<20).map { $0 }
				let (_, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

				continuation.onFinish { reason in
					terminatedExpectation()
					print("Terminated: \(reason)")
				}

				for num in input {
					try await Task.sleep(for: .milliseconds(20))
					guard num < 4 else { return }
					try continuation.yield(num)
					print(num)
				}
			}

			// If we don't wait a bit for the `onTermination` to complete, then `confirmation` will conclude that the
			// expectation is never called.
			try await Task.sleep(for: .milliseconds(500))
		}
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func cancelViaStreamCallThrowing() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		let continuationShouldError = DelayedExpectation()
		Task {
			var completedSending: [Int] = []
			do {
				for num in input {
					try await Task.sleep(for: .milliseconds(20))
					try continuation.yield(num)
					completedSending.append(num)
				}
				try continuation.finish()
			} catch {
				#expect(completedSending != input)
				continuationShouldError.fulfill()
			}
		}

		Task {
			try await Task.sleep(for: .milliseconds(19 * 3))
			stream.cancel(throwing: CancellationError())
		}

		await #expect(throws: CancellationError.self, performing: {
			for try await num in stream {
				print(num)
			}
		})
		// need to delay to give the sending continuation a chance to loop around to attempt to send again.
		try await Task.sleep(for: .milliseconds(40))
		continuationShouldError.verify()
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func cancelViaStreamCallThrowingDefault() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		let continuationShouldError = DelayedExpectation()
		Task {
			var completedSending: [Int] = []
			do {
				for num in input {
					try await Task.sleep(for: .milliseconds(20))
					try continuation.yield(num)
					completedSending.append(num)
				}
				try continuation.finish()
			} catch {
				#expect(completedSending != input)
				continuationShouldError.fulfill()
			}
		}

		Task {
			try await Task.sleep(for: .milliseconds(19 * 3))
			stream.cancel()
		}

		await #expect(throws: CancellationError.self, performing: {
			for try await num in stream {
				print(num)
			}
		})
		// need to delay to give the sending continuation a chance to loop around to attempt to send again.
		try await Task.sleep(for: .milliseconds(40))
		continuationShouldError.verify()
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func cancelViaStreamCallThrowingSimpleError() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		let continuationShouldError = DelayedExpectation()
		Task {
			var completedSending: [Int] = []
			do {
				for num in input {
					try await Task.sleep(for: .milliseconds(20))
					try continuation.yield(num)
					completedSending.append(num)
				}
				try continuation.finish()
			} catch {
				#expect(completedSending != input)
				continuationShouldError.fulfill()
			}
		}

		Task {
			try await Task.sleep(for: .milliseconds(19 * 3))
			stream.cancel(throwing: SimpleError(message: "Foo"))
		}

		await #expect(throws: SimpleError.self, performing: {
			for try await num in stream {
				print(num)
			}
		})
		// need to delay to give the sending continuation a chance to loop around to attempt to send again.
		try await Task.sleep(for: .milliseconds(40))
		continuationShouldError.verify()
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func cancelViaStreamCallNoThrowing() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		let continuationShouldError = DelayedExpectation()
		Task {
			var completedSending: [Int] = []
			do {
				for num in input {
					try await Task.sleep(for: .milliseconds(20))
					try continuation.yield(num)
					completedSending.append(num)
				}
				try continuation.finish()
			} catch {
				#expect(completedSending != input)
				continuationShouldError.fulfill()
			}
		}

		Task {
			try await Task.sleep(for: .milliseconds(19 * 3))
			stream.cancel(throwing: nil)
		}

		var out: [Int] = []

		for try await num in stream {
			out.append(num)
		}

		#expect(out != input)
		// need to delay to give the sending continuation a chance to loop around to attempt to send again.
		try await Task.sleep(for: .milliseconds(40))
		continuationShouldError.verify()
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func slowRead() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		Task {
			for num in input {
				try continuation.yield(num)
			}
			try continuation.finish()
		}

		var out: [Int] = []

		for try await num in stream {
			try await Task.sleep(for: .milliseconds(20))
			out.append(num)
		}

		#expect(input == out)
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func slowThenFastRead() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		Task {
			for num in input {
				try await Task.sleep(for: .milliseconds(20))
				try continuation.yield(num)
			}
			try continuation.finish()
		}

		var out: [Int] = []

		for try await num in stream {
			let delay = num < 4 ? 40 : 10
			try await Task.sleep(for: .milliseconds(delay))
			out.append(num)
		}

		#expect(input == out)
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func fastThenSlowFeed() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		Task {
			for num in input {
				let delay = num < 10 ? 5 : 40
				try await Task.sleep(for: .milliseconds(delay))
				try continuation.yield(num)
			}
			try continuation.finish()
		}

		var out: [Int] = []

		for try await num in stream {
			try await Task.sleep(for: .milliseconds(30))
			out.append(num)
		}

		#expect(input == out)
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func bufferOverrunFail() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(bufferingPolicy: .limited(10), errorOnCancellation: CancellationError())

		Task {
			for num in input {
				let yieldResult = try continuation.yield(num)

				if case .dropped(let value) = yieldResult {
					while case .dropped = try continuation.yield(value) {
						try await Task.sleep(for: .milliseconds(5))
					}
				}
			}
			try continuation.finish()
		}

		var out: [Int] = []

		try await Task.sleep(for: .milliseconds(10))
		for try await num in stream {
			out.append(num)
		}

		#expect(input == out)
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func whileLoop() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		Task {
			for num in input {
				try await Task.sleep(for: .milliseconds(20))
				try continuation.yield(num)
			}
			try continuation.finish()
		}

		var out: [Int] = []

		var iterator = stream.makeAsyncIterator()
		while let num = try await iterator.next() {
			out.append(num)
		}

		#expect(input == out)
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func whileLoopTaskCancelled() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		Task {
			for num in input {
				try await Task.sleep(for: .milliseconds(20))
				try continuation.yield(num)
			}
			try continuation.finish()
		}

		let toStop = Task {
			var out: [Int] = []

			var iterator = stream.makeAsyncIterator()
			while let num = try await iterator.next() {
				out.append(num)
				print(num)
			}

			return out
		}

		Task {
			try await Task.sleep(for: .milliseconds(19 * 3))
			toStop.cancel()
		}

		await #expect(throws: CancellationError.self, performing: {
			_ = try await toStop.value
		})
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func whileLoopStreamCancelled() async throws {
		let input = (0..<20).map { $0 }
		let (stream, continuation) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		Task {
			for num in input {
				try await Task.sleep(for: .milliseconds(20))
				try continuation.yield(num)
			}
			try continuation.finish()
		}

		let toStop = Task {
			var out: [Int] = []

			var iterator = stream.makeAsyncIterator()
			while let num = try await iterator.next() {
				out.append(num)
				print(num)
			}

			return out
		}

		Task {
			try await Task.sleep(for: .milliseconds(19 * 3))
			stream.cancel()
		}

		await #expect(throws: CancellationError.self, performing: {
			try await toStop.value
		})
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func finishCancelled() async throws {
		let stream = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError()).stream

		await confirmation { finishExpectation in
			stream.onFinish {
				guard $0.finishedOrCancelledError is CancellationError else { return }
				finishExpectation()
			}
			stream.cancel()
		}
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func finishThrown() async throws {
		let (stream, cont) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		try await confirmation { finishExpectation in
			stream.onFinish {
				guard $0.finishedOrCancelledError is SimpleError else { return }
				finishExpectation()
			}

			try cont.finish(throwing: SimpleError(message: "Foo"))
		}
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func finishClean() async throws {
		let (stream, cont) = AsyncCancellableThrowingStream<Int, Error>.makeStream(errorOnCancellation: CancellationError())

		try await confirmation { finishExpectation in
			stream.onFinish {
				guard $0.finishedOrCancelledError == nil else { return }
				finishExpectation()
			}

			try cont.finish()
		}
	}
}
