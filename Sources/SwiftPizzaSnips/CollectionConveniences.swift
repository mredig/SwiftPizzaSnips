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

	func binaryFilter(_ predicate: (Element) throws -> Bool) rethrows -> (pass: [Element], fail: [Element]) {
		try reduce(into: (pass: [Element](), fail: [Element]())) {
			let value = try predicate($1)
			if value {
				$0.0.append($1)
			} else {
				$0.1.append($1)
			}
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
