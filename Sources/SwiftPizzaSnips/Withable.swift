import Foundation

public protocol Withable {
	associatedtype TSelf

	@discardableResult
	func with(_ block: (_ instance: inout TSelf) -> Void) -> TSelf
}

public extension Withable {
	@discardableResult
	func with(_ block: (_ instance: inout Self) -> Void) -> Self {
		var new = self
		block(&new)
		return new
	}
}

extension NSObject: Withable {}
