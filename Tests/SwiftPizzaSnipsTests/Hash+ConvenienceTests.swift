import XCTest
import SwiftPizzaSnips

#if canImport(CryptoKit)
import CryptoKit

@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
final class HashConvenienceTests: XCTestCase {
	func testHashingFile() throws {
		let file = try Bundle.module.url(forResource: "sample", withExtension: "bin").unwrap()

		let hash = try Insecure.MD5.hash(fileStream: file, bufferSizeBytes: 3)

		XCTAssertEqual("d642008723a327aa8a3a5eb8cd1aa27a", hash.toHexString())
	}
}
#endif
