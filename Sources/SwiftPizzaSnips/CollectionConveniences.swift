import Foundation

public extension RangeReplaceableCollection {
	@discardableResult
	mutating func popFirst() -> Element? {
		guard !isEmpty else { return nil }
		return removeFirst()
	}
}

public extension Collection {
	var isOccupied: Bool {
		!isEmpty
	}

	var emptyIsNil: Self? { isOccupied ? self : nil }
}

public extension Array {
	subscript(optional index: Int) -> Element? {
		guard index < count else { return nil }
		return self[index]
	}
}

public extension ContiguousArray {
	subscript(optional index: Int) -> Element? {
		guard index < count else { return nil }
		return self[index]
	}
}

public extension Optional where Wrapped == String {
	var nilIsEmpty: Wrapped {
		switch self {
		case .none:
			Wrapped.init()
		case .some(let value):
			value
		}
	}
}

public extension Optional where Wrapped: ExpressibleByArrayLiteral {
	var nilIsEmpty: Wrapped {
		self ?? []
	}
}
