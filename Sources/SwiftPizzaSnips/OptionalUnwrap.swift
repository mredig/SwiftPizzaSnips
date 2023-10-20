import Foundation

public extension Optional {
	func unwrap(line: Int = #line, file: String = #file) throws -> Wrapped {
		guard case .some(let wrapped) = self else {
			throw OptionalError.nilValue(ofType: Wrapped.self, line: line, file: file)
		}
		return wrapped
	}

	// sourcery:localizedError
	enum OptionalError: Error {
		case nilValue(ofType: Wrapped.Type, line: Int, file: String)
	}
}

extension Optional.OptionalError: CustomDebugStringConvertible, LocalizedError {
	public var debugDescription: String {
		switch self {
		case .nilValue(let type, _, _): "OptionalError.nilValue of \(type)"
		}
	}

	public var errorDescription: String? { debugDescription }

	public var failureReason: String? { debugDescription }

	public var helpAnchor: String? { debugDescription }

	public var recoverySuggestion: String? { debugDescription }
}

