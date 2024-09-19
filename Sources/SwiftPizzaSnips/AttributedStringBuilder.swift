import Foundation

#if !os(watchOS)
#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

@available(macOS 12, iOS 15, tvOS 15, *)
@resultBuilder
public struct AttributedStringBuilder {
	public protocol Snip {
		func snippetToAttributedString() -> AttributedString
	}

	public static func buildFinalResult(_ component: any Snip) -> AttributedString {
		component.snippetToAttributedString()
	}

	public static func buildBlock(_ components: Snip...) -> Snip {
		components
			.map {
				$0.snippetToAttributedString()
			}
			.reduce(into: AttributedString(), { $0.append($1) })
	}

	public static func buildEither(first component: Snip) -> Snip {
		component
	}

	public static func buildEither(second component: Snip) -> Snip {
		component
	}

	public static func buildOptional(_ component: Snip?) -> Snip {
		component ?? AttributedString()
	}

	public static func buildArray(_ components: [Snip]) -> Snip {
		components.reduce(into: AttributedString(), { $0.append($1.snippetToAttributedString()) })
	}

	public static func buildPartialBlock(first: Snip) -> Snip {
		first
	}

	public static func buildPartialBlock(accumulated: Snip, next: Snip) -> Snip {
		accumulated.snippetToAttributedString().with {
			$0.append(next.snippetToAttributedString())
		}
	}
}

@available(macOS 12, iOS 15, tvOS 15, *)
extension AttributedString: AttributedStringBuilder.Snip, Withable {
	public init(@AttributedStringBuilder builder: () -> AttributedString) {
		self = builder()
	}

	public func snippetToAttributedString() -> AttributedString {
		self
	}
}

@available(macOS 12, iOS 15, tvOS 15, *)
extension AttributedStringBuilder.Snip where Self: StringProtocol {
	public func snippetToAttributedString() -> AttributedString {
		AttributedString(self)
	}
}

@available(macOS 12, iOS 15, tvOS 15, *)
extension String: AttributedStringBuilder.Snip {}

@available(macOS 12, iOS 15, tvOS 15, *)
extension Substring: AttributedStringBuilder.Snip {}


@available(macOS 12, iOS 15, tvOS 15, *)
public typealias ASComponent = AttributedStringComponent
@available(macOS 12, iOS 15, tvOS 15, *)
public struct AttributedStringComponent: RawRepresentable, ExpressibleByStringInterpolation, ExpressibleByStringLiteral, Withable, AttributedStringBuilder.Snip {
	public var rawValue: String

	var fontSize: Double?
	var font: OSFont? {
		fontDescriptor.flatMap { OSFont(descriptor: $0, size: fontSize ?? OSFont.systemFontSize) }
	}
	var color: OSColor?

	private var fontDescriptor: OSFontDescriptor?

	public init(
		_ rawValue: String,
		font: OSFont? = nil,
		color: OSColor? = nil
	) {
		self.rawValue = rawValue
		self.fontDescriptor = font?.fontDescriptor
		self.color = color
	}

	public init(rawValue: String) {
		self.init(rawValue)
	}

	public init(stringLiteral value: String) {
		self.init(value)
	}

	public func withFont(_ font: OSFont) -> AttributedStringComponent {
		let new = self.with {
			$0.fontDescriptor = font.fontDescriptor
		}
		return new
	}

	public func withFontSize(_ fontSize: Double) -> AttributedStringComponent {
		let new = self.with {
			$0.fontSize = fontSize
		}
		return new
	}

	public func withColor(_ color: OSColor) -> AttributedStringComponent {
		let new = self.with {
			$0.color = color
		}
		return new
	}

	public func withFontDescriptor(_ block: (inout OSFontDescriptor) -> Void) -> AttributedStringComponent {
		var newDescriptor = fontDescriptor ?? OSFontDescriptor()
		block(&newDescriptor)
		return self.with {
			$0.fontDescriptor = newDescriptor
		}
	}

	public func withItalics(_ flag: Bool = true) -> AttributedStringComponent {
		var new = self
		let baseDescriptor = new.fontDescriptor ?? OSFontDescriptor()
		var traits = baseDescriptor.symbolicTraits
		let trait: OSFontDescriptor.SymbolicTraits.Element
		#if os(macOS)
		trait = .italic
		#else
		trait = .traitItalic
		#endif
		if flag {
			traits.insert(trait)
		} else {
			traits.remove(trait)
		}
		new.fontDescriptor = baseDescriptor.withSymbolicTraits(traits)
		return new
	}

	public func snippetToAttributedString() -> AttributedString {
		let container = AttributeContainer().with {
			if let font = fontDescriptor
				.map({ OSFont(descriptor: $0, size: fontSize ?? OSFont.systemFontSize) }) {
				$0.font = font
			}
			if let color = color {
				$0.foregroundColor = color
			}
		}

		return AttributedString(rawValue, attributes: container)
	}
}
#endif
