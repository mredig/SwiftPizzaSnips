import Foundation

fileprivate let encoder = PropertyListEncoder()
fileprivate let decoder = PropertyListDecoder()

class CodableTransformer<CodableType: Codable>: ValueTransformer {
	override func transformedValue(_ value: Any?) -> Any? {
		guard let original = value as? CodableType else { return nil }

		do {
			return try encoder.encode(original)
		} catch {
			print("Error transforming data: \(error)")
			return nil
		}
	}

	override func reverseTransformedValue(_ value: Any?) -> Any? {
		guard let data = value as? Data else { return nil }

		do {
			return try decoder.decode(CodableType.self, from: data)
		} catch {
			print("Error transforming data: \(error)")
			return nil
		}
	}
}
