#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit) || canImport(UIKit)
@available(iOS 16.0, *)
@MainActor
public struct Alert: Sendable, Hashable, Withable {
	#if canImport(AppKit)
	public typealias OSAlert = NSAlert
	public typealias Severity = NSAlert.Style
	#elseif canImport(UIKit)
	public typealias OSAlert = UIAlertController
	public typealias Severity = UIAlertControllerSeverity
	#endif

	public var title: String
	public var message: String

	#if canImport(AppKit)
	public nonisolated(unsafe) var icon: OSImage?
	public var suppressionButtonOption: SuppressionButtonOption = .hide
	public var accessoryView: NSView?
	#elseif canImport(UIKit)
	public var style: UIAlertController.Style?
	#endif

	public var severity: Severity?

	public var actions: [Action]

	public init(title: String, message: String, actions: [Action] = []) {
		self.title = title
		self.message = message
		self.actions = actions
	}

	#if canImport(AppKit)
	@MainActor
	public func createAlert() -> NSAlert {
		let alertView = CustomAlert()
		alertView.messageText = title
		alertView.informativeText = message

		if let severity {
			alertView.alertStyle = severity
		}

		if let accessoryView {
			alertView.layout()
			alertView.accessoryView = accessoryView
		}

		if let icon {
			alertView.icon = icon
		}

		for action in actions {
			alertView.addAction(action)
		}

		return alertView
	}
	#elseif canImport(UIKit)
	@MainActor
	public func createAlert() -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: style ?? .actionSheet)

		if let severity {
			alertController.severity = severity
		}

		for action in actions {
			alertController.addAction(UIAlertAction(title: action.title, style: action.style, handler: { [unowned alertController] alertAction in
				switch action.action {
				case .alertProcessor(let block):
					block(alertController)
				case .textFieldProcessor(let block):
					block(alertController.textFields ?? [])
				case .void(let block):
					block()
				}
			}))
		}

		return alertController
	}
	#endif

	#if canImport(AppKit)
	public struct SuppressionButtonOption: Sendable, Hashable, Withable {
		public static let hide = SuppressionButtonOption()
		public static func show(onSubmit: @escaping OnSubmit) -> SuppressionButtonOption {
			SuppressionButtonOption(onSubmit: onSubmit)
		}

		public typealias OnSubmit = @Sendable @MainActor (NSButton.StateValue) -> Void
		private let onSubmit: OnSubmit?
		private let id = UUID()

		private init(onSubmit: OnSubmit? = nil) {
			self.onSubmit = onSubmit
		}

		public static func == (lhs: Alert.SuppressionButtonOption, rhs: Alert.SuppressionButtonOption) -> Bool {
			switch (lhs.onSubmit, rhs.onSubmit) {
			case (.none, .none): true
			case (.some, .none), (.none, .some): false
			case (.some, .some):
				lhs.id == rhs.id
			}
		}

		public func hash(into hasher: inout Hasher) {
			guard onSubmit != nil else {
				return hasher.combine(0)
			}
			hasher.combine(id)
		}
	}
	#endif

	@MainActor
	public struct Action: Sendable, Hashable, Withable {
		public var title: String

		#if canImport(AppKit)
		public var isDefault: Bool
		public let action: @Sendable @MainActor () -> Void
		#elseif canImport(UIKit)
		public var style: UIAlertAction.Style
		public let action: ActionStyle
		#endif

		private let actionID = UUID()

		#if canImport(AppKit)
		public init(title: String, isDefault: Bool = false, action: @escaping @Sendable @MainActor () -> Void = {}) {
			self.title = title
			self.isDefault = isDefault
			self.action = action
		}
		#elseif canImport(UIKit)
		public init(title: String, isDefault: Bool = false, action: ActionStyle = .void({})) {
			self.title = title
			self.isDefault = isDefault
			self.action = action
		}
		#endif

		public nonisolated static func == (lhs: Alert.Action, rhs: Alert.Action) -> Bool {
			#if canImport(AppKit)
			lhs.title == rhs.title
			&& lhs.actionID == rhs.actionID
			&& lhs.isDefault == rhs.isDefault
			#elseif canImport(UIKit)
			lhs.title == rhs.title
			&& lhs.style == rhs.style
			&& lhs.actionID == rhs.actionID
			#endif
		}

		public nonisolated func hash(into hasher: inout Hasher) {
			hasher.combine(title)
			#if canImport(AppKit)
			hasher.combine(isDefault)
			#endif
			hasher.combine(actionID)
		}

		#if canImport(UIKit)
		public enum ActionStyle: Sendable {
			case void(@Sendable @MainActor () -> Void)
			case textFieldProcessor(@Sendable @MainActor ([UITextField]) -> Void)
			case alertProcessor(@Sendable @MainActor (UIAlertController) -> Void)
		}
		#endif
	}

	#if canImport(AppKit)
	private class CustomAlert: NSAlert {
		var actions: [NSButton: Action] = [:]

		func addAction(_ action: Action) {
			let button = addButton(withTitle: action.title)
			button.keyEquivalent = ""
			if action.isDefault {
				button.keyEquivalent = "\r"
			}
			registerButton(button, for: action)
		}

		override func addButton(withTitle title: String) -> NSButton {
			let button = super.addButton(withTitle: title)

			button.target = self
			button.action = #selector(runAction)

			return button
		}

		func registerButton(_ button: NSButton, for action: Action) {
			actions[button] = action
		}

		@objc func runAction(_ sender: NSButton) {
			guard let action = actions[sender] else { return }
			action.action()
		}
	}
	#endif
}
#endif
