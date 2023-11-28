import XCTest
import SwiftPizzaSnips

@available(iOS 16.0, *)
final class WithableTests: XCTestCase {
	func testWithable() {
		let str = "fee fie fo fum"
		let nsArray = NSMutableArray().with { 
			$0.add(str as NSString)
		}

		XCTAssertEqual(1, nsArray.count)
		XCTAssertEqual(nsArray[0] as? NSString, str as NSString)
	}

	func testThrowingWithable() throws {
		let url = try Bundle.module.url(forResource: "sample", withExtension: "bin").unwrap()

		let prog = try Progress().with {
			$0.totalUnitCount = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize.map(Int64.init) ?? 0
		}

		XCTAssertEqual(10240, prog.totalUnitCount)
	}

	func testAsyncWithable() async throws {
		let url = try Bundle.module.url(forResource: "sample", withExtension: "bin").unwrap()

		let prog = try await Progress().asyncWith {
			$0.totalUnitCount = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize.map(Int64.init) ?? 0
			try await Task.sleep(nanoseconds: 100)
		}

		XCTAssertEqual(10240, prog.totalUnitCount)
	}
}
