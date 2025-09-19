import Foundation
import SwiftPizzaSnips
import Testing

struct SortifierTests {
	struct Base: SortifierTiebreaker {
		let value: String

		func isLessThanForTiebreak(_ rhs: Self) -> Bool {
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

	struct BaseMutable: Codable, SortifierTiebreaker {
		let value: String
		var mutableValue: Int

		func isLessThanForTiebreak(_ rhs: Self) -> Bool {
			value < rhs.value
		}
	}

	@Test func dynamicMembersWork() async throws {
		let base = BaseMutable(value: "asdf", mutableValue: 5)

		var sortified = Sortifier(base, sortingValue: 10)

		#expect(sortified.value == "asdf")
		#expect(sortified.mutableValue == 5)
		#expect(sortified.wrapped.mutableValue == 5)
		sortified.mutableValue = 1
		#expect(sortified.mutableValue == 1)
		#expect(sortified.wrapped.mutableValue == 1)
		#expect(sortified.sortingValue == 10)
	}

	@Test func equatable() async throws {
		let base = BaseMutable(value: "asdf", mutableValue: 5)
		let base2 = BaseMutable(value: "asdf", mutableValue: 5)
		let base3 = BaseMutable(value: "fdsa", mutableValue: 5)

		#expect(base == base2)
		#expect(base != base3)

		let sortifier = Sortifier(base, sortingValue: 0)
		let sortifierMatch = Sortifier(base2, sortingValue: 0)

		let sortifierNonMatchSortValue = Sortifier(base, sortingValue: 1)
		let sortifierNonMatchWrappedValue = Sortifier(base3, sortingValue: 0)

		#expect(sortifier == sortifierMatch)
		#expect(sortifier != sortifierNonMatchSortValue)
		#expect(sortifier != sortifierNonMatchWrappedValue)
	}
}

extension SortifierTests {
	struct BaseCodable: Codable, SortifierTiebreaker {
		let value: String

		func isLessThanForTiebreak(_ rhs: Self) -> Bool {
			value < rhs.value
		}
	}

	private static let encoder = JSONEncoder().with {
		$0.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
	}
	private static let decoder = JSONDecoder()

	private static func jsonDataBaseCodable(value: String, sortingValue: Double) -> Data {
		let formatter = NumberFormatter()
		let sortString = formatter.string(from: sortingValue as NSNumber) ?? "\(sortingValue)"

		let str = """
  {"sortingValue":\(sortString),"value":"\(value)"}
  """
		return Data(str.utf8)
	}

	@Test func encodedDataIsFlat() async throws {
		let base = BaseCodable(value: "asdf")

		let encodedData = try Self.encoder.encode(Sortifier(base, sortingValue: 10))
		let expectedData = Self.jsonDataBaseCodable(value: base.value, sortingValue: 10)

		#expect(encodedData == expectedData)
	}

	@Test func decodedDataIsntFlat() async throws {
		let inData = Self.jsonDataBaseCodable(value: "asdf", sortingValue: 0)

		let decoded = try Self.decoder.decode(Sortifier<BaseCodable>.self, from: inData)
		let expected = BaseCodable(value: "asdf")

		#expect(decoded == expected)
	}

	struct BaseCodableConflict: Codable, SortifierTiebreaker {
		let value: String
		let sortingValue: Double

		func isLessThanForTiebreak(_ rhs: Self) -> Bool {
			value < rhs.value
		}
	}

	@Test func encodeWithConflictUsesWrappedSortValue() async throws {
		let base = BaseCodableConflict(value: "asdf", sortingValue: 1)

		let encodedData = try Self.encoder.encode(Sortifier(base, sortingValue: 10))
		let expectedData = Self.jsonDataBaseCodable(value: base.value, sortingValue: 1)

		#expect(encodedData == expectedData)
	}

	@Test func decodeWithConflictPopulatesBothSortingValues() async throws {
		let inData = Self.jsonDataBaseCodable(value: "asdf", sortingValue: 0)

		let decoded = try Self.decoder.decode(Sortifier<BaseCodableConflict>.self, from: inData)
		let expected = BaseCodableConflict(value: "asdf", sortingValue: 0)

		#expect(decoded == expected)
	}
}
