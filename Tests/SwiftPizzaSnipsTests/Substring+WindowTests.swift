import XCTest
import SwiftPizzaSnips

final class SubstringWindowTests: XCTestCase {
	private let string = "abcdefghijklmnopqrstuvwxyz 1234567890"
	private lazy var startRange: Range<String.Index> = {
		string.index(string.startIndex, offsetBy: 10)..<string.index(string.startIndex, offsetBy: 20)
	}()

	func testSubstringWindowAdvancingForward() throws {
		let sub = string[startRange]

		let forward1 = try sub.advancingWindow()
		XCTAssertEqual("lmnopqrstu", forward1)

		let forward4 = try sub.advancingWindow(count: 4)
		XCTAssertEqual("opqrstuvwx", forward4)

		// uses previous result
		let forward5 = try forward4.advancingWindow()
		XCTAssertEqual("pqrstuvwxy", forward5)

		XCTAssertNoThrow(try sub.advancingWindow(count: 17))
		XCTAssertThrowsError(try sub.advancingWindow(count: 18))
		XCTAssertThrowsError(try sub.advancingWindow(count: 19))
	}

	func testSubstringWindowAdvancingBackward() throws {
		let sub = string[startRange]

		let backward1 = try sub.advancingWindow(count: -1)
		XCTAssertEqual("jklmnopqrs", backward1)

		let backward4 = try sub.advancingWindow(count: -4)
		XCTAssertEqual("ghijklmnop", backward4)

		// uses previous result
		let backward5 = try backward4.advancingWindow(count: -1)
		XCTAssertEqual("fghijklmno", backward5)

		XCTAssertNoThrow(try sub.advancingWindow(count: -10))
		XCTAssertThrowsError(try sub.advancingWindow(count: -11))
		XCTAssertThrowsError(try sub.advancingWindow(count: -12))
	}

	func testSubstringWindowAdvanceForward() throws {
		var sub = string[startRange]

		try sub.advanceWindow()
		XCTAssertEqual("lmnopqrstu", sub)

		try sub.advanceWindow(count: 4)
		XCTAssertEqual("pqrstuvwxy", sub)

		XCTAssertNoThrow(try sub.advanceWindow(count: 12))
		XCTAssertEqual("1234567890", sub)
		XCTAssertThrowsError(try sub.advanceWindow())
		XCTAssertEqual("1234567890", sub)
		XCTAssertThrowsError(try sub.advanceWindow())
		XCTAssertEqual("1234567890", sub)
	}

	func testSubstringWindowAdvanceBackward() throws {
		var sub = string[startRange]

		try sub.advanceWindow(count: -1)
		XCTAssertEqual("jklmnopqrs", sub)

		try sub.advanceWindow(count: -4)
		XCTAssertEqual("fghijklmno", sub)

		XCTAssertNoThrow(try sub.advanceWindow(count: -5))
		XCTAssertEqual("abcdefghij", sub)
		XCTAssertThrowsError(try sub.advanceWindow(count: -1))
		XCTAssertEqual("abcdefghij", sub)
		XCTAssertThrowsError(try sub.advanceWindow(count: -1))
		XCTAssertEqual("abcdefghij", sub)
	}

	func testSubstringWindowAdvancingUpperBoundForward() throws {
		let sub = string[startRange]

		let upForward1 = try sub.advancingUpperBound()
		XCTAssertEqual("klmnopqrstu", upForward1)

		let upForward4 = try sub.advancingUpperBound(count: 4)
		XCTAssertEqual("klmnopqrstuvwx", upForward4)

		// uses previous result
		let upForward5 = try upForward4.advancingUpperBound()
		XCTAssertEqual("klmnopqrstuvwxy", upForward5)

		XCTAssertNoThrow(try sub.advancingUpperBound(count: 17))
		XCTAssertThrowsError(try sub.advancingUpperBound(count: 18))
		XCTAssertThrowsError(try sub.advancingUpperBound(count: 19))
	}

	func testSubstringWindowAdvancingUpperBoundBackward() throws {
		let sub = string[startRange]

		let stepping1 = try sub.advancingUpperBound(count: -1)
		XCTAssertEqual("klmnopqrs", stepping1)

		let stepping4 = try sub.advancingUpperBound(count: -4)
		XCTAssertEqual("klmnop", stepping4)

		// uses previous result
		let stepping5 = try stepping4.advancingUpperBound(count: -1)
		XCTAssertEqual("klmno", stepping5)

		XCTAssertNoThrow(try sub.advancingUpperBound(count: -10))
		XCTAssertThrowsError(try sub.advancingUpperBound(count: -11))
		XCTAssertThrowsError(try sub.advancingUpperBound(count: -12))
	}

	func testSubstringWindowAdvancingLowerBoundForward() throws {
		let sub = string[startRange]

		let stepping1 = try sub.advancingLowerBound()
		XCTAssertEqual("lmnopqrst", stepping1)

		let stepping4 = try sub.advancingLowerBound(count: 4)
		XCTAssertEqual("opqrst", stepping4)

		// uses previous result
		let stepping5 = try stepping4.advancingLowerBound()
		XCTAssertEqual("pqrst", stepping5)

		XCTAssertNoThrow(try sub.advancingLowerBound(count: 10))
		XCTAssertThrowsError(try sub.advancingLowerBound(count: 11))
		XCTAssertThrowsError(try sub.advancingLowerBound(count: 12))
	}

	func testSubstringWindowAdvancingLowerBoundBackward() throws {
		let sub = string[startRange]

		let stepping1 = try sub.advancingLowerBound(count: -1)
		XCTAssertEqual("jklmnopqrst", stepping1)

		let stepping4 = try sub.advancingLowerBound(count: -4)
		XCTAssertEqual("ghijklmnopqrst", stepping4)

		// uses previous result
		let stepping5 = try stepping4.advancingLowerBound(count: -1)
		XCTAssertEqual("fghijklmnopqrst", stepping5)

		XCTAssertNoThrow(try sub.advancingLowerBound(count: -10))
		XCTAssertThrowsError(try sub.advancingLowerBound(count: -11))
		XCTAssertThrowsError(try sub.advancingLowerBound(count: -12))
	}

	func testSubstringWindowAdvanceToEnd() throws {
		let sub = string[startRange]

		let advancing = sub.advancingWindowToEnd()
		XCTAssertEqual(advancing, "1234567890")
		XCTAssertEqual(sub, "klmnopqrst")

		var advance = sub
		advance.advanceWindowToEnd()
		XCTAssertEqual(advance, "1234567890")
	}

	func testSubstringWindowAdvanceToStart() throws {
		let sub = string[startRange]

		let advancing = sub.advancingWindowToStart()
		XCTAssertEqual(advancing, "abcdefghij")
		XCTAssertEqual(sub, "klmnopqrst")

		var advance = sub
		advance.advanceWindowToStart()
		XCTAssertEqual(advance, "abcdefghij")
	}
}
