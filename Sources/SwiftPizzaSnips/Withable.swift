import Foundation

public protocol Withable {
	associatedtype TSelf

	@discardableResult
	func with(_ block: (_ instance: inout TSelf) throws -> Void) rethrows -> TSelf
	@available(macOS 10.15.0, iOS 13.0, *)
	func asyncWith(_ block: (_ instance: inout TSelf) async throws -> Void) async rethrows -> TSelf
}

public extension Withable {
	@discardableResult
	func with(_ block: (_ instance: inout Self) throws -> Void) rethrows -> Self {
		var new = self
		try block(&new)
		return new
	}

	@available(macOS 10.15.0, iOS 13.0, *)
	@discardableResult
	func asyncWith(_ block: (_ instance: inout Self) async throws -> Void) async rethrows -> Self {
		var new = self
		try await block(&new)
		return new
	}
}

extension NSObject: Withable {}

extension JSONDecoder: Withable {}
extension JSONEncoder: Withable {}
extension PropertyListDecoder: Withable {}
extension PropertyListEncoder: Withable {}
