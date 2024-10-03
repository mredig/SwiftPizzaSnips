import Foundation

public struct TestError: LocalizedError {
	public let message: String?

	init(message: String? = nil) {
		self.message = message
	}

	public static let fail = TestError()
	public static func fail(_ message: String? = nil) -> TestError {
		TestError(message: message)
	}

	public var errorDescription: String? { message ?? "Test failed" }
}
