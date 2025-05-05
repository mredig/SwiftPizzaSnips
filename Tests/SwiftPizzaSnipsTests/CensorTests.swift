import Testing
import SwiftPizzaSnips

struct CensorTests {
	let longString = "BB75836B-8C5F-429B-97B3-DF830457CAD8"
	let longStringCensored = "************************************"

	let shortString = "abcd"
	let	shortStringCensored = "****"

	@Test func censorLongStringComplete() async throws {
		let censored = Censor(rawValue: longString, level: .complete)

		let expectation = "***"
		#expect(censored.description == expectation)
		#expect(censored.debugDescription == "Censor: \(expectation)")
	}

	@Test func censorLongStringAllowCount() async throws {
		let censored = Censor(rawValue: longString, level: .allowCharCount)

		let expectation = longStringCensored
		#expect(censored.description == expectation)
		#expect(censored.debugDescription == "Censor: \(expectation)")
	}

	@Test func censorLongStringAllowCountAndFirstLast() async throws {
		let censored = Censor(rawValue: longString, level: .firstAndLastRevealedAndCharCount)

		let expectation = "B\(longStringCensored.dropLast(2))8"
		#expect(censored.description == expectation)
		#expect(censored.debugDescription == "Censor: \(expectation)")
	}

	@Test func censorLongStringNoCountAndFirstLast() async throws {
		let censored = Censor(rawValue: longString, level: .firstAndLastRevealedNoCharCount)

		let expectation = "B***8"
		#expect(censored.description == expectation)
		#expect(censored.debugDescription == "Censor: \(expectation)")
	}

	@Test func censorShortStringComplete() async throws {
		let censored = Censor(rawValue: shortString, level: .complete)

		let expectation = "***"
		#expect(censored.description == expectation)
		#expect(censored.debugDescription == "Censor: \(expectation)")
	}

	@Test func censorShortStringAllowCount() async throws {
		let censored = Censor(rawValue: shortString, level: .allowCharCount)

		let expectation = shortStringCensored
		#expect(censored.description == expectation)
		#expect(censored.debugDescription == "Censor: \(expectation)")
	}

	@Test func censorShortStringAllowCountAndFirstLast() async throws {
		let censored = Censor(rawValue: shortString, level: .firstAndLastRevealedAndCharCount)

		let expectation = "***"
		#expect(censored.description == expectation)
		#expect(censored.debugDescription == "Censor: \(expectation)")
	}

	@Test func censorShortStringNoCountAndFirstLast() async throws {
		let censored = Censor(rawValue: shortString, level: .firstAndLastRevealedNoCharCount)

		let expectation = "***"
		#expect(censored.description == expectation)
		#expect(censored.debugDescription == "Censor: \(expectation)")
	}
}
