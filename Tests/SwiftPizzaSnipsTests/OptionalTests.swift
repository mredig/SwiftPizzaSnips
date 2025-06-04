import Testing
import SwiftPizzaSnips

struct OptionalTests {
	@Test func basicOptionalUnwraps() {
		let a: Int? = 0
		let b: Int? = nil

		#expect(throws: Never.self, performing: {
			try a.unwrap()
		})
		#expect(throws: Optional<Int>.OptionalError.self, performing: {
			try b.unwrap()
		})
	}

	@Test func optionalOrFatalUnwraps() {
		let a: Int? = 0

		#expect(a.unwrapOrFatalError(message: "There should *definitely* be a value") == 0)
//		#expect(try Optional<Int>.none.unwrapOrFatalError(message: "It would be great to test this, but it would crash the tests. Oh well."))
	}

	@Test func optionalUnwrapAndCast() throws {
		let a: Any? = 0
		let b: Any? = nil

		#expect(throws: Never.self, performing: {
			try a.unwrapCast(as: Int.self)
		})
		#expect(throws: Error.self, performing: {
			try b.unwrapCast(as: Int.self)
		})
	}

	@Test func optionalUnwrapCastOrFatalUnwraps() {
		let a: Any? = 0

		#expect(a.unwrapCastOrFatalError(as: Int.self, message: "There should *definitely* be a value") == 0)
//		#expect(try Optional<Int>.none.unwrapCastOrFatalError(as: Int.self, message: "It would be great to test this, but it would crash the tests. Oh well."))
	}

	@Test func customError() async throws {
		let a: Int? = 0
		let b: Any? = nil

		#expect(throws: Never.self, performing: {
			try a.unwrap(or: SimpleError(message: "No int value"))
		})
		#expect(throws: SimpleError.self, performing: {
			try b.unwrap(or: SimpleError(message: "No int value"))
		})
	}
}
