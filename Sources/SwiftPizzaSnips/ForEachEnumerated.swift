public extension RandomAccessCollection where Index == Int {
	/// SwiftUI's `ForEach` doesn't allow `.enumerated()` sequences because it doesn't conform to `RandomAccessCollection`.
	///
	/// Well, `ForEachEnumeratedSequence` does. This allows you to write code like this:
	///
	/// ```swift
	///	let sequence = "abcdefghijklm".map { String($0) }
	/// List {
	/// 	ForEach(sequence.forEachEnumerated(), id: \.self.element) { (offset, letter) in
	/// 		if offset != sequence.startIndex {
	/// 			Divider()
	/// 		}
	/// 		Text(letter)
	/// 	}
	/// }
	/// ```
	///
	/// This allows you to conditionally alter your layout based on the offset of the element you're on, like only putting dividers between items
	/// in a list, avoiding a `Divider` on the very top or bottom of the `VStack`, etc.
	///
	/// - Returns: An enumerated sequence
	func forEachEnumerated() -> ForEachEnumeratedSequence<Self> {
		ForEachEnumeratedSequence(base: self)
	}
}

/// SwiftUI's `ForEach` doesn't allow `.enumerated()` sequences because it doesn't conform to `RandomAccessCollection`.
///
/// Well, `ForEachEnumeratedSequence` does. This allows you to write code like this:
///
/// ```swift
///	let sequence = "abcdefghijklm".map { String($0) }
/// List {
/// 	ForEach(sequence.forEachEnumerated(), id: \.self.element) { (offset, letter) in
/// 		if offset != sequence.startIndex {
/// 			Divider()
/// 		}
/// 		Text(letter)
/// 	}
/// }
/// ```
///
/// This allows you to conditionally alter your layout based on the offset of the element you're on, like only putting dividers between items
/// in a list, avoiding a `Divider` on the very top or bottom of the `VStack`, etc.
public struct ForEachEnumeratedSequence<Base: RandomAccessCollection>: Sequence where Base.Index == Int {
	public var base: Base

	public struct Iterator: IteratorProtocol {
		public typealias Element = (offset: Int, element: Base.Element)

		private var sequence: Base
		private var offset: Int

		init(sequence: Base) {
			self.sequence = sequence
			self.offset = sequence.startIndex
		}

		public mutating func next() -> Element? {
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

	public subscript(position: Base.Index) -> Element {
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
