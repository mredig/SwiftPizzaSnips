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
	public static func buildBlock(_ components: AttributedStringComponent...) -> AttributedString {
		components
			.map {
				var container = AttributeContainer()
				container.font = $0.font
				container.foregroundColor = $0.color
				return AttributedString($0.rawValue, attributes: container)
			}
			.reduce(into: AttributedString(), { $0.append($1) })
	}

	public static func buildEither(first component: AttributedString) -> AttributedString {
		component
	}

	public static func buildEither(second component: AttributedString) -> AttributedString {
		component
	}

	public static func buildOptional(_ component: AttributedString?) -> AttributedString {
		component ?? AttributedString()
	}

	public static func buildArray(_ components: [AttributedString]) -> AttributedString {
		components.reduce(into: AttributedString(), { $0.append($1) })
	}
}

@available(macOS 12, iOS 15, tvOS 15, *)
extension AttributedString {
	public init(@AttributedStringBuilder builder: () -> AttributedString) {
		self = builder()
	}
}

public typealias ASComponent = AttributedStringComponent
public struct AttributedStringComponent: RawRepresentable, ExpressibleByStringInterpolation, ExpressibleByStringLiteral, Withable {
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
		self.fontDescriptor = font?.fontDescriptor ?? OSFont.systemFont(ofSize: OSFont.systemFontSize).fontDescriptor
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
}
#endif
