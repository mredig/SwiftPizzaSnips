import Foundation
#if canImport(CryptoKit)
import CryptoKit
#elseif canImport(Crypto)
import Crypto
#endif

#if canImport(CryptoKit) || canImport(Crypto)
@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension UUID {
	/// MD5 hashes and UUIDs have the same byte count. There are situations where it's convenient to exchange one for
	/// the other (for example, providing a unique, consistent ID for a set of data that wasn't previously assigned an
	/// ID - just don't use for cryptographically secure needs as MD5 is no longer secure)
	/// - Parameter md5Hash: The MD5 hash in Apple's CryptoKit format
	public init(md5Hash: Insecure.MD5Digest) {
		let data = Data(md5Hash)
		self.init(uuid: (
			data[0],
			data[1],
			data[2],
			data[3],
			data[4],
			data[5],
			data[6],
			data[7],
			data[8],
			data[9],
			data[10],
			data[11],
			data[12],
			data[13],
			data[14],
			data[15]
		))
	}
}

@available(macOS 10.15, iOS 13.2, tvOS 13.2, watchOS 6.1, *)
extension Insecure.MD5Digest {
	public init(uuid: UUID) {
		let buffer = UnsafeMutableBufferPointer<UUID>.allocate(capacity: 1)
		buffer[0] = uuid
		defer {
			buffer[0] = UUID()
			buffer.deallocate()
		}

		let digest = buffer.withMemoryRebound(to: Insecure.MD5Digest.self) { buffer2 in
			buffer2[0]
		}
		self = digest
	}
}
#endif
