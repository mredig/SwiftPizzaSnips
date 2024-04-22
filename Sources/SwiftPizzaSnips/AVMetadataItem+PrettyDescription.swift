import AVFoundation

@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
extension AVMetadataItem: @unchecked Sendable {
	public var loadDescription: String {
		get async {
			let firstLine = "AVMetadataItem:"
			var content: [String] = []
			if let identifier {
				content.append("identifier: \(identifier.rawValue)")
			}
			if let dataType {
				content.append("dataType: \(dataType)")
			}
			if let key {
				content.append("key: \(key)")
			}
			if let commonKey {
				content.append("commonKey: \(commonKey.rawValue)")
			}
			if let keySpace {
				content.append("keySpace: \(keySpace.rawValue)")
			}
			if time.isValid {
				content.append("time: \(time)")
			}
			if duration.isValid {
				content.append("duration: \(duration)")
			}
			if let startDate {
				content.append("startDate: \(startDate)")
			}

			async let (value, stringValue, numberValue, dateValue, dataValue, extraAttributes) =
				load(.value, .stringValue, .numberValue, .dateValue, .dataValue, .extraAttributes)
			do {
				if let value = try await value {
					content.append("value: \(value as Any)")
				}
			} catch {
				content.append("Unable to load value information.")
			}
			do {
				if let stringValue = try await stringValue {
					content.append("stringValue: \(stringValue)")
				}
			} catch {
				content.append("Unable to load stringValue information.")
			}
			do {
				if let numberValue = try await numberValue {
					content.append("numberValue: \(numberValue)")
				}
			} catch {
				content.append("Unable to load numberValue information.")
			}
			do {
				if let dateValue = try await dateValue {
					content.append("dateValue: \(dateValue)")
				}
			} catch {
				content.append("Unable to load dateValue information.")
			}
			do {
				if let dataValue = try await dataValue {
					content.append("dataValue: \(dataValue)")
				}
			} catch {
				content.append("Unable to load dataValue information.")
			}
			do {
				if let extraAttributes = try await extraAttributes {
					content.append("extraAttributes: \(extraAttributes)")
				}
			} catch {
				content.append("Unable to load extraAttributes information.")
			}

			content = content.map { "\t\($0)" }
			content = [firstLine] + content
			return content.joined(separator: "\n")
		}
	}
}
