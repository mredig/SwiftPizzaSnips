import Foundation

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
public protocol ProgressProvider: AnyObject, CustomStringConvertible {
	var totalUnitCount: UInt64 { get }
	var completedUnitCount: UInt64 { get }
	var fractionCompleted: Double { get }
	var foundationProgress: Progress { get }
	// Refrain from changing this value yourself. Let the parent handle itself.
	var parent: ProgressProvider? { get set }

	func onProgressUpdate(_ action: @escaping @Sendable (any ProgressProvider) -> Void)

	/// This should be called automatically on updates. Typically there would be no need to call this yourself, but if you want to here it is.
	func sendProgressUpdates()
}

private let fractionFormatter = NumberFormatter().with {
	$0.numberStyle = .percent
	$0.maximumFractionDigits = 4
}
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
extension ProgressProvider {
	public var superDescription: String {
		"""
		\(Self.self): \(completedUnitCount) / \(totalUnitCount) (\(fractionFormatter.string(from: fractionCompleted as NSNumber) ?? ""))
		"""
	}

	public var description: String {
		superDescription
	}
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
fileprivate extension ProgressProvider {
	func _fractionCompletedValue() -> Double {
		let fraction = Double(completedUnitCount) / Double(totalUnitCount)
		if fraction.isNaN || fraction.isSignalingNaN {
			return 0
		} else if fraction.isInfinite {
			return 1
		}

		return fraction
	}

	func _updateFoundationProgress() {
		let total = foundationProgress.totalUnitCount
		let completed = Int64(fractionCompleted * Double(total))
		foundationProgress.completedUnitCount = completed
	}
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
public protocol ProgressBasicIngress: ProgressProvider {
	func markFinished()
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
public protocol ProgressFractionIngress: ProgressBasicIngress {
	func updateFractionCompleted(_ value: Double)
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
public protocol ProgressIntegralIngress: ProgressBasicIngress {
	func setTotalUnitCount(_ total: UInt64)
	func updateCompletedValue(_ value: UInt64)
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
public protocol ProgressIngress: ProgressFractionIngress & ProgressIntegralIngress {}


@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
public final class SimpleProgress: ProgressIngress {
	private let lock = NSLock()
	private let blockLock = NSLock()
	public let foundationProgress = Progress(totalUnitCount: 1_000_000)
	public private(set) var totalUnitCount: UInt64 = 0
	public private(set) var completedUnitCount: UInt64 = 0
	public private(set) var fractionCompleted: Double = 0

	public weak var parent: (any ProgressProvider)?

	private var updateBlocks: [@Sendable (any ProgressProvider) -> Void] = []

	public init(completedUnitCount: UInt64 = 0, totalUnitCount: UInt64 = 0) {
		lock.lock()
		defer { lock.unlock() }
		let comp = min(completedUnitCount, totalUnitCount)
		let total = max(completedUnitCount, totalUnitCount)
		self.fractionCompleted = 0
		self.completedUnitCount = comp
		self.totalUnitCount = total

		self.fractionCompleted = _fractionCompletedValue()
		_updateFoundationProgress()
	}

	public convenience init(fractionCompleted: Double, totalUnitCount: UInt64 = 1_000_000) {
		let fraction = max(min(fractionCompleted, 1), 0)
		let completed = fraction * Double(totalUnitCount)

		self.init(completedUnitCount: UInt64(completed), totalUnitCount: totalUnitCount)
	}

	public func onProgressUpdate(_ action: @escaping @Sendable (any ProgressProvider) -> Void) {
		blockLock.withLock {
			updateBlocks.append(action)
		}
	}

	public func markFinished() {
		updateFractionCompleted(1)
	}

	public func updateFractionCompleted(_ value: Double) {
		guard value.isFinite else { return }
		lock.withLock {
			let newValue = max(min(value, 1), 0)

			let completed = UInt64(newValue * Double(totalUnitCount))
			completedUnitCount = completed
			fractionCompleted = newValue
			_updateFoundationProgress()
			sendProgressUpdates()
		}
	}

	public func setTotalUnitCount(_ total: UInt64) {
		lock.withLock {
			totalUnitCount = total

			completedUnitCount = min(completedUnitCount, total)

			self.fractionCompleted = _fractionCompletedValue()
			_updateFoundationProgress()
			sendProgressUpdates()
		}
	}

	public func updateCompletedValue(_ value: UInt64) {
		lock.withLock {
			completedUnitCount = min(value, totalUnitCount)
			self.fractionCompleted = _fractionCompletedValue()
			_updateFoundationProgress()
			sendProgressUpdates()
		}
	}

	/// This will be called automatically on updates. Typically there would be no need to call this yourself, but if you want to here it is.
	public func sendProgressUpdates() {
		blockLock.withLock {
			for updateBlock in updateBlocks {
				updateBlock(self)
			}
		}
	}
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
public final class MultiProgressTracker: ProgressProvider {
	private let lock = NSLock()
	private let blockLock = NSLock()
	public let foundationProgress = Progress(totalUnitCount: 1_000_000)
	public private(set) var totalUnitCount: UInt64 = 0
	public private(set) var completedUnitCount: UInt64 = 0
	public private(set) var fractionCompleted: Double = 0

	private var updateBlocks: [@Sendable (any ProgressProvider) -> Void] = []

	public weak var parent: (any ProgressProvider)?
	public private(set) var children: [(provider: any ProgressProvider, contributionUnits: UInt64)] = []

	public var description: String {
		let children = children
			.map { "\($0.provider.description) (\($0.contributionUnits) contributionUnits)"}
			.joined(separator: "\n")
			.prefixingLines(with: "\t")
		return [
			superDescription,
			children,
		]
			.joined(separator: "\n")
	}

	public init() {}

	public func addChildProgress(_ progress: ProgressProvider, withContributionUnitsAddedToTotal contributionUnits: UInt64? = nil) throws(Error) {
		blockLock.lock()
		defer { blockLock.unlock() }
		guard progress.parent == nil else { throw .childProgressAlreadyHasParent }
		progress.parent = self

		let contributionUnits = contributionUnits ?? progress.totalUnitCount
		totalUnitCount += contributionUnits
		children.append((progress, contributionUnits))
		progress.onProgressUpdate { [weak self] _ in
			guard let self else { return }
			lock.withLock { [self] in
				self._updateChildContributions()
				self.sendProgressUpdates()
			}
		}
		lock.withLock(_updateChildContributions)
	}

	public func onProgressUpdate(_ action: @escaping @Sendable (any ProgressProvider) -> Void) {
		blockLock.withLock {
			updateBlocks.append(action)
		}
	}

	private func _updateChildContributions() {
		completedUnitCount = children.reduce(0, { $0 + UInt64($1.provider.fractionCompleted * Double($1.contributionUnits)) })
		fractionCompleted = _fractionCompletedValue()
		_updateFoundationProgress()
	}

	/// This will be called automatically on updates. Typically there would be no need to call this yourself, but if you want to here it is.
	public func sendProgressUpdates() {
		blockLock.withLock {
			for updateBlock in updateBlocks {
				updateBlock(self)
			}
		}
	}

	public enum Error: Swift.Error {
		case childProgressAlreadyHasParent
	}
}
