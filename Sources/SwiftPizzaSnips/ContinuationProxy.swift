/// There are some times where you needs to use a continuation, but the order of operations requires attaining a
/// reference to the continuation prior to the ability to retrieve it.
///
/// `ContinuationProxy` will allow you to create a proxy for the continuation that you can interact with prior to the
/// actual continuation. Then, once you have the actual continuation, you supply it to the proxy.
///
/// In the end, use the proxy in place of the continuation as it will resolve in which ever order you use it. Either:
///
/// 1. Create proxy
/// 1. Give proxy continuation
/// 1. Give proxy result
/// 1. complete
///
/// or
///
/// 1. Create proxy
/// 1. Give proxy result
/// 1. Give proxy continuation
/// 1. complete
///
///	The proxy will also *enforce* a single use and a single result, silently discarding multiple invocations of
///	either method.
///
/// The only catch here is that proxy needs to be provided an unused continuation exactly once and a result exactly
/// once. (but if you do it more than once, it'll silently discard the additional attempts)
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final public class ContinuationProxy<T, E: Error>: @unchecked Sendable {
	private var state: State = .awaitingInput

	private enum State {
		case awaitingInput
		case awaitingContinuation(Result<T, E>)
		case awaitingResult(UnsafeContinuation<T, any Error>)
		case completed
	}

	private let lock = MutexLock()

	public var hasCompleted: Bool {
		lock.withLock {
			switch state {
			case .awaitingInput, .awaitingContinuation, .awaitingResult:
				false
			case .completed:
				true
			}
		}
	}

	public var needsContinuation: Bool {
		lock.withLock {
			switch state {
			case .awaitingInput, .awaitingContinuation:
				true
			case .awaitingResult, .completed:
				false
			}
		}
	}

	public var needsResult: Bool {
		lock.withLock {
			switch state {
			case .awaitingInput, .awaitingResult:
				true
			case .awaitingContinuation, .completed:
				false
			}
		}
	}

	public init() {}

	deinit {
		assert(hasCompleted, "Continuation Proxy (\(self)) was deallocated before being continued. Be sure to resume before discarding.")
	}

	public func setContinuation(_ continuation: UnsafeContinuation<T, any Error>) {
		lock.withLock {
			switch state {
			case .awaitingInput:
				self.state = .awaitingResult(continuation)
			case .awaitingContinuation(let result):
				continuation.resume(with: result)
				self.state = .completed
			case .awaitingResult, .completed:
				return
			}
		}
	}

	public func resume(with result: Result<T, E>) {
		lock.withLock {
			switch state {
			case .awaitingInput:
				state = .awaitingContinuation(result)
			case .awaitingContinuation, .completed:
				return
			case .awaitingResult(let unsafeContinuation):
				unsafeContinuation.resume(with: result)
				self.state = .completed
			}
		}
	}

	public func resume(returning value: T) {
		resume(with: .success(value))
	}


	public func resume() where T == Void {
		resume(with: .success(()))
	}


	public func resume(throwing error: E) {
		resume(with: .failure(error))
	}
}
