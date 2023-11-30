import Foundation

public func wrap<T>(_ block: () throws -> T) -> Result<T, Error> {
	do {
		let output = try block()
		return .success(output)
	} catch {
		return .failure(error)
	}
}

#if swift(>=5.5)
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public func wrap<T>(_ block: () async throws -> T) async -> Result<T, Error> {
	do {
		let output = try await block()
		return .success(output)
	} catch {
		return .failure(error)
	}
}
#endif
