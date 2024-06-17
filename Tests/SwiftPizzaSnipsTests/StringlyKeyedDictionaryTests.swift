import XCTest
import SwiftPizzaSnips

final class StringlyKeyedDictionaryTests: XCTestCase {

	struct Keysss: RawRepresentable {
		static let foo = Keysss(rawValue: "foo")
		static let bar = Keysss(rawValue: "bar")
		static let mismatch = Keysss(rawValue: "baz")

		let rawValue: String
	}

	enum EnumKeys: String {
		case foo
		case bar
		case mismatch = "baz"
	}

	func testStringlyKeyedDictionary() {
		let starterDict = [
			"foo": 5,
			"bar": 10,
			"baz": 15
		]

		var keyedDict = StringlyKeyedDictionary(dictionary: starterDict, type: Keysss.self)

		XCTAssertEqual(keyedDict[.foo], 5)
		XCTAssertEqual(keyedDict[.bar], 10)
		XCTAssertEqual(keyedDict[.mismatch], 15)
		XCTAssertNotEqual(keyedDict[.mismatch], 10)

		keyedDict[.foo] = 50
		keyedDict[.mismatch] = 100

		XCTAssertNotEqual(keyedDict[.foo], 5)
		XCTAssertEqual(keyedDict[.foo], 50)
		XCTAssertNotEqual(keyedDict[.mismatch], 15)
		XCTAssertEqual(keyedDict[.mismatch], 100)
	}

	func testEnumStringlyKeyedDictionary() {
		let starterDict = [
			"foo": 5,
			"bar": 10,
			"baz": 15
		]

		var keyedDict = StringlyKeyedDictionary(dictionary: starterDict, type: EnumKeys.self)

		XCTAssertEqual(keyedDict[.foo], 5)
		XCTAssertEqual(keyedDict[.bar], 10)
		XCTAssertEqual(keyedDict[.mismatch], 15)
		XCTAssertNotEqual(keyedDict[.mismatch], 10)

		keyedDict[.foo] = 50
		keyedDict[.mismatch] = 100

		XCTAssertNotEqual(keyedDict[.foo], 5)
		XCTAssertEqual(keyedDict[.foo], 50)
		XCTAssertNotEqual(keyedDict[.mismatch], 15)
		XCTAssertEqual(keyedDict[.mismatch], 100)
	}


	func testStringlyKeyedSimplerInit() {
		// this doesn't actually need any assertions, but demonstrates how to init with an explicit type and an empty
		// dictionary
		let testing = StringlyKeyedDictionary<Keysss, Any>(dictionary: [:])
		XCTAssertNil(testing[.foo])
	}

	func testStringlyKeyedSimplestInit() {
		// this doesn't actually need any assertions, but demonstrates how to init with an explicit type and an empty
		// dictionary
		let testing: StringlyKeyedDictionary<Keysss, Any> = [:]
		XCTAssertNil(testing[.foo])
	}

	func testStringKeyedCodable() throws {
		let starterDict = [
			"foo": 5,
			"bar": 10,
			"baz": 15
		]

		let keyedDict = StringlyKeyedDictionary(dictionary: starterDict, type: Keysss.self)

		let encoder = JSONEncoder().with {
			$0.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
		}
		let data = try encoder.encode(keyedDict)

		let expectedJSON = """
			{"bar":10,"baz":15,"foo":5}
			"""

		XCTAssertEqual(String(decoding: data, as: UTF8.self), expectedJSON)

		let decoder = JSONDecoder()
		let decodedDict = try decoder.decode(StringlyKeyedDictionary<Keysss, Int>.self, from: data)

		XCTAssertEqual(keyedDict, decodedDict)
	}
}
