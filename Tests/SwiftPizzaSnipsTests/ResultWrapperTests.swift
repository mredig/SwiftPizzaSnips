import XCTest
import SwiftPizzaSnips

final class ResultWrapperTests: XCTestCase {
	func testResultWrapperSuccess() {
		let wrapped = wrap {
			"Foo"
		}

		XCTAssertNoThrow(try wrapped.get())
	}

	func testResultWrapperFailure() {
		let wrapped = wrap {
			throw SimpleError(message: "Bar")
		}

		XCTAssertThrowsError(try wrapped.get())
	}

	func testAsyncResultWrapperSuccess() async {
		let wrapped = await wrap {
			try await Task.sleep(nanoseconds: 200_000)
			return "Foo"
		}

		XCTAssertNoThrow(try wrapped.get())
	}

	func testAsyncResultWrapperFailure() async {
		let wrapped = await wrap {
			try await Task.sleep(nanoseconds: 200_000)
			throw SimpleError(message: "Bar")
		}

		XCTAssertThrowsError(try wrapped.get())
	}
}
