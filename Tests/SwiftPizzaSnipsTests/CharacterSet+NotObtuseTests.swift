import XCTest
import SwiftPizzaSnips

final class CharacterSetNotObtuseTests: XCTestCase {
	func testContainsCharacter() {
		let hasAlphanumeric = "aabc123"
		let hasAlpha = "aslkdfj"
		let hasNumeric = "13245"
		let hasSpecialCharacter = "123alksdjf%#*"
		let specialCharacters = CharacterSet.punctuationCharacters.union(.symbols)

		XCTAssertTrue(hasAlphanumeric.containsCharacter(from: .alphanumerics))
		XCTAssertTrue(hasAlphanumeric.containsCharacter(from: .lowercaseLetters))
		XCTAssertTrue(hasAlphanumeric.containsCharacter(from: .decimalDigits))
		XCTAssertFalse(hasAlphanumeric.containsCharacter(from: specialCharacters))

		XCTAssertTrue(hasAlpha.containsCharacter(from: .alphanumerics))
		XCTAssertTrue(hasAlpha.containsCharacter(from: .lowercaseLetters))
		XCTAssertFalse(hasAlpha.containsCharacter(from: .decimalDigits))
		XCTAssertFalse(hasAlpha.containsCharacter(from: specialCharacters))

		XCTAssertTrue(hasNumeric.containsCharacter(from: .alphanumerics))
		XCTAssertFalse(hasNumeric.containsCharacter(from: .lowercaseLetters))
		XCTAssertTrue(hasNumeric.containsCharacter(from: .decimalDigits))
		XCTAssertFalse(hasNumeric.containsCharacter(from: specialCharacters))

		XCTAssertTrue(hasSpecialCharacter.containsCharacter(from: .alphanumerics))
		XCTAssertTrue(hasSpecialCharacter.containsCharacter(from: .lowercaseLetters))
		XCTAssertTrue(hasSpecialCharacter.containsCharacter(from: .decimalDigits))
		XCTAssertTrue(hasSpecialCharacter.containsCharacter(from: specialCharacters))
	}
}
