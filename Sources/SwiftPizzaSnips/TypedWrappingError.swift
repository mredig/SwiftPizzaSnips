/// A protocol for creating type-safe error wrappers that preserve underlying errors while adding domain-specific context.
///
/// `TypedWrappingError` enables you to wrap generic errors (like `URLError`, `NSError`, or custom errors)
/// into domain-specific error types with rich contextual information. This is particularly useful for:
/// - Adding call-site context (URLs, file paths, operation names) to generic errors
/// - Converting third-party errors into your application's error domain
/// - Preserving error chains for debugging while presenting structured errors to callers
///
/// ## Recommended Pattern: Enum-Based Errors
///
/// The most flexible implementation uses an enum with associated values:
///
/// ```swift
/// enum NetworkError: TypedWrappingError {
///     case connectivityIssue(URL, underlying: Error)
///     case invalidResponse(URL, underlying: Error)
///     case timeout(URL, duration: TimeInterval, underlying: Error)
///     case other(underlying: Error)  // Fallback case
///
///     typealias Context = URL
///
///     static func wrap(_ anyError: Error) -> Self {
///         .other(underlying: anyError)
///     }
///
///     static func wrap(_ anyError: Error, context: URL) -> Self {
///         .connectivityIssue(context, underlying: anyError)
///     }
/// }
/// ```
///
/// ## Usage with `captureAnyError`
///
/// Use the `captureAnyError` function to wrap errors at call sites:
///
/// ```swift
/// let url = URL(string: "https://api.example.com/data")!
/// let data: Data = try await captureAnyError(
///     errorType: NetworkError.self,
///     {
///         try await URLSession.shared.data(from: url).0
///     },
///     errorContextualization: { _ in url }  // Provide context from call site
/// )
/// ```
///
/// If a `NetworkError` is thrown inside the closure, it passes through unchanged.
/// Other errors are wrapped using `NetworkError.wrap(_:context:)`.
public protocol TypedWrappingError: Error {
	associatedtype Context

	static func wrap(_ anyError: Error) -> Self
	static func wrap(_ anyError: Error, context: Context) -> Self
}

/// Default implementation for errors that don't require additional context.
public extension TypedWrappingError where Context == Void {
	static func wrap(_ anyError: Error, context: Context) -> Self {
		wrap(anyError)
	}
}

/// Executes a throwing closure and wraps any errors into a specific `TypedWrappingError` type.
///
/// - Parameters:
///   - errorType: The error type to wrap into. Can usually be inferred.
///   - actionBlock: The throwing closure to execute.
///   - errorContextualization: Optional closure to provide context for error wrapping.
/// - Returns: The result of the action block.
/// - Throws: An error of type `E`. If the action block throws an `E`, it passes through unchanged.
///           Otherwise, the error is wrapped using `E.wrap(_:context:)` or `E.wrap(_:)`.
public func captureAnyError<T, E: TypedWrappingError>(
	errorType: E.Type = E.self,
	_ actionBlock: () throws -> T,
	errorContextualization: ((Error) -> E.Context)? = nil
) throws(E) -> T {
	do {
		return try actionBlock()
	} catch let error as E {
		throw error
	} catch {
		if let errorContextualization {
			let context = errorContextualization(error)
			throw E.wrap(error, context: context)
		} else {
			throw E.wrap(error)
		}
	}
}

/// Executes an async throwing closure and wraps any errors into a specific `TypedWrappingError` type.
///
/// - Parameters:
///   - isolation: The actor to isolate execution to. Defaults to `#isolation` (inherits caller's context).
///   - errorType: The error type to wrap into. Can usually be inferred.
///   - actionBlock: The async throwing closure to execute.
///   - errorContextualization: Optional closure to provide context for error wrapping.
/// - Returns: The result of the action block.
/// - Throws: An error of type `E`. If the action block throws an `E`, it passes through unchanged.
///           Otherwise, the error is wrapped using `E.wrap(_:context:)` or `E.wrap(_:)`.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public func captureAnyError<T, E: TypedWrappingError>(
	isolation actor: isolated (any Actor)? = #isolation,
	errorType: E.Type = E.self,
	_ actionBlock: @Sendable () async throws -> T,
	errorContextualization: ((Error) -> E.Context)? = nil
) async throws(E) -> T {
	do {
		return try await actionBlock()
	} catch let error as E {
		throw error
	} catch {
		if let errorContextualization {
			let context = errorContextualization(error)
			throw E.wrap(error, context: context)
		} else {
			throw E.wrap(error)
		}
	}
}
