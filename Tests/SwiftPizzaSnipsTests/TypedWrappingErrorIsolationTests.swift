import Testing
import SwiftPizzaSnips
import Foundation

struct TypedWrappingErrorTests {

	// MARK: - Enum-Based Error Tests
	
	// These tests demonstrate the recommended pattern: using enums as TypedWrappingError types.
	// Enums provide type-safe, structured errors with rich contextual information.

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testEnumBasicWrapping() async throws {
		// Simplest case: wrap a generic error into a domain-specific enum
		// Without errorContextualization, falls back to the default wrap(_:) implementation
		let error = try await #require(throws: NetworkError.self) {
			let _: Data = try await captureAnyError(
				errorType: NetworkError.self,
				{
					try await Task.sleep(for: .milliseconds(1))
					throw TestError.basic  // Generic error
				}
			)
		}
		
		// Without contextualization, NetworkError uses .other as the fallback case
		if case .other(let underlying) = error {
			#expect(underlying is TestError)
		} else {
			Issue.record("Expected .other case")
		}
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testEnumWithContextFromCallSite() async throws {
		// Real-world pattern: the calling code knows what operation it was performing
		// and provides that context when wrapping errors
		let endpointURL = URL(string: "https://api.example.com/data")!

		let error = try await #require(throws: NetworkError.self) {
			let _: String = try await captureAnyError(
				errorType: NetworkError.self,
				{
					try await Task.sleep(for: .milliseconds(1))
					// Simulate a URLError or other generic networking error
					throw TestError.basic
				},
				errorContextualization: { _ in 
					// The calling code provides the URL it was trying to fetch
					// This context is captured from the call site, not the error itself
					endpointURL 
				}
			)
		}

		// With contextualization, the error gets wrapped with the provided URL
		if case .connectivityIssue(let url, let underlying) = error {
			#expect(url == endpointURL)
			#expect(underlying is TestError)
		} else {
			Issue.record("Expected connectivityIssue with context")
		}
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testEnumErrorWithRichContext() async throws {
		let testURL = URL(string: "https://api.example.com/users")!

		// Manually create a specific enum case to demonstrate structured errors
		let error = try await #require(throws: NetworkError.self) {
			let _: Data = try await captureAnyError(
				errorType: NetworkError.self,
				{
					try await Task.sleep(for: .milliseconds(1))
					// Throw a timeout case directly
					throw NetworkError.timeout(testURL, duration: 30.0, underlying: TestError.basic)
				}
			)
		}

		// The already-wrapped error should pass through
		if case .timeout(let url, let duration, let underlying) = error {
			#expect(url == testURL)
			#expect(duration == 30.0)
			#expect(underlying is TestError)
		} else {
			Issue.record("Expected timeout case to pass through")
		}
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testEnumErrorPreservesAllCaseData() async throws {
		let testURL = URL(string: "https://api.example.com/endpoint")!
		let statusCode = 500

		let error = try await #require(throws: NetworkError.self) {
			let _: Void = try await captureAnyError(
				errorType: NetworkError.self,
				{
					try await Task.sleep(for: .milliseconds(1))
					throw NetworkError.serverError(testURL, statusCode: statusCode, underlying: TestError.withValue(123))
				}
			)
		}

		// Verify all associated values are preserved
		if case .serverError(let url, let code, let underlying) = error {
			#expect(url == testURL)
			#expect(code == statusCode)
			if let testError = underlying as? TestError,
			   case .withValue(let value) = testError {
				#expect(value == 123)
			} else {
				Issue.record("Expected underlying TestError.withValue")
			}
		} else {
			Issue.record("Expected serverError case")
		}
	}


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
		#expect(error.underlying is TestError)
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

	@Test func testVoidContextProtocolExtension() throws {
		// This test specifically covers the protocol extension at line 8-11
		// which provides a default implementation of wrap(_:context:) for Context == Void
		let error = try #require(throws: SimpleWrappingError.self) {
			let _: Int = try captureAnyError(
				errorType: SimpleWrappingError.self,
				{ throw TestError.basic },
				errorContextualization: { _ in () }  // Explicitly pass Void context
			)
		}
		#expect(error.underlying is TestError)
	}
}

// MARK: - Test Error Types

enum TestError: Error {
	case basic
	case withValue(Int)
}

/// Example enum-based TypedWrappingError demonstrating the typical/expected pattern.
///
/// This enum wraps networking errors with rich, structured context:
/// - Specific cases for different error scenarios
/// - Associated values capture relevant details (URLs, status codes, durations)
/// - Underlying error is always preserved for debugging
/// - Fallback `.other` case for errors without context
enum NetworkError: TypedWrappingError {
	/// Connection failed to reach the server
	case connectivityIssue(URL, underlying: Error)
	
	/// Server returned invalid or unexpected response
	case invalidResponse(URL, underlying: Error)
	
	/// Request exceeded the timeout duration
	case timeout(URL, duration: TimeInterval, underlying: Error)
	
	/// Server returned an HTTP error status code
	case serverError(URL, statusCode: Int, underlying: Error)
	
	/// Fallback for errors without specific context
	case other(underlying: Error)

	/// The context type that call sites can provide
	typealias Context = URL

	/// Access the wrapped error from any case
	var underlying: Error {
		switch self {
		case .connectivityIssue(_, let error),
				.invalidResponse(_, let error),
				.timeout(_, _, let error),
				.serverError(_, _, let error),
				.other(let error):
			return error
		}
	}

	/// Extract the URL if this error has one
	var url: URL? {
		switch self {
		case .connectivityIssue(let url, _),
				.invalidResponse(let url, _),
				.timeout(let url, _, _),
				.serverError(let url, _, _):
			return url
		case .other:
			return nil
		}
	}

	/// Default wrapping without context - uses the fallback `.other` case
	static func wrap(_ anyError: Error) -> NetworkError {
		.other(underlying: anyError)
	}

	/// Wrapping with context from the call site - creates a `.connectivityIssue`
	static func wrap(_ anyError: Error, context: URL) -> NetworkError {
		.connectivityIssue(context, underlying: anyError)
	}
}

struct SimpleWrappingError: TypedWrappingError {
	typealias Context = Void

	let underlying: Error

	static func wrap(_ anyError: Error) -> SimpleWrappingError {
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
