import Foundation
import XCTest
import SwiftPizzaSnips

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
		let arr1: [Int]? = []
		let arr2: [Int]? = [1]
		let arr3: [Int]? = nil

		XCTAssertEqual(str1.nilIsEmpty, "foo")
		XCTAssertEqual(str2.nilIsEmpty, "")

		XCTAssertEqual(arr1.nilIsEmpty, [])
		XCTAssertEqual(arr2.nilIsEmpty, [1])
		XCTAssertEqual(arr3.nilIsEmpty, [])
	}

	func testBinaryFilter() throws {
		let inputs = (0...10).map { $0 }

		let (even, odd) = inputs.binaryFilter { $0.isMultiple(of: 2) }

		XCTAssertEqual(even, [0, 2, 4, 6, 8, 10])
		XCTAssertEqual(odd, [1, 3, 5, 7, 9])
	}

	func testBinarySearch() throws {
		for length in 0...100 {
			let collection = 0...length
			let targets = (-4)...(length + 4)

			for toFind in targets {
				let binarySearchIndex = collection.bisectToFirstIndex(where: { $0 > toFind })
				let expectedIndex = collection.firstIndex { $0 > toFind }
				XCTAssertEqual(binarySearchIndex, expectedIndex, "Looking for \(toFind) in 0...\(length)")
			}
		}
	}
}
