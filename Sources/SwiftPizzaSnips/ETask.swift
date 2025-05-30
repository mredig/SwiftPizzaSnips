/// A (hopefully) temporary stand in for `Task`. Currently, `Task` only supports throwing `any Error`, so `ETask`
/// adds the ability to throw strongly typed errors. This abstracts away the need to manually verify the thrown
/// error conforms to `Failure` at the call site and instead just lets you make the `ETask` properly typed in the
/// first place. (`ETask` is short for "typedError-Task")
///
/// Once `Swift.Task` gets updated with support for typed throws, this should be removed. In theory, it should allow
/// for a drop in replacement, assuming there's no significant API change to `Swift.Task`
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct ETask<Success: Sendable, Failure: Error>: Sendable, Hashable {
	private let underlyingTask: Task<Success, Error>

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
				return .failure(error as! Failure) // swiftlint:disable:this force_cast
			}
		}
	}

	/// Same as `Task.isCancelled`
	public var isCancelled: Bool { underlyingTask.isCancelled }

	/// Same as `Task.init`
	public init(
		priority: TaskPriority? = nil,
		@_implicitSelfCapture operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) {
		self.init(detached: false, priority: priority, operation: operation)
	}

	private init(
		detached: Bool,
		priority: TaskPriority? = nil,
		@_implicitSelfCapture operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) {
		if detached {
			underlyingTask = Task.detached(priority: priority, operation: operation)
		} else {
			underlyingTask = Task(priority: priority, operation: operation)
		}
	}

	/// Same as `Task.detached`
	public static func detached(
		priority: TaskPriority? = nil,
		operation: sending @escaping @isolated(any) () async throws(Failure) -> Success
	) -> ETask<Success, Failure> {
		Self.init(detached: true, priority: priority, operation: operation)
	}

	/// Same as `Task.cancel`
	public func cancel() {
		underlyingTask.cancel()
	}
}
