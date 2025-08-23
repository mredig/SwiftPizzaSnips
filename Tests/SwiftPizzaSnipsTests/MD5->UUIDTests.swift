import Testing
import SwiftPizzaSnips
import Foundation
#if canImport(CryptoKit)
import CryptoKit
#elseif canImport(Crypto)
import Crypto
#endif

#if canImport(CryptoKit) || canImport(Crypto)
struct MD5ToUUIDTests {
	@available(macOS 13.0, iOS 13.2, tvOS 13.2, watchOS 9, *)
	@Test(arguments: [
		("asdf", UUID(uuidString: "912EC803-B2CE-49E4-A541-068D495AB570")),
		("1", UUID(uuidString: "C4CA4238-A0B9-2382-0DCC-509A6F75849B")),
		("Never once touched my per diem. I'd go to Craft Service, get some raw veggies, bacon, Cup-A-Soup…baby, I got a stew goin'.", UUID(uuidString: "C1BCE429-C226-F123-C2C3-C5516C50DA39")),
	])
	func simple(inputValue: String, expectedHashedID: UUID?) async throws {
		var hasher = Insecure.MD5()
		hasher.update(string: inputValue)

		let hash = hasher.finalize()
		let newID = UUID(md5Hash: hash)
		#expect(newID == expectedHashedID)
	}

	@available(macOS 13.0, iOS 13.2, tvOS 13.2, watchOS 9, *)
	@Test(arguments: [
		"asdf",
		"1",
		"Never once touched my per diem. I'd go to Craft Service, get some raw veggies, bacon, Cup-A-Soup…baby, I got a stew goin'.",
	])
	func simple2(inputValue: String) async throws {
		var hasher = Insecure.MD5()
		hasher.update(string: inputValue)

		let hash = hasher.finalize()
		let newID = UUID(md5Hash: hash)
		let backConvertedDigest = Insecure.MD5Digest(uuid: newID)
		#expect(hash == backConvertedDigest)
	}
}
#endif
