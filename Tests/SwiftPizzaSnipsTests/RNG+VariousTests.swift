import XCTest
import SwiftPizzaSnips
#if canImport(Crypto)
import Crypto
#elseif canImport(CryptoKit)
import CryptoKit
#endif

#if canImport(CryptoKit) || canImport(Crypto)

final class RNGVariousTests: XCTestCase {
	func testRandomData() throws {
		var rng: any RandomNumberGenerator = SeedableRNG(seed: 665544)

		let random = Data.random(count: 128, using: &rng)

		let expected = """
			b1ebb99ab0e12024091ac1ea1875942be1aa931f00cab71739f62e23684827e011d4023350d8b0fe699c490cb8e1bbb44127e09aa04c31f299cc\
			9d820881e34571642c5bf06676bfc94660f65866c72aa14b10894067d58cf9ca6d0ea8d1284ad19cdcbd908dbbde29194bebf802618f01180a2a\
			e05948313089986180b9e891
			"""
		XCTAssertEqual(random.toHexString(), expected)
	}

	@available(iOS 16, tvOS 16, watchOS 10, *)
	func testRandomStream() throws {
		var rng: any RandomNumberGenerator = SeedableRNG(seed: 665544)

		let input = RandomInputStream(using: &rng)
		input.open()

		let tempFile = URL.temporaryDirectory.appending(component: "randomtestdata.bin")
		try? FileManager.default.removeItem(at: tempFile)
		addTeardownBlock {
			try FileManager.default.removeItem(at: tempFile)
		}

		let fileSize = 10 // count
			* 1024 // KB
			* 1024 // MB
		let length = 10240
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
		defer { buffer.deallocate() }

		let out = try OutputStream(url: tempFile, append: false).unwrap()
		out.open()
		for _ in stride(from: 0, to: fileSize, by: length) {
			let inCount = input.read(buffer, maxLength: length)
			guard inCount == length else {
				throw SimpleError(message: "invalid input count")
			}
			let outCount = out.write(buffer, maxLength: length)
			guard outCount == length else {
				throw SimpleError(message: "invalid output count")
			}
		}
		out.close()

		let check = try InputStream(url: tempFile).unwrap()
		let newBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
		defer { newBuffer.deallocate() }

		var md5 = Insecure.MD5()
		check.open()
		while check.hasBytesAvailable {
			let inCount = check.read(newBuffer, maxLength: length)
			let raw = UnsafeRawPointer(newBuffer)
			let rawBuffer = UnsafeRawBufferPointer(start: raw, count: inCount)
			md5.update(bufferPointer: rawBuffer)
		}
		check.close()

		XCTAssertEqual("43412d135e6b57ed9f441a2f40169fce", md5.finalize().toHexString())
	}
}
#endif
