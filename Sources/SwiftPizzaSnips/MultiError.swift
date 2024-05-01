import Foundation

public struct MultiError: Error, ExpressibleByArrayLiteral {
	public var errors: [Error]

	public init(arrayLiteral elements: Error...) {
		self.init(errors: elements)
	}

	public init(errors: [Error]) {
		self.errors = errors
	}
}

extension MultiError: CustomStringConvertible {
	public var description: String {
		"MultiError: There were \(errors.count) errors"
	}
}

extension MultiError: CustomDebugStringConvertible {
	public var debugDescription: String {
		let debugDescriptions = errors
			.map {
				let customDebug = $0 as CustomDebugStringConvertible
				return customDebug.debugDescription
			}
		return "MultiError: There were \(errors.count) errors: \(debugDescriptions.joined(separator: "\n\n"))"
	}
}

extension MultiError: LocalizedError {
	public var failureReason: String? {
		errors
			.map {
				guard
					let localized = $0 as? LocalizedError,
					let failureReason = localized.failureReason
				else { return "Unknown Failure Reason" }
				return failureReason
			}
			.joined(separator: "\n\n")
	}

	public var helpAnchor: String? {
		errors
			.map {
				guard
					let localized = $0 as? LocalizedError,
					let helpAnchor = localized.helpAnchor
				else { return "No help available" }
				return helpAnchor
			}
			.joined(separator: "\n\n")
	}

	public var recoverySuggestion: String? {
		errors
			.map {
				guard
					let localized = $0 as? LocalizedError,
					let recoverySuggestion = localized.recoverySuggestion
				else { return "No recovery suggestion" }
				return recoverySuggestion
			}
			.joined(separator: "\n\n")
	}
}
