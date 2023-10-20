import Foundation

public struct SimpleError: Error {
	public let message: String

	public init(message: String) {
		self.message = message
	}
}

extension SimpleError: CustomDebugStringConvertible, LocalizedError {
	public var debugDescription: String { "SimpleError: '\(message)'" }

	public var errorDescription: String? { debugDescription }

	public var failureReason: String? { debugDescription }

	public var helpAnchor: String? { debugDescription }

	public var recoverySuggestion: String? { debugDescription }
}
