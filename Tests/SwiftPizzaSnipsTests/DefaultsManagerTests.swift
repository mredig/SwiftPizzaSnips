import XCTest
import SwiftPizzaSnips

final class DefaultsManagerTests: XCTestCase {
	static let testValueNilKey = "com.pizzaSnips.testValueNil"
	static let testValueValueKey = "com.pizzaSnips.testValueValue"
	static let doubleValueTestKey = "com.pizzaSnips.doubleTestValue"
	static let transformableTestValueKey = "com.pizzaSnips.transformableTestValue"
	static let transformableTestValueNilKey = "com.pizzaSnips.transformableTestValueNil"
	static let transformableTestValueDefaultKey = "com.pizzaSnips.transformableTestValueDefault"
	static let allKeys = [
		testValueNilKey,
		testValueValueKey,
		doubleValueTestKey,
		transformableTestValueKey,
		transformableTestValueNilKey,
		transformableTestValueDefaultKey,
	]

	static let tValuePeter = TransformableValue(name: "Peter", age: 31, favoriteColor: "Green")
	static let tValueFrank = TransformableValue(name: "Frank", age: 23, favoriteColor: "Blue")
	static let tValueViolet = TransformableValue(name: "Violet", age: 65, favoriteColor: "Brown")

	static let encoder = PropertyListEncoder()
	static let decoder = PropertyListDecoder()

	private static func cleanupKeys() {
		for key in allKeys {
			UserDefaults.standard.removeObject(forKey: key)
		}

		UserDefaults.standard.setValue(42, forKey: testValueValueKey)
		let data = try! encoder.encode(tValueViolet)
		UserDefaults.standard.setValue(data, forKey: transformableTestValueKey)
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
	func testDefaultsManagerGetNilKey() {
		let nilValue = defaults[.testValueNil]

		XCTAssertNil(nilValue)
	}

	func testDefaultsManagerGetValueKey() {
		let hasValue = defaults[.testValueValue]

		XCTAssertEqual(42, hasValue)
	}

	func testDefaultsManagerSetKeyNil() {
		defaults[.testValueNil] = nil
		XCTAssertNil(defaults[.testValueNil])

		defaults[.testValueValue] = nil
		XCTAssertNil(defaults[.testValueValue])
	}

	func testDefaultsManagerSetKeyValue() {
		defaults[.testValueNil] = 501

		defaults[.testValueValue] = 69 // nice

		XCTAssertEqual(501, defaults[.testValueNil])
		XCTAssertEqual(69, defaults[.testValueValue])
	}

	func testDefaultsManagerGetTranformedKeyNil() {
		let nilValue = defaults[.transformableNil]

		XCTAssertNil(nilValue)
	}

	func testDefaultsManagerGetTranformedKeyValue() {
		let value = defaults[.transformableWithValue]

		XCTAssertEqual(Self.tValueViolet, value)
	}

	func testDefaultsManagerSetTransformedKeyNil() {
		defaults[.transformableNil] = nil
		XCTAssertNil(defaults[.transformableNil])

		defaults[.transformableWithValue] = nil
		XCTAssertNil(defaults[.transformableWithValue])
	}

	func testDefaultsManagerSetTransformedKeyValue() {
		defaults[.transformableNil] = Self.tValueFrank
		defaults[.transformableWithValue] = Self.tValuePeter

		XCTAssertEqual(Self.tValueFrank, defaults[.transformableNil])
		XCTAssertEqual(Self.tValuePeter, defaults[.transformableWithValue])
	}

	// MARK: - KeyWithDefault
	func testDefaultsManagerGetKeyWithDefault() {
		let defaultValue = defaults[.doubleValueTest]
		XCTAssertEqual(3.14159, defaultValue)
	}

	func testDefaultsManagerSetKeyWithDefault() {
		defaults[.doubleValueTest] = 123.456

		XCTAssertEqual(123.456, defaults[.doubleValueTest])
	}

	func testDefaultsManagerSetKeyWithDefaultNil() {
		defaults[.doubleValueTest] = 123.456
		XCTAssertEqual(123.456, defaults[.doubleValueTest])

		defaults.removeValue(for: .doubleValueTest)
		XCTAssertEqual(3.14159, defaults[.doubleValueTest])
	}

	func testDefaultsManagerGetTransformedKeyWithDefault() {
		let defaultValue = defaults[.transformableDefault]
		XCTAssertEqual(Self.tValueFrank, defaultValue)
	}

	func testDefaultsManagerSetTransformedKeyWithDefault() {
		defaults[.transformableDefault] = Self.tValueViolet

		XCTAssertEqual(Self.tValueViolet, defaults[.transformableDefault])
	}

	func testDefaultsManagerSetTransformedKeyWithDefaultNil() {
		defaults[.transformableDefault] = Self.tValueViolet
		XCTAssertEqual(Self.tValueViolet, defaults[.transformableDefault])

		defaults.removeValue(for: .transformableDefault)
		XCTAssertEqual(Self.tValueFrank, defaults[.transformableDefault])
	}
}

private let transformableValueTransform = DefaultsManager.Transform(
	get: { data in
		try DefaultsManagerTests.decoder.decode(TransformableValue.self, from: data)
	},
	set: { value in
		try DefaultsManagerTests.encoder.encode(value)
	})

extension DefaultsManager.Key where Value == Int, StoredValue == Value {
	static let testValueNil = Self(rawValue: DefaultsManagerTests.testValueNilKey)
	static let testValueValue = Self(rawValue: DefaultsManagerTests.testValueValueKey)
}

extension DefaultsManager.Key where Value == TransformableValue, StoredValue == Data {
	static let transformableNil = Self(
		rawValue: DefaultsManagerTests.transformableTestValueNilKey)
		.withTransform(transformableValueTransform)

	static let transformableWithValue = Self(
		rawValue: DefaultsManagerTests.transformableTestValueKey)
		.withTransform(
			get: transformableValueTransform.get,
			set: transformableValueTransform.set)
}

extension DefaultsManager.KeyWithDefault where Value == Double, StoredValue == Value {
	static let doubleValueTest = Self(
		rawValue: DefaultsManagerTests.doubleValueTestKey,
		defaultValue: 3.14159)
}

extension DefaultsManager.KeyWithDefault where Value == TransformableValue, StoredValue == Data {
	static let transformableDefault = Self(
		rawValue: DefaultsManagerTests.transformableTestValueDefaultKey,
		defaultValue: DefaultsManagerTests.tValueFrank)
		.withTransform(
			get: transformableValueTransform.get,
			set: transformableValueTransform.set)
}

struct TransformableValue: Codable, Hashable {
	let name: String
	let age: Int
	let favoriteColor: String
}
