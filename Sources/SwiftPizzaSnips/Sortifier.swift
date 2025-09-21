public protocol SortifierTiebreaker: Equatable {
	func isLessThanForTiebreak(_ rhs: Self) -> Bool
}

/// Useful when you need to arbitrarily sort data, but want to prevent storing any sorting value directly on the sorted type.
/// `Sortifier` allows you to
/// * wrap the base model in a sortable data type
/// * Encode/Decode said data in a flat structure alongside the sorting value
/// * retain equatability and hashability of the base type, even when sorting values differ
///
/// A potential scenario might be that you want to store ui elements in the order a user determines, unrelated to any
/// inherent data. The user moves an element and you need to check if the element is already in the list or a new
/// element. If the element data type stored the sorting value directly, the same element in different positions
/// would fail an equatibility test.
///
/// However, with Sortifier, two `Sortifier<Wrapped>` objects with the same base `Wrapped` value and different
/// sorting values would evaluate not equal, their base values would still evaluate equal.
@dynamicMemberLookup
public struct Sortifier<Wrapped: SortifierTiebreaker>: Comparable {

	public var sortingValue: Double

	public var wrapped: Wrapped

	public init(_ wrapped: Wrapped, sortingValue: Double) {
		self.sortingValue = sortingValue
		self.wrapped = wrapped
	}

	public static func < (lhs: Sortifier, rhs: Sortifier) -> Bool {
		guard lhs.sortingValue == rhs.sortingValue else {
			return lhs.sortingValue < rhs.sortingValue
		}

		return lhs.wrapped.isLessThanForTiebreak(rhs.wrapped)
	}

	public static func == (lhs: Sortifier<Wrapped>, rhs: Sortifier<Wrapped>) -> Bool {
		lhs.sortingValue == rhs.sortingValue && lhs.wrapped == rhs.wrapped
	}

	public subscript<T>(dynamicMember member: WritableKeyPath<Wrapped, T>) -> T {
		get { wrapped[keyPath: member] }
		set { wrapped[keyPath: member] = newValue }
	}

	public subscript<T>(dynamicMember member: KeyPath<Wrapped, T>) -> T {
		wrapped[keyPath: member]
	}
}

extension Sortifier {
	public static func == (lhs: Sortifier, rhs: Wrapped) -> Bool {
		lhs.wrapped == rhs
	}

	public static func == (lhs: Wrapped, rhs: Sortifier) -> Bool {
		rhs == lhs
	}
}

extension Sortifier: Hashable where Wrapped: Hashable {}
extension Sortifier {
	private enum CodingKeys: String, CodingKey {
		case sortingValue
	}
}
extension Sortifier: Encodable where Wrapped: Encodable {
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.sortingValue, forKey: .sortingValue)

		try wrapped.encode(to: encoder)
	}
}
extension Sortifier: Decodable where Wrapped: Decodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		let sortingValue = try container.decode(Double.self, forKey: .sortingValue)

		let wrapped = try Wrapped(from: decoder)

		self.init(wrapped, sortingValue: sortingValue)
	}
}

#if canImport(Foundation)
import Foundation
extension Sortifier: DecodableWithConfiguration where Wrapped: Decodable {
	/// When decoding and a `sortingValue` is missing, instead of failing, you can provide either a default value or
	/// derive a `sortingValue` from the decoded `Wrapped` value
	public struct DecodingConfiguration {
		public var deriveDefaultSortingValueFrom: (Wrapped) -> Double

		/// No derivation, just provide the same default sorting value for anything that doesn't have it explicitly
		public init(defaultSortingValue: Double = .greatestFiniteMagnitude) {
			self.deriveDefaultSortingValueFrom = { _ in defaultSortingValue}
		}

		/// Given the decoded `wrapped` value, you can derive a `sortingValue` from it.
		///
		/// For example, maybe a reasonable default sorting for stored, previously unsorted data is to sort by
		/// an `id: String` value, so you might do
		/// ```swift
		/// DecodingConfiguration { storedData in
		///		let id = storedData.id // a String
		///
		///		var sortValue: Double = 0
		///		for (offset, letter) in id.enumerated() {
		///			let multiplier = pow(0.001, Double(offset))
		///			let letterValue = Double(letter.asciiValue ?? 0)
		///			sortValue += letterValue * multiplier
		///		}
		///		return sortValue
		/// }
		public init(deriveSortingValueFrom: @escaping (Wrapped) -> Double) {
			self.deriveDefaultSortingValueFrom = deriveSortingValueFrom
		}
	}

	public init(from decoder: any Decoder, configuration: DecodingConfiguration) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		let _sortingValue = try container.decodeIfPresent(Double.self, forKey: .sortingValue)
		let wrapped = try Wrapped(from: decoder)

		let sortingValue = _sortingValue ?? configuration.deriveDefaultSortingValueFrom(wrapped)

		self.init(wrapped, sortingValue: sortingValue)
	}
}
#endif
