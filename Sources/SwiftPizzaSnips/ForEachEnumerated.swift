public extension RandomAccessCollection where Index == Int {
	func forEachEnumerated() -> ForEachEnumeratedSequence<Self> {
		ForEachEnumeratedSequence(base: self)
	}
}

public struct ForEachEnumeratedSequence<Base: RandomAccessCollection>: Sequence where Base.Index == Int {
	public var base: Base

	public struct Iterator: IteratorProtocol {
		public typealias Element = (Int, Base.Element)

		private var sequence: Base
		private var offset: Int

		init(sequence: Base) {
			self.sequence = sequence
			self.offset = sequence.startIndex
		}

		public mutating func next() -> (Int, Base.Element)? {
			guard
				sequence.indices.contains(offset)
			else { return nil }
			let delta = offset - sequence.startIndex
			defer { offset += 1 }

			return (delta, sequence[offset])
		}
	}

	public func makeIterator() -> Iterator {
		Iterator(sequence: base)
	}
}

extension ForEachEnumeratedSequence: Collection {
	public func index(after i: Base.Index) -> Base.Index {
		base.index(after: i)
	}

	public subscript(position: Base.Index) -> (Int, Base.Element) {
		let element = base[position]
		return (position, element)
	}

	public typealias Index = Base.Index

	public var startIndex: Base.Index { base.startIndex }
	public var endIndex: Base.Index { base.endIndex }
}

extension ForEachEnumeratedSequence: BidirectionalCollection {
	public func index(before i: Base.Index) -> Base.Index {
		base.index(before: i)
	}
}

extension ForEachEnumeratedSequence: RandomAccessCollection {}
