import Foundation

extension URL {
	/// Provides a cleaner call for `checkResourceIsReachable()` without throwing when you don't care about the reason.. False just means the file isn't
	/// accessible for *some* reason. Maybe it's not there. Maybe it's on a network volume that's not mounted. Maybe it has permissions you or the sandbox
	/// cannot access. Maybe you just suck.
	public func checkResourceIsAccessible() -> Bool {
		do {
			return try checkResourceIsReachable()
		} catch {
			return false
		}
	}
}
