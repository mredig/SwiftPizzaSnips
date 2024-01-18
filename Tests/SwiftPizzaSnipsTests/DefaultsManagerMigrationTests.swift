import XCTest
import SwiftPizzaSnips

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
final class DefaultsManagerMigrationTests: XCTestCase {
	static let doubleValueTestKey = DefaultsManager.KeyWithDefault<Double, Double>.doubleValueTest.rawValue
	static let stringyValueKey = DefaultsManager.Key<String, String>.stringyValue.rawValue
	static let defaultsVersionKey = "com.pizzaSnips.defaultsVersion"
	static let allKeys = [
		doubleValueTestKey,
		defaultsVersionKey,
		stringyValueKey,
	]

	private static func cleanupKeys() {
		for key in allKeys {
			UserDefaults.standard.removeObject(forKey: key)
		}
		DefaultsManager.clearMigrations()
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

	func testDefaultsMigration() throws {
		DefaultsManager.addMigration(
			.init(
				migrationVersion: 0,
				onMigrate: {
					DefaultsManager.shared[.doubleValueTest] = 43
				})
		)
		DefaultsManager.runMigrations()

		XCTAssertEqual(43, defaults[.doubleValueTest])
	}

	func testDefaultsMigrationSecondRun() throws {
		DefaultsManager.addMigration(
			.init(
				migrationVersion: 0,
				onMigrate: {
					DefaultsManager.shared[.doubleValueTest] += 1
				})
		)
		DefaultsManager.runMigrations()


		DefaultsManager.addMigration(
			.init(
				migrationVersion: 1,
				onMigrate: {
					DefaultsManager.shared[.doubleValueTest] = 41
				})
		)
		DefaultsManager.runMigrations()

		XCTAssertEqual(41, defaults[.doubleValueTest])
	}

	func testDefaultsMigrationOrdering() throws {
		DefaultsManager.addMigration(
			.init(
				migrationVersion: 1,
				onMigrate: {
					let value = DefaultsManager.shared[.stringyValue] ?? "no value"
					let newValue = "'\(value)' was the previous content"
					DefaultsManager.shared[.stringyValue] = newValue
				})
		)
		DefaultsManager.addMigration(
			.init(
				migrationVersion: 0,
				onMigrate: {
					DefaultsManager.shared[.stringyValue] = "foobar"
				})
		)

		DefaultsManager.runMigrations()

		XCTAssertEqual("'foobar' was the previous content", defaults[.stringyValue])
	}
}

extension DefaultsManager.Key where Value == String, StoredValue == String {
	static let stringyValue = Self(
		rawValue: "com.pizzaSnips.stringyValue")
}
