#if canImport(AppKit)
import AppKit

extension NSToolbarItem.Identifier: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
	public init(stringLiteral value: StringLiteralType) {
		self.init(value)
	}
}

#endif
