import Foundation

public extension StringProtocol {
	func containsCharacter(from characterSet: CharacterSet) -> Bool {
		rangeOfCharacter(from: characterSet) != nil
	}
}
