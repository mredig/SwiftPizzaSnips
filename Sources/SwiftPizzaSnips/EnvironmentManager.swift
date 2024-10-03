import Foundation

public class EnvironmentManager {
	private static var environment: [String: String] { ProcessInfo.processInfo.environment }

	public static let shared = EnvironmentManager()

	private init() {}

	public func getVar(_ key: Key) -> String? {
		Self.environment[key.rawValue]
	}

	public subscript(key: Key) -> String? {
		getVar(key)
	}

	public struct Key: RawRepresentable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
		public static let path: Key = "PATH"
		public static let home: Key = "HOME"
		public static let logname: Key = "LOGNAME"
		public static let lang: Key = "LANG"
		public static let tmpdir: Key = "TMPDIR"
		public static let shell: Key = "SHELL"
		public static let cfUserTextEncoding: Key = "__CF_USER_TEXT_ENCODING"

		public let rawValue: String

		public var key: String { rawValue }

		public init(rawValue: String) {
			self.init(rawValue)
		}

		public init(stringLiteral value: StringLiteralType) {
			self.init(value)
		}

		public init(_ key: String) {
			self.rawValue = key
		}
	}
}
