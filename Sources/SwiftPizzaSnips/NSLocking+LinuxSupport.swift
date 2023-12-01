import Foundation

#if canImport(FoundationNetworking)
extension NSLocking {
	public func withLock<R>(_ body: () throws -> R) rethrows -> R {
		lock()
		defer { unlock() }
		return try body()
	}
}
#endif
