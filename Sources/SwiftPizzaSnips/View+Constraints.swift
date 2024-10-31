#if !canImport(FoundationNetworking) && !os(watchOS)
#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif


public extension OSView {
	/**
	 requires that the childview is ALREADY a child view
	 */
	@available(macOS 10.15, *)
	@discardableResult
	func constrain(
		_ childView: OSView,
		inset: NSDirectionalEdgeInsets = .zero,
		safeAreaDirections: DirectionalToggle = .none,
		priorities: DirectionalEdgeConstraintPriorities = .required,
		directions: DirectionalToggle = .all) -> [NSLayoutConstraint] {
			assert(childView.isSubviewOf(self), "\(childView) is not a subview of \(self). Cannot create constraints.")

			childView.translatesAutoresizingMaskIntoConstraints = false

			var constraints: [NSLayoutConstraint] = []

			let guide: AnchorProvider = {
				if #available(macOS 11.0, *) {
					safeAreaLayoutGuide
				} else {
					self
				}
			}()

			if directions.top == .create {
				let topAnchor = safeAreaDirections.top == .create ? guide.topAnchor : topAnchor
				constraints += [
					childView.topAnchor.constraint(equalTo: topAnchor, constant: inset.top)
						.withPriority(priorities.top)
				]
			}

			if directions.leading == .create {
				let leadingAnchor = safeAreaDirections.leading == .create ? guide.leadingAnchor : leadingAnchor
				constraints += [
					childView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.leading)
						.withPriority(priorities.leading)
				]
			}
			if directions.bottom == .create {
				let bottomAnchor = safeAreaDirections.bottom == .create ? guide.bottomAnchor : bottomAnchor
				constraints += [
					bottomAnchor.constraint(equalTo: childView.bottomAnchor, constant: inset.bottom)
						.withPriority(priorities.bottom)
				]
			}
			if directions.trailing == .create {
				let trailingAnchor = safeAreaDirections.trailing == .create ? guide.trailingAnchor : trailingAnchor
				constraints += [
					trailingAnchor.constraint(equalTo: childView.trailingAnchor, constant: inset.trailing)
						.withPriority(priorities.trailing)
				]
			}

			return constraints
		}

	private func isSubviewOf(_ possibleSuperview: OSView) -> Bool {
		var current: OSView? = self
		while let sub = current {
			defer { current = sub.superview }
			guard
				sub.superview === possibleSuperview
			else { continue }
			return true
		}
		return false
	}
}

public extension Array where Element == NSLayoutConstraint {
	func activate() { NSLayoutConstraint.activate(self) }
}

@available(macOS 10.15, *)
public extension NSDirectionalEdgeInsets {

	static let zero = NSDirectionalEdgeInsets()
	static let eight = NSDirectionalEdgeInsets(scalar: 8)
	static let sixteen = NSDirectionalEdgeInsets(scalar: 16)

	init(horizontal: Double = 0, vertical: Double = 0) {
		self.init(
			top: vertical,
			leading: horizontal,
			bottom: vertical,
			trailing: horizontal)
	}

	init(scalar: Double = 0) {
		self.init(
			top: scalar,
			leading: scalar,
			bottom: scalar,
			trailing: scalar)
	}
}

public struct DirectionalMeasurement<Measurement>: Withable {
	public var top: Measurement
	public var leading: Measurement
	public var bottom: Measurement
	public var trailing: Measurement

	public init(
		top: Measurement,
		leading: Measurement,
		bottom: Measurement,
		trailing: Measurement) {
			self.top = top
			self.leading = leading
			self.bottom = bottom
			self.trailing = trailing
		}

	public init(
		horizontal: Measurement,
		vertical: Measurement) {
			self.init(
				top: vertical,
				leading: horizontal,
				bottom: vertical,
				trailing: horizontal)
		}

	public init(uniform: Measurement) {
		self.init(
			horizontal: uniform,
			vertical: uniform)
	}
}

public typealias DirectionalEdgeConstraintPriorities = DirectionalMeasurement<ConstraintPriority>
public extension DirectionalEdgeConstraintPriorities {
	static let required = DirectionalEdgeConstraintPriorities(uniform: .required)
	static let defaultHigh = DirectionalEdgeConstraintPriorities(uniform: .defaultHigh)
	static let defaultLow = DirectionalEdgeConstraintPriorities(uniform: .defaultLow)

	init(
		top: ConstraintPriority = .required,
		leading: ConstraintPriority = .required,
		bottom: ConstraintPriority = .required,
		trailing: ConstraintPriority = .required) {
			self.top = top
			self.leading = leading
			self.bottom = bottom
			self.trailing = trailing
		}
	
	init(
		horizontal: ConstraintPriority = .required,
		vertical: ConstraintPriority = .required) {
			self.init(
				top: vertical,
				leading: horizontal,
				bottom: vertical,
				trailing: horizontal)
		}
	
	init(uniform: ConstraintPriority = .required) {
		self.init(
			horizontal: uniform,
			vertical: uniform)
	}
	
	init(floatLiteral value: Float) {
		self.init(uniform: ConstraintPriority(value))
	}
}

public enum DirectionalToggleOption {
	case create
	case skip
}
public typealias DirectionalToggle = DirectionalMeasurement<DirectionalToggleOption>
extension DirectionalToggle {
	public static let all = DirectionalToggle(uniform: .create)
	public static let horizontal = DirectionalToggle(horizontal: .create, vertical: .skip)
	public static let vertical = DirectionalToggle(horizontal: .skip, vertical: .create)

	public static let top = DirectionalToggle(uniform: .skip).with { $0.top = .create }
	public static let bottom = DirectionalToggle(uniform: .skip).with { $0.bottom = .create }
	public static let leading = DirectionalToggle(uniform: .skip).with { $0.leading = .create }
	public static let trailing = DirectionalToggle(uniform: .skip).with { $0.trailing = .create }

	public static let none = DirectionalToggle(uniform: .skip)
}
#endif

private protocol AnchorProvider {
	var topAnchor: NSLayoutYAxisAnchor { get }
	var bottomAnchor: NSLayoutYAxisAnchor { get }
	var leadingAnchor: NSLayoutXAxisAnchor { get }
	var trailingAnchor: NSLayoutXAxisAnchor { get }
	var leftAnchor: NSLayoutXAxisAnchor { get }
	var rightAnchor: NSLayoutXAxisAnchor { get }

	var centerXAnchor: NSLayoutXAxisAnchor { get }
	var centerYAnchor: NSLayoutYAxisAnchor { get }

	var heightAnchor: NSLayoutDimension { get }
	var widthAnchor: NSLayoutDimension { get }
}

extension OSView: AnchorProvider {}

@available(macOS 11, *)
extension NSLayoutGuide: AnchorProvider {}
