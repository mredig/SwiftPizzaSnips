@available(macOS 13.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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

	/// Same as `Task.init`
	public init(
		priority: TaskPriority? = nil,
		timeout: ContinuousClock.Instant.Duration,
		@_implicitSelfCapture operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) {
		self.init(detached: false, priority: priority, timeout: timeout, operation: operation)
	}

	private init(
		detached: Bool,
		priority: TaskPriority? = nil,
		timeout: ContinuousClock.Instant.Duration,
		@_implicitSelfCapture operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) {
		let timeoutOperation = { () async throws(Failure) -> Success in
			do {
				return try await withThrowingTaskGroup(of: Success.self) { group in
					group.addTask {
						try await operation()
					}

					group.addTask {
						try await Task.sleep(for: timeout)
						throw Failure.timedOut
					}

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

		if detached {
			underlyingTask = ETask.detached(priority: priority, operation: timeoutOperation)
		} else {
			underlyingTask = ETask(priority: priority, operation: timeoutOperation)
		}
	}

	/// Same as `Task.detached`
	public static func detached(
		priority: TaskPriority? = nil,
		timeout: ContinuousClock.Instant.Duration,
		operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) -> TimeoutTask<Success, Failure> {
		Self.init(detached: true, priority: priority, timeout: timeout, operation: operation)
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
