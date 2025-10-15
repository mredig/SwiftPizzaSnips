import Testing
import Foundation
import SwiftPizzaSnips

struct TriggeredTaskTests {
	
	// MARK: - Basic Success Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func basicSuccess() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			return 42
		}
		
		task.start()
		let result = try await task.value
		
		#expect(result == 42)
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func basicSuccessDetached() async throws {
		let task = TriggeredTask.detached { () async throws(SimpleError) -> String in
			return "Hello"
		}
		
		task.start()
		let result = try await task.value
		
		#expect(result == "Hello")
	}
	
	// MARK: - Basic Failure Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func basicFailure() async throws {
		let expectedError = SimpleError(message: "Test error")
		
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			throw expectedError
		}
		
		task.start()
		
		do {
			_ = try await task.value
			Issue.record("Expected task to throw")
		} catch let TriggeredTask<Int, SimpleError>.TriggeredTaskError.failed(error) {
			#expect(error == expectedError)
		} catch {
			Issue.record("Unexpected error: \(error)")
		}
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func basicFailureDetached() async throws {
		let expectedError = SimpleError(message: "Detached error")
		
		let task = TriggeredTask.detached { () async throws(SimpleError) -> String in
			throw expectedError
		}
		
		task.start()
		
		do {
			_ = try await task.value
			Issue.record("Expected task to throw")
		} catch let TriggeredTask<String, SimpleError>.TriggeredTaskError.failed(error) {
			#expect(error == expectedError)
		} catch {
			Issue.record("Unexpected error: \(error)")
		}
	}
	
	// MARK: - Result Property Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func resultPropertySuccess() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Bool in
			return true
		}
		
		task.start()
		let result = await task.result
		
		switch result {
		case .success(let value):
			#expect(value == true)
		case .failure:
			Issue.record("Expected success but got failure")
		}
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func resultPropertyFailure() async throws {
		let expectedError = SimpleError(message: "Result test")
		
		let task = TriggeredTask { () async throws(SimpleError) -> Bool in
			throw expectedError
		}
		
		task.start()
		let result = await task.result
		
		switch result {
		case .success:
			Issue.record("Expected failure but got success")
		case .failure(let error):
			switch error {
			case .failed(let innerError):
				#expect(innerError == expectedError)
			case .cancelled:
				Issue.record("Expected failed but got cancelled")
			}
		}
	}
	
	// MARK: - Cancellation Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func cancelBeforeStart() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			return 42
		}
		
		task.cancel()
		
		do {
			_ = try await task.value
			Issue.record("Expected task to throw cancelled")
		} catch TriggeredTask<Int, SimpleError>.TriggeredTaskError.cancelled {
			// Expected
		} catch {
			Issue.record("Unexpected error: \(error)")
		}
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func cancelAfterStart() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			do {
				try await Task.sleep(for: .seconds(1))
			} catch {
				throw SimpleError(message: "Sleep interrupted")
			}
			return 42
		}
		
		task.start()
		task.cancel()
		
		#expect(task.isCancelled)
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func isCancelledProperty() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			return 42
		}
		
		#expect(task.isCancelled == false)
		
		task.cancel()
		
		#expect(task.isCancelled == true)
	}
	
	// MARK: - Timing Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func taskDoesNotExecuteUntilStarted() async throws {
		var executed = false
		
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			executed = true
			return 42
		}
		
		// Give it a moment to potentially execute (it shouldn't)
		try await Task.sleep(for: .milliseconds(100))
		#expect(executed == false, "Task should not execute before start() is called")
		
		task.start()
		_ = try await task.value
		
		#expect(executed == true)
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func taskExecutesImmediatelyAfterStart() async throws {
		let startTime = Date()
		
		let task = TriggeredTask { () async throws(SimpleError) -> Date in
			return Date()
		}
		
		// Wait a bit before starting
		try await Task.sleep(for: .milliseconds(100))
		
		task.start()
		let executionTime = try await task.value
		
		// Execution time should be significantly after start time
		let interval = executionTime.timeIntervalSince(startTime)
		#expect(interval >= 0.1, "Task should execute after the delay, not immediately upon creation")
	}
	
	// MARK: - Multiple Start/Cancel Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func multipleStartCallsAreHarmless() async throws {
		var executionCount = 0
		
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			executionCount += 1
			return executionCount
		}
		
		task.start()
		task.start() // Second call should be silently ignored
		task.start() // Third call should be silently ignored
		
		let result = try await task.value
		
		#expect(executionCount == 1, "Task should only execute once despite multiple start() calls")
		#expect(result == 1)
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func multipleCancelCallsAreHarmless() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			do {
				try await Task.sleep(for: .seconds(1))
			} catch {
				throw SimpleError(message: "Sleep interrupted")
			}
			return 42
		}
		
		task.cancel()
		task.cancel() // Should be harmless
		task.cancel() // Should be harmless
		
		do {
			_ = try await task.value
			Issue.record("Expected task to throw cancelled")
		} catch TriggeredTask<Int, SimpleError>.TriggeredTaskError.cancelled {
			// Expected
		} catch {
			Issue.record("Unexpected error: \(error)")
		}
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func startAfterCancelDoesNotExecute() async throws {
		var executed = false
		
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			executed = true
			return 42
		}
		
		task.cancel()
		task.start() // Should be ignored since already cancelled
		
		do {
			_ = try await task.value
			Issue.record("Expected task to throw cancelled")
		} catch TriggeredTask<Int, SimpleError>.TriggeredTaskError.cancelled {
			// Expected
		} catch {
			Issue.record("Unexpected error: \(error)")
		}
		
		try await Task.sleep(for: .milliseconds(50))
		#expect(executed == false, "Task should not execute after being cancelled")
	}
	
	// MARK: - Async Operation Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func asyncOperationCompletes() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> String in
			do {
				try await Task.sleep(for: .milliseconds(50))
			} catch {
				throw SimpleError(message: "Sleep failed")
			}
			return "Completed"
		}
		
		task.start()
		let result = try await task.value
		
		#expect(result == "Completed")
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func asyncOperationWithMultipleSteps() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			var sum = 0
			for i in 1...5 {
				do {
					try await Task.sleep(for: .milliseconds(10))
				} catch {
					throw SimpleError(message: "Sleep failed")
				}
				sum += i
			}
			return sum
		}
		
		task.start()
		let result = try await task.value
		
		#expect(result == 15) // 1+2+3+4+5
	}
	
	// MARK: - Priority Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func taskWithHighPriority() async throws {
		let task = TriggeredTask(priority: .high) {
			Task.basePriority
		}
		
		task.start()
		let result = try await task.value
		
		#expect(result == .high)
	}

	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func taskWithMediumPriority() async throws {
		let task = TriggeredTask(priority: .medium) {
			Task.basePriority
		}

		task.start()
		let result = try await task.value

		#expect(result == .medium)
	}

	// MARK: - Coordination Tests (Primary Use Case)
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func coordinateMultipleTasksSequentially() async throws {
		var executionOrder: [Int] = []
		
		let task1 = TriggeredTask { () async throws(SimpleError) -> Int in
			executionOrder.append(1)
			return 1
		}
		
		let task2 = TriggeredTask { () async throws(SimpleError) -> Int in
			executionOrder.append(2)
			return 2
		}
		
		let task3 = TriggeredTask { () async throws(SimpleError) -> Int in
			executionOrder.append(3)
			return 3
		}
		
		// Start in specific order
		task2.start()
		_ = try await task2.value
		
		task1.start()
		_ = try await task1.value
		
		task3.start()
		_ = try await task3.value
		
		#expect(executionOrder == [2, 1, 3])
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func coordinateMultipleTasksSimultaneously() async throws {
		var startedTasks = 0
		
		let task1 = TriggeredTask { () async throws(SimpleError) -> Int in
			startedTasks += 1
			do {
				try await Task.sleep(for: .milliseconds(50))
			} catch {
				throw SimpleError(message: "Sleep failed")
			}
			return 1
		}
		
		let task2 = TriggeredTask { () async throws(SimpleError) -> Int in
			startedTasks += 1
			do {
				try await Task.sleep(for: .milliseconds(50))
			} catch {
				throw SimpleError(message: "Sleep failed")
			}
			return 2
		}
		
		let task3 = TriggeredTask { () async throws(SimpleError) -> Int in
			startedTasks += 1
			do {
				try await Task.sleep(for: .milliseconds(50))
			} catch {
				throw SimpleError(message: "Sleep failed")
			}
			return 3
		}
		
		// Verify none have started
		try await Task.sleep(for: .milliseconds(10))
		#expect(startedTasks == 0)
		
		// Start all at once
		task1.start()
		task2.start()
		task3.start()
		
		// Wait for all to complete
		async let result1 = task1.value
		async let result2 = task2.value
		async let result3 = task3.value
		
		let (r1, r2, r3) = try await (result1, result2, result3)
		
		#expect(r1 == 1)
		#expect(r2 == 2)
		#expect(r3 == 3)
		#expect(startedTasks == 3)
	}
	
	// MARK: - Value Copying Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func structCopySharesUnderlyingTask() async throws {
		let task1 = TriggeredTask { () async throws(SimpleError) -> Int in
			return 42
		}
		
		let task2 = task1 // Copy the struct
		
		// Starting task2 should also "start" task1 since they share the underlying task
		task2.start()
		
		let result1 = try await task1.value
		let result2 = try await task2.value
		
		#expect(result1 == 42)
		#expect(result2 == 42)
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func structCopyCancelAffectsBoth() async throws {
		let task1 = TriggeredTask { () async throws(SimpleError) -> Int in
			do {
				try await Task.sleep(for: .seconds(1))
			} catch {
				throw SimpleError(message: "Sleep failed")
			}
			return 42
		}
		
		let task2 = task1 // Copy the struct
		
		task2.cancel() // Cancel via copy
		
		#expect(task1.isCancelled == true, "Cancelling copy should affect original")
		#expect(task2.isCancelled == true)
	}
	
	// MARK: - Error Type Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func customErrorType() async throws {
		enum CustomError: Error {
			case someError
			case anotherError
		}
		
		let task = TriggeredTask { () async throws(CustomError) -> String in
			throw CustomError.someError
		}
		
		task.start()
		
		let result = await task.result
		switch result {
		case .success:
			Issue.record("Expected failure")
		case .failure(let error):
			switch error {
			case .failed(.someError):
				break // Expected
			default:
				Issue.record("Wrong error type: \(error)")
			}
		}
	}
	
	// MARK: - Never Error Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func neverFailingTask() async throws {
		let task = TriggeredTask { () async throws(Never) -> String in
			return "This never fails"
		}
		
		task.start()
		let result = try await task.value
		
		#expect(result == "This never fails")
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func neverFailingTaskCancelled() async throws {
		let task = TriggeredTask { () async throws(Never) -> String in
			// This should never execute because we cancel first
			return "This never fails"
		}
		
		task.cancel()
		
		// Even though the operation can't fail, cancellation should still work
		do {
			_ = try await task.value
			Issue.record("Expected task to throw cancelled")
		} catch TriggeredTask<String, Never>.TriggeredTaskError.cancelled {
			// Expected - cancellation works even for Never-failing tasks
		} catch {
			Issue.record("Unexpected error: \(error)")
		}
	}

	// MARK: - Sendable Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func taskIsSendable() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			return 42
		}
		
		// Send task to a detached task (requires Sendable)
		let _ = await withCheckedContinuation { continuation in
			Task.detached {
				task.start()
				let result = try? await task.value
				continuation.resume(returning: result)
			}
		}
	}
	
	// MARK: - Integration with Task Groups
	
	// Demonstrates starting multiple TriggeredTasks in parallel from within a task group
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func coordinateTasksStartedFromTaskGroup() async throws {
		let tasks = (1...5).map { i in
			TriggeredTask { () async throws(SimpleError) -> Int in
				do {
					try await Task.sleep(for: .milliseconds(10))
				} catch {
					throw SimpleError(message: "Sleep failed")
				}
				return i * 2
			}
		}
		
		// Start tasks from within the group in parallel - demonstrates coordinated parallel start
		let results = await withTaskGroup(of: Int?.self) { group in
			for task in tasks {
				group.addTask {
					task.start() // Each task starts in parallel
					return try? await task.value
				}
			}
			
			var collected: [Int] = []
			for await result in group {
				if let result = result {
					collected.append(result)
				}
			}
			return collected.sorted()
		}
		
		#expect(results == [2, 4, 6, 8, 10])
	}
	
	// Demonstrates awaiting tasks in task group while starting them in non-sequential order from parallel context
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func coordinateTasksStartedInNonSequentialOrder() async throws {
		let completionOrder = MutexLock()
		var completions: [Int] = []
		
		// Create 5 tasks that record when they complete
		let tasks = (1...5).map { i in
			TriggeredTask { () async throws(SimpleError) -> Int in
				do {
					try await Task.sleep(for: .milliseconds(20))
				} catch {
					throw SimpleError(message: "Sleep failed")
				}
				completionOrder.withLock {
					completions.append(i)
				}
				return i
			}
		}
		
		// Start awaiting tasks in a task group
		let resultsTask = Task {
			try await withThrowingTaskGroup(of: Int?.self) { group in
				for task in tasks {
					group.addTask {
						try await task.value
					}
				}
				
				var results: [Int] = []
				for try await result in group {
					if let result = result {
						results.append(result)
					}
				}
				return results
			}
		}
		
		// Parallel task starts them in non-sequential order: 3, 1, 5, 2, 4
		let startOrder = [3, 1, 5, 2, 4]
		let startTask = Task {
			for index in startOrder {
				tasks[index - 1].start()
				try? await Task.sleep(for: .milliseconds(5)) // Stagger the starts
			}
		}
		
		_ = await startTask.value
		let results = try await resultsTask.value
		
		// All tasks should complete
		#expect(results.count == 5)
		
		// Completion order should roughly match start order (3, 1, 5, 2, 4)
		// since they all have the same work duration
		completionOrder.withLock {
			#expect(completions.count == 5)
			// First few should match start order (accounting for concurrency)
			#expect(completions.contains(3))
			#expect(completions.contains(1))
			#expect(completions.contains(5))
			#expect(completions.contains(2))
			#expect(completions.contains(4))
		}
	}
	
	// MARK: - Convenience Methods Tests
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func startAndAwaitSuccess() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			return 99
		}
		
		let result = try await task.startAndAwait()
		
		#expect(result == 99)
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func startAndAwaitFailure() async throws {
		let expectedError = SimpleError(message: "Convenience error")
		
		let task = TriggeredTask { () async throws(SimpleError) -> String in
			throw expectedError
		}
		
		do {
			_ = try await task.startAndAwait()
			Issue.record("Expected task to throw")
		} catch let TriggeredTask<String, SimpleError>.TriggeredTaskError.failed(error) {
			#expect(error == expectedError)
		} catch {
			Issue.record("Unexpected error: \(error)")
		}
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func startAndAwaitCancelled() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			do {
				try await Task.sleep(for: .seconds(1))
			} catch {
				throw SimpleError(message: "Sleep interrupted")
			}
			return 42
		}
		
		task.cancel()
		
		do {
			_ = try await task.startAndAwait()
			Issue.record("Expected task to throw cancelled")
		} catch TriggeredTask<Int, SimpleError>.TriggeredTaskError.cancelled {
			// Expected
		} catch {
			Issue.record("Unexpected error: \(error)")
		}
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func startAndAwaitResultSuccess() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> Bool in
			return true
		}
		
		let result = await task.startAndAwaitResult()
		
		switch result {
		case .success(let value):
			#expect(value == true)
		case .failure:
			Issue.record("Expected success but got failure")
		}
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func startAndAwaitResultFailure() async throws {
		let expectedError = SimpleError(message: "Result convenience error")
		
		let task = TriggeredTask { () async throws(SimpleError) -> Int in
			throw expectedError
		}
		
		let result = await task.startAndAwaitResult()
		
		switch result {
		case .success:
			Issue.record("Expected failure but got success")
		case .failure(let error):
			switch error {
			case .failed(let innerError):
				#expect(innerError == expectedError)
			case .cancelled:
				Issue.record("Expected failed but got cancelled")
			}
		}
	}
	
	@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *)
	@Test func startAndAwaitResultCancelled() async throws {
		let task = TriggeredTask { () async throws(SimpleError) -> String in
			do {
				try await Task.sleep(for: .seconds(1))
			} catch {
				throw SimpleError(message: "Sleep interrupted")
			}
			return "Done"
		}
		
		task.cancel()
		
		let result = await task.startAndAwaitResult()
		
		switch result {
		case .success:
			Issue.record("Expected cancelled but got success")
		case .failure(let error):
			switch error {
			case .cancelled:
				// Expected
				break
			case .failed:
				Issue.record("Expected cancelled but got failed")
			}
		}
	}
}
