#if os(macOS)
import AppKit

public extension NSLayoutConstraint {
	func withPriority(_ value: Priority) -> NSLayoutConstraint {
		self.priority = value
		return self
	}
}
#elseif os(iOS) || os(tvOS)
import UIKit

public extension NSLayoutConstraint {
	func withPriority(_ value: UILayoutPriority) -> NSLayoutConstraint {
		self.priority = value
		return self
	}
}
#endif
