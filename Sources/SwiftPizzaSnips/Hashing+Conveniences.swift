import Foundation
#if canImport(Crypto)
import Crypto
#elseif canImport(CryptoKit)
import CryptoKit
#endif

#if canImport(CryptoKit) || canImport(Crypto)

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension Digest {
	public func toHexString() -> String {
		Data(self).toHexString()
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension HashFunction {
	/// Generates a hash streaming from a file without loading all the data into memory. Defaults to a 10 MB buffer.
	public static func hash(fileStream input: URL, bufferSizeBytes: Int = 1024 * 1024 * 10) throws -> Digest {
		let stream = try InputStream(url: input).unwrap()
		return try hash(stream: stream, bufferSizeBytes: bufferSizeBytes)
	}

	/// Generates a hash from a stream without loading all the data into memory. Defaults to a 10 MB buffer.
	public static func hash(stream input: InputStream, bufferSizeBytes: Int = 1024 * 1024 * 10) throws -> Digest {
		var hasher = Self.init()

		let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: bufferSizeBytes)
		guard let pointer = buffer.baseAddress else { throw NSError(domain: "Error allocating buffer", code: -2) }
		input.open()
		while input.hasBytesAvailable {
			let bytesRead = input.read(pointer, maxLength: bufferSizeBytes)
			let bufferrr = UnsafeRawBufferPointer(start: pointer, count: bytesRead)
			hasher.update(bufferPointer: bufferrr)
		}
		input.close()

		return hasher.finalize()
	}
}
#endif
