import Foundation

package extension URL {
	typealias DirectoryHint = Hint
	init(filePath path: String, directoryHint: Hint = .inferFromPath, relativeTo base: URL? = nil) {
		let isDirectory: Bool
		switch directoryHint {
		case .checkFileSystem:
			let fm = FileManager.default
			var isDir: ObjCBool = false
			let temp = URL(fileURLWithPath: path, relativeTo: base)
			let exists = fm.fileExists(atPath: temp.path, isDirectory: &isDir)
			guard exists else { fallthrough }
			isDirectory = isDir.boolValue
		case .inferFromPath:
			isDirectory = path.last == "/"
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
}
