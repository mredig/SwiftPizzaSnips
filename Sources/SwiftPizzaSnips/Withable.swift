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

extension JSONDecoder: Withable {}
extension JSONEncoder: Withable {}
extension PropertyListDecoder: Withable {}
extension PropertyListEncoder: Withable {}
