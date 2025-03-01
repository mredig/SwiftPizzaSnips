#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// Very simple locking mechanism. Cross platform, might even be compatible with some embedded systems
/// (relies on `pthread_mutex_t`) as it doesn't rely on `Foundation`
///
/// Offers debug output, informing via the console when a lock is activated and deactivated when
/// `debugMode` is `true`.
///
/// Operates very similar to `NSLock`, specifically regarding the requirement that you don't call `.lock()`
/// without calling `.unlock()` on the same thread, or a deadlock will ensue.
public class MutexLock: @unchecked Sendable {
	private var mutex: pthread_mutex_t

	/// Ignored in release builds, but in DEBUG builds will print to console lock and unlock calls and where it was called from when set to `true`.
	///
	/// Access to this property is NOT thread safe.
	public var debugMode = false

	public init() {
		self.mutex = pthread_mutex_t()

		let success = pthread_mutex_init(&mutex, nil)
		guard success == 0 else { fatalError("Lock creation catastrophically failed") }
	}

	deinit {
		guard pthread_mutex_destroy(&mutex) == 0 else {
			return print("Failed to destroy mutex lock.")
		}
	}

	#if DEBUG
	public func lock(file: String = #fileID, line: Int = #line) {
		if debugMode {
			print("Locked at \(file):\(line)")
		}
		pthread_mutex_lock(&mutex)
	}

	public func unlock(file: String = #fileID, line: Int = #line) {
		if debugMode {
			print("Unlocked at \(file):\(line)")
		}
		pthread_mutex_unlock(&mutex)
	}

	public func withLock<T, F>(block: () throws(F) -> T, file: String = #fileID, line: Int = #line) throws(F) -> T {
		lock(file: file, line: line)
		defer { unlock(file: file, line: line) }
		return try block()
	}
	#else
	public func lock() {
		pthread_mutex_lock(&mutex)
	}

	public func unlock() {
		pthread_mutex_unlock(&mutex)
	}

	public func withLock<T, F>(block: () throws(F) -> T) throws(F) -> T {
		lock()
		defer { unlock() }
		return try block()
	}
	#endif
}
