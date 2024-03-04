import XCTest
import SwiftPizzaSnips
#if canImport(CryptoKit)
import CryptoKit

final class HashFunctionTests: XCTestCase {
	func testHashTrueBool() throws {
		let numTrueBool: Bool = true
		let numFalseBool: Bool = false

		var hasher = PersistentHashable.Hasher()
		hasher.update(bool: numTrueBool)

		XCTAssertEqual(hasher.finalize().toHexString(), "55a54008ad1ba589aa210d2629c1df41")
	}

	func testHashFalseBool() throws {
		let numFalseBool: Bool = false

		var hasher = PersistentHashable.Hasher()
		hasher.update(bool: numFalseBool)

		XCTAssertEqual(hasher.finalize().toHexString(), "93b885adfe0da089cdf634904fd59f71")
	}

	func testUInt8() throws {
		let numUInt8: UInt8 = 142

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numUInt8)

		XCTAssertEqual(hasher.finalize().toHexString(), "f1663aba9ffae5338b6382a24b2e5377")
	}

	func testInt8() throws {
		let numInt8: Int8 = -114

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numInt8)

		XCTAssertEqual(hasher.finalize().toHexString(), "f1663aba9ffae5338b6382a24b2e5377")
	}

	func testUInt16() throws {
		let numUInt16: UInt16 = 25963

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numUInt16)

		XCTAssertEqual(hasher.finalize().toHexString(), "25bc6654798eb508fa0b6343212a74fe")
	}

	func testInt16() throws {
		let numInt16: Int16 = 25963

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numInt16)

		XCTAssertEqual(hasher.finalize().toHexString(), "25bc6654798eb508fa0b6343212a74fe")
	}

	#if arch(arm64) // see Float16 docs
	func testFloat16() throws {
		let numFloat16: Float16 = 1387

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numFloat16)

		XCTAssertEqual(hasher.finalize().toHexString(), "25bc6654798eb508fa0b6343212a74fe")
	}
	#endif

	func testUInt32() throws {
		let numUInt32: UInt32 = 1881172084

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numUInt32)

		XCTAssertEqual(hasher.finalize().toHexString(), "4b247e1731ef41324099b578bf3f9f2c")
	}

	func testInt32() throws {
		let numInt32: Int32 = 1881172084

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numInt32)

		XCTAssertEqual(hasher.finalize().toHexString(), "4b247e1731ef41324099b578bf3f9f2c")
	}

	func testFloat() throws {
		let numFloat: Float = 1.98575511e+29

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numFloat)

		XCTAssertEqual(hasher.finalize().toHexString(), "4b247e1731ef41324099b578bf3f9f2c")
	}

	func testUInt64() throws {
		let numUInt64: UInt64 = 5280563060687183956

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numUInt64)

		XCTAssertEqual(hasher.finalize().toHexString(), "3b39540abdf2754cb48cb6065e552f4a")
	}

	func testInt64() throws {
		let numInt64: Int64 = 5280563060687183956

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numInt64)

		XCTAssertEqual(hasher.finalize().toHexString(), "3b39540abdf2754cb48cb6065e552f4a")
	}

	func testUInt() throws {
		let numUInt: UInt = 5280563060687183956

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numUInt)

		XCTAssertEqual(hasher.finalize().toHexString(), "3b39540abdf2754cb48cb6065e552f4a")
	}

	func testInt() throws {
		let numInt: Int = 5280563060687183956

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numInt)

		XCTAssertEqual(hasher.finalize().toHexString(), "3b39540abdf2754cb48cb6065e552f4a")
	}

	func testDouble() throws {
		let numDouble: Double = 1.0850925985511023e+45

		var hasher = PersistentHashable.Hasher()
		hasher.update(number: numDouble)

		XCTAssertEqual(hasher.finalize().toHexString(), "3b39540abdf2754cb48cb6065e552f4a")
	}

	func testString() throws {
		let string = "foo bar"

		var hasher = PersistentHashable.Hasher()
		hasher.update(string: string)

		XCTAssertEqual(hasher.finalize().toHexString(), "327b6f07435811239bc47e1544353273")
	}
}
#endif
