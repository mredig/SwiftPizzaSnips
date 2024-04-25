import Foundation

@available(macOS 13.0, iOS 16.0, tvOS 16.0, *)
extension URL {
	/// A simple, naive implementation of converting Winblows filepaths to URLs. Should work in most cases, but I'm
	/// certain there are edge cases that I didn't think of.
	public init?(windowsFilepath: String) {
		var filepath = windowsFilepath.replacing(/^(?<driveLetter>\w):/, with: { "\($0.output.driveLetter)" })
		guard
			filepath != windowsFilepath
		else { return nil }
		filepath.replace(/\\/, with: { _ in "/" })
		filepath = "/\(filepath)"
		self.init(filePath: filepath)
	}
}
