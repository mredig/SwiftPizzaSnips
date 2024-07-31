import Foundation

extension String {
	public func prefixingLines<S: StringProtocol>(with prefix: S) -> String {
		var new = "\(prefix)"
		for char in self {
			new.append(char)
			guard char == "\n" else { continue }
			new.append(String(prefix))
		}
		return new
	}
}
