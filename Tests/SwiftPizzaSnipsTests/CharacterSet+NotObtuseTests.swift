import Foundation
import SwiftPizzaSnips
import Testing

struct CharacterSetNotObtuseTests {
	@Test
	func containsCharacter() {
		let hasAlphanumeric = "aabc123"
		let hasAlpha = "aslkdfj"
		let hasNumeric = "13245"
		let hasSpecialCharacter = "123alksdjf%#*"
		let specialCharacters = CharacterSet.punctuationCharacters.union(.symbols)

		#expect(hasAlphanumeric.containsCharacter(from: .alphanumerics))
		#expect(hasAlphanumeric.containsCharacter(from: .lowercaseLetters))
		#expect(hasAlphanumeric.containsCharacter(from: .decimalDigits))
		#expect(hasAlphanumeric.containsCharacter(from: specialCharacters) == false)

		#expect(hasAlpha.containsCharacter(from: .alphanumerics))
		#expect(hasAlpha.containsCharacter(from: .lowercaseLetters))
		#expect(hasAlpha.containsCharacter(from: .decimalDigits) == false)
		#expect(hasAlpha.containsCharacter(from: specialCharacters) == false)

		#expect(hasNumeric.containsCharacter(from: .alphanumerics))
		#expect(hasNumeric.containsCharacter(from: .lowercaseLetters) == false)
		#expect(hasNumeric.containsCharacter(from: .decimalDigits))
		#expect(hasNumeric.containsCharacter(from: specialCharacters) == false)

		#expect(hasSpecialCharacter.containsCharacter(from: .alphanumerics))
		#expect(hasSpecialCharacter.containsCharacter(from: .lowercaseLetters))
		#expect(hasSpecialCharacter.containsCharacter(from: .decimalDigits))
		#expect(hasSpecialCharacter.containsCharacter(from: specialCharacters))
	}
}
