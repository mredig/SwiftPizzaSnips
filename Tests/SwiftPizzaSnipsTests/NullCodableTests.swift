import Foundation
import Testing
import SwiftPizzaSnips

struct NullCodableTests {
	private struct TestNullCodable: Codable, Hashable {
		@NullCodable
		var foo: String?

		var bar: Int

		init(foo: String? = nil, bar: Int) {
			self.foo = foo
			self.bar = bar
		}

		static let sampleJSONWithValue = Data(#"{"bar":5,"foo":"asdf"}"#.utf8)
		static let sampleJSONWithNull = Data(#"{"bar":5,"foo":null}"#.utf8)
		static let sampleJSONWithNoValue = Data(#"{"bar":5}"#.utf8)

		static let encoder = JSONEncoder().with {
			$0.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
		}
		static let decocder = JSONDecoder()
	}

	@Test
	func testNullEncodingWithValue() throws {
		let testedValue = TestNullCodable(foo: "asdf", bar: 5)

		let data = try TestNullCodable.encoder.encode(testedValue)
		#expect(data == TestNullCodable.sampleJSONWithValue)
	}

	@Test
	func testNullEncodingWithNullValue() throws {
		let testedValue = TestNullCodable(foo: nil, bar: 5)

		let data = try TestNullCodable.encoder.encode(testedValue)
		#expect(data == TestNullCodable.sampleJSONWithNull)
	}

	@Test
	func testNullDecodingWithValue() throws {
		let expected = TestNullCodable(foo: "asdf", bar: 5)
		let actual = try TestNullCodable.decocder.decode(TestNullCodable.self, from: TestNullCodable.sampleJSONWithValue)

		#expect(expected == actual)
	}

	@Test
	func testNullDecodingWithNullValue() throws {
		let expected = TestNullCodable(foo: nil, bar: 5)
		let actual = try TestNullCodable.decocder.decode(TestNullCodable.self, from: TestNullCodable.sampleJSONWithNull)

		#expect(expected == actual)
	}

	@Test
	func testNullDecodingWithNoValue() throws {
		#expect(
			performing: {
				try TestNullCodable.decocder.decode(TestNullCodable.self, from: TestNullCodable.sampleJSONWithNoValue)
			},
			throws: {
				guard
					let error = $0 as? DecodingError,
					case .keyNotFound(let codingKey, _) = error,
					codingKey.stringValue == "foo"
				else { return false }
				return true
			})
	}
}
