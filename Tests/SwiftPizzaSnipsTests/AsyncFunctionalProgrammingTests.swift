import XCTest
import SwiftPizzaSnips

@available(iOS 13.0, *)
final class AsyncFunctionalProgrammingTests: XCTestCase {
	func testAsyncFilter() async throws {
		let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

		let evens = await array.asyncFilter {
			try? await Task.sleep(nanoseconds: 1_000)
			return $0.isMultiple(of: 2)
		}

		XCTAssertEqual([2, 4, 6, 8, 0], evens)
	}

	func testAsyncMap() async throws {
		let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

		let fiveX = await array.asyncMap {
			try? await Task.sleep(nanoseconds: 1_000)
			return $0 * 5
		}

		XCTAssertEqual(array.map { $0 * 5 }, fiveX)
	}

	func testAsyncCompactMap() async throws {
		let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

		let odds: [Int] = try await array.asyncCompactMap {
			try await Task.sleep(nanoseconds: 1_000)
			guard $0.isMultiple(of: 2) == false else { return nil }
			return $0
		}

		XCTAssertEqual([1, 3, 5, 7, 9], odds)
	}

	func testAsyncReduce() async throws {
		let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

		let accumulated = await array.asyncReduce(0) {
			try? await Task.sleep(nanoseconds: 1_000)
			return $0 + $1
		}

		XCTAssertEqual(45, accumulated)
	}


	func testAsyncReduceInto() async throws {
		let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

		let accumulated = await array.asyncReduce(into: Set<Int>()) {
			try? await Task.sleep(nanoseconds: 1_000)
			$0.insert($1)
		}

		XCTAssertEqual(Set(array), accumulated)
	}
}
