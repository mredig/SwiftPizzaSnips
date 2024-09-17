import XCTest
import SwiftPizzaSnips

final class ScanningIteratorTests: XCTestCase {

	let sequence = [1, 4, 56, 7]

	func testScanningIteratorForward() throws {
		var scanningIterator = sequence.scanningIterator

		XCTAssertEqual(scanningIterator.scan(), 1)
		XCTAssertEqual(scanningIterator.scan(), 4)
		XCTAssertEqual(scanningIterator.scan(), 56)
		XCTAssertEqual(scanningIterator.scan(), 7)
		XCTAssertEqual(scanningIterator.scan(), nil)
	}

	func testScanningForwardAndBackward() throws {
		var scanningIterator = sequence.scanningIterator

		XCTAssertEqual(scanningIterator.scan(), 1)
		XCTAssertEqual(scanningIterator.scan(), 4)
		XCTAssertEqual(scanningIterator.scan(), 56)
		XCTAssertEqual(scanningIterator.scanPrevious(), 56)
		XCTAssertEqual(scanningIterator.scanPrevious(), 4)
		XCTAssertEqual(scanningIterator.scan(), 4)
		XCTAssertEqual(scanningIterator.scan(), 56)
		XCTAssertEqual(scanningIterator.scan(), 7)
	}

	func testScanAndPeek() throws {
		var scanningIterator = sequence.scanningIterator

		XCTAssertEqual(scanningIterator.scan(), 1)
		XCTAssertEqual(scanningIterator.peek(), 4)
		XCTAssertEqual(scanningIterator.peek(), 4)
		XCTAssertEqual(scanningIterator.scan(), 4)
		XCTAssertEqual(scanningIterator.scan(), 56)
		XCTAssertEqual(scanningIterator.peekPrevious(), 56)
		XCTAssertEqual(scanningIterator.peekPrevious(), 56)
		XCTAssertEqual(scanningIterator.peekPrevious(), 56)
		XCTAssertEqual(scanningIterator.scan(), 7)
	}

	func testScanningUpToSomething() throws {
		var scanningIterator = sequence.scanningIterator

		XCTAssertEqual(scanningIterator.scan(upTo: 56), [1, 4])
		XCTAssertEqual(scanningIterator.peekPrevious(), 4)
		XCTAssertEqual(scanningIterator.peek(), 56)
		XCTAssertEqual(scanningIterator.scan(upTo: 100), [56, 7])
	}

	func testScanningAtEnds() throws {
		var scanningIterator = sequence.scanningIterator

		XCTAssertEqual(scanningIterator.peekPrevious(), nil)
		XCTAssertEqual(scanningIterator.scanPrevious(), nil)
		XCTAssertEqual(scanningIterator.scan(upTo: 100), [1, 4, 56, 7])
		XCTAssertEqual(scanningIterator.peek(), nil)
		XCTAssertEqual(scanningIterator.scan(), nil)
	}
}
