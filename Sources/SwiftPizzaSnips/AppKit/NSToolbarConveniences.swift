#if canImport(AppKit)
import AppKit

public extension NSToolbar {
	func refreshToolbar() {
		setConfiguration(configuration)
	}
}

#endif
