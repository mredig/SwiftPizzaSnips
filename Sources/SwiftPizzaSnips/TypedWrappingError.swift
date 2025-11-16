public protocol TypedWrappingError: Error {
	associatedtype Context

	static func wrap(_ anyError: Error) -> Self
	static func wrap(_ anyError: Error, context: Context) -> Self
}

public extension TypedWrappingError where Context == Void {
	static func wrap(_ anyError: Error, context: Context) -> Self {
		wrap(anyError)
	}
}

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
