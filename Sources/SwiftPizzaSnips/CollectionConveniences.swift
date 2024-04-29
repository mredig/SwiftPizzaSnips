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

	@available(*, deprecated, renamed: "bifurcate")
	func binaryFilter(_ predicate: (Element) throws -> Bool) rethrows -> (pass: [Element], fail: [Element]) {
		try bifurcate(predicate)
	}
	func bifurcate(_ predicate: (Element) throws -> Bool) rethrows -> (pass: [Element], fail: [Element]) {
		try reduce(into: (pass: [Element](), fail: [Element]())) {
			let value = try predicate($1)
			if value {
				$0.0.append($1)
			} else {
				$0.1.append($1)
			}
		}
	}

	/// Iterates through the collection, creating a array for each group you specify via `Enum`. Returns a dictionary of
	/// `[Element]` arrays, using the `Enum` values returned in predicate as keys
	func nfurcate<Enum: Hashable>(_ predicate: (Element) throws -> Enum) rethrows -> [Enum: [Element]] {
		try reduce(into: [Enum: [Element]]()) {
			let result = try predicate($1)

			$0[result, default: []].append($1)
		}
	}
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
