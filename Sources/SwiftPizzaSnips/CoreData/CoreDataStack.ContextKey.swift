import Foundation

@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
public extension CoreDataStack {
	struct ContextKey: RawRepresentable, Hashable, ExpressibleByStringInterpolation {
		public static let global: ContextKey = "coredatastack.contextkey.global"
		public static let main: ContextKey = "coredatastack.contextkey.main"

		public let rawValue: String

		public init(rawValue: String) {
			self.rawValue = rawValue
		}

		public init(stringLiteral value: StringLiteralType) {
			self.init(rawValue: value)
		}
	}
}
