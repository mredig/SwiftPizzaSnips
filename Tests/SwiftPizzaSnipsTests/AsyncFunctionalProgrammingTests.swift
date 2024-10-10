import Testing
import SwiftPizzaSnips

struct AsyncFunctionalProgrammingTests {
	@available(iOS 13.0, *)
	@Test func testAsyncFilter() async throws {
		let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

		let evens = await array.asyncFilter {
			try? await Task.sleep(nanoseconds: 1_000)
			return $0.isMultiple(of: 2)
		}

		#expect([2, 4, 6, 8, 0] == evens)
	}

	@available(iOS 13.0, *)
	@Test func testAsyncMap() async throws {
		let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

		let fiveX = await array.asyncMap {
			try? await Task.sleep(nanoseconds: 1_000)
			return $0 * 5
		}

		#expect(array.map { $0 * 5 } == fiveX)
	}

	@available(iOS 13.0, *)
	@Test func testAsyncCompactMap() async throws {
		let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

		let odds: [Int] = try await array.asyncCompactMap {
			try await Task.sleep(nanoseconds: 1_000)
			guard $0.isMultiple(of: 2) == false else { return nil }
			return $0
		}

		#expect([1, 3, 5, 7, 9] == odds)
	}

	@Test func testAsyncConcurrentMap() async throws {
		let array = (0..<100000).map { $0 }

		let multiplied = await array.asyncConcurrentMap {
			$0 * 1000
		}

		let expected = array.map { $0 * 1000 }

		#expect(expected == multiplied)
	}

	@available(iOS 13.0, *)
	@Test func testAsyncReduce() async throws {
		let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

		let accumulated = await array.asyncReduce(0) {
			try? await Task.sleep(nanoseconds: 1_000)
			return $0 + $1
		}

		#expect(45 == accumulated)
	}


	@available(iOS 13.0, *)
	@Test func testAsyncReduceInto() async throws {
		let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

		let accumulated = await array.asyncReduce(into: Set<Int>()) {
			try? await Task.sleep(nanoseconds: 1_000)
			$0.insert($1)
		}

		#expect(Set(array) == accumulated)
	}
}
