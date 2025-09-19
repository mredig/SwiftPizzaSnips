import Foundation
import SwiftPizzaSnips
import Testing

struct SortifierTests {
	struct Base: SortifierTiebreaker {
		let value: String

		func isLessThanForTiebreak(_ rhs: SortifierTests.Base) -> Bool {
			value < rhs.value
		}
	}

	static let mockBases = [
		Base(value: "asdf"),
		Base(value: "fdas"),
		Base(value: "z"),
		Base(value: "aklsdrghjkajls"),
	]

	static let mockBasesValueSorted = [
		Base(value: "aklsdrghjkajls"),
		Base(value: "asdf"),
		Base(value: "fdas"),
		Base(value: "z"),
	]

	@Test func sortWithEstablishedOrder() async throws {
		let sortified = Self.mockBases.enumerated().map {
			Sortifier($0.element, sortingValue: Double($0.offset))
		}

		let sorted = sortified.sorted()

		#expect(sorted.map(\.wrapped) == Self.mockBases)
	}

	@Test func sortWithInvertedOrder() async throws {
		let sortified = Self.mockBases.reversed().enumerated().map {
			Sortifier($0.element, sortingValue: Double($0.offset))
		}

		let sorted = sortified.sorted()

		#expect(sorted.map(\.wrapped) == Array(Self.mockBases.reversed()))
	}
	
	/// This assumes `<` does nothing when values are equal. If that changes, this would be expected to be flaky.
	@Test func sortWithEstablishedWithoutSortingValues() async throws {
		let sortified = Self.mockBases.map {
			Sortifier($0, sortingValue: 0)
		}

		let sorted = sortified.sorted()

		#expect(sorted.map(\.wrapped) == Self.mockBasesValueSorted)
	}

	@Test func equalityWithBaseValue() async throws {
		let base = Self.mockBases.first!

		let wrappedA = Sortifier(base, sortingValue: 0)
		let wrappedB = Sortifier(base, sortingValue: 1)
		let wrappedC = Sortifier(base, sortingValue: 2)

		#expect(base == wrappedA)
		#expect(base == wrappedB)
		#expect(base == wrappedC)
		#expect(wrappedA == base)
		#expect(wrappedB == base)
		#expect(wrappedC == base)

		#expect(wrappedA != wrappedB)
		#expect(wrappedC != wrappedB)
		#expect(wrappedC != wrappedA)
	}
}
