public protocol SortifierTiebreaker: Equatable {
	func isLessThanForTiebreak(_ rhs: Self) -> Bool
}

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
