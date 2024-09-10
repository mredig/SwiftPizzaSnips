import XCTest
import SwiftPizzaSnips

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
final class DefaultsManagerNotificationTests: XCTestCase {
	static let testNotificationNullableAKey = "com.pizzaSnips.testNotificationNullableA"
	static let testNotificationNullableBKey = "com.pizzaSnips.testNotificationNullableB"
	static let testNotificationDefaultValueAKey = "com.pizzaSnips.testNotificationDefaultAValue"
	static let testNotificationDefaultValueBKey = "com.pizzaSnips.testNotificationDefaultBValue"

	static let allKeys = [
		testNotificationNullableAKey,
		testNotificationNullableBKey,
		testNotificationDefaultValueAKey,
		testNotificationDefaultValueBKey,
	]

	private static func cleanupKeys() {
		for key in allKeys {
			UserDefaults.standard.removeObject(forKey: key)
		}
	}

	override func setUp() {
		super.setUp()

		Self.cleanupKeys()
	}

	override func tearDown() {
		super.tearDown()

		Self.cleanupKeys()
	}

	let defaults = DefaultsManager.shared

	// MARK: - Key
	enum Which<T: Hashable>: Hashable, CustomDebugStringConvertible {
		case a(T)
		case b(T)

		var debugDescription: String {
			switch self {
			case .a(let int):
				"a \(int as Any)"
			case .b(let int):
				"b \(int as Any)"
			}
		}
	}

	func testNotifyingWithOneKey() throws {
		var results: [Which<Int?>] = []
		defaults.registerNotifications(for: .testNotificationNullableAKey) { newValue in
			results.append(.a(newValue))
		}

		defaults[.testNotificationNullableAKey] = 0
		defaults[.testNotificationNullableAKey] = 1
		defaults[.testNotificationNullableAKey] = nil

		let expected: [Which<Int?>] = [
			.a(0),
			.a(1),
			.a(nil),
		]

		XCTAssertEqual(expected, results)
	}

	func testNotifyingWithTwoKeys() throws {
		var results: [Which<Int?>] = []
		defaults.registerNotifications(for: .testNotificationNullableAKey) { newValue in
			results.append(.a(newValue))
		}

		defaults.registerNotifications(for: .testNotificationNullableBKey) { newValue in
			results.append(.b(newValue))
		}

		defaults[.testNotificationNullableAKey] = 0
		defaults[.testNotificationNullableAKey] = nil

		defaults[.testNotificationNullableBKey] = 29
		defaults[.testNotificationNullableAKey] = 15
		defaults[.testNotificationNullableBKey] = 150

		let expected: [Which<Int?>] = [
			.a(0),
			.a(nil),
			.b(29),
			.a(15),
			.b(150),
		]

		XCTAssertEqual(expected, results)
	}

	func testNotifyingWithTwoKeysAndTwoSubs() throws {
		var results: [Which<Int?>] = []
		let aHandle = defaults.registerNotifications(for: .testNotificationNullableAKey) { newValue in
			results.append(.a(newValue))
		}

		defaults.registerNotifications(for: .testNotificationNullableBKey) { newValue in
			results.append(.b(newValue))
		}

		defaults[.testNotificationNullableAKey] = 0
		defaults[.testNotificationNullableAKey] = nil

		defaults[.testNotificationNullableBKey] = 29
		defaults[.testNotificationNullableAKey] = 15

		defaults.registerNotifications(for: .testNotificationNullableAKey) { newValue in
			results.append(.a(newValue))
		}

		defaults[.testNotificationNullableAKey] = 1
		defaults[.testNotificationNullableBKey] = 2

		defaults.deregisterNotifications(for: aHandle)
		defaults[.testNotificationNullableAKey] = 3
		defaults[.testNotificationNullableBKey] = 4

		let expected: [Which<Int?>] = [
			.a(0),
			.a(nil),
			.b(29),
			.a(15),

			.a(1),
			.a(1),
			.b(2),
			.a(3),
			.b(4),
		]

		XCTAssertEqual(expected, results)
	}

	func testNotifyingWithDefaultKeyCombination() throws {
		var results: [Which<Int>] = []
		defaults.registerNotifications(for: .testNotificationDefaultValueAKey) { newValue in
			results.append(.a(newValue))
		}

		defaults.registerNotifications(for: .testNotificationDefaultValueBKey) { newValue in
			results.append(.b(newValue))
		}

		defaults[.testNotificationDefaultValueAKey] = 0
		defaults[.testNotificationDefaultValueAKey] = 1
		defaults.reset(key: .testNotificationDefaultValueAKey)

		defaults[.testNotificationDefaultValueBKey] = 29
		defaults[.testNotificationDefaultValueBKey] = 15
		defaults[.testNotificationDefaultValueAKey] = 15
		defaults[.testNotificationDefaultValueBKey] = 150

		let a2Handle = defaults.registerNotifications(for: .testNotificationDefaultValueAKey) { newValue in
			results.append(.a(newValue))
		}

		defaults[.testNotificationDefaultValueAKey] = 1
		defaults[.testNotificationDefaultValueBKey] = 2

		defaults.deregisterNotifications(for: a2Handle)
		defaults[.testNotificationDefaultValueAKey] = 3
		defaults[.testNotificationDefaultValueBKey] = 4
		defaults.reset(key: .testNotificationDefaultValueAKey)
		defaults.reset(key: .testNotificationDefaultValueBKey)

		let expected: [Which<Int>] = [
			.a(0),
			.a(1),
			.a(-1234),
			.b(29),
			.b(15),
			.a(15),
			.b(150),

			.a(1),
			.a(1),
			.b(2),
			.a(3),
			.b(4),
			.a(-1234),
			.b(4567),
		]

		XCTAssertEqual(expected, results)
	}
}

extension DefaultsManager.Key where Value == Int, StoredValue == Value {
	static let testNotificationNullableAKey = Self(DefaultsManagerNotificationTests.testNotificationNullableAKey)
	static let testNotificationNullableBKey = Self(DefaultsManagerNotificationTests.testNotificationNullableBKey)
}

extension DefaultsManager.KeyWithDefault where Value == Int, StoredValue == Value {
	static let testNotificationDefaultValueAKey = Self(
		DefaultsManagerNotificationTests.testNotificationDefaultValueAKey,
		defaultValue: -1234)

	static let testNotificationDefaultValueBKey = Self(
		DefaultsManagerNotificationTests.testNotificationDefaultValueBKey,
		defaultValue: 4567)
}
