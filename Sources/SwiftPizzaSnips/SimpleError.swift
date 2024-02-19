import Foundation

/// For scenarios where creating a specialized error type is overkill. However, in the event that an alert is ever shown to 
/// the user, you may provide an optional `userRecoverSuggestion` to help guide the user to a solution. Otherwise,
/// the default recovery suggestion is for the user to take a screenshot and send it to the developer (you). This should
/// both discourage you from using this *all* the time as you should instead try to recover from errors in your logic, but in
/// the event that an error *is* displayed to an end user, help you prioritize which bugs/issues are the most important as
/// only the users who care the most will reach out.
public struct SimpleError: Error {
	public let message: String
	public let userRecoverySuggestion: String?
	public let line: Int
	public let function: String
	public let file: String

	public init(message: String, userRecoverySuggestion: String? = nil, line: Int = #line, function: String = #function, file: String = #fileID) {
		self.message = message
		self.userRecoverySuggestion = userRecoverySuggestion
		self.line = line
		self.function = function
		self.file = file
	}
}

extension SimpleError: CustomStringConvertible {
	public var description: String { "SimpleError: '\(message)'" }
}

extension SimpleError: CustomDebugStringConvertible, LocalizedError {
	public var debugDescription: String { "SimpleError: '\(message)' in \(file):\(line) - \(function)" }

	public var errorDescription: String? { description }

	public var failureReason: String? { debugDescription }

	public var helpAnchor: String? { description }

	public var recoverySuggestion: String? {
		userRecoverySuggestion ??
		"Please provide the developer with a screenshot of this error. \(file):\(line) \(function)"
	}
}
