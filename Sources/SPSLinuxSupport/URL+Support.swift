import Foundation

/// Apple's Foundation has a bunch of modern features on URL that weren't ported out to Swift's open source URL. This
/// might not perfectly replicate, but should generally have the same interface.
public extension URL {
	private static func checkFileSystemForDirectory(from path: String) -> Bool {
		let fm = FileManager.default
		var isDir: ObjCBool = false
		let exists = fm.fileExists(atPath: path, isDirectory: &isDir)
		guard exists else { return inferFromPathForDirectory(from: path) }
		return isDir.boolValue
	}

	private static func inferFromPathForDirectory(from path: String) -> Bool {
		path.hasSuffix("/")
	}

	typealias DirectoryHint = Hint
	init(filePath path: String, directoryHint: Hint = .inferFromPath, relativeTo base: URL? = nil) {

		let isDirectory: Bool
		switch directoryHint {
		case .checkFileSystem:
			isDirectory = Self.checkFileSystemForDirectory(from: path)
		case .inferFromPath:
			isDirectory = Self.inferFromPathForDirectory(from: path)
		case .isDirectory:
			isDirectory = true
		case .notDirectory:
			isDirectory = false
		}

		self.init(fileURLWithPath: path, isDirectory: isDirectory, relativeTo: base)
	}

	enum Hint {
		case checkFileSystem
		case inferFromPath
		case isDirectory
		case notDirectory
	}

	func path(percentEncoded: Bool = true) -> String {
		let strPath: String = path
		var outPath = percentEncoded ?
			strPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? strPath :
			strPath
		if hasDirectoryPath && outPath.last != "/" {
			outPath.append("/")
		}
		return outPath
	}

	mutating func append(component: String, directoryHint: Hint = .inferFromPath) {
		append(components: component, directoryHint: directoryHint)
	}

	func appending(component: String, directoryHint: Hint = .inferFromPath) -> URL {
		appending(components: component, directoryHint: directoryHint)
	}

	func appending<S: StringProtocol>(components: S..., directoryHint: Hint = .inferFromPath) -> URL {
		_appending(components: components, directoryHint: directoryHint)
	}

	private func _appending<S: StringProtocol>(components: [S], directoryHint: Hint) -> URL {
		var hint = directoryHint
		if hint == .checkFileSystem, isFileURL == false {
			hint = .inferFromPath
		}
		
		var temp = self
		var last = ""
		for component in components {
			temp.appendPathComponent(String(component))
			last = String(component)
		}

		let isDir: Bool
		switch hint {
		case .checkFileSystem:
			isDir = Self.checkFileSystemForDirectory(from: temp.path())
		case .inferFromPath:
			isDir = last.hasSuffix("/")
		case .isDirectory:
			isDir = true
		case .notDirectory:
			isDir = false
		}

		if isDir {
			temp.deleteLastPathComponent()
			temp.appendPathComponent(last, isDirectory: true)
		}
		return temp
	}

	mutating func append<S: StringProtocol>(components: S..., directoryHint: Hint = .inferFromPath) {
		self = self._appending(components: components, directoryHint: directoryHint)
	}

	func appending<S: StringProtocol>(path: S, directoryHint: Hint = .inferFromPath) -> URL {
		let pathComponents = path.split(separator: "/")
		if path.hasSuffix("/"), path.isEmpty == false {
			var strPath = pathComponents
				.map { String($0) }
			strPath[strPath.endIndex - 1].append("/")
			return _appending(components: strPath, directoryHint: directoryHint)
		} else {
			return _appending(components: pathComponents, directoryHint: directoryHint)
		}
	}

	mutating func append<S: StringProtocol>(path: S, directoryHint: Hint = .inferFromPath) {
		self = self.appending(path: path, directoryHint: directoryHint)
	}

	func appending(queryItems: [URLQueryItem]) -> URL {
		guard
			var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
		else {
			fatalError("ERROR:!! URLComponents could not init with url \(self)")
		}

		if components.queryItems == nil {
			components.queryItems = []
		}
		components.queryItems?.append(contentsOf: queryItems)

		guard
			let outURL = components.url
		else {
			fatalError("ERROR:!! URLComponents could not append URL with query items: \(self) - query items: \(queryItems)")
		}

		return outURL
	}

	mutating func append(queryItems: [URLQueryItem]) {
		self = self.appending(queryItems: queryItems)
	}
}
