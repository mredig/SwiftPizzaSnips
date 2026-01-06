#if targetEnvironment(simulator)
import UIKit

/// Create symlinks in a convenient location to gain easier access to simulator containers
/// 
/// Note: only works for simulator targets. Wrap calls in `#if targetEnvironment(simulator)`
/// 
/// - Parameters:
///   - rootDirectory: The host directory that will be created to store the symlinks into the container
///   - links: Keys: the name you want to create a folder with; Values: the container path to link to. For example ["AppContainer": URL.libraryDirectory.deletingLastPathComponent()]
/// - Throws: Forwards errors from FileManager
public func createContainerSymlink(rootDirectory: URL, links: [String: URL]) throws {
	let device = UIDevice.current
	let id = device.identifierForVendor?.uuidString
	let nameBuilder = [
		device.name,
		device.systemName,
		device.systemVersion,
		id.map { "(\($0))" }
	]
	let name = nameBuilder.compactMap(\.self).joined(separator: "_")

	let directory = rootDirectory
		.appendingPathComponent(name)

	try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

	for (linkName, target) in links {
		let linkURL = directory.appendingPathComponent(linkName)
		try FileManager.default.createSymbolicLink(at: linkURL, withDestinationURL: target)
	}
}
#endif
