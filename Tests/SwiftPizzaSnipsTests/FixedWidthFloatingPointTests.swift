import XCTest
import SwiftPizzaSnips

final class FixedWidthFloatingPointTests: XCTestCase {
	#if arch(arm64) // see Float16 docs
	@available(macOS 11.0, iOS 14.0, tvOS 14.0, *)
	func testFloat16() throws {
		let val: UInt16 = 54321
		let float: Float16 = -67.0625

		fixedWidthCompare(int: val, fp: float)
	}
	#endif

	func testFloat() throws {
		let val: UInt32 = 1123477881
		let float: Float32 = 123.456001

		fixedWidthCompare(int: val, fp: float)
	}

	func testDouble() throws {
		let val: UInt64 = 4614256650576692846
		let float: Double = 3.1415899999999999

		fixedWidthCompare(int: val, fp: float)
	}

	private func fixedWidthCompare<FWI: FixedWidthInteger, FWFP: FixedWidthFloatingPoint>(
		int: FWI,
		fp: FWFP,
		line: UInt = #line
	) where FWFP.BitRepresentation == FWI {
		XCTAssert(UInt64(fp.bitPattern) == UInt64(int), "\(int) and \(fp) bit pattern mismatch", line: line)
		XCTAssert(UInt64(fp.bigEndian) == UInt64(int.bigEndian), "\(int) and \(fp) bigEndian mismatch", line: line)
		XCTAssert(UInt64(fp.littleEndian) == UInt64(int.littleEndian), "\(int) and \(fp) littleEndian mismatch", line: line)
		XCTAssert(UInt64(fp.leadingZeroBitCount) == UInt64(int.leadingZeroBitCount), "\(int) and \(fp) leadingZeroBitCount mismatch", line: line)
		XCTAssert(UInt64(fp.nonzeroBitCount) == UInt64(int.nonzeroBitCount), "\(int) and \(fp) nonzeroBitCount mismatch", line: line)
		XCTAssert(UInt64(fp.byteSwapped) == UInt64(int.byteSwapped), "\(int) and \(fp) byteSwapped mismatch", line: line)
	}
}
