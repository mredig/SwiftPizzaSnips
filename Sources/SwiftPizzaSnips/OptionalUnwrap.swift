import Foundation

public extension Optional {
	/// Often times it's much more convenient or clean to unwrap an optional by throwing
	func unwrap(_ messageOnFail: String? = nil, line: Int = #line, file: String = #file) throws -> Wrapped {
		guard case .some(let wrapped) = self else {
			throw OptionalError.nilValue(
				ofType: Wrapped.self,
				message: messageOnFail,
				line: line,
				file: file)
		}
		return wrapped
	}

	/// For when you are *absolutely* suere there's a value, or the state is so corrupt that it should just exit if
	/// this value doesn't exist.
	func unwrapOrFatalError(message: String, line: Int = #line, file: String = #file) -> Wrapped {
		guard case .some(let wrapped) = self else {
			fatalError("\(file):\(line) - \(message)")
		}

		return wrapped
	}

	// sourcery:localizedError
	enum OptionalError: Error {
		case nilValue(ofType: Wrapped.Type, message: String?, line: Int, file: String)
	}
}

extension Optional.OptionalError: CustomDebugStringConvertible, LocalizedError {
	public var debugDescription: String {
		switch self {
		case .nilValue(let type, let message, _, _):
			guard let message else {
				return "OptionalError.nilValue of \(type)"
			}
			return  "OptionalError.nilValue of \(type) - \(message)"
		}
	}

	public var errorDescription: String? { debugDescription }

	public var failureReason: String? { debugDescription }

	public var helpAnchor: String? { debugDescription }

	public var recoverySuggestion: String? { debugDescription }
}

