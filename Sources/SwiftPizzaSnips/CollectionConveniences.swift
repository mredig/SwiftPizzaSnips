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
