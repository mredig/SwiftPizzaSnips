import Testing
import SwiftPizzaSnips

struct ContinuationProxyTests {
	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	@Test func continuationFirstCustomErrorSuccess() async throws {
		let continuationProxy = ContinuationProxy<Int, AnError>()

		#expect(continuationProxy.needsResult == true)
		#expect(continuationProxy.needsContinuation == true)
		#expect(continuationProxy.hasCompleted == false)

		let result = try await withUnsafeThrowingContinuation { continuation in
			continuationProxy.setContinuation(continuation)
			#expect(continuationProxy.needsResult == true)
			#expect(continuationProxy.needsContinuation == false)
			#expect(continuationProxy.hasCompleted == false)

			Task {
				try await Task.sleep(for: .seconds(0.1))
				continuationProxy.resume(returning: 5)
				#expect(continuationProxy.needsResult == false)
				#expect(continuationProxy.needsContinuation == false)
				#expect(continuationProxy.hasCompleted == true)
			}
		}

		#expect(continuationProxy.needsResult == false)
		#expect(continuationProxy.needsContinuation == false)
		#expect(continuationProxy.hasCompleted == true)
		#expect(result == 5)
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	@Test func resultFirstCustomErrorSuccess() async throws {
		let continuationProxy = ContinuationProxy<Int, AnError>()

		#expect(continuationProxy.needsResult == true)
		#expect(continuationProxy.needsContinuation == true)
		#expect(continuationProxy.hasCompleted == false)

		let result = try await withUnsafeThrowingContinuation { continuation in
			continuationProxy.resume(returning: 10)
			#expect(continuationProxy.needsResult == false)
			#expect(continuationProxy.needsContinuation == true)
			#expect(continuationProxy.hasCompleted == false)

			Task {
				try await Task.sleep(for: .seconds(0.1))
				continuationProxy.setContinuation(continuation)
				#expect(continuationProxy.needsResult == false)
				#expect(continuationProxy.needsContinuation == false)
				#expect(continuationProxy.hasCompleted == true)
			}
		}

		#expect(continuationProxy.needsResult == false)
		#expect(continuationProxy.needsContinuation == false)
		#expect(continuationProxy.hasCompleted == true)
		#expect(result == 10)
	}


	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	@Test func continuationFirstCustomErrorFailure() async throws {
		let continuationProxy = ContinuationProxy<Int, AnError>()

		#expect(continuationProxy.needsResult == true)
		#expect(continuationProxy.needsContinuation == true)
		#expect(continuationProxy.hasCompleted == false)

		await #expect(throws: AnError.self, performing: {
			_ = try await withUnsafeThrowingContinuation { continuation in
				continuationProxy.setContinuation(continuation)
				#expect(continuationProxy.needsResult == true)
				#expect(continuationProxy.needsContinuation == false)
				#expect(continuationProxy.hasCompleted == false)

				Task {
					try await Task.sleep(for: .seconds(0.1))
					continuationProxy.resume(throwing: AnError())
					#expect(continuationProxy.needsResult == false)
					#expect(continuationProxy.needsContinuation == false)
					#expect(continuationProxy.hasCompleted == true)
				}
			}
		})

