#if canImport(AppKit)
import AppKit

public class SimpleToolbarWindowController: NSWindowController {
	public private(set) var toolbarItems: [NSToolbarItem.Identifier: NSToolbarItem] = [:]
	public private(set) var toolbarItemOrder: [NSToolbarItem] = [] {
		didSet {
			toolbar.refreshToolbar()
		}
	}

	public let toolbar: NSToolbar

	public init(toolbarIdentifier: NSToolbar.Identifier, windowConfig: (NSWindow) throws -> Void) rethrows {
		self.toolbar = NSToolbar(identifier: toolbarIdentifier)

		let newWindow = NSWindow()
		try windowConfig(newWindow)

		super.init(window: newWindow)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func appendToolbarItem(_ toolbarItem: NSToolbarItem) {
		guard toolbarItems[toolbarItem.itemIdentifier] == nil else { return }
		toolbarItems[toolbarItem.itemIdentifier] = toolbarItem
		toolbarItemOrder.append(toolbarItem)
	}

	public func removeToolbarItem(_ toolbarItem: NSToolbarItem) {
		guard let existing = toolbarItems[toolbarItem.itemIdentifier] else { return }
		toolbarItems.removeValue(forKey: toolbarItem.itemIdentifier)
		toolbarItemOrder.removeAll(where: { $0.itemIdentifier == existing.itemIdentifier })
	}

	public func insertToolbarItem(_ toolbarItem: NSToolbarItem, before priorToolbarItem: NSToolbarItem) {
		guard
			toolbarItems[toolbarItem.itemIdentifier] == nil,
			let index = toolbarItemOrder.firstIndex(of: priorToolbarItem)
		else { return }
		toolbarItems[toolbarItem.itemIdentifier] = toolbarItem
		toolbarItemOrder.insert(toolbarItem, at: index)
	}

	public func insertToolbarItem(_ toolbarItem: NSToolbarItem, after previousToolbarItem: NSToolbarItem) {
		guard
			toolbarItems[toolbarItem.itemIdentifier] == nil,
			let index = toolbarItemOrder.firstIndex(of: previousToolbarItem)
		else { return }
		let newIndex = toolbarItemOrder.index(after: index)
		toolbarItems[toolbarItem.itemIdentifier] = toolbarItem
		toolbarItemOrder.insert(toolbarItem, at: newIndex)
	}
}

extension SimpleToolbarWindowController: NSToolbarDelegate, NSToolbarItemValidation {
	public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		toolbarItemOrder.map(\.itemIdentifier)
	}

	public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		toolbarItemOrder.map(\.itemIdentifier)
	}

	public func toolbar(
		_ toolbar: NSToolbar,
		itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
		willBeInsertedIntoToolbar flag: Bool
	) -> NSToolbarItem? {
		toolbarItems[itemIdentifier]
	}

	public func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
		true
	}
}

#endif
