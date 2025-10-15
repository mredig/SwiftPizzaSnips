/// A Task that awaits a signal to start instead of executing immediately.
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 6.0, *)
public struct TriggeredTask<Success: Sendable, Failure: Error>: Sendable {
	private let underlyingTask: ETask<Success, TriggeredTaskError>

	/// Same as `Task.value`
	public var value: Success {
		get async throws(TriggeredTaskError) {
			try await result.get()
		}
	}

	/// Same as `Task.result`
	public var result: Result<Success, TriggeredTaskError> {
		get async {
			await underlyingTask.result
		}
	}

	/// Same as `Task.isCancelled`
	public var isCancelled: Bool { underlyingTask.isCancelled }

	private let continuation: ContinuationProxy<Void, CancellationError>

	/// Basics are the same as `Task.init`, but the operation doesn't start executing immediately. Instead, it
	/// internally awaits a continuation that suspends the task until `start()` is called.
	public init(
		priority: TaskPriority? = nil,
		@_implicitSelfCapture operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) {
		self.init(
			detached: false,
			priority: priority,
			operation: operation)
	}

	/// Basics are the same as `Task.detached`, but the operation doesn't start executing immediately. Instead, it
	/// internally awaits a continuation that suspends the task until `start()` is called.
	public static func detached(
		priority: TaskPriority? = nil,
		operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) -> TriggeredTask<Success, Failure> {
		Self.init(
			detached: true,
			priority: priority,
			operation: operation)
	}

	private init(detached: Bool, priority: TaskPriority?, operation: sending @escaping @isolated(any) () async throws(Failure) -> Success) {

		let proxy = ContinuationProxy<Void, CancellationError>()
		self.continuation = proxy

		let internalOperation = { () async throws(TriggeredTaskError) -> Success in
			do {
				try await withUnsafeThrowingContinuation { cont in
					proxy.setContinuation(cont)
				}
			} catch {
				throw .cancelled
			}

			do throws(Failure) {
				return try await operation()
			} catch {
				throw .failed(error)
			}
		}

		if detached {
			self.underlyingTask = ETask.detached(priority: priority, operation: internalOperation)
		} else {
			self.underlyingTask = ETask(priority: priority, operation: internalOperation)
		}
	}

	/// Same as `Task.cancel`
	public func cancel() {
		continuation.resume(throwing: CancellationError())
		underlyingTask.cancel()
	}

	/// The Task doesn't start until you call this method.
	public func start() {
		continuation.resume()
	}

	public enum TriggeredTaskError: Swift.Error {
		case cancelled
		case failed(Failure)
	}
}
