import XCTest
import SwiftPizzaSnips

final class PrivateAPITests: XCTestCase {
	func testDemoMethodGetting() {
		getAllMethodNames(for: NSDiffableDataSourceSnapshotReference.self)
	}

	func testPropertyGetting() throws {
		getAllPropertyNames(for: NSClassFromString("__NSDiffableDataSourceSnapshot"))
	}

	func testIvarGetting() throws {
		getAllIVars(for: NSClassFromString("__NSDiffableDataSourceSnapshot"))
	}

	func testProtocolGetting() throws {
		getProtocolConformances(for: NSClassFromString("__NSDiffableDataSourceSnapshot"))
	}
	
}
