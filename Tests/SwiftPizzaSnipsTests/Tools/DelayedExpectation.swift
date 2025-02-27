import Testing
import Foundation

/// Swift Testing only supports async expectations via a closure like `await confirmation { fulfillment in fulfillment() }`.
/// This class is a simple workaround to instead allow the fulfillment object to exist on the top level of the method, get called wherever async,
/// then manually verified that it completed before the test is completed.
class DelayedExpectation {
	private let lock = NSLock()

	private var _expectedCompletionFulfillment = 1..<2
	public var expectedCompletionFulfillment: Range<Int> {
		get { lock.withLock { _expectedCompletionFulfillment } }
		set { lock.withLock { _expectedCompletionFulfillment = newValue } }
	}

	private var completed = 0

	public func fulfill(fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
		lock.withLock {
			completed += 1

			if _expectedCompletionFulfillment.upperBound <= completed {
				Issue.record(
					"Overfulfillment of expectation",
					sourceLocation: SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column))
			}
		}
	}

	public func verify(fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
		lock.withLock {
			guard _expectedCompletionFulfillment.contains(completed) else {
				Issue.record(
					"Mismatched fulfillment of expectation. Fulfilled \(completed) time(s), but should have completed \(_expectedCompletionFulfillment) time(s).",
					sourceLocation: SourceLocation(
						fileID: fileID,
						filePath: filePath,
						line: line,
						column: column))
				return
			}
		}
	}
}
