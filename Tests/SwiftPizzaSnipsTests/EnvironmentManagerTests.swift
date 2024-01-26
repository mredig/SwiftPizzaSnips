import XCTest
import SwiftPizzaSnips

final class EnvironmentManagerTests: XCTestCase {
	func testEnvironmentManager() {
		let keys: [EnvironmentManager.Key] = [
			.path,
			.tmpdir,
			.home,
			.lang,
			.logname,
			.shell,
			.cfUserTextEncoding,
		]

		keys.forEach { print(EnvironmentManager.shared[$0]) }

		XCTAssertEqual(EnvironmentManager.shared[.foo], "bar")
	}
}

extension EnvironmentManager.Key {
	static let foo: Self = "FOO"
}
