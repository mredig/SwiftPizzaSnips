import Testing
import SwiftPizzaSnips
import Foundation

@Suite(.serialized)
struct MutexLockTests {
	let iterations = 999999

	class UnsafeLiar: @unchecked Sendable {
		var value = 0
	}

	@Test func baseline() async throws {
		let liar = UnsafeLiar()
		DispatchQueue.concurrentPerform(iterations: iterations) { _ in
			var localCopy = liar.value
			localCopy += 1
			liar.value = localCopy
		}
		print("without locking: \(liar.value)")

		#expect(iterations > liar.value, "If these values are identical, there aren't enough iterations to accurately test")
	}

	@Test func deferralMethod() async throws {
		let myLock = MutexLock()

		let liar = UnsafeLiar()
		DispatchQueue.concurrentPerform(iterations: iterations) { _ in
			myLock.lock()
			defer { myLock.unlock() }
			var localCopy = liar.value
			localCopy += 1
			liar.value = localCopy
		}

		#expect(iterations == liar.value, "If the lock works, there should be no race conditions causing iterations to get lost.")
	}

	@Test func withLock() async throws {
		let myLock = MutexLock()

		let liar = UnsafeLiar()
		DispatchQueue.concurrentPerform(iterations: iterations) { i in
			if i == 999999 - 100 {
				myLock.debugMode = true
			}
			myLock.withLock {
				var localCopy = liar.value
				localCopy += 1
				liar.value = localCopy
			}
		}

		#expect(iterations == liar.value, "If the lock works, there should be no race conditions causing iterations to get lost.")
	}
}
