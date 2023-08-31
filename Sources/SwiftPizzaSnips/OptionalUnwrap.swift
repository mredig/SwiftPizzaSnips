import Foundation

public extension Optional {
	func unwrap() throws -> Wrapped {
		guard case .some(let wrapped) = self else {
			throw OptionalError.nilValue(ofType: Wrapped.self)
		}
		return wrapped
	}

	enum OptionalError: Error {
		case nilValue(ofType: Wrapped.Type)
	}
}
