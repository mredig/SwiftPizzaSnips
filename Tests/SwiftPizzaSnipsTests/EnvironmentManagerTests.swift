import Testing
import Foundation
import SwiftPizzaSnips
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

struct EnvironmentManagerTests {
	#if os(Linux)
	init() {
		setenv("FOO", "bar", 1)
	}
	#endif

	@Test func existingValue() {
		let keys: [EnvironmentManager.Key] = [
			.path,
			.tmpdir,
			.home,
			.lang,
			.logname,
			.shell,
			.cfUserTextEncoding,
		]

		keys.forEach { print(EnvironmentManager.shared[$0] as Any) }

		#expect(EnvironmentManager.shared[.foo] == "bar")
	}

	@Test func newValue() {
		setenv("BAZ", "asdf", 1)

		#expect(EnvironmentManager.shared[.baz] == "asdf")
	}
}

extension EnvironmentManager.Key {
	static let foo: Self = "FOO"
	static let baz: Self = "BAZ"
}
