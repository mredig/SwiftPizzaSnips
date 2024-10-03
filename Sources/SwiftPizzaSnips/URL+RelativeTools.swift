import Foundation
#if canImport(FoundationNetworking)
import SPSLinuxSupport
#endif

public extension URL {
	/// provides the relative path needed to walk from `origin` to `destination` with individual directories
	/// listed in an array
	@available(*, deprecated, renamed: "relativeURLComponents(from:to:)", message: "Use new version")
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
	@available(*, deprecated, renamed: "...", message: "Use new version")
	static func relativePath(from origin: URL, to destination: URL) throws -> String {
		try relativeComponents(from: origin, to: destination).joined(separator: "/")
	}

	/// provides the relative path needed to walk from `origin` to `destination` as a relative url.
	/// suitable for creating symlinks
	@available(*, deprecated, renamed: "...", message: "Use new version")
	static func relativeFileURL(from origin: URL, to destination: URL) throws -> URL {
		guard
			[origin, destination].allSatisfy({ $0.isFileURL })
		else { throw RelativePathError.oneOrBothURLsNotFilepathURL }

		if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *) {
			return URL(filePath: try relativePath(from: origin, to: destination), relativeTo: origin)
		} else {
			return URL(fileURLWithPath: try relativePath(from: origin, to: destination), relativeTo: origin)
		}
	}

	/// `pathA` and `pathB` must both be file scheme URLs and point to a directory
	/// (enforced via the soft heuristics `.hasDirectoryPath`). If it appears to point to a file, the last component will
	/// be removed.
	@available(*, deprecated, renamed: "deepestCommonDirectory", message: "Be careful - the behavior is SLIGHTLY changed to be more correct")
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
		if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *) {
			return URL(filePath: commonPath, directoryHint: .isDirectory)
		} else {
			return URL(fileURLWithPath: commonPath, isDirectory: true)
		}
	}

	@available(*, deprecated, renamed: "deepestCommonDirectory", message: "Be careful - the behavior is SLIGHTLY changed to be more correct")
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

	/// Finds the deepest directory path between two given URLs.
	///
	/// Heuristics are used to determine whether a given url is a file or directory url. No filesystem calls are made (at least not intentionally).
	/// However, if the two paths are identical apart from one being a directory and the other being a file (`/foo/bar` vs `/foo/bar/`)
	/// the last component being a directory will determine that that component *is* in fact a directory.
	///
	/// Throws `RelativePathError.mismatchedURLScheme` if the urls are of different schemes (You can't compare an `https`
	/// and `file` url against each other.
	///
	/// Currently requires that each path is a `file://` scheme url. This isn't an inherent requirement and could be resolved with a bit
	/// more effort, but this is the simplest path forward currently. As a result, `.oneOrBothURLsNotFilepathURL` is thrown if this occurs.
	static func deepestCommonDirectory(between pathA: URL, and pathB: URL) throws(RelativePathError) -> URL {
		guard pathA.scheme == pathB.scheme else { throw .mismatchedURLScheme }
		guard pathA.isFileURL else { throw .oneOrBothURLsNotFilepathURL }

		guard pathA.pathComponents != pathB.pathComponents else {
			return [pathA, pathA].first(where: { $0.hasDirectoryPath }) ?? pathA.deletingLastPathComponent()
		}

		let zipped = zip(pathA.pathComponents, pathB.pathComponents)

		var pathAccumulator: [String] = []
		for (a, b) in zipped {
			guard a == b else { break }
			pathAccumulator.append(a)
		}

		if pathAccumulator.first == "/" {
			pathAccumulator.popFirst()
		}

		let commonPath = "/" + pathAccumulator.joined(separator: "/")
		if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *) {
			return URL(filePath: commonPath, directoryHint: .isDirectory)
		} else {
			return URL(fileURLWithPath: commonPath, isDirectory: true)
		}
	}

	/// The same as `deepestCommonDirectory(between:and:)` except compares between an entire array of URLs.
	///
	/// In addition to any errors the other method can throw, this can additionally throw `.requiresANonEmptyArray` if the array is empty.
	///
	/// If you provide only a single url, the url will just evaluate (via `.hasDirectoryPath`) and return that url
	/// (deleting the last component if it's not a directory)
	static func deepestCommonDirectory(from urls: [URL]) throws(RelativePathError) -> URL {
		guard urls.isOccupied else { throw .requiresANonEmptyArray }
		guard urls.count > 1 else {
			let loneURL = urls[0]
			if loneURL.hasDirectoryPath {
				return loneURL
			} else {
				return loneURL.deletingLastPathComponent()
			}
		}
		var urls = urls

		guard
			var common = urls.popLast()
		else { throw .requiresANonEmptyArray }

		for url in urls {
			let previous = common
			common = try deepestCommonDirectory(between: previous, and: url)
		}
		return common
	}

	func isAParentOf(_ url: URL) -> Bool {
		var new = self
		if hasDirectoryPath == false {
			if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *) {
				new = URL(filePath: path(percentEncoded: false), directoryHint: .isDirectory)
			} else {
				new = URL(fileURLWithPath: path, isDirectory: true)
			}
		}
		// TODO: bench a comparison between these methods sometime.
//		return URL.commonParentDirectoryURL(between: new, and: url) == new
		if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9, *) {
			return url.path(percentEncoded: false).hasPrefix(new.path(percentEncoded: false))
		} else {
			return url.path.hasPrefix(new.path)
		}
	}

	// sourcery:localizedError
	enum RelativePathError: Error {
		case mismatchedURLScheme
		case oneOrBothURLsNotFilepathURL
		case requiresANonEmptyArray
	}
}

extension URL.RelativePathError: CustomDebugStringConvertible, LocalizedError {
	public var debugDescription: String {
		switch self {
		case .mismatchedURLScheme: "URL.RelativePathError.mismatchedURLScheme"
		case .oneOrBothURLsNotFilepathURL: "URL.RelativePathError.oneOrBothURLsNotFilepathURL"
		case .requiresANonEmptyArray: "URL.RelativePathError.requiresANonEmptyArray"
		}
	}

	public var errorDescription: String? { debugDescription }

	public var failureReason: String? { debugDescription }

	public var helpAnchor: String? { debugDescription }

	public var recoverySuggestion: String? { debugDescription }
}
