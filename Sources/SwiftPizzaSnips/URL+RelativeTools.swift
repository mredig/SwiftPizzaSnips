import Foundation
#if canImport(FoundationNetworking)
import LinuxSupport
#endif

public extension URL {
	/// provides the relative path needed to walk from `origin` to `destination` with individual directories
	/// listed in an array
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

	/// provides the relative path needed to walk from `origin` to `destination` with individual directories
	static func relativePath(from origin: URL, to destination: URL) throws -> String {
		try relativeComponents(from: origin, to: destination).joined(separator: "/")
	}

	/// provides the relative path needed to walk from `origin` to `destination` as a relative url.
	/// suitable for creating symlinks
	static func relativeFileURL(from origin: URL, to destination: URL) throws -> URL {
		guard
			[origin, destination].allSatisfy({ $0.isFileURL })
		else { throw RelativePathError.oneOrBothURLsNotFilepathURL }

		if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
			return URL(filePath: try relativePath(from: origin, to: destination), relativeTo: origin)
		} else {
			return URL(fileURLWithPath: try relativePath(from: origin, to: destination), relativeTo: origin)
		}
	}

	/// `pathA` and `pathB` must both be file scheme URLs and point to a directory
	/// (enforced via the soft heuristics `.hasDirectoryPath`). If it appears to point to a file, the last component will
	/// be removed.
	static func commonParentDirectoryURL(between pathA: URL, and pathB: URL) -> URL? {
		var pathA = pathA
		var pathB = pathB

		if pathA.hasDirectoryPath == false {
			pathA.deleteLastPathComponent()
		}
		if pathB.hasDirectoryPath == false {
			pathB.deleteLastPathComponent()
		}

		guard
			[pathA, pathB].allSatisfy({ $0.isFileURL && $0.hasDirectoryPath })
		else { return nil }
		guard pathA != pathB else { return pathA }

		let aComponents = pathA.absoluteURL.pathComponents
		let bComponents = pathB.absoluteURL.pathComponents

		var index = 0
		var pathAccumulator: [String] = []
		while
			let aComponent = aComponents[optional: index],
			let bComponent = bComponents[optional: index] {
			defer { index += 1 }

			guard aComponent == bComponent else { break }
			pathAccumulator.append(aComponent)
		}

		if pathAccumulator.first == "/" {
			pathAccumulator.popFirst()
		}

		let commonPath = "/" + pathAccumulator.joined(separator: "/")
		if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
			return URL(filePath: commonPath, directoryHint: .isDirectory)
		} else {
			return URL(fileURLWithPath: commonPath, isDirectory: true)
		}
	}

	static func commonParentDirectoryURL(from urls: [URL]) -> URL? {
		guard urls.count > 1 else { return urls.first }
		var urls = urls

		var common = urls.popLast()

		for url in urls {
			guard let previous = common else { return nil }
			common = commonParentDirectoryURL(between: previous, and: url)
		}
		return common
	}

	func isAParentOf(_ url: URL) -> Bool {
		var new = self
		if hasDirectoryPath == false {
			if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
				new = URL(filePath: path(percentEncoded: false), directoryHint: .isDirectory)
			} else {
				new = URL(fileURLWithPath: path, isDirectory: true)
			}
		}
		// TODO: bench a comparison between these methods sometime.
//		return URL.commonParentDirectoryURL(between: new, and: url) == new
		if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
			return url.path(percentEncoded: false).hasPrefix(new.path(percentEncoded: false))
		} else {
			return url.path.hasPrefix(new.path)
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
