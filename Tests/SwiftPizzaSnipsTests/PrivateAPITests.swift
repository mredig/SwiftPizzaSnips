import XCTest
import SwiftPizzaSnips

final class PrivateAPITests: XCTestCase {
	func testDemoMethodGetting() {
		getAllMethodNames(for: NSClassFromString("_NSDiffableDataSourceState"))
	}

	func testPropertyGetting() throws {
		getAllPropertyNames(for: NSClassFromString("__NSDiffableDataSourceSnapshot"))
	}

	func testIvarGetting() throws {
		getAllIVars(for: NSClassFromString("__NSDiffableDataSourceSnapshot"))
	}

	func testProtocolGetting() throws {
		getProtocolConformances(for: NSClassFromString("_NSDiffableDataSourceState"))
	}
	
	func testProtocolMembers() throws {
		print("a")
		getProtocolSymbols(for: NSProtocolFromString("_NSDiffableDataSourceQuerying"))

		print("\n\nb")
		getProtocolSymbols(for: NSProtocolFromString("NSCopying"))

		print("\n\nc")
		getProtocolSymbols(for: NSProtocolFromString("NSObjectProtocol"))

		print("\n\nd")
		getProtocolSymbols(for: NSProtocolFromString("_NSDiffableDataSourceState"))
	}
}
