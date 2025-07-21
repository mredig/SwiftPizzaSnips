@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 6.0, *)
public struct TimeoutTask<Success: Sendable, Failure: TimedOutError>: Sendable, Hashable {
	private let underlyingTask: ETask<Success, Failure>

	/// Same as `Task.value`
	public var value: Success {
		get async throws(Failure) {
			try await result.get()
		}
	}

	/// Same as `Task.result`
	public var result: Result<Success, Failure> {
		get async {
			do {
				let resultA = await underlyingTask.result
				let success = try resultA.get()
				return .success(success)
			} catch {
				return .failure(error)
			}
		}
	}

	/// Same as `Task.isCancelled`
	public var isCancelled: Bool { underlyingTask.isCancelled }

	/// Basics are the same as `Task.init`, but `shouldUseStructuredTasks` differs.
	///
	/// When `shouldUseStructuredTasks` is set to `true`, that means that the whole task tree is created with structured
	/// tasks (although, any child `Task`s of `operation` are at your mercy). This is usually the *right* strategy,
	/// however there are some potential exceptions.
	///
	/// When using code that isn't async/await aware, or maybe even some code that *is*, the `Task` won't respect the
	/// `isCancelled` state of the `Task`. The consequence of this is that, when using structured tasks, even the
	/// cancelled branch of the tree must finish everything before the parent task can complete. So, for example, if a
	/// task were to `usleep()` for `10` seconds, but your timeout was set to `1` second, you would still have to
	/// wait the entire `10` seconds before learning that your task timed out. The underlying code *will still* execute
	/// to completion regardless of this state here, but often times you don't care and just need to update UI and
	/// consider it a write off.
	///
	/// Contrarily, if the `usleep()` function were called in an unstructured child task, the timeout can trigger
	/// immediately upon firing, informing the call site that the task timed out after the expected `1` second interval.
	///
	/// Of note, when `shouldUseStructuredTasks` is false, it is only the `operation` closure that is passed to the
	/// unstructured task (and therefore any children of that `Task`), but the rest of the tree remains structured.
	public init(
		priority: TaskPriority? = nil,
		timeout: ContinuousClock.Instant.Duration,
		shouldUseStructuredTasks: Bool = true,
		@_implicitSelfCapture operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) {
		self.init(
			detached: false,
			priority: priority,
			timeout: timeout,
			shouldUseStructuredTasks: shouldUseStructuredTasks,
			operation: operation)
	}

	private init(
		detached: Bool,
		priority: TaskPriority?,
		timeout: ContinuousClock.Instant.Duration,
		shouldUseStructuredTasks: Bool,
		@_implicitSelfCapture operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) {
		let timeoutOperation = { () async throws(Failure) -> Success in
			if shouldUseStructuredTasks {
				return try await Self.structuredGroupTask(timeout: timeout, operation: operation)
			} else {
				return try await Self.unstructuredGroupTask(timeout: timeout, operation: operation)
			}
		}

		if detached {
			underlyingTask = ETask.detached(priority: priority, operation: timeoutOperation)
		} else {
			underlyingTask = ETask(priority: priority, operation: timeoutOperation)
		}
	}

	private static func structuredGroupTask(
		timeout: ContinuousClock.Instant.Duration,
		@_implicitSelfCapture operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) async throws(Failure) -> Success {
		do {
			return try await withThrowingTaskGroup(of: Success.self) { group in
				group.addTask {
					try await operation()
				}

				group.addTask {
					do {
						try await Task.sleep(for: timeout)
						throw Failure.timedOut
					} catch is CancellationError {
						throw Failure.timedOut
					}
				}

				defer { group.cancelAll() }
				guard
					let result = try await group.next()
				else { throw Failure.timedOut }
				return result
			}
		} catch let error as Failure {
			throw error
		} catch is CancellationError {
			throw .cancelled
		} catch {
			fatalError(
				"""
				Expected error of type \(Failure.self) but got an error of \(type(of: error)). \
				However, here's the error: \(error)
				""")
		}
	}

	private static func unstructuredGroupTask(
		timeout: ContinuousClock.Instant.Duration,
		@_implicitSelfCapture operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) async throws(Failure) -> Success {
		do {
			let continuationProxy = ContinuationProxy<Success, Failure>()

			let taskWrapper = Task {
				do throws(Failure) {
					let result = try await operation()
					continuationProxy.resume(returning: result)
				} catch {
					continuationProxy.resume(throwing: error)
				}
			}

			return try await withThrowingTaskGroup(of: Success.self) { group in
				group.addTask {
					try await withTaskCancellationHandler(
						operation: {
							try await withUnsafeThrowingContinuation { continuation in
								continuationProxy.setContinuation(continuation)
							}
						},
						onCancel: {
							taskWrapper.cancel()
							continuationProxy.resume(throwing: .cancelled)
						})
				}

				group.addTask {
					try await Task.sleep(for: timeout)
					throw Failure.timedOut
				}

				defer { group.cancelAll() }
				guard
					let result = try await group.next()
				else { throw Failure.timedOut }
				return result
			}
		} catch let error as Failure {
			throw error
		} catch {
			fatalError(
				"""
				Expected error of type \(Failure.self) but got an error of \(type(of: error)). \
				However, here's the error: \(error)
				""")
		}
	}

	/// Basics are the same as `Task.detached`, but `shouldUseStructuredTasks` differs.
	///
	/// When `shouldUseStructuredTasks` is set to `true`, that means that the whole task tree is created with structured
	/// tasks (although, any child `Task`s of `operation` are at your mercy). This is usually the *right* strategy,
	/// however there are some potential exceptions.
	///
	/// When using code that isn't async/await aware, or maybe even some code that *is*, the `Task` won't respect the
	/// `isCancelled` state of the `Task`. The consequence of this is that, when using structured tasks, even the
	/// cancelled branch of the tree must finish everything before the parent task can complete. So, for example, if a
	/// task were to `usleep()` for `10` seconds, but your timeout was set to `1` second, you would still have to
	/// wait the entire `10` seconds before learning that your task timed out. The underlying code *will still* execute
	/// to completion regardless of this state here, but often times you don't care and just need to update UI and
	/// consider it a write off.
	///
	/// Contrarily, if the `usleep()` function were called in an unstructured child task, the timeout can trigger
	/// immediately upon firing, informing the call site that the task timed out after the expected `1` second interval.
	///
	/// Of note, when `shouldUseStructuredTasks` is false, it is only the `operation` closure that is passed to the
	/// unstructured task (and therefore any children of that `Task`), but the rest of the tree remains structured.
	public static func detached(
		priority: TaskPriority? = nil,
		timeout: ContinuousClock.Instant.Duration,
		shouldUseStructuredTasks: Bool = true,
		operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) -> TimeoutTask<Success, Failure> {
		Self.init(
			detached: true,
			priority: priority,
			timeout: timeout,
			shouldUseStructuredTasks: shouldUseStructuredTasks,
			operation: operation)
	}

	/// Same as `Task.cancel`
	public func cancel() {
		underlyingTask.cancel()
	}
}

public protocol TimedOutError: Error {
	static var timedOut: Self { get }
	static var cancelled: Self { get }
}
