import Foundation

public extension Sequence {
	func sorted<C: Comparable>(byPriority priorityFunction: (Element) throws -> C, tieBreaker: ((Element, Element) -> Bool)? = nil) rethrows -> [Element] {
		try sorted(by: { a, b in
			let priorityA = try priorityFunction(a)
			let priorityB = try priorityFunction(b)
			if let tieBreaker, priorityA == priorityB {
				return tieBreaker(a, b)
			} else {
				return priorityA < priorityB
			}
		})
	}
}
