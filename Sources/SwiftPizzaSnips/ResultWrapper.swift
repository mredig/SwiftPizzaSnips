import Foundation

public func wrap<T>(_ block: () throws -> T) -> Result<T, Error> {
	do {
		let output = try block()
		return .success(output)
	} catch {
		return .failure(error)
	}
}

public func wrap<T>(_ block: () async throws -> T) async -> Result<T, Error> {
	do {
		let output = try await block()
		return .success(output)
	} catch {
		return .failure(error)
	}
}
