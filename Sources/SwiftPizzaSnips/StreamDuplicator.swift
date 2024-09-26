@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
public enum StreamDuplicator<ASeq: AsyncSequence> {
	public typealias Stream = AsyncThrowingStream<ASeq.Element, any Error>

	public static func duplicateStream(
		count: Int,
		stream: ASeq,
		bufferingPolicy: Stream.Continuation.BufferingPolicy = .unbounded
	) -> [Stream] {
		var continuations: [Stream.Continuation] = []
		var streams: [Stream] = []

		for _ in 0..<count {
			let (newStream, newCont) = Stream.makeStream(of: Stream.Element.self, throwing: Error.self, bufferingPolicy: bufferingPolicy)
			streams.append(newStream)
			continuations.append(newCont)
		}

		Task {
			do {
				for try await item in stream {
					continuations.forEach { $0.yield(item) }
				}
				continuations.forEach { $0.finish() }
			} catch {
				continuations.forEach { $0.finish(throwing: error) }
			}
		}

		return streams
	}
}
