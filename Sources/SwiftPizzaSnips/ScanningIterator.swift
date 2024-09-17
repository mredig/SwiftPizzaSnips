public struct ScanningIterator<Collection: BidirectionalCollection> {
	public let sequence: Collection

	public var isAtEnd: Bool { index >= sequence.endIndex }
	public private(set) var index: Collection.Index

	public init(sequence: Collection) {
		self.index = sequence.startIndex
		self.sequence = sequence
	}

	public func peek() -> Collection.Element? {
		peek(forward: true).value
	}

	public mutating func scan() -> Collection.Element? {
		get(forward: true)
	}

	public func peekPrevious() -> Collection.Element? {
		peek(forward: false).value
	}

	public mutating func scanPrevious() -> Collection.Element? {
		get(forward: false)
	}

	@discardableResult
	public mutating func scan(upTo matchingBlock: (Collection.Element) -> Bool) -> Collection.SubSequence {
		let firstIndex = index
		let searchSlice = sequence[index...]

		guard
			let lastIndex = searchSlice.firstIndex(where: matchingBlock)
		else {
			index = sequence.endIndex
			return searchSlice
		}

		index = lastIndex
		return sequence[firstIndex..<lastIndex]
	}

	@discardableResult
	public mutating func scan(upTo value: Collection.Element) -> Collection.SubSequence where Collection.Element: Equatable {
		scan(upTo: { $0 == value })
	}

	private func peek(forward: Bool) -> (iteratedIndex: Collection.Index, value: Collection.Element?) {
		if forward {
			guard isAtEnd == false else { return (index, nil) }
			guard index < sequence.endIndex else { return (index, nil) }
			let nextIndex = sequence.index(after: index)
			return (nextIndex, sequence[index])
		} else {
			let prevIndex = sequence.index(before: index)
			guard prevIndex >= sequence.startIndex else { return (index, nil) }
			return (prevIndex, sequence[prevIndex])
		}
	}

	private mutating func get(forward: Bool) -> Collection.Element? {
		let peeked = peek(forward: forward)

		guard
			let value = peeked.value
		else { return nil }
		index = peeked.iteratedIndex

		return value
	}
}

public extension BidirectionalCollection {
	var scanningIterator: ScanningIterator<Self> {
		ScanningIterator(sequence: self)
	}
}
