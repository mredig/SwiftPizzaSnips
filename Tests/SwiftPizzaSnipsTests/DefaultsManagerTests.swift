import XCTest
import SwiftPizzaSnips

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
final class DefaultsManagerTests: XCTestCase {
	static let testValueNilKey = "com.pizzaSnips.testValueNil"
	static let testValueValueKey = "com.pizzaSnips.testValueValue"
	static let doubleValueTestKey = "com.pizzaSnips.doubleTestValue"
	static let transformableTestValueKey = "com.pizzaSnips.transformableTestValue"
	static let transformableTestAutoCodingValueKey = "com.pizzaSnips.transformableTestAutoCodingValueKey"
	static let transformableTestAutoCodingValueWithDefaultKey = "com.pizzaSnips.transformableTestAutoCodingValueWithDefaultKey"
	static let transformableTestIDKey = "com.pizzaSnips.transformableTestID"
	static let transformableTestValueNilKey = "com.pizzaSnips.transformableTestValueNil"
	static let transformableTestValueDefaultKey = "com.pizzaSnips.transformableTestValueDefault"
	static let asymettricalTransformableTestValueDefaultKey = "com.pizzaSnips.asymettricalTransformableTestValueDefault"
	static let int8NumberKey = "com.pizzaSnips.int8NumberKey"
	static let int16NumberKey = "com.pizzaSnips.int16NumberKey"
	static let int32NumberKey = "com.pizzaSnips.int32NumberKey"
	static let int64NumberKey = "com.pizzaSnips.int64NumberKey"
	static let uint8NumberKey = "com.pizzaSnips.uint8NumberKey"
	static let uint16NumberKey = "com.pizzaSnips.uint16NumberKey"
	static let uint32NumberKey = "com.pizzaSnips.uint32NumberKey"
	static let uint64NumberKey = "com.pizzaSnips.uint64NumberKey"
	static let allKeys = [
		testValueNilKey,
		testValueValueKey,
		doubleValueTestKey,
		transformableTestValueKey,
		transformableTestAutoCodingValueKey,
		transformableTestAutoCodingValueWithDefaultKey,
		transformableTestValueNilKey,
		transformableTestValueDefaultKey,
		asymettricalTransformableTestValueDefaultKey,
		int8NumberKey,
		int16NumberKey,
		int32NumberKey,
		int64NumberKey,
		uint8NumberKey,
		uint16NumberKey,
		uint32NumberKey,
		uint64NumberKey,
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

		UserDefaults.standard.set(42, forKey: testValueValueKey)
		let data = try! encoder.encode(tValueViolet)
		UserDefaults.standard.set(data, forKey: transformableTestValueKey)
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

	func testDefaultsManagerSetAutoCodableTransformedKeyValue() {
		defaults[.transformableAutoCodingValue] = Self.tValuePeter

		XCTAssertEqual(Self.tValuePeter, defaults[.transformableAutoCodingValue])
	}

	func testDefaultsManagerTransformableIDStoredAsString() throws {
		let id = UUID()
		defaults[.transformableID] = id
		XCTAssertEqual(id, defaults[.transformableID])

		defaults[.transformableID] = nil
		XCTAssertNil(defaults[.transformableID])
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

	func testDefaultsManagerSetAutoCodableTransformedKeyWithDefaultValue() {
		defaults[.transformableAutoCodingDefaultValue] = Self.tValuePeter
		XCTAssertEqual(Self.tValuePeter, defaults[.transformableAutoCodingDefaultValue])

		defaults.removeValue(for: .transformableAutoCodingDefaultValue)
		XCTAssertEqual(Self.tValueViolet, defaults[.transformableAutoCodingDefaultValue])
	}

	func testDefaultsManagerGetAutoCodableTransformedKeyWithDefaultValue() {
		XCTAssertEqual(Self.tValueViolet, defaults[.transformableAutoCodingDefaultValue])
	}

	func testDefaultsManagerSetAsymetricalTransformedKeyWithDefault() {
		let nobodyPath = "/Users/nobody"
		let somebodyPath = "/Users/somebody"

		let initialValue = defaults[.asymTransformValue]
		XCTAssertEqual([], initialValue)

		defaults[.asymTransformValue].append(nobodyPath)
		XCTAssertEqual([nobodyPath], defaults[.asymTransformValue])

		defaults[.asymTransformValue].append(nobodyPath)
		XCTAssertEqual([nobodyPath], defaults[.asymTransformValue])

		defaults[.asymTransformValue].append(somebodyPath)
		XCTAssertEqual([nobodyPath, somebodyPath], defaults[.asymTransformValue])

		defaults[.asymTransformValue].append(nobodyPath)
		XCTAssertEqual([nobodyPath, somebodyPath], defaults[.asymTransformValue])

		defaults[.asymTransformValue].append(somebodyPath)
		XCTAssertEqual([nobodyPath, somebodyPath], defaults[.asymTransformValue])
	}

	func testDefaultsManagerGetDefaultValueFromKeyWithDefault() {
		let expectedValue = 3.14159

		XCTAssertEqual(expectedValue, defaults[.doubleValueTest])

		defaults[.doubleValueTest] = 213
		XCTAssertEqual(213, defaults[.doubleValueTest])
		XCTAssertEqual(expectedValue, defaults[defaultValue: .doubleValueTest])
	}

	func testDefaultsManagerResetToDefaultValueFromKeyWithDefault() {
		let expectedValue = 3.14159

		XCTAssertEqual(expectedValue, defaults[.doubleValueTest])

		defaults[.doubleValueTest] = 213
		XCTAssertEqual(213, defaults[.doubleValueTest])

		defaults.reset(key: .doubleValueTest) // <-- first option
		XCTAssertEqual(expectedValue, defaults[.doubleValueTest])

		// alternative option
		defaults[.doubleValueTest] = 213
		XCTAssertEqual(213, defaults[.doubleValueTest])

		_ = defaults[reset: .doubleValueTest] // <-- this is the alt
		XCTAssertEqual(expectedValue, defaults[.doubleValueTest])
	}

	func testInt8() throws {
		let expectedValue: Int8 = .max

		XCTAssertEqual(expectedValue, defaults[.int8NumberValue])

		defaults[.int8NumberValue] = 0
		XCTAssertEqual(0, defaults[.int8NumberValue])

		defaults.reset(key: .int8NumberValue)
		XCTAssertEqual(expectedValue, defaults[.int8NumberValue])
	}

	func testInt16() throws {
		let expectedValue: Int16 = .max

		XCTAssertEqual(expectedValue, defaults[.int16NumberValue])

		defaults[.int16NumberValue] = 0
		XCTAssertEqual(0, defaults[.int16NumberValue])

		defaults.reset(key: .int16NumberValue)
		XCTAssertEqual(expectedValue, defaults[.int16NumberValue])
	}

	func testInt32() throws {
		let expectedValue: Int32 = .max

		XCTAssertEqual(expectedValue, defaults[.int32NumberValue])

		defaults[.int32NumberValue] = 0
		XCTAssertEqual(0, defaults[.int32NumberValue])

		defaults.reset(key: .int32NumberValue)
		XCTAssertEqual(expectedValue, defaults[.int32NumberValue])
	}

	func testInt64() throws {
		let expectedValue: Int64 = .max

		XCTAssertEqual(expectedValue, defaults[.int64NumberValue])

		defaults[.int64NumberValue] = 0
		XCTAssertEqual(0, defaults[.int64NumberValue])

		defaults.reset(key: .int64NumberValue)
		XCTAssertEqual(expectedValue, defaults[.int64NumberValue])
	}

	func testUInt8() throws {
		let expectedValue: UInt8 = .max

		XCTAssertEqual(expectedValue, defaults[.uint8NumberValue])

		defaults[.uint8NumberValue] = 0
		XCTAssertEqual(0, defaults[.uint8NumberValue])

		defaults.reset(key: .uint8NumberValue)
		XCTAssertEqual(expectedValue, defaults[.uint8NumberValue])
	}

	func testUInt16() throws {
		let expectedValue: UInt16 = .max

		XCTAssertEqual(expectedValue, defaults[.uint16NumberValue])

		defaults[.uint16NumberValue] = 0
		XCTAssertEqual(0, defaults[.uint16NumberValue])

		defaults.reset(key: .uint16NumberValue)
		XCTAssertEqual(expectedValue, defaults[.uint16NumberValue])
	}

	func testUInt32() throws {
		let expectedValue: UInt32 = .max

		XCTAssertEqual(expectedValue, defaults[.uint32NumberValue])

		defaults[.uint32NumberValue] = 0
		XCTAssertEqual(0, defaults[.uint32NumberValue])

		defaults.reset(key: .uint32NumberValue)
		XCTAssertEqual(expectedValue, defaults[.uint32NumberValue])
	}

	func testUInt64() throws {
		let expectedValue: UInt64 = .max

		XCTAssertEqual(expectedValue, defaults[.uint64NumberValue])

		defaults[.uint64NumberValue] = 0
		XCTAssertEqual(0, defaults[.uint64NumberValue])

		defaults.reset(key: .uint64NumberValue)
		XCTAssertEqual(expectedValue, defaults[.uint64NumberValue])
	}

	func testUInt() throws {
		let expectedValue: UInt = .max

		XCTAssertEqual(expectedValue, defaults[.uintNumberValue])

		defaults[.uintNumberValue] = 0
		XCTAssertEqual(0, defaults[.uintNumberValue])

		defaults.reset(key: .uintNumberValue)
		XCTAssertEqual(expectedValue, defaults[.uintNumberValue])
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
private let transformableValueTransform = DefaultsManager.Transform(
	get: { data in
		try DefaultsManagerTests.decoder.decode(TransformableValue.self, from: data)
	},
	set: { value in
		try DefaultsManagerTests.encoder.encode(value)
	})

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.Key where Value == Int, StoredValue == Value {
	static let testValueNil = Self(DefaultsManagerTests.testValueNilKey)
	static let testValueValue = Self(DefaultsManagerTests.testValueValueKey)
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.Key where Value == TransformableValue, StoredValue == Data {
	static let transformableNil = Self(DefaultsManagerTests.transformableTestValueNilKey)
		.withTransform(transformableValueTransform)

	static let transformableWithValue = Self(DefaultsManagerTests.transformableTestValueKey)
		.withTransform(
			get: transformableValueTransform.get,
			set: transformableValueTransform.set)

	static let transformableAutoCodingValue = Self(autoCodingValueWithKey: DefaultsManagerTests.transformableTestAutoCodingValueKey)
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.Key where Value == UUID, StoredValue == String {
	static let transformableID = Self(DefaultsManagerTests.transformableTestIDKey)
		.withTransform(
			get: { UUID(uuidString: $0) },
			set: { $0.uuidString })
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == Double, StoredValue == Value {
	static let doubleValueTest = Self(DefaultsManagerTests.doubleValueTestKey, defaultValue: 3.14159)
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == TransformableValue, StoredValue == Data {
	static let transformableDefault = Self(
		DefaultsManagerTests.transformableTestValueDefaultKey,
		defaultValue: DefaultsManagerTests.tValueFrank)
		.withTransform(
			get: transformableValueTransform.get,
			set: transformableValueTransform.set)

	static let transformableAutoCodingDefaultValue = Self(autoCodingValueWithKey: DefaultsManagerTests.transformableTestAutoCodingValueWithDefaultKey, defaultValue: DefaultsManagerTests.tValueViolet)
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == [String], StoredValue == Value {
	static let asymTransformValue = Self(
		DefaultsManagerTests.asymettricalTransformableTestValueDefaultKey,
		defaultValue: [])
		.withTransform(set: { arrayIn in
			arrayIn.reduce(
				into: [String]()) {
					guard $0.contains($1) == false else { return }
					$0.append($1)
				}
		})
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == Int8, StoredValue == Value {
	static let int8NumberValue = Self(
		DefaultsManagerTests.int8NumberKey,
		defaultValue: .max)
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == Int16, StoredValue == Value {
	static let int16NumberValue = Self(
		DefaultsManagerTests.int16NumberKey,
		defaultValue: .max)
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == Int32, StoredValue == Value {
	static let int32NumberValue = Self(
		DefaultsManagerTests.int32NumberKey,
		defaultValue: .max)
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == Int64, StoredValue == Value {
	static let int64NumberValue = Self(
		DefaultsManagerTests.int64NumberKey,
		defaultValue: .max)
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == UInt8, StoredValue == Value {
	static let uint8NumberValue = Self(
		DefaultsManagerTests.uint8NumberKey,
		defaultValue: .max)
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == UInt16, StoredValue == Value {
	static let uint16NumberValue = Self(
		DefaultsManagerTests.uint16NumberKey,
		defaultValue: .max)
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == UInt32, StoredValue == Value {
	static let uint32NumberValue = Self(
		DefaultsManagerTests.uint32NumberKey,
		defaultValue: .max)
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == UInt64, StoredValue == Value {
	static let uint64NumberValue = Self(
		DefaultsManagerTests.uint64NumberKey,
		defaultValue: .max)
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension DefaultsManager.KeyWithDefault where Value == UInt, StoredValue == Value {
	static let uintNumberValue = Self(
		DefaultsManagerTests.uint64NumberKey,
		defaultValue: .max)
}

struct TransformableValue: Codable, Hashable {
	let name: String
	let age: Int
	let favoriteColor: String
}
