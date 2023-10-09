import Foundation
import XCTest
@testable import SwiftPizzaSnips
import Combine

final class CollectionConvenienceTests: XCTestCase {
	func testPopFirst() {
		var arr = [1, 2, 3, 4, 5]

		XCTAssertEqual(1, arr.popFirst())
		XCTAssertEqual(2, arr.popFirst())
		XCTAssertEqual(3, arr.popFirst())
		XCTAssertEqual(4, arr.popFirst())
		XCTAssertEqual(5, arr.popFirst())
		XCTAssertNil(arr.popFirst())
	}

	func testIsOccupied() {
		let arr1 = [1, 2]
		let arr2: [Int] = []

		XCTAssertTrue(arr1.isOccupied)
		XCTAssertFalse(arr2.isOccupied)
	}

	func testOptionalIndexing() {
		let arr = [1, 2, 3]

		XCTAssertEqual(1, arr[optional: 0])
		XCTAssertEqual(2, arr[optional: 1])
		XCTAssertEqual(3, arr[optional: 2])
		XCTAssertNil(arr[optional: 3])
	}

	func testOptionalIndexingContiguous() {
		let arr: ContiguousArray = [1, 2, 3]

		XCTAssertEqual(1, arr[optional: 0])
		XCTAssertEqual(2, arr[optional: 1])
		XCTAssertEqual(3, arr[optional: 2])
		XCTAssertNil(arr[optional: 3])
	}

	func testEmptyIsNil() {
		let str1 = ""
		let str2 = "foo"
		let arr1: [Int] = []
		let arr2 = [1]

		XCTAssertNil(str1.emptyIsNil)
		XCTAssertEqual(str2, "foo")

		XCTAssertNil(arr1.emptyIsNil)
		XCTAssertEqual(arr2.emptyIsNil, [1])
	}

	func testNilIsEmpty() {
		let str1: String? = "foo"
		let str2: String? = nil

		XCTAssertEqual(str1.nilIsEmpty, "foo")
		XCTAssertEqual(str2.nilIsEmpty, "")
	}
}
