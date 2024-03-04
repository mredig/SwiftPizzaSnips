import XCTest
import SwiftPizzaSnips

// Note: Many of these tests are just confirming that they provide consistent hashes. If it's found that a value is
// incorrect, but consistent, that's *kind* of a bug? Kind of? But not really, as long as it achieves consistency...
// It would just mean that it'd be harder to independently verify the hash external to this library.
final class PersistentHashableTests: XCTestCase {
	func testHashFunctionNumbers() throws {
		let numTrueBool: Bool = true
		let numFalseBool: Bool = false
		let numUInt81: UInt8 = 1
		let numUInt80: UInt8 = 0
		let numInt: Int = 5280563060687183956
		let numUInt: UInt = 5280563060687183956
		let numInt8: Int8 = -114
		let numUInt8: UInt8 = 142
		let numInt16: Int16 = 25963
		let numUInt16: UInt16 = 25963
		let numInt32: Int32 = 1881172084
		let numUInt32: UInt32 = 1881172084
		let numInt64: Int64 = 5280563060687183956
		let numUInt64: UInt64 = 5280563060687183956
		let numFloat: Float = 1.98575511e+29
		#if arch(arm64) // see Float16 docs
		let numFloat16: Float16 = 1387
		#endif
		#if arch(x86_64)
		let numFloat80: Float80 = 0
		#endif
		let numDouble: Double = 1.0850925985511023e+45
		var numDecimal = Decimal(UInt64.max)
		numDecimal += 1

		XCTAssertEqual(numTrueBool.persistentHashValue().toHexString(), "55a54008ad1ba589aa210d2629c1df41")
		XCTAssertEqual(numUInt81.persistentHashValue().toHexString(), "55a54008ad1ba589aa210d2629c1df41")
		XCTAssertEqual(numFalseBool.persistentHashValue().toHexString(), "93b885adfe0da089cdf634904fd59f71")
		XCTAssertEqual(numUInt80.persistentHashValue().toHexString(), "93b885adfe0da089cdf634904fd59f71")

		XCTAssertEqual(numInt8.persistentHashValue().toHexString(), "f1663aba9ffae5338b6382a24b2e5377")
		XCTAssertEqual(numUInt8.persistentHashValue().toHexString(), "f1663aba9ffae5338b6382a24b2e5377")

		XCTAssertEqual(numInt16.persistentHashValue().toHexString(), "25bc6654798eb508fa0b6343212a74fe")
		XCTAssertEqual(numUInt16.persistentHashValue().toHexString(), "25bc6654798eb508fa0b6343212a74fe")
		#if arch(arm64) // see Float16 docs
		XCTAssertEqual(numFloat16.persistentHashValue().toHexString(), "25bc6654798eb508fa0b6343212a74fe")
		#endif

		XCTAssertEqual(numInt32.persistentHashValue().toHexString(), "4b247e1731ef41324099b578bf3f9f2c")
		XCTAssertEqual(numUInt32.persistentHashValue().toHexString(), "4b247e1731ef41324099b578bf3f9f2c")
		XCTAssertEqual(numFloat.persistentHashValue().toHexString(), "4b247e1731ef41324099b578bf3f9f2c")

		XCTAssertEqual(numInt.persistentHashValue().toHexString(), "3b39540abdf2754cb48cb6065e552f4a")
		XCTAssertEqual(numUInt.persistentHashValue().toHexString(), "3b39540abdf2754cb48cb6065e552f4a")
		XCTAssertEqual(numInt64.persistentHashValue().toHexString(), "3b39540abdf2754cb48cb6065e552f4a")
		XCTAssertEqual(numUInt64.persistentHashValue().toHexString(), "3b39540abdf2754cb48cb6065e552f4a")
		XCTAssertEqual(numDouble.persistentHashValue().toHexString(), "3b39540abdf2754cb48cb6065e552f4a")

		XCTAssertEqual(numDecimal.persistentHashValue().toHexString(), "6a00140112ebab75e3ece5dbfda9113a")
	}

	func testHashFunctionDate() throws {
		let date = Date(timeIntervalSinceReferenceDate: 123456)

		XCTAssertEqual(date.persistentHashValue().toHexString(), "dcdca4ae0fe75d4d157639adab74a1ae")
	}

	func testHashFunctionRanges() throws {
		let range = 0..<10
		let closedRange = 0...10

		XCTAssertEqual(range.persistentHashValue().toHexString(), "d5215e55e2693606fe0498a16e73188f")
		XCTAssertEqual(closedRange.persistentHashValue().toHexString(), "3e19530fa7a81cbddaaa13e415cd9d64")
	}

	func testHashFunctionCollections() throws {
		let arr = [0, 1, 2, 3, 4, 5]
		let dict = [
			"foo": "bar",
			"baz": "baf"
		]
		let set = Set(["a", "b", "c", "d", "e"])
		let data = Data([1, 3, 3, 7])
		let slice = Slice(base: data, bounds: 1..<3)

		XCTAssertEqual(arr.persistentHashValue().toHexString(), "fc6ad0d11f928e1f172ee4932e831fc7")
		XCTAssertEqual(dict.persistentHashValue().toHexString(), "2287f075548b1e624ca7cf18363fb92b")
		XCTAssertEqual(set.persistentHashValue().toHexString(), "ab56b4d92b40713acc5af89985d4b786")
		XCTAssertEqual(data.persistentHashValue().toHexString(), "6be695782012de2b2853c2f920f1b1d2")
		XCTAssertEqual(slice.persistentHashValue().toHexString(), "ac2bfee68b9182158d1c5bab47effd65")
	}

	func testHashFunctionString() throws {
		let string = "foo bar"
		let subStart = string.index(after: string.startIndex)
		let subEnd = string.index(before: string.endIndex)
		let sub = string[subStart..<subEnd]

		XCTAssertEqual(string.persistentHashValue().toHexString(), "327b6f07435811239bc47e1544353273")
		XCTAssertEqual(sub.persistentHashValue().toHexString(), "0228ecdf817c4b7783361d1f09a319ca")
	}

	func testHashFunctionOptional() throws {
		let value: String? = "foo bar"
		let null: String? = nil

		XCTAssertEqual(value.persistentHashValue().toHexString(), "327b6f07435811239bc47e1544353273")
		XCTAssertEqual(null.persistentHashValue().toHexString(), "93b885adfe0da089cdf634904fd59f71")
	}
}
