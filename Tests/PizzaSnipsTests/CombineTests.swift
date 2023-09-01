import XCTest
@testable import SwiftPizzaSnips
import Combine

final class CombineTests: XCTestCase {

	@available(macOS 15.0, *)
	func testBag() {
		var bag: Bag = []

		XCTAssertEqual(bag.count, 0)
		NotificationCenter
			.default
			.publisher(for: .NSCalendarDayChanged)
			.sink { _ in
				// noop
			}
			.store(in: &bag)

		XCTAssertEqual(bag.count, 1)
	}
}
