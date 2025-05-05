public struct Censor: RawRepresentable, Sendable, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
	public var rawValue: String

	public enum Level: Sendable, Hashable {
		case complete
		case allowCharCount
		case firstAndLastRevealedNoCharCount
		case firstAndLastRevealedAndCharCount
	}

	public var level: Level = .complete

	public var description: String {
		switch level {
		case .complete:
			return "***"
		case .allowCharCount:
			return String(repeating: "*", count: rawValue.count)
		case .firstAndLastRevealedNoCharCount:
			guard let firstAndLast else { return "***" }
			return "\(firstAndLast.first)***\(firstAndLast.last)"
		case .firstAndLastRevealedAndCharCount:
			guard let firstAndLast else { return "***" }
			return "\(firstAndLast.first)\(String(repeating: "*", count: rawValue.count - 2))\(firstAndLast.last)"
		}
	}

	public var debugDescription: String {
		"Censor: \(description)"
	}

	private var firstAndLast: (first: Character, last: Character)? {
		guard rawValue.count > 4 else { return nil }
		guard
			let first = rawValue.first,
			let last = rawValue.last
		else { return nil }
		return (first, last)
	}

	public init(rawValue: String) {
		self.rawValue = rawValue
	}

	public init(rawValue: String, level: Level) {
		self.init(rawValue: rawValue)
		self.level = level
	}
}
