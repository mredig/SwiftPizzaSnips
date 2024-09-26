@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
public protocol ContinProt: Sendable {
	associatedtype Element
	associatedtype YieldResult
	associatedtype Failure: Error
	@discardableResult
	func yield(_ value: Element) -> YieldResult
	@discardableResult
	func yield(with result: Result<Element, Failure>) -> YieldResult
	func finish(throwing error: Failure?)
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
public protocol AsyncContinuationSequence: AsyncSequence {
	associatedtype Continuation: ContinProt
	associatedtype Failure
	associatedtype BufferingPolicy

	static func makeStream(bufferingPolicy: BufferingPolicy) -> (Self, Self.Continuation)
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension AsyncStream.Continuation: ContinProt {
	public func finish(throwing error: Never? = nil) { finish() }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension AsyncStream: AsyncContinuationSequence {
	public typealias Failure = Never
	public static func makeStream(bufferingPolicy: Continuation.BufferingPolicy) -> (AsyncStream<Element>, Continuation) {
		makeStream(of: Element.self, bufferingPolicy: bufferingPolicy)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension AsyncThrowingStream.Continuation: ContinProt where Failure == Error {}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension AsyncThrowingStream: AsyncContinuationSequence where Failure == any Error {
	public static func makeStream(bufferingPolicy: Continuation.BufferingPolicy) -> (AsyncThrowingStream<Element, Failure>, Continuation) {
		makeStream(of: Element.self, throwing: Failure.self, bufferingPolicy: bufferingPolicy)
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension AsyncContinuationSequence {
	public static func duplicateStream<ASeq: AsyncSequence>(
		count: Int,
		_ inStream: ASeq,
		bufferingPolicy: BufferingPolicy
	) -> [Self] where ASeq.Element == Element, Continuation.Element == Element, Continuation.Failure == Failure {
		var out: [(stream: Self, continuation: Self.Continuation)] = []

		for _ in 0..<count {
			let (newStream, newCont) = makeStream(bufferingPolicy: bufferingPolicy)
			out.append((newStream, newCont))
		}

		Task {
			do {
				for try await item in inStream {
					out.forEach { $0.continuation.yield(item) }
				}
				out.forEach { $0.continuation.finish(throwing: nil) }
			} catch let error as Failure {
				out.forEach { $0.continuation.finish(throwing: error) }
			}
		}

		return out.map(\.stream)
	}
}
