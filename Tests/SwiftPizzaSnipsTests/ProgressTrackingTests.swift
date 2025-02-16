import Testing
import Foundation
import SwiftPizzaSnips

struct ProgressTrackingTests {
	// Test all scenarios for fractional range clamping
	@Test("Fractional value clamps between 0.0 and 1.0")
	func fractionValueClamps0To1() {
		let progress = SimpleProgress()
		progress.setTotalUnitCount(100)

		progress.updateFractionCompleted(-0.5)
		#expect(progress.fractionCompleted == 0.0)
		#expect(progress.completedUnitCount == 0)

		progress.updateFractionCompleted(1.5)
		#expect(progress.fractionCompleted == 1.0)
		#expect(progress.completedUnitCount == 100)
	}

	// Test completed count exceeding total
	@Test("Completed unit count cannot exceed total")
	func completedUnitCountCannotExceedTotal() {
		let progress = SimpleProgress()
		progress.setTotalUnitCount(100)

		progress.updateCompletedValue(50)
		#expect(progress.completedUnitCount == 50)
		#expect(progress.fractionCompleted == 0.5)

		progress.updateCompletedValue(200)
		#expect(progress.completedUnitCount == 100) // Should clamp
		#expect(progress.fractionCompleted == 1.0)
	}

	// Test reducing total unit count to below completed count
	@Test("Reducing total count clamps completed count")
	func totalCannotBeLessThanCompleted() {
		let progress = SimpleProgress()
		progress.setTotalUnitCount(100)
		progress.updateCompletedValue(80)

		progress.setTotalUnitCount(50)
		#expect(progress.totalUnitCount == 50)
		#expect(progress.completedUnitCount == 50) // Clamped to new total
		#expect(progress.fractionCompleted == 1.0)
	}

	// Test progress at edge conditions
	@Test("Fractional value tested at 0, 0.5, and 1")
	func fractionalEdgeCases() {
		let progress = SimpleProgress()
		progress.setTotalUnitCount(100)

		progress.updateFractionCompleted(0.0)
		#expect(progress.completedUnitCount == 0)
		#expect(progress.fractionCompleted == 0.0)

		progress.updateFractionCompleted(0.5)
		#expect(progress.completedUnitCount == 50)
		#expect(progress.fractionCompleted == 0.5)

		progress.updateFractionCompleted(1.0)
		#expect(progress.completedUnitCount == 100)
		#expect(progress.fractionCompleted == 1.0)
	}

	@Test func setTotalUnitCount() {
		let progress = SimpleProgress()
		progress.setTotalUnitCount(100)

		#expect(progress.totalUnitCount == 100)
		#expect(progress.completedUnitCount == 0)
		#expect(progress.fractionCompleted == 0.0)
	}

	@Test func updateCompletedValue() {
		let progress = SimpleProgress()
		progress.setTotalUnitCount(100)
		progress.updateCompletedValue(40)

		#expect(progress.completedUnitCount == 40)
		#expect(progress.fractionCompleted == 0.4)
	}

	@Test func updateFractionCompleted() {
		let progress = SimpleProgress()
		progress.setTotalUnitCount(100)
		progress.updateFractionCompleted(0.75)

		#expect(progress.completedUnitCount == 75)
		#expect(progress.fractionCompleted == 0.75)
	}

	@Test func markFinished() {
		let progress = SimpleProgress()
		progress.setTotalUnitCount(100)
		progress.markFinished()

		#expect(progress.completedUnitCount == 100)
		#expect(progress.fractionCompleted == 1.0)
	}

	@Test func onProgressUpdateCallbackSimpleProgress() async throws {
		let progress = SimpleProgress()
		progress.setTotalUnitCount(100)

		await confirmation { confirmed in
			progress.onProgressUpdate { updatedProgress in
				#expect(updatedProgress.fractionCompleted == 1.0)
				confirmed()
			}

			progress.markFinished()
		}
	}

	@Test func addChildProgress() throws {
		let tracker = MultiProgressTracker()
		let child1 = SimpleProgress()
		child1.setTotalUnitCount(100)
		let child2 = SimpleProgress()
		child2.setTotalUnitCount(50)

		try tracker.addChildProgress(child1, withContributionUnitsAddedToTotal: 100)
		try tracker.addChildProgress(child2, withContributionUnitsAddedToTotal: 50)

		#expect(tracker.children.count == 2)
		#expect(tracker.totalUnitCount == 150)
	}

	@Test func childProgressUpdatesReflectedInParent() throws {
		let tracker = MultiProgressTracker()
		let child = SimpleProgress()
		child.setTotalUnitCount(100)
		try tracker.addChildProgress(child, withContributionUnitsAddedToTotal: 1000)

		child.updateCompletedValue(40)

		#expect(tracker.completedUnitCount == 400)
		#expect(tracker.fractionCompleted == 40.0 / 100.0)
	}

	@Test func childProgressUpdatesReflectedInParent2() throws {
		let tracker = MultiProgressTracker()
		let child = SimpleProgress()
		child.setTotalUnitCount(100)
		try tracker.addChildProgress(child) // use child total by default

		child.updateCompletedValue(40)

		#expect(tracker.completedUnitCount == 40)
		#expect(tracker.fractionCompleted == 40.0 / 100.0)
	}

	@Test func addChildWithExistingParentThrowsError() {
		let parent1 = MultiProgressTracker()
		let parent2 = MultiProgressTracker()
		let child = SimpleProgress()

		#expect(throws: Never.self, performing: {
			try parent1.addChildProgress(child, withContributionUnitsAddedToTotal: 100)
		})
		#expect(throws: MultiProgressTracker.Error.childProgressAlreadyHasParent) {
			try parent2.addChildProgress(child, withContributionUnitsAddedToTotal: 50)
		}
	}

	@Test func onProgressUpdateCallbackMultiProgressTracker() async throws {
		let tracker = MultiProgressTracker()
		let child = SimpleProgress()
		try tracker.addChildProgress(child, withContributionUnitsAddedToTotal: 100)

		await confirmation { confirm in
			tracker.onProgressUpdate { updatedProg in
				#expect(updatedProg.fractionCompleted == 0.5)
				confirm()
			}

			child.updateFractionCompleted(0.5)
		}
	}
}
