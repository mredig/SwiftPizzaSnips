import Foundation

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
public protocol ProgressProvider: AnyObject {
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

	public init() {}

	public func onProgressUpdate(_ action: @escaping @Sendable (any ProgressProvider) -> Void) {
		blockLock.withLock {
			updateBlocks.append(action)
		}
	}

	public func markFinished() {
		updateFractionCompleted(1)
	}

	public func updateFractionCompleted(_ value: Double) {
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

			let fraction = Double(completedUnitCount) / Double(total)
			fractionCompleted = fraction
			_updateFoundationProgress()
			sendProgressUpdates()
		}
	}

	public func updateCompletedValue(_ value: UInt64) {
		lock.withLock {
			completedUnitCount = min(value, totalUnitCount)
			let fraction = Double(completedUnitCount) / Double(totalUnitCount)
			fractionCompleted = fraction
			_updateFoundationProgress()
			sendProgressUpdates()
		}
	}

	private func _updateFoundationProgress() {
		let total = foundationProgress.totalUnitCount
		let completed = Int64(fractionCompleted * Double(total))
		foundationProgress.completedUnitCount = completed
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
	public private(set) var children: [any ProgressProvider] = []

	public init() {}

	public func addChildProgress(_ progress: ProgressProvider, withContributionUnitsAddedToTotal contributionUnits: UInt64? = nil) throws(Error) {
		blockLock.lock()
		defer { blockLock.unlock() }
		guard progress.parent == nil else { throw .childProgressAlreadyHasParent }
		progress.parent = self

		let contributionUnits = contributionUnits ?? progress.totalUnitCount
		let doubleContribUnits = Double(contributionUnits)
		totalUnitCount += contributionUnits
		children.append(progress)
		progress.onProgressUpdate { [weak self] _ in
			guard let self else { return }
			lock.withLock { [self] in
				self.completedUnitCount = self.children.reduce(0, { $0 + UInt64($1.fractionCompleted * doubleContribUnits) })
				self.fractionCompleted = Double(self.completedUnitCount) / Double(self.totalUnitCount)
				self._updateFoundationProgress()
				self.sendProgressUpdates()
			}
		}
	}

	public func onProgressUpdate(_ action: @escaping @Sendable (any ProgressProvider) -> Void) {
		blockLock.withLock {
			updateBlocks.append(action)
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

	private func _updateFoundationProgress() {
		let total = foundationProgress.totalUnitCount
		let completed = Int64(fractionCompleted * Double(total))
		foundationProgress.completedUnitCount = completed
	}

	public enum Error: Swift.Error {
		case childProgressAlreadyHasParent
	}
}
