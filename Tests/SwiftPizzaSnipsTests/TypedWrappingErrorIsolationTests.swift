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

	// MARK: - Edge Cases

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
