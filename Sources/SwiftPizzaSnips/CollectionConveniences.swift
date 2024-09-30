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
		guard indices.contains(index) else { return nil }
		return self[index]
	}
}

public extension ContiguousArray {
	subscript(optional index: Int) -> Element? {
		guard indices.contains(index) else { return nil }
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

public extension RandomAccessCollection {
	/// If it's not already obvious, this will only provide valid results on a low to high sorted collection.
	/// Additionally, the `predicate` *must* return a result answering whether the proposed element is `greater` than
	/// what you're looking for. See discussion for example:
	///
	/// So, if we are looking for `toFind`, the following predicate would be valid:
	///
	/// ```swift
	/// { $0 > toFind }
	/// ```
	///
	/// but
	///
	/// ```swift
	/// { $0 < toFind }
	/// ```
	/// would provide invalid results!
	func bisectToFirstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
		var intervalStart = startIndex
		var intervalEnd = endIndex

		while intervalStart != intervalEnd {
			let intervalLength = distance(from: intervalStart, to: intervalEnd)

			let testIndex: Index
			guard intervalLength > 1 else {
				testIndex = intervalStart
				return try predicate(self[testIndex]) ? testIndex : nil
			}

			testIndex = index(intervalStart, offsetBy: (intervalLength - 1) / 2)

			if try predicate(self[testIndex]) {
				intervalEnd = index(after: testIndex)
			} else {
				intervalStart = index(after: testIndex)
			}
		}

		return nil
	}

	/// If it's not already obvious, this will only provide valid results on a low to high sorted collection.
	func binarySearchFirstIndex(where predicate: (Element) throws -> BinarySearchComparisonResult) rethrows -> Index? {
		var intervalStart = startIndex
		var intervalEnd = endIndex

		while intervalStart != intervalEnd {
			let intervalLength = distance(from: intervalStart, to: intervalEnd)

			let testIndex: Index
			guard intervalLength > 1 else {
				testIndex = intervalStart
				return try predicate(self[testIndex]) == .proposedElementIsExactMatch ? testIndex : nil
			}

			testIndex = index(intervalStart, offsetBy: (intervalLength - 1) / 2)

			let result = try predicate(self[testIndex])
			switch result {
			case .proposedElementIsLess:
				intervalStart = index(after: testIndex)
			case .proposedElementIsExactMatch:
				return testIndex
			case .proposedElementIsGreater:
				intervalEnd = index(after: testIndex)
			}
		}

		return nil
	}

	/// If it's not already obvious, this will only provide valid results on a low to high sorted collection.
	func binarySearchFirstElement(where predicate: (Element) throws -> BinarySearchComparisonResult) rethrows -> Element? {
		guard let index = try binarySearchFirstIndex(where: predicate) else { return nil }
		return self[index]
	}
}

public enum BinarySearchComparisonResult {
	case proposedElementIsLess
	case proposedElementIsExactMatch
	case proposedElementIsGreater
}
