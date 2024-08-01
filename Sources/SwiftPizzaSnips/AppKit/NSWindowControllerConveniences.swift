#if canImport(AppKit)
import AppKit

public extension NSWindowController {
	convenience init(withWindowConfig configBlock: (NSWindow) throws -> Void) rethrows {
		let newWindow = NSWindow()
		try configBlock(newWindow)
		self.init(window: newWindow)
	}

	convenience init(instantiatingNewWindow: Bool) {
		if instantiatingNewWindow {
			self.init(withWindowConfig: { _ in })
		} else {
			self.init(window: nil)
		}
	}
}
#endif
