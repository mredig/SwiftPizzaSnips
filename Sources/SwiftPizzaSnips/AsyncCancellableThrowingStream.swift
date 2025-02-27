//===----------------------------------------------------------------------===//
//
// This source file was part of the Swift.org open source project and has been modified by Michael Redig.
//
// Copyright (c) 2020-2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Swift
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public struct AsyncCancellableThrowingStream<Element, Failure: Error> {
	/// A mechanism to interface between synchronous code and an asynchronous
	/// stream.
	///
	/// The closure you provide to the `AsyncCancellableThrowingStream` in
	/// `init(_:bufferingPolicy:_:)` receives an instance of this type when
	/// invoked. Use this continuation to provide elements to the stream by
	/// calling one of the `yield` methods, then terminate the stream normally by
	/// calling the `finish()` method. You can also use the continuation's
	/// `finish(throwing:)` method to terminate the stream by throwing an error.
	///
	/// - Note: Unlike other continuations in Swift,
	/// `AsyncCancellableThrowingStream.Continuation` supports escaping.
	public struct Continuation: Sendable {
		/// A type that indicates how the stream terminated.
		///
		/// The `onTermination` closure receives an instance of this type.
		public enum Termination {

			/// The stream finished as a result of calling the continuation's
			///  `finish` method.
			///
			///  The associated `Failure` value provides the error that terminated
			///  the stream. If no error occurred, this value is `nil`.
			case finished(Failure?)

			/// The stream finished as a result of cancellation.
			case cancelled
		}

		/// A type that indicates the result of yielding a value to a client, by
		/// way of the continuation.
		///
		/// The various `yield` methods of `AsyncCancellableThrowingStream.Continuation` return
		/// this type to indicate the success or failure of yielding an element to
		/// the continuation.
		public enum YieldResult {

			/// The stream successfully enqueued the element.
			///
			/// This value represents the successful enqueueing of an element, whether
			/// the stream buffers the element or delivers it immediately to a pending
			/// call to `next()`. The associated value `remaining` is a hint that
			/// indicates the number of remaining slots in the buffer at the time of
			/// the `yield` call.
			///
			/// - Note: From a thread safety perspective, `remaining` is a lower bound
			/// on the number of remaining slots. This is because a subsequent call
			/// that uses the `remaining` value could race on the consumption of
			/// values from the stream.
			case enqueued(remaining: Int)

			/// The stream didn't enqueue the element because the buffer was full.
			///
			/// The associated element for this case is the element that the stream
			/// dropped.
			case dropped(Element)

			/// The stream didn't enqueue the element because the stream was in a
			/// terminal state.
			///
			/// This indicates the stream terminated prior to calling `yield`, either
			/// because the stream finished normally or through cancellation, or
			/// it threw an error.
			case terminated
		}

		/// A strategy that handles exhaustion of a buffer’s capacity.
		public enum BufferingPolicy {
			/// Continue to add to the buffer, treating its capacity as infinite.
			case unbounded

			case limited(Int)
		}

		let storage: _Storage

		/// Resume the task awaiting the next iteration point by having it return
		/// normally or throw, based on a given result.
		///
		/// - Parameter result: A result to yield from the continuation. In the
		///   `.success(_:)` case, this returns the associated value from the
		///   iterator's `next()` method. If the result is the `failure(_:)` case,
		///   this call terminates the stream with the result's error, by calling
		///   `finish(throwing:)`.
		/// - Returns: A `YieldResult` that indicates the success or failure of the
		///   yield operation.
		///
		/// If nothing is awaiting the next value and the result is success, this call
		/// attempts to buffer the result's element.
		///
		/// If you call this method repeatedly, each call returns immediately, without
		/// blocking for any awaiting consumption from the iteration.
		@discardableResult
		public func yield(
			with result: __shared sending Result<Element, Failure>
		) throws(CancellationError) -> YieldResult where Failure == Error {
			switch result {
			case .success(let val):
				return try storage.yield(val)
			case .failure(let err):
				storage.finish(throwing: err)
				return .terminated
			}
		}

		/// Resume the task awaiting the next iteration point by having it return
		/// normally from its suspension point.
		///
		/// - Returns: A `YieldResult` that indicates the success or failure of the
		///   yield operation.
		///
		/// Use this method with `AsyncCancellableThrowingStream` instances whose `Element`
		/// type is `Void`. In this case, the `yield()` call unblocks the
		/// awaiting iteration; there is no value to return.
		///
		/// If you call this method repeatedly, each call returns immediately,
		/// without blocking for any awaiting consumption from the iteration.
		@discardableResult
		public func yield() throws(CancellationError) -> YieldResult where Element == Void, Failure == Error {
			try yield(with: .success(()))
		}

		/// Resume the task awaiting the next iteration point by having it return
		/// normally from its suspension point with a given element.
		///
		/// - Parameter value: The value to yield from the continuation.
		/// - Returns: A `YieldResult` that indicates the success or failure of the
		///   yield operation.
		///
		/// If nothing is awaiting the next value, the method attempts to buffer the
		/// result's element.
		///
		/// This can be called more than once and returns to the caller immediately
		/// without blocking for any awaiting consumption from the iteration.
		@discardableResult
		public func yield(_ value: sending Element) throws(CancellationError) -> YieldResult where Failure == Error {
			try yield(with: .success(value))
		}

		/// Resume the task awaiting the next iteration point by having it return
		/// nil, which signifies the end of the iteration.
		///
		/// - Parameter error: The error to throw, or `nil`, to finish normally.
		///
		/// Calling this function more than once has no effect. After calling
		/// finish, the stream enters a terminal state and doesn't produce any additional
		/// elements.
		public func finish(throwing error: __owned Failure? = nil) throws(CancellationError) where Failure == Error {
			if let error {
				try yield(with: .failure(error))
			} else {
				storage.finish()
			}
		}

		/// A callback to invoke when canceling iteration of an asynchronous
		/// stream.
		///
		/// If an `onTermination` callback is set, using task cancellation to
		/// terminate iteration of an `AsyncCancellableThrowingStream` results in a call to this
		/// callback.
		///
		/// Canceling an active iteration invokes the `onTermination` callback
		/// first, and then resumes by yielding `nil` or throwing an error from the
		/// iterator. This means that you can perform needed cleanup in the
		///  cancellation handler. After reaching a terminal state, the
		///  `AsyncCancellableThrowingStream` disposes of the callback.
		public var onTermination: (@Sendable (Termination) -> Void)? {
			get {
				return storage.getOnTermination()
			}
			nonmutating set {
				storage.setOnTermination(newValue)
			}
		}
	}

	final class _Context {
		let storage: _Storage
		let produce: () async throws(Failure) -> Element?

		init(storage: _Storage, produce: @escaping () async throws(Failure) -> Element?) {
			self.storage = storage
			self.produce = produce
		}

		deinit {
			storage.cancel(throwing: nil)
		}
	}

	let context: _Context

	/// Constructs an asynchronous stream for an element type, using the
	/// specified buffering policy and element-producing closure.
	///
	/// - Parameters:
	///   - elementType: The type of element the `AsyncCancellableThrowingStream`
	///   produces.
	///   - limit: The maximum number of elements to
	///   hold in the buffer. By default, this value is unlimited. Use a
	///   `Continuation.BufferingPolicy` to buffer a specified number of oldest
	///   or newest elements.
	///   - build: A custom closure that yields values to the
	///   `AsyncCancellableThrowingStream`. This closure receives an
	///   `AsyncCancellableThrowingStream.Continuation` instance that it uses to provide
	///   elements to the stream and terminate the stream when finished.
	///
	/// The `AsyncStream.Continuation` received by the `build` closure is
	/// appropriate for use in concurrent contexts. It is thread safe to send and
	/// finish; all calls are to the continuation are serialized. However, calling
	/// this from multiple concurrent contexts could result in out-of-order
	/// delivery.
	///
	/// The following example shows an `AsyncStream` created with this
	/// initializer that produces 100 random numbers on a one-second interval,
	/// calling `yield(_:)` to deliver each element to the awaiting call point.
	/// When the `for` loop exits, the stream finishes by calling the
	/// continuation's `finish()` method. If the random number is divisible by 5
	/// with no remainder, the stream throws a `MyRandomNumberError`.
	///
	///     let stream = AsyncCancellableThrowingStream<Int, Error>(Int.self,
	///                                                  bufferingPolicy: .bufferingNewest(5)) { continuation in
	///         Task.detached {
	///             for _ in 0..<100 {
	///                 await Task.sleep(1 * 1_000_000_000)
	///                 let random = Int.random(in: 1...10)
	///                 if random % 5 == 0 {
	///                     continuation.finish(throwing: MyRandomNumberError())
	///                     return
	///                 } else {
	///                     continuation.yield(random)
	///                 }
	///             }
	///             continuation.finish()
	///         }
	///     }
	///
	///     // Call point:
	///     do {
	///         for try await random in stream {
	///             print(random)
	///         }
	///     } catch {
	///         print(error)
	///     }
	///
	public init(
		_ elementType: Element.Type = Element.self,
		bufferingPolicy limit: Continuation.BufferingPolicy = .unbounded,
		_ build: (Continuation) -> Void
	) where Failure == Error {
		let storage = _Storage(limit: limit)
		context = _Context(storage: storage, produce: storage.next)
		build(Continuation(storage: storage))
	}

	public func cancel(throwing failure: Failure? = nil) {
		context.storage.cancel(throwing: failure)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension AsyncCancellableThrowingStream: AsyncSequence {
	/// The asynchronous iterator for iterating an asynchronous stream.
	///
	/// This type is not `Sendable`. Don't use it from multiple
	/// concurrent contexts. It is a programmer error to invoke `next()` from a
	/// concurrent context that contends with another such call, which
	/// results in a call to `fatalError()`.
	public struct Iterator: AsyncIteratorProtocol {
		let context: _Context

		/// The next value from the asynchronous stream.
		///
		/// When `next()` returns `nil`, this signifies the end of the
		/// `AsyncCancellableThrowingStream`.
		///
		/// It is a programmer error to invoke `next()` from a concurrent context
		/// that contends with another such call, which results in a call to
		///  `fatalError()`.
		///
		/// If you cancel the task this iterator is running in while `next()` is
		/// awaiting a value, the `AsyncCancellableThrowingStream` terminates. In this case,
		/// `next()` may return `nil` immediately, or else return `nil` on
		/// subsequent calls.
		public mutating func next() async throws -> Element? {
			return try await context.produce()
		}

		/// The next value from the asynchronous stream.
		///
		/// When `next()` returns `nil`, this signifies the end of the
		/// `AsyncCancellableThrowingStream`.
		///
		/// It is a programmer error to invoke `next()` from a concurrent
		/// context that contends with another such call, which results in a call to
		/// `fatalError()`.
		///
		/// If you cancel the task this iterator is running in while `next()`
		/// is awaiting a value, the `AsyncCancellableThrowingStream` terminates. In this case,
		/// `next()` may return `nil` immediately, or else return `nil` on
		/// subsequent calls.

		@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
		public mutating func next(isolation actor: isolated (any Actor)?) async throws(Failure) -> Element? {
			return try await context.produce()
		}
	}

	/// Creates the asynchronous iterator that produces elements of this
	/// asynchronous sequence.
	public func makeAsyncIterator() -> Iterator {
		return Iterator(context: context)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension AsyncCancellableThrowingStream {
	/// Initializes a new ``AsyncCancellableThrowingStream`` and an ``AsyncCancellableThrowingStream/Continuation``.
	///
	/// - Parameters:
	///   - elementType: The element type of the stream.
	///   - failureType: The failure type of the stream.
	///   - limit: The buffering policy that the stream should use.
	/// - Returns: A tuple containing the stream and its continuation. The continuation should be passed to the
	/// producer while the stream should be passed to the consumer.
	public static func makeStream(
		of elementType: Element.Type = Element.self,
		throwing failureType: Failure.Type = Failure.self,
		bufferingPolicy limit: Continuation.BufferingPolicy = .unbounded
	) -> (stream: AsyncCancellableThrowingStream<Element, Failure>, continuation: AsyncCancellableThrowingStream<Element, Failure>.Continuation) where Failure == Error {
		var continuation: AsyncCancellableThrowingStream<Element, Failure>.Continuation!
		let stream = AsyncCancellableThrowingStream<Element, Failure>(bufferingPolicy: limit) { continuation = $0 }
		return (stream: stream, continuation: continuation!)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension AsyncCancellableThrowingStream: @unchecked Sendable where Element: Sendable { }


@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension AsyncCancellableThrowingStream {
	internal final class _Storage: @unchecked Sendable {
		typealias TerminationHandler = @Sendable (Continuation.Termination) -> Void
		enum Terminal {
			case finished
			case failed(Failure)
		}

		struct State {
			var continuation: UnsafeContinuation<Element?, Error>?
//			var pending = _Deque<Element>()
			var pending: ContiguousArray<Element> = .init(unsafeUninitializedCapacity: 32, initializingWith: { _, count in count = 0 })
			let limit: Continuation.BufferingPolicy
			var onTermination: TerminationHandler?
			var terminal: Terminal?

			init(limit: Continuation.BufferingPolicy) {
				self.limit = limit
			}
		}
		// Stored as a singular structured assignment for initialization
		var state: State

		init(limit: Continuation.BufferingPolicy) {
			self.state = State(limit: limit)
		}

		deinit {
			state.onTermination?(.cancelled)
		}

		private let streamLock = NSLock()
		private func lock() { streamLock.lock() }
		private func unlock() { streamLock.unlock() }

		func getOnTermination() -> TerminationHandler? {
			lock()
			let handler = state.onTermination
			unlock()
			return handler
		}

		func setOnTermination(_ newValue: TerminationHandler?) {
			lock()
			withExtendedLifetime(state.onTermination) {
				state.onTermination = newValue
				unlock()
			}
		}

		@Sendable func cancel(throwing failure: Failure?) {
			lock()
			// swap out the handler before we invoke it to prevent double cancel
			let handler = state.onTermination
			state.onTermination = nil
			unlock()

			// handler must be invoked before yielding nil for termination
			handler?(.cancelled)

			finish(throwing: failure)
		}

		func yield(_ value: __owned Element) throws(CancellationError) -> Continuation.YieldResult {
			var result: Continuation.YieldResult
			lock()
			let limit = state.limit
			let count = state.pending.count
			guard state.terminal == nil else {
				unlock()
				throw CancellationError()
			}

			if let continuation = state.continuation {
				// I'm not sure this block can actually get reached...
				// If the pending count > 0, the continuation will be called immediately in next, draining the pending
				// buffer before getting set to `state`. Contrarily, the continuation will only get set to `state`
				// if the buffer is empty. I think the only way to reach this would be some exceedingly rare race condition
				// where the continuation gets set to state, but then the pending buffer gets pounded before the
				// continuation can be fulfilled... But that also shouldn't be possilbe?
				if count > 0 {
					switch limit {
					case .unbounded:
						result = .enqueued(remaining: .max)
						state.pending.append(value)
					case .limited(let limitValue):
						if count < limitValue {
							result = .enqueued(remaining: limitValue - (count + 1))
							state.pending.append(value)
						} else {
							result = .dropped(value)
						}
					}
					state.continuation = nil
					let toSend = state.pending.removeFirst()
					unlock()
					continuation.resume(returning: toSend)
				} else {
					switch limit {
					case .unbounded:
						result = .enqueued(remaining: .max)
					case .limited(let limitValue):
						result = .enqueued(remaining: limitValue)
					}

					state.continuation = nil
					unlock()
					continuation.resume(returning: value)
				}
			} else {
				switch limit {
				case .unbounded:
					result = .enqueued(remaining: .max)
					state.pending.append(value)
				case .limited(let limitValue):
					if count < limitValue {
						result = .enqueued(remaining: limitValue - (count + 1))
						state.pending.append(value)
					} else {
						result = .dropped(value)
					}
				}
				unlock()
			}
			return result
		}

		func finish(throwing error: __owned Failure? = nil) {
			lock()
			let handler = state.onTermination
			state.onTermination = nil
			if state.terminal == nil {
				if let failure = error {
					state.terminal = .failed(failure)
				} else {
					state.terminal = .finished
				}
			}

			if let continuation = state.continuation {
				if state.pending.count > 0 {
					state.continuation = nil
					let toSend = state.pending.removeFirst()
					unlock()
					handler?(.finished(error))
					continuation.resume(returning: toSend)
				} else if let terminal = state.terminal {
					state.continuation = nil
					unlock()
					handler?(.finished(error))
					switch terminal {
					case .finished:
						continuation.resume(returning: nil)
					case .failed(let error):
						continuation.resume(throwing: error)
					}
				} else {
					unlock()
					handler?(.finished(error))
				}
			} else {
				unlock()
				handler?(.finished(error))
			}
		}

		func next(_ continuation: UnsafeContinuation<Element?, Error>) {
			lock()
			if state.continuation == nil {
				if state.pending.count > 0 {
					let toSend = state.pending.removeFirst()
					unlock()
					continuation.resume(returning: toSend)
				} else if let terminal = state.terminal {
					state.terminal = .finished
					unlock()
					switch terminal {
					case .finished:
						continuation.resume(returning: nil)
					case .failed(let error):
						continuation.resume(throwing: error)
					}
				} else {
					state.continuation = continuation
					unlock()
				}
			} else {
				unlock()
				fatalError("attempt to await next() on more than one task")
			}
		}

		func next() async throws -> Element? {
			try await withTaskCancellationHandler {
				try await withUnsafeThrowingContinuation {
					next($0)
				}
			} onCancel: { [cancel] in
				cancel(nil)
			}
		}
	}
}
