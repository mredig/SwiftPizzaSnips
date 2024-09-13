import XCTest
import SwiftPizzaSnips
#if canImport(AppKit)
import AppKit
#endif
#if canImport(RegexBuilder)
import RegexBuilder
#endif

@available(iOS 16, tvOS 16, watchOS 10, *)
final class SimpleErrorTests: XCTestCase {
	private static let suggestedRecovery = "You're holding it wrong"

	private static let isDebugRegex = Regex {
		"SimpleError"
		ZeroOrMore {
			/./
		}
		"\(#fileID)"
	}

	private static let isDefaultUserRecoveryRegex = Regex {
		"Please provide the developer"
		ZeroOrMore {
			/./
		}
		"\(#fileID)"
	}

	private static let isSuggestedUserRecoveryRegex = Regex {
		"\(suggestedRecovery)"
	}

	func testDebugInfoAppearsWhereExpectedNoUserSuggestion() {
		do {
			throw SimpleError(message: "Sample")
		} catch {
			let shouldNotBeDebug = "\(error)"
			var shouldBeDebug = ""
			debugPrint(error, to: &shouldBeDebug)

			XCTAssertEqual(shouldNotBeDebug.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(shouldBeDebug.matches(of: Self.isDebugRegex).count, 1)

			guard let localError = error as? LocalizedError else {
				XCTFail()
				return
			}

			XCTAssertEqual(localError.errorDescription?.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(localError.failureReason?.matches(of: Self.isDebugRegex).count, 1)
			XCTAssertEqual(localError.helpAnchor?.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(localError.recoverySuggestion?.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(localError.recoverySuggestion?.matches(of: Self.isDefaultUserRecoveryRegex).count, 1)
			XCTAssertEqual(localError.recoverySuggestion?.matches(of: Self.isSuggestedUserRecoveryRegex).count, 0)

			let debugError = error as CustomDebugStringConvertible

			XCTAssertEqual(debugError.debugDescription.matches(of: Self.isDebugRegex).count, 1)

			return
		}
	}

	func testDebugInfoAppearsWhereExpectedWithUserSuggestion() {
		do {
			throw SimpleError(message: "Sample", userRecoverySuggestion: Self.suggestedRecovery)
		} catch {
			let shouldNotBeDebug = "\(error)"
			var shouldBeDebug = ""
			debugPrint(error, to: &shouldBeDebug)

			XCTAssertEqual(shouldNotBeDebug.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(shouldBeDebug.matches(of: Self.isDebugRegex).count, 1)

			guard let localError = error as? LocalizedError else {
				XCTFail()
				return
			}

			XCTAssertEqual(localError.errorDescription?.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(localError.failureReason?.matches(of: Self.isDebugRegex).count, 1)
			XCTAssertEqual(localError.helpAnchor?.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(localError.recoverySuggestion?.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(localError.recoverySuggestion?.matches(of: Self.isDefaultUserRecoveryRegex).count, 0)
			XCTAssertEqual(localError.recoverySuggestion?.matches(of: Self.isSuggestedUserRecoveryRegex).count, 1)

			let debugError = error as CustomDebugStringConvertible

			XCTAssertEqual(debugError.debugDescription.matches(of: Self.isDebugRegex).count, 1)

			return
		}
	}

	#if canImport(AppKit) && !targetEnvironment(macCatalyst)
	func testAlertConversionNoSuggestion() throws {
		do {
			throw SimpleError(message: "Sample")
		} catch {
			let alert = NSAlert(error: error)

			XCTAssertEqual(alert.messageText.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(alert.informativeText.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(alert.informativeText.matches(of: Self.isDefaultUserRecoveryRegex).count, 1)
			XCTAssertEqual(alert.informativeText.matches(of: Self.isSuggestedUserRecoveryRegex).count, 0)
		}
	}

	func testAlertConversionWithSuggestion() throws {
		do {
			throw SimpleError(message: "Sample", userRecoverySuggestion: Self.suggestedRecovery)
		} catch {
			let alert = NSAlert(error: error)

			XCTAssertEqual(alert.messageText.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(alert.informativeText.matches(of: Self.isDebugRegex).count, 0)
			XCTAssertEqual(alert.informativeText.matches(of: Self.isDefaultUserRecoveryRegex).count, 0)
			XCTAssertEqual(alert.informativeText.matches(of: Self.isSuggestedUserRecoveryRegex).count, 1)		}
	}
	#endif
}
