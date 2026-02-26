import Testing
import SwiftPizzaSnips

struct WeakableRefTests {
	@Test func valuesWork() async throws {
		@WeakableRef
		var string = "foo"

		@WeakableRef
		var number = 5

		#expect(string == "foo")
		#expect(number == 5)
	}

	private class ExampleClass {
		let value: Int

		init(value: Int) {
			self.value = value
		}
	}

	@Test func classesWork() async throws {
		let existing = ExampleClass(value: 0)

		@WeakableRef
		var existingRef = existing

		@WeakableRef
		var newRef = ExampleClass(value: 1)

		#expect(existing.value == 0)
		#expect(existingRef?.value == 0)
		#expect(newRef == nil)
	}

	protocol SampleProtocol {}

	struct SampleStruct: SampleProtocol {}
	class SampleClass: SampleProtocol {}

	@Test func protocolsWork() async throws {
		let existingClass = SampleClass()
		let existingStruct = SampleStruct()

		@WeakableRef
		var existingClassRef = existingClass

		@WeakableRef
		var existingStructRef = existingStruct

		@WeakableRef
		var newClassRef = SampleClass()

		@WeakableRef
		var newStructRef = SampleStruct()

		#expect(existingClassRef != nil)
		#expect(existingStructRef != nil)
		#expect(newClassRef == nil)
		#expect(newStructRef != nil)
	}
}
