#if canImport(SwiftUI) && os(iOS)
import SwiftUI

/// A button view that can be used in a list that will be formatted like a NavigationLink, except you can do an arbitrary action.
@available(iOS 16.0, *)
public struct NavigationButton<Label: View>: View {
	let label: () -> Label

	let action: () -> Void

	public init(label: @escaping () -> Label, action: @escaping () -> Void) {
		self.label = label
		self.action = action
	}

	public init(title: String, action: @escaping () -> Void) where Label == Text {
		self.init(
			label: { Text(title) },
			action: action)
	}

	public var body: some View {
		Button(
			action: action,
			label: {
				LabeledContent(
					content: {
						Image(systemName: "chevron.forward")
							.imageScale(.small)
							.fontWeight(.semibold)
							.foregroundStyle(Color(hue: 0, saturation: 0, brightness: 0.72))
					},
					label: label)
			})
	}
}

#endif
