import Foundation
import Testing
import SwiftPizzaSnips

struct DefaultValueWrapperTests {
	private struct TestDefaultValueWrapper: Codable, Hashable {

		@DefaultValueWrapper(defaultValue: "baz")
		var foo: String?

		var bar: Int

		init(foo: String? = nil, bar: Int) {
			self.bar = bar
			self.foo = foo
		}

		init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)

			let foo = try container.decodeIfPresent(String.self, forKey: .foo)
			let bar = try container.decode(Int.self, forKey: .bar)

			self.init(foo: foo, bar: bar)
		}
	}

	@Test
	func testNonNil() throws {
		let value = TestDefaultValueWrapper(foo: "asdf", bar: 5)

		#expect(value.bar == 5)
		#expect(value.foo == "asdf")
		#expect(value.$foo == "asdf")
	}

	@Test
	func testNil() throws {
		let value = TestDefaultValueWrapper(foo: nil, bar: 5)

		#expect(value.bar == 5)
		#expect(value.foo == nil)
		#expect(value.$foo == "baz")
	}

	@Test
	func testNil2() throws {
		var value = TestDefaultValueWrapper(bar: 5)

		#expect(value.bar == 5)
		#expect(value.foo == nil)
		#expect(value.$foo == "baz")

		value.foo = "bar"
		#expect(value.foo == "bar")
		#expect(value.$foo == "bar")

		value.foo = nil
		#expect(value.foo == nil)
		#expect(value.$foo == "baz")
	}
}
