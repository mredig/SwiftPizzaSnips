import Testing
import SwiftPizzaSnips

struct EnvironmentManagerTests {
	@Test func testEnvironmentManager() {
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
}

extension EnvironmentManager.Key {
	static let foo: Self = "FOO"
}
