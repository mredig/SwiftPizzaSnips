import Foundation

public protocol RawRepEquatable: RawRepresentable, Equatable where RawValue: Equatable {}
public extension RawRepEquatable {
	static func == (lhs: Self, rhs: RawValue) -> Bool {
		lhs.rawValue == rhs
	}

	static func == (lhs: RawValue, rhs: Self) -> Bool {
		rhs.rawValue == lhs
	}

	static func != (lhs: Self, rhs: RawValue) -> Bool {
		lhs.rawValue != rhs
	}

	static func != (lhs: RawValue, rhs: Self) -> Bool {
		rhs.rawValue != lhs
	}
}
