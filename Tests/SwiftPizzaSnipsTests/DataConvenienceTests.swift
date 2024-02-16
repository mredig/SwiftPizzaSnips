import XCTest
import SwiftPizzaSnips

final class DataConvenienceTests: XCTestCase {
	func testDataHexInitEven() throws {
		let hexString = "0x4F829ECDCFF34B3C91D3189DF4CC47D5"

		let data = try Data(hexString: hexString)

		XCTAssertEqual("0x\(data.toHexString())", hexString.lowercased())
	}

	func testDataHexInitOdd() throws {
		var hexString = "0x4F829ECDCFF34B3C91D3189DF4CC47D54"

		let data = try Data(hexString: hexString)

		hexString.removeFirst(2)

		XCTAssertEqual(data.toHexString(), "0\(hexString.lowercased())")
	}

	func testInvalidCharacters() throws {
		let hexString = "0x4F829ECDCFF34B3C91D31894DF4CC47xD5"

		XCTAssertThrowsError(try Data(hexString: hexString)) { error in
			XCTAssertEqual(error as! Data.DataHexError, Data.DataHexError.invalidCharacterInHexString)
		}
	}

	func testNoValue() throws {
		let hexStringA = ""
		let hexStringB = "0x"

		let dataA = try Data(hexString: hexStringA)
		XCTAssertEqual(Data(), dataA)

		let dataB = try Data(hexString: hexStringB)
		XCTAssertEqual(Data(), dataB)
	}

	func testDataHexInitEvenNo0x() throws {
		let hexString = "4F829ECDCFF34B3C91D3189DF4CC47D5"

		let data = try Data(hexString: hexString)

		XCTAssertEqual(data.toHexString(), hexString.lowercased())
	}

	func testDataHexInitOddNo0x() throws {
		let hexString = "4F829ECDCFF34B3C91D3189DF4CC47D54"

		let data = try Data(hexString: hexString)

		XCTAssertEqual(data.toHexString(), "0\(hexString.lowercased())")
	}
}
