import Foundation

public extension URL {
	static func relativeComponents(from origin: URL, to destination: URL) throws -> [String] {
		guard
			origin.scheme == destination.scheme
		else { throw RelativePathError.mismatchedURLScheme }

		let thisPathComponents: [String]
		if origin.hasDirectoryPath {
			thisPathComponents = origin.pathComponents
		} else {
			thisPathComponents = origin.deletingLastPathComponent().pathComponents
		}
		let destPathComponents = destination.pathComponents

		var divergeIndex = 0
		for (index, component) in thisPathComponents.enumerated() {
			divergeIndex = index
			guard
				index < destPathComponents.count
			else { break }
			let destComponent = destPathComponents[index]

			guard destComponent == component else { break }
		}

		let upDir = ".."

		let sourcePath = thisPathComponents[divergeIndex...]
		let destPath = destPathComponents[divergeIndex...]

		var outPath = Array(repeating: upDir, count: sourcePath.count)
		outPath.append(contentsOf: destPath)

		return outPath
	}

	static func relativePath(from origin: URL, to destination: URL) throws -> String {
		try relativeComponents(from: origin, to: destination).joined(separator: "/")
	}

	static func relativeFileURL(from origin: URL, to destination: URL) throws -> URL {
		guard
			[origin, destination].allSatisfy({ $0.scheme == "file" })
		else { throw RelativePathError.oneOrBothURLsNotFilepathURL }

		if #available(macOS 13.0, *) {
			return URL(filePath: try relativePath(from: origin, to: destination), relativeTo: origin)
		} else {
			return URL(fileURLWithPath: try relativePath(from: origin, to: destination), relativeTo: origin)
		}
	}

	// sourcery:localizedError
	enum RelativePathError: Error {
		case mismatchedURLScheme
		case oneOrBothURLsNotFilepathURL
	}
}

extension URL.RelativePathError: CustomDebugStringConvertible, LocalizedError {
	public var debugDescription: String {
		switch self {
		case .mismatchedURLScheme: "URL.RelativePathError.mismatchedURLScheme"
		case .oneOrBothURLsNotFilepathURL: "URL.RelativePathError.oneOrBothURLsNotFilepathURL"
		}
	}

	public var errorDescription: String? { debugDescription }

	public var failureReason: String? { debugDescription }

	public var helpAnchor: String? { debugDescription }

	public var recoverySuggestion: String? { debugDescription }
}
