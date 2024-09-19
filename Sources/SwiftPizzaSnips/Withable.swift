import Foundation
#if canImport(UIKit)
import UIKit
#endif

public protocol Withable {
	associatedtype TSelf

	@discardableResult
	func with(_ block: (_ instance: inout TSelf) throws -> Void) rethrows -> TSelf
	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
	func asyncWith(_ block: (_ instance: inout TSelf) async throws -> Void) async rethrows -> TSelf
}

public extension Withable {
	@discardableResult
	func with(_ block: (_ instance: inout Self) throws -> Void) rethrows -> Self {
		var new = self
		try block(&new)
		return new
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
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

extension Bool: Withable {}
extension Int: Withable {}
extension UInt: Withable {}
extension Int8: Withable {}
extension UInt8: Withable {}
extension Int16: Withable {}
extension UInt16: Withable {}
extension Int32: Withable {}
extension UInt32: Withable {}
extension Int64: Withable {}
extension UInt64: Withable {}
extension Float: Withable {}
#if arch(arm64) // see Float16 docs
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7, *)
extension Float16: Withable {}
#endif
#if arch(x86_64)
extension Float80: Withable {}
#endif
extension Double: Withable {}
extension Decimal: Withable {}
extension Range: Withable {}
extension ClosedRange: Withable {}

extension String: Withable {}
extension Substring: Withable {}
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
extension Regex: Withable {}

extension Array: Withable {}
extension Dictionary: Withable {}
extension Set: Withable {}
extension Data: Withable {}
extension Slice: Withable {}

extension Optional: Withable {}

// MARK: misc
#if canImport(UIKit) && !os(watchOS)
@available(iOS 14.0, tvOS 14, *)
extension UICollectionLayoutListConfiguration: Withable {}
#endif
