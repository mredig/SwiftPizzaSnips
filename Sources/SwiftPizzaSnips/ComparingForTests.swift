#if os(macOS)
import Foundation
import AppKit

public enum ComparingForTests {
	public enum Resource {
		case data(Data, fileExtension: String)
		case url(URL)
		public static func codable<E: Encodable>(_ inData: E, encodedBy encoder: JSONEncoder? = nil) throws -> Resource {
			let encoder = encoder ?? JSONEncoder().with {
				$0.outputFormatting = [.prettyPrinted, .sortedKeys]
			}
			let data = try encoder.encode(inData)
			return .data(data, fileExtension: "json")
		}
		public static func string(_ value: String) -> Resource {
			return .data(Data(value.utf8), fileExtension: "txt")
		}
		@available(macOS 10.15, *)
		public static func stringified(_ value: Any) -> Resource {
			let stringifiedValue = "\(value)"
			let scanner = Scanner(string: stringifiedValue)

			var out = ""
			while scanner.isAtEnd == false {
				guard let chunk = scanner.scanUpToString(", ") else { continue }
				out.append(chunk)
				out.append(",\n")
				_ = scanner.scanString(", ")
			}

			return .string(out)
		}

		func copy(to destURL: URL) throws {
			switch self {
			case .data(let data, _):
				try data.write(to: destURL)
			case .url(let url):
				try FileManager.default.copyItem(at: url, to: destURL)
			}
		}

		var fileExtension: String {
			switch self {
			case .data(_, let fileExtension):
				fileExtension
			case .url(let url):
				url.pathExtension
			}
		}
	}

	public static func compareFilesInFinder(
		withExpectation expectation: Resource,
		andActualResult result: Resource,
		inTempDirectory: URL? = nil,
		contextualInfo: String? = nil,
		openInFinder: Bool = true
	) throws {
		let outDir = inTempDirectory ?? FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

		let expectationURL = outDir.appendingPathComponent("expectation").appendingPathExtension(expectation.fileExtension)
		try expectation.copy(to: expectationURL)
		let resultURL = outDir.appendingPathComponent("result").appendingPathExtension(result.fileExtension)
		try result.copy(to: resultURL)

		if let contextualInfo {
			let contextURL = outDir.appendingPathComponent("context").appendingPathExtension("txt")
			try Data(contextualInfo.utf8).write(to: contextURL)
		}

		print("Comparing files in \(outDir)")
		guard openInFinder else { return }
		NSWorkspace.shared.activateFileViewerSelecting([expectationURL, resultURL])
	}
}
#endif
