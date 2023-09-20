import Foundation

extension FileManager {
	func applicationSupportDirectory(
		forBundleIdentifier bundleID: String = Bundle.main.bundleIdentifier!,
		prettyName: String = ProcessInfo.processInfo.processName) throws -> URL {

			let folderName = bundleID
			let appSupportDir = try url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
				.appendingPathComponent(folderName)
				.appendingPathExtension("localized")
			try createDirectory(at: appSupportDir, withIntermediateDirectories: true)

			let localizedDir = appSupportDir.appendingPathComponent(".localized")
			if (try? localizedDir.checkResourceIsReachable()) != true {
				try createDirectory(at: localizedDir, withIntermediateDirectories: true)

				let prettified = """
					"\(folderName)" = "\(prettyName)";
					"""
				let localizedFile = localizedDir
					.appendingPathComponent("localization")
					.appendingPathExtension("strings")
				try prettified.write(to: localizedFile, atomically: true, encoding: .utf8)
			}

			return appSupportDir
		}
}
