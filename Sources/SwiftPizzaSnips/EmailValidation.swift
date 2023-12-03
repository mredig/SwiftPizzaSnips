import Foundation

@available(macOS 13, iOS 16, tvOS 16, watchOS 10, *)
public struct EmailAddress: RawRepresentable {
	public let rawValue: String

	public let supportLevel: SupportLevel

	public init?(rawValue: String) {
		try? self.init(withValidation: rawValue)
	}

	public init(withValidation rawValue: String, requireTLD: Bool = true) throws {
		self.supportLevel = try Self.validateEmailAddress(rawValue, requireTLD: requireTLD)
		self.rawValue = rawValue
	}

	/// These values are given in soft language intentionally because email validation is highly varied and many
	/// places are too strict. The support level is based on authors anecdotal experiences.
	public enum SupportLevel: Int, Equatable, Comparable {
		case widelySupported
		case mostlySupported
		case technicallySupported

		public static func < (lhs: SupportLevel, rhs: SupportLevel) -> Bool {
			lhs.rawValue < rhs.rawValue
		}
	}

	/// By RFC 5322, should be MOSTLY correct and cover the most common use cases. It turns out email validation
	/// is *very* complicated. The more esoteric valid emails might/will not be validated as correct. Aka, some false
	/// negatives are expected, but false positives should not happen.
	///
	/// Note: ios, tvos, and watch os availability is a guess as I don't have those sdks installed to confirm.
	@discardableResult // swiftlint:disable:next function_body_length
	public static func validateEmailAddress(_ address: String, requireTLD: Bool = true) throws -> SupportLevel {
		guard 3...255 ~= address.count else { throw EmailError.invalidLength }

		// swiftlint:disable:next cyclomatic_complexity function_body_length large_tuple
		func parseEmailSections() throws -> (local: String, domain: String, supportLevel: SupportLevel) {
			var local = ""
			var domain = ""
			var supportLevel = SupportLevel.widelySupported

			let escapeAndAt = CharacterSet("\\@".unicodeScalars)
			let quotes = CharacterSet("\"".unicodeScalars)
			let space = CharacterSet(" ".unicodeScalars)
			let nothing = CharacterSet()
			let localStoppers = escapeAndAt.union(quotes).union(space)

			var inQuotes = false
			var finishedLocal = false
			let scanner = Scanner(string: address)
			scanner.charactersToBeSkipped = nil
			while scanner.isAtEnd == false {
				if finishedLocal {
					guard
						let partial = scanner.scanUpToCharacters(from: nothing)
					else { throw EmailError.invalidFormat }
					domain = partial
				} else {
					var partial = ""
					if let scanned = scanner.scanUpToCharacters(from: localStoppers) {
						partial = scanned
					}

					defer { local.append(partial) }

					guard
						let character = scanner.scanCharacter()
					else { throw EmailError.invalidFormat }

					switch character {
					case "\\":
						guard inQuotes == true else { throw EmailError.escapesAndSpacesOnlyAllowedWithinQuotes }
						guard
							let next = scanner.scanCharacter()
						else { throw EmailError.escapedSequenceUnfinished }
						partial.append(character)
						partial.append(next)
						supportLevel = max(supportLevel, .technicallySupported)
					case "@":
						guard inQuotes == false else { continue }
						finishedLocal = true
					case "\"":
						partial.append(character)
						if inQuotes == false {
							inQuotes = true
						} else {
							inQuotes = false
							guard
								scanner.scanString("@") != nil
							else { throw EmailError.quotesMustCoverEntireLocalSection }
							// back up one character since @ check was successful
							scanner.currentIndex = address.index(before: scanner.currentIndex)
						}
						supportLevel = max(supportLevel, .technicallySupported)
					case " ":
						guard inQuotes == true else { throw EmailError.escapesAndSpacesOnlyAllowedWithinQuotes }
						supportLevel = max(supportLevel, .technicallySupported)
					default:
						throw EmailError.scannerError
					}
				}
			}
			return (local, domain, supportLevel)
		}

		let info = try parseEmailSections()
		let local = info.local
		let domain = info.domain
		var supportLevel = info.supportLevel

		guard 1...64 ~= local.count else { throw EmailError.localSectionInvalidLength }

		guard local.first != "." && local.last != "." else { throw EmailError.localSectionStartsOrEndsWithDot }

		guard local.contains("..") == false else { throw EmailError.localSectionHasConsecutiveDots }

		try validateEmailDomain(domain, requireTLD: requireTLD)

		if local.contains(/\+/) {
			supportLevel = max(supportLevel, .mostlySupported)
		}

		if local.contains(/[\/\=\!\%\$]/) {
			supportLevel = max(supportLevel, .technicallySupported)
		}

		if requireTLD == false && domain.contains(".") == false {
			supportLevel = max(supportLevel, .technicallySupported)
		}

		return supportLevel
	}

	public enum EmailError: String, Error, CustomStringConvertible {
		case quotesMustCoverEntireLocalSection
		case escapesAndSpacesOnlyAllowedWithinQuotes
		case invalidFormat
		case escapedSequenceUnfinished
		case scannerError
		case noAtSign
		case invalidLength
		case localSectionInvalidLength
		case localSectionStartsOrEndsWithDot
		case localSectionHasConsecutiveDots

		public var description: String {
			"\(EmailError.self).\(rawValue)"
		}
	}

	@available(macOS 13, iOS 16, tvOS 16, watchOS 10, *)
	public static func validateEmailDomain(_ domain: String, requireTLD: Bool = true) throws {
		guard 1...253 ~= domain.count else { throw DomainError.invalidLength }
		guard domain.contains("..") == false else { throw DomainError.hasConsecutiveDots }

		if requireTLD {
			guard domain.contains(".") else { throw DomainError.hasNoTLD }
		}

		if domain.hasPrefix(".") || domain.hasSuffix(".") {
			throw DomainError.startsOrEndsWithDot
		}

		if domain.hasPrefix("-") || domain.hasSuffix("-") {
			throw DomainError.startsOrEndsWithHyphen
		}

		let illegalSubdomains = domain.split(separator: ".")
			.filter { $0.count > 63 }

		guard illegalSubdomains.isEmpty else { throw DomainError.hasSectionWithInvalidCharacterCount }

		let domainRegex = /^[A-Za-z0-9\-\.]+$/
		guard domain.wholeMatch(of: domainRegex) != nil else {
			throw DomainError.hasInvalidCharacters
		}
	}

	public enum DomainError: String, Error, CustomStringConvertible {
		case invalidLength
		case hasConsecutiveDots
		case hasNoTLD
		case hasInvalidCharacters
		case startsOrEndsWithDot
		case startsOrEndsWithHyphen
		case hasSectionWithInvalidCharacterCount

		public var description: String {
			"\(DomainError.self).\(rawValue)"
		}
	}
}
