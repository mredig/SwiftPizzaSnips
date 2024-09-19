#if os(macOS)
import AppKit

public typealias OSView = NSView
public typealias ConstraintPriority = NSLayoutConstraint.Priority

public typealias OSColor = NSColor
public typealias OSFont = NSFont
public typealias OSFontDescriptor = NSFontDescriptor

#elseif os(iOS) || os(tvOS)
import UIKit

public typealias OSView = UIView
public typealias ConstraintPriority = UILayoutPriority

public typealias OSColor = UIColor
public typealias OSFont = UIFont
public typealias OSFontDescriptor = UIFontDescriptor

#endif
