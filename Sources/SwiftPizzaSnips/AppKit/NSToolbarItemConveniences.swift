#if canImport(AppKit)
import AppKit

extension NSToolbarItem.Identifier: @retroactive ExpressibleByStringLiteral, @retroactive ExpressibleByStringInterpolation {
	public init(stringLiteral value: StringLiteralType) {
		self.init(value)
	}
}

#endif
