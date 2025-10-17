extension NSError {
	public struct Codes: RawRepEquatable, ExpressibleByIntegerLiteral {
		public let rawValue: Int

		public init(rawValue: Int) {
			self.rawValue = rawValue
		}

		public init(_ rawValue: Int) {
			self.init(rawValue: rawValue)
		}

		public init(integerLiteral value: IntegerLiteralType) {
			self.init(value)
		}
	}
}

#if canImport(FoundationNetworking)
import FoundationNetworking
#elseif canImport(Foundation)
import Foundation
#endif

#if canImport(Foundation) || canImport(FoundationNetworking)
extension NSError.Codes {
	var asURLErrorCode: URLError.Code { .init(rawValue: rawValue) }
	var asCocoaErrorCode: CocoaError.Code { .init(rawValue: rawValue) }
}
#endif

#if canImport(CloudKit)
import CloudKit
extension NSError.Codes {
	var asCloudKitCode: CKError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(StoreKit)
import StoreKit
extension NSError.Codes {
	var asStoreKitCode: SKError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(AVFoundation)
import AVFoundation
extension NSError.Codes {
	var asAVFoundationCode: AVError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(Photos)
import Photos
@available(iOS 13, *)
extension NSError.Codes {
	var asPHPhotosCode: PHPhotosError.Code? { .init(rawValue: rawValue) }
}
#endif
