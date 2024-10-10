import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
public extension Sequence {
	func asyncStream() -> AsyncStream<Element> {
		AsyncStream { continuation in
			forEach { continuation.yield($0) }
			continuation.finish()
		}
	}

	func asyncFilter(_ predicate: (Element) async throws -> Bool) async rethrows -> [Element] {
		let stream = asyncStream()

		var accumulator: [Element] = []
		for await element in stream {
			guard
				try await predicate(element)
			else { continue }
			accumulator.append(element)
		}
		return accumulator
	}

	func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
		let stream = asyncStream()

		var accumulator: [T] = []
		for await element in stream {
			try accumulator.append(await transform(element))
		}
		return accumulator
	}

	func asyncConcurrentMap<T>(_ transform: @escaping @Sendable (Element) async throws -> T) async rethrows -> [T] {
		try await withThrowingTaskGroup(of: (index: Int, result: T).self) { group in
			for (index, element) in self.enumerated() {
				group.addTask {
					let altered = try await transform(element)
					return (index, altered)
				}
			}

			var accumulator: [Int: T] = [:]
			for try await result in group {
				accumulator[result.index] = result.result
			}

			let sorted = accumulator.sorted { $0.key < $1.key }
			return sorted.map(\.value)
		}
	}

	func asyncCompactMap<T>(transform: (Element) async throws -> T?) async rethrows -> [T] {
		let stream = asyncStream()

		var accumulator: [T] = []
		for await element in stream {
			guard
				let new = try await transform(element)
			else { continue }
			accumulator.append(new)
		}
		return accumulator
	}

	func asyncReduce<Result>(
		_ initialResult: Result,
		_ nextPartialResult: (Result, Element) async throws -> Result
	) async rethrows -> Result {
		let stream = asyncStream()

		var result = initialResult
		for await element in stream {
			result = try await nextPartialResult(result, element)
		}
		return result
	}

	func asyncReduce<Result>(
		into initialResult: Result,
		_ nextPartialResult: (inout Result, Element) async throws -> Void
	) async rethrows -> Result {
		let stream = asyncStream()

		var result = initialResult
		for await element in stream {
			try await nextPartialResult(&result, element)
		}
		return result
	}

	func asyncForEach(_ body: (Element) async throws -> Void) async rethrows {
		let stream = asyncStream()

		for await element in stream {
			try await body(element)
		}
	}
}
