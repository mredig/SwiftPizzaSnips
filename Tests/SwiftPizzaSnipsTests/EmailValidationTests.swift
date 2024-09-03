import XCTest
import SwiftPizzaSnips

final class EmailValidationTests: XCTestCase {
	@available(macOS 13, iOS 16, tvOS 16, watchOS 10, *)
	func testEmailValidationOnPreviousValues() throws {
		var emailResult = wrap { try EmailAddress(withValidation: "test@gmail.com") }
		XCTAssertEqual(try emailResult.get().supportLevel, .widelySupported)

		emailResult = wrap { try EmailAddress(withValidation: "test") }
		XCTAssertThrowsError(try emailResult.get())

		emailResult = wrap { try EmailAddress(withValidation: "test@gmail") }
		XCTAssertThrowsError(try emailResult.get())

		emailResult = wrap { try EmailAddress(withValidation: "test@gmail", requireTLD: false) }
		XCTAssertEqual(try emailResult.get().supportLevel, .technicallySupported)

		emailResult = wrap { try EmailAddress(withValidation: "test@.com") }
		XCTAssertThrowsError(try emailResult.get())

		emailResult = wrap { try EmailAddress(withValidation: "testing+gmailsorting@gmail.com") }
		XCTAssertEqual(try emailResult.get().supportLevel, .mostlySupported)
	}

	@available(macOS 13, iOS 16, tvOS 16, watchOS 10, *)
	func testEmailValidationOnValidEmails() throws {
		// test cases sourced from https://www.linuxjournal.com/article/9585,
		// but validation corrected against https://www.dominicsayers.com/isemail/
		var emailResult = wrap { try EmailAddress(withValidation: ##"dclo@us.ibm.com"##) }
		XCTAssertEqual(try emailResult.get().supportLevel, .widelySupported)

		emailResult = wrap { try EmailAddress(withValidation: ##""Abc@def"@example.com"##) }
		XCTAssertEqual(try emailResult.get().supportLevel, .technicallySupported)

		emailResult = wrap { try EmailAddress(withValidation: ##""Fred Bloggs"@example.com"##) }
		XCTAssertEqual(try emailResult.get().supportLevel, .technicallySupported)

		emailResult = wrap { try EmailAddress(withValidation: ##"customer/department=shipping@example.com"##) }
		XCTAssertEqual(try emailResult.get().supportLevel, .technicallySupported)

		emailResult = wrap { try EmailAddress(withValidation: ##"$A12345@example.com"##) }
		XCTAssertEqual(try emailResult.get().supportLevel, .technicallySupported)

		emailResult = wrap { try EmailAddress(withValidation: ##"!def!xyz%abc@example.com"##) }
		XCTAssertEqual(try emailResult.get().supportLevel, .technicallySupported)

		emailResult = wrap { try EmailAddress(withValidation: ##"_somename@example.com"##) }
		XCTAssertEqual(try emailResult.get().supportLevel, .widelySupported)

		emailResult = wrap { try EmailAddress(withValidation: ##"user+mailbox@example.com"##) }
		XCTAssertEqual(try emailResult.get().supportLevel, .mostlySupported)

		emailResult = wrap { try EmailAddress(withValidation: ##"peter.piper@example.com"##) }
		XCTAssertEqual(try emailResult.get().supportLevel, .widelySupported)

		emailResult = wrap { try EmailAddress(withValidation: ##""Doug \"Ace\" L."@example.com"##) }
		XCTAssertEqual(try emailResult.get().supportLevel, .technicallySupported)
	}

	@available(macOS 13, iOS 16, tvOS 16, watchOS 10, *)
	func testEmailValidationOnInvalidEmails() throws {
		var emailResult = wrap { try EmailAddress(withValidation: ##"abc\\@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"Fred\ Bloggs@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"Joe.\\Blow@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"abc\@def@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"abc@def@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"abc\\@def@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"abc\@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"doug@"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##""qu@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"ote"@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##".dot@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"dot.@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"two..dot@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##""Doug "Ace" L."@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"Doug\ \"Ace\"\ L\.@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"Doug\ \"Ace\"\ Lovell@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"hello world@example.com"##) }
		XCTAssertThrowsError(try emailResult.get())
		emailResult = wrap { try EmailAddress(withValidation: ##"gatsby@f.sc.ot.t.f.i.tzg.era.l.d."##) }
		XCTAssertThrowsError(try emailResult.get())
	}

	@available(macOS 13, iOS 16, tvOS 16, watchOS 10, *)
	func testCodingEmail() throws {
		let encoder = JSONEncoder()
		let decoder = JSONDecoder()

		let widely = try EmailAddress(withValidation: ##"dclo@us.ibm.com"##)
		let widelyData = try encoder.encode(widely)
		let widelyDecoded = try decoder.decode(EmailAddress.self, from: widelyData)
		XCTAssertEqual(widelyDecoded.supportLevel, .widelySupported)
		XCTAssertEqual(widelyDecoded, widely)

		let mostly = try EmailAddress(withValidation: ##"user+mailbox@example.com"##)
		let mostlyData = try encoder.encode(mostly)
		let mostlyDecoded = try decoder.decode(EmailAddress.self, from: mostlyData)
		XCTAssertEqual(mostlyDecoded.supportLevel, .mostlySupported)
		XCTAssertEqual(mostlyDecoded, mostly)

		let technically = try EmailAddress(withValidation: ##""Abc@def"@example.com"##)
		let technicallyData = try encoder.encode(technically)
		let technicallyDecoded = try decoder.decode(EmailAddress.self, from: technicallyData)
		XCTAssertEqual(technicallyDecoded.supportLevel, .technicallySupported)
		XCTAssertEqual(technicallyDecoded, technically)

		let noTLD = try EmailAddress(withValidation: "test@gmail", requireTLD: false)
		let noTLDData = try encoder.encode(noTLD)
		let noTLDDecoded = try decoder.decode(EmailAddress.self, from: noTLDData)
		XCTAssertEqual(noTLDDecoded.supportLevel, .technicallySupported)
		XCTAssertEqual(noTLDDecoded, noTLD)
	}
}
