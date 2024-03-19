import Foundation

extension BinaryFloatingPoint {
	public func isWithinTolerance(of other: Self, tolerance: Self = 0.0001) -> Bool {
		let diff = abs(self - other)
		return diff <= tolerance
	}
}
