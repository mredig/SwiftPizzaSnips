import Foundation

public extension Optional {
	func unwrap(line: Int = #line, file: String = #file) throws -> Wrapped {
		guard case .some(let wrapped) = self else {
			throw OptionalError.nilValue(ofType: Wrapped.self, line: line, file: file)
		}
		return wrapped
	}

	enum OptionalError: Error {
		case nilValue(ofType: Wrapped.Type, line: Int, file: String)
	}
}