		#expect(continuationProxy.needsResult == false)
		#expect(continuationProxy.needsContinuation == false)
		#expect(continuationProxy.hasCompleted == true)
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	@Test func resultFirstCustomErrorFailure() async throws {
		let continuationProxy = ContinuationProxy<Int, AnError>()

		#expect(continuationProxy.needsResult == true)
		#expect(continuationProxy.needsContinuation == true)
		#expect(continuationProxy.hasCompleted == false)

		await #expect(throws: AnError.self, performing: {
			_ = try await withUnsafeThrowingContinuation { continuation in
				continuationProxy.resume(throwing: AnError())
				#expect(continuationProxy.needsResult == false)
				#expect(continuationProxy.needsContinuation == true)
				#expect(continuationProxy.hasCompleted == false)

				Task {
					try await Task.sleep(for: .seconds(0.1))
					continuationProxy.setContinuation(continuation)
					#expect(continuationProxy.needsResult == false)
					#expect(continuationProxy.needsContinuation == false)
					#expect(continuationProxy.hasCompleted == true)
				}
			}
		})

		#expect(continuationProxy.needsResult == false)
		#expect(continuationProxy.needsContinuation == false)
		#expect(continuationProxy.hasCompleted == true)
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	@Test func resultFirstCustomErrorMultipleResultInvocationsIgnored() async throws {
		let continuationProxy = ContinuationProxy<Int, AnError>()

		#expect(continuationProxy.needsResult == true)
		#expect(continuationProxy.needsContinuation == true)
		#expect(continuationProxy.hasCompleted == false)

		let result = try await withUnsafeThrowingContinuation { continuation in
			continuationProxy.resume(returning: 10)
			continuationProxy.resume(returning: 9)
			continuationProxy.resume(returning: 8)

			#expect(continuationProxy.needsResult == false)
			#expect(continuationProxy.needsContinuation == true)
			#expect(continuationProxy.hasCompleted == false)

			Task {
				try await Task.sleep(for: .seconds(0.1))
				continuationProxy.setContinuation(continuation)
				#expect(continuationProxy.needsResult == false)
				#expect(continuationProxy.needsContinuation == false)
				#expect(continuationProxy.hasCompleted == true)

				continuationProxy.resume(returning: 7)
				continuationProxy.resume(returning: 6)
			}
		}

		#expect(continuationProxy.needsResult == false)
		#expect(continuationProxy.needsContinuation == false)
		#expect(continuationProxy.hasCompleted == true)
		#expect(result == 10)
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	@Test func resultFirstCustomErrorMultipleContinuationInvocationsIgnored() async throws {
		let continuationProxy = ContinuationProxy<Int, AnError>()

		#expect(continuationProxy.needsResult == true)
		#expect(continuationProxy.needsContinuation == true)
		#expect(continuationProxy.hasCompleted == false)

		let result = try await withUnsafeThrowingContinuation { continuation in
			continuationProxy.resume(returning: 10)

			#expect(continuationProxy.needsResult == false)
			#expect(continuationProxy.needsContinuation == true)
			#expect(continuationProxy.hasCompleted == false)

			Task {
				try await Task.sleep(for: .seconds(0.1))
				continuationProxy.setContinuation(continuation)
				continuationProxy.setContinuation(continuation)
				#expect(continuationProxy.needsResult == false)
				#expect(continuationProxy.needsContinuation == false)
				#expect(continuationProxy.hasCompleted == true)

				continuationProxy.setContinuation(continuation)
				continuationProxy.setContinuation(continuation)
			}
		}

		#expect(continuationProxy.needsResult == false)
		#expect(continuationProxy.needsContinuation == false)
		#expect(continuationProxy.hasCompleted == true)
		#expect(result == 10)
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	@Test func resultFirstCustomErrorMultipleBothInvocationsIgnored() async throws {
		let continuationProxy = ContinuationProxy<Int, AnError>()

		#expect(continuationProxy.needsResult == true)
		#expect(continuationProxy.needsContinuation == true)
		#expect(continuationProxy.hasCompleted == false)

		let result = try await withUnsafeThrowingContinuation { continuation in
			continuationProxy.resume(returning: 10)
			continuationProxy.resume(returning: 9)
			continuationProxy.resume(returning: 8)

			#expect(continuationProxy.needsResult == false)
			#expect(continuationProxy.needsContinuation == true)
			#expect(continuationProxy.hasCompleted == false)

			Task {
				try await Task.sleep(for: .seconds(0.1))
				continuationProxy.setContinuation(continuation)
				continuationProxy.setContinuation(continuation)
				#expect(continuationProxy.needsResult == false)
				#expect(continuationProxy.needsContinuation == false)
				#expect(continuationProxy.hasCompleted == true)

				continuationProxy.setContinuation(continuation)
				continuationProxy.resume(returning: 7)
				continuationProxy.setContinuation(continuation)
				continuationProxy.resume(returning: 6)
			}
		}

		#expect(continuationProxy.needsResult == false)
		#expect(continuationProxy.needsContinuation == false)
		#expect(continuationProxy.hasCompleted == true)
		#expect(result == 10)
	}

	struct AnError: Error {}
}
