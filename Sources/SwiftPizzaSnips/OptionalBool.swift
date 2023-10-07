import Foundation

public extension Optional where Wrapped == Bool {
	var nilIsFalse: Bool {
		self ?? false
	}

	var nilIsTrue: Bool {
		self ?? true
	}
}
