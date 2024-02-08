import Foundation

extension Substring {
	public var range: Range<String.Index> { startIndex..<endIndex }

	public mutating func advanceWindow(count: Int = 1) throws {
		let new = try advancingWindow(count: count)
		self = new
	}

	public func advancingWindow(count: Int = 1) throws -> Substring {
		let upper: String.Index
		let lower: String.Index
		if count >= 0 {
			let u = try upperBound(advancedBy: count)
			let tRange = range.lowerBound..<u
			let l = try lowerBound(advancedBy: count, usingRange: tRange)
			upper = u
			lower = l
		} else {
			let l = try lowerBound(advancedBy: count)
			let tRange = l..<range.upperBound
			let u = try upperBound(advancedBy: count, usingRange: tRange)
			upper = u
			lower = l
		}

		let newRange = lower..<upper
		return base[newRange]
	}

	public func advancingWindowToEnd() -> Substring {
		let rangeSize = base.distance(from: range.lowerBound, to: range.upperBound)
		
		let newLower = base.index(base.endIndex, offsetBy: -rangeSize)

		return base[newLower..<base.endIndex]
	}

	mutating public func advanceWindowToEnd() {
		self = self.advancingWindowToEnd()
	}

	public func advancingWindowToStart() -> Substring {
		let rangeSize = base.distance(from: range.lowerBound, to: range.upperBound)

		let newUpper = base.index(base.startIndex, offsetBy: rangeSize)

		return base[base.startIndex..<newUpper]
	}

	mutating public func advanceWindowToStart() {
		self = self.advancingWindowToStart()
	}

	public mutating func advanceUpperBound(count: Int = 1) throws {
		let new = try advancingUpperBound(count: count)
		self = new
	}

	public mutating func advanceLowerBound(count: Int = 1) throws {
		let new = try advancingLowerBound(count: count)
		self = new
	}

	public func advancingUpperBound(count: Int = 1) throws -> Substring {
		let upper = try upperBound(advancedBy: count)

		let newRange = range.lowerBound..<upper
		return base[newRange]
	}

	public func advancingLowerBound(count: Int = 1) throws -> Substring {
		let lower = try lowerBound(advancedBy: count)

		let newRange = lower..<range.upperBound
		return base[newRange]
	}

	private func upperBound(advancedBy count: Int, usingRange: Range<String.Index>? = nil) throws -> String.Index {
		let range = usingRange ?? range
		guard count != 0 else { return range.upperBound }
		let (limit, potentialError) = {
			if count >= 0 {
				(base.endIndex, WindowError.exceedsUpperBound)
			} else {
				(range.lowerBound, WindowError.exceedsLowerBound)
			}
		}()
		guard
			let upper = base.index(range.upperBound, offsetBy: count, limitedBy: limit)
		else { throw potentialError }

		return upper
	}

	private func lowerBound(advancedBy count: Int, usingRange: Range<String.Index>? = nil) throws -> String.Index {
		let range = usingRange ?? range
		guard count != 0 else { return range.lowerBound }
		let (limit, potentialError) = {
			if count >= 0 {
				(range.upperBound, WindowError.exceedsUpperBound)
			} else {
				(base.startIndex, WindowError.exceedsLowerBound)
			}
		}()

		guard
			let lower = base.index(range.lowerBound, offsetBy: count, limitedBy: limit)
		else { throw potentialError }

		return lower
	}

	public enum WindowError: Swift.Error {
		case exceedsLowerBound
		case exceedsUpperBound
	}
}
