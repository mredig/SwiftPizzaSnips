import Testing
import SwiftPizzaSnips

// MARK: - Test Error Types

enum TestError: Error {
	case basic
	case withValue(Int)
}

struct SimpleWrappingError: TypedWrappingError {
	typealias Context = Void

	let underlying: Error

	static func wrap(_ anyError: Error) -> SimpleWrappingError {
		SimpleWrappingError(underlying: anyError)
	}

	static func wrap(_ anyError: Error, context: Context) -> SimpleWrappingError {
		SimpleWrappingError(underlying: anyError)
	}
}

struct ContextualWrappingError: TypedWrappingError {
	typealias Context = String

	let underlying: Error
	let context: String

	static func wrap(_ anyError: Error) -> ContextualWrappingError {
		ContextualWrappingError(underlying: anyError, context: "default")
	}

	static func wrap(_ anyError: Error, context: String) -> ContextualWrappingError {
		ContextualWrappingError(underlying: anyError, context: context)
	}
}

// MARK: - Test Actors

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
actor TestActor {
	var counter = 0
	var executionLog: [String] = []

	func increment() {
		counter += 1
	}

	func log(_ message: String) {
		executionLog.append(message)
	}

	func reset() {
		counter = 0
		executionLog = []
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
@MainActor
class MainActorCounter {
	var value = 0

	func increment() {
		value += 1
	}
}

// MARK: - Isolation Tests
struct TypedWrappingErrorIsolationTests {

	// MARK: - Basic Functionality Tests

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testBasicErrorWrapping() async throws {
		await #expect(throws: SimpleWrappingError.self) {
			try await captureAnyError(errorType: SimpleWrappingError.self) {
				try await Task.sleep(for: .milliseconds(1))
				throw TestError.basic
			}
		}
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testContextualErrorWrapping() async throws {
		let error = try await #require(throws: ContextualWrappingError.self) {
			let _: Int = try await captureAnyError(
				errorType: ContextualWrappingError.self,
				{
					try await Task.sleep(for: .milliseconds(1))
					throw TestError.withValue(123)
				},
				errorContextualization: { _ in "custom context" }
			)
		}
		#expect(error.context == "custom context")
		#expect(error.underlying is TestError)
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testAlreadyWrappedErrorPassesThrough() async throws {
		let wrappedError = SimpleWrappingError(underlying: TestError.basic)

		let error = try await #require(throws: SimpleWrappingError.self) {
			let _: Int = try await captureAnyError(
				errorType: SimpleWrappingError.self,
				{
					try await Task.sleep(for: .milliseconds(1))
					throw wrappedError
				}
			)
		}
		// Verify it's the same error that was thrown, not re-wrapped
		#expect(error.underlying is TestError)
		// The error should pass through the catch block at line 43-44
		_ = error // Force use of the error to ensure line 43-44 is covered
	}

	// MARK: - Actor Isolation Tests

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testActorIsolationWithStateAccess() async throws {
		let actor = TestActor()

		// This demonstrates that the closure still needs `await` to access actor state
		// even when the function is isolated to the actor
		let result = try await captureAnyError(
			isolation: actor,
			errorType: SimpleWrappingError.self,
			{
				try await Task.sleep(for: .milliseconds(10))
				await actor.increment()
				return await actor.counter
			}
		)

		#expect(result == 1)
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testMultipleActorsDoNotShareIsolation() async throws {
		let actor1 = TestActor()
		let actor2 = TestActor()

		await actor1.increment()
		await actor1.increment()

		// Isolate to actor1
		let result1 = try await captureAnyError(
			isolation: actor1,
			errorType: SimpleWrappingError.self,
			{
				try await Task.sleep(for: .milliseconds(1))
				return await actor1.counter
			}
		)

		// Isolate to actor2
		let result2 = try await captureAnyError(
			isolation: actor2,
			errorType: SimpleWrappingError.self,
			{
				try await Task.sleep(for: .milliseconds(1))
				return await actor2.counter
			}
		)

		#expect(result1 == 2)
		#expect(result2 == 0)
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testActorIsolationWithErrors() async throws {
		let actor = TestActor()

		let error = try await #require(throws: ContextualWrappingError.self) {
			let _: Int = try await captureAnyError(
				isolation: actor,
				errorType: ContextualWrappingError.self,
				{
					try await Task.sleep(for: .milliseconds(10))
					await actor.log("before error")
					throw TestError.basic
				},
				errorContextualization: { _ in "from actor" }
			)
		}
		#expect(error.context == "from actor")
		let log = await actor.executionLog
		#expect(log == ["before error"])
	}

	// MARK: - MainActor Tests
	// REMOVED: testMainActorIsolation - Tautological test
	// Coverage provided by: testMainActorIsolationInheritance

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@MainActor
	@Test func testMainActorIsolationInheritance() async throws {
		let counter = MainActorCounter()

		// Called from MainActor context, should inherit isolation via #isolation
		// But @Sendable closure still needs await to access MainActor state
		let result = try await captureAnyError(
			errorType: SimpleWrappingError.self,
			{
				try await Task.sleep(for: .milliseconds(10))
				await counter.increment()
				return await counter.value
			}
		)

		#expect(result == 1)
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@MainActor
	@Test func testMainActorExplicitNilBreaksIsolation() async throws {
		let counter = MainActorCounter()

		// Explicitly pass nil to break out of MainActor isolation
		let result = try await captureAnyError(
			isolation: nil,
			errorType: SimpleWrappingError.self,
			{
				try await Task.sleep(for: .milliseconds(10))
				// Now we need await because we're not isolated anymore
				await counter.increment()
				return await counter.value
			}
		)

		#expect(result == 1)
	}

	// MARK: - Isolation Hopping Tests

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testIsolationHoppingBetweenActors() async throws {
		let actor1 = TestActor()
		let actor2 = TestActor()

		await actor1.log("initial")

		// Start on actor1
		let _: Void = try await captureAnyError(
			isolation: actor1,
			errorType: SimpleWrappingError.self,
			{
				try await Task.sleep(for: .milliseconds(5))
				await actor1.log("on actor1")
			}
		)

		// Hop to actor2
		let _: Void = try await captureAnyError(
			isolation: actor2,
			errorType: SimpleWrappingError.self,
			{
				try await Task.sleep(for: .milliseconds(5))
				await actor2.log("on actor2")
			}
		)

		// Back to actor1
		let _: Void = try await captureAnyError(
			isolation: actor1,
			errorType: SimpleWrappingError.self,
			{
				try await Task.sleep(for: .milliseconds(5))
				await actor1.log("back on actor1")
			}
		)

		let log1 = await actor1.executionLog
		let log2 = await actor2.executionLog

		#expect(log1 == ["initial", "on actor1", "back on actor1"])
		#expect(log2 == ["on actor2"])
	}

	// MARK: - Concurrency Tests

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testConcurrentExecutionNonIsolated() async throws {
		let actor = TestActor()

		// Execute multiple non-isolated calls concurrently
		await withTaskGroup(of: Void.self) { group in
			for i in 0..<10 {
				group.addTask {
					_ = try? await captureAnyError(
						isolation: nil,
						errorType: SimpleWrappingError.self,
						{
							try await Task.sleep(for: .milliseconds(10))
							await actor.log("task \(i)")
						}
					)
				}
			}
		}

		let log = await actor.executionLog
		#expect(log.count == 10)
		// Order is not guaranteed with non-isolated execution
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testSequentialExecutionWithSameIsolation() async throws {
		let actor = TestActor()

		// Execute multiple calls with same isolation
		for i in 0..<5 {
			let _: Void = try await captureAnyError(
				isolation: actor,
				errorType: SimpleWrappingError.self,
				{
					try await Task.sleep(for: .milliseconds(5))
					await actor.log("sequential \(i)")
					await actor.increment()
				}
			)
		}

		let counter = await actor.counter
		let log = await actor.executionLog

		#expect(counter == 5)
		#expect(log.count == 5)
	}

	// MARK: - Error Context Preservation Tests

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testErrorContextPreservedAcrossIsolation() async throws {
		let actor = TestActor()

		let error = try await #require(throws: ContextualWrappingError.self) {
			let _: Int = try await captureAnyError(
				isolation: actor,
				errorType: ContextualWrappingError.self,
				{
					try await Task.sleep(for: .milliseconds(5))
					throw TestError.withValue(999)
				},
				errorContextualization: { error in
					// Context can be computed based on the error
					if case .withValue(let val) = error as? TestError {
						return "value was \(val)"
					}
					return "unknown"
				}
			)
		}
		#expect(error.context == "value was 999")
	}

	// MARK: - Performance-Related Tests
	// REMOVED: testFastPathNoSuspension - Tautological test
	// REMOVED: testSlowPathWithSuspension - Tautological test
	// Performance characteristics are implicit in other tests

	// MARK: - Edge Cases

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testEmptyClosureSuccess() async throws {
		let result: Void = try await captureAnyError(
			errorType: SimpleWrappingError.self,
			{
				try await Task.sleep(for: .milliseconds(1))
			}
		)

		// Should compile and run without issues
		_ = result
	}

	@Test func testNestedCatureAnyError() async throws {
		let actor = TestActor()

		let result = try await captureAnyError(
			isolation: actor,
			errorType: SimpleWrappingError.self
		) {
			// Nested call with different isolation
			try await captureAnyError(
				isolation: nil,
				errorType: SimpleWrappingError.self,
				{
					try await Task.sleep(for: .milliseconds(5))
					return 42
				}
			)
		}

		#expect(result == 42)
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testNestedErrorWrapping() async throws {
		await #expect(throws: SimpleWrappingError.self) {
			try await captureAnyError(errorType: SimpleWrappingError.self) {
				// Inner call throws
				try await captureAnyError(errorType: ContextualWrappingError.self) {
					try await Task.sleep(for: .milliseconds(1))
					throw TestError.basic
				}
			}
		}
	}
}

// MARK: - Synchronous Version Tests

struct TypedWrappingErrorSyncTests {

	// REMOVED: testSyncBasicSuccess - Tautological test
	// Coverage provided by: testSyncErrorWrapping

	@Test func testSyncErrorWrapping() throws {
		#expect(throws: SimpleWrappingError.self) {
			try captureAnyError(errorType: SimpleWrappingError.self) {
				throw TestError.withValue(456)
			}
		}
	}

	@Test func testSyncWithContext() throws {
		let error = try #require(throws: ContextualWrappingError.self) {
			let _: Int = try captureAnyError(
				errorType: ContextualWrappingError.self,
				{ throw TestError.basic },
				errorContextualization: { _ in "sync context" }
			)
		}
		#expect(error.context == "sync context")
	}

	@Test func testSyncAlreadyWrappedErrorPassesThrough() throws {
		let wrappedError = SimpleWrappingError(underlying: TestError.basic)

		let error = try #require(throws: SimpleWrappingError.self) {
			let _: Int = try captureAnyError(
				errorType: SimpleWrappingError.self,
				{ throw wrappedError }
			)
		}
		#expect(error.underlying is TestError)
	}
}
