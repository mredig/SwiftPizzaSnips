#if os(macOS)
import Foundation
import AppKit

public enum ComparingForTests {
	public enum Resource {
		case data(Data, fileExtension: String)
		case url(URL)

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
		before: Resource,
		andAfter after: Resource,
		inTempDirectory: URL? = nil,
		contextualInfo: String? = nil,
		openInFinder: Bool = true
	) throws {
		let outDir = inTempDirectory ?? FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

		let beforeURL = outDir.appendingPathComponent("before").appendingPathExtension(before.fileExtension)
		try before.copy(to: beforeURL)
		let afterURL = outDir.appendingPathComponent("after").appendingPathExtension(after.fileExtension)
		try after.copy(to: afterURL)

		if let contextualInfo {
			let contextURL = outDir.appendingPathComponent("context").appendingPathExtension("txt")
			try Data(contextualInfo.utf8).write(to: contextURL)
		}

		print("Comparing files in \(outDir)")
		guard openInFinder else { return }
		NSWorkspace.shared.activateFileViewerSelecting([beforeURL, afterURL])
	}
}
#endif
