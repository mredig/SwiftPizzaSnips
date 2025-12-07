#if canImport(ObjectiveC)

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
	public var asURLErrorCode: URLError.Code { .init(rawValue: rawValue) }
	public var asCocoaErrorCode: CocoaError.Code { .init(rawValue: rawValue) }
}
#endif

#if canImport(CloudKit)
import CloudKit
extension NSError.Codes {
	public var asCloudKitCode: CKError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(StoreKit)
import StoreKit
@available(watchOS 6.2, *)
extension NSError.Codes {
	public var asStoreKitCode: SKError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(AVFoundation)
import AVFoundation
extension NSError.Codes {
	public var asAVFoundationCode: AVError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(Photos)
import Photos
@available(macOS 10.15, iOS 13, tvOS 13.0, *)
extension NSError.Codes {
	public var asPHPhotosCode: PHPhotosError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(CoreData)
import CoreData
extension NSError.Codes {
	public var asCoreDataCode: CocoaError.Code { .init(rawValue: rawValue) }
}
#endif

#if canImport(CoreLocation)
import CoreLocation
extension NSError.Codes {
	public var asCoreLocationCode: CLError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(HealthKit)
import HealthKit
@available(macOS 13.0, *)
extension NSError.Codes {
	public var asHealthKitCode: HKError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(PassKit)
import PassKit
extension NSError.Codes {
	public var asPassKitCode: PKPaymentError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(Speech)
import Speech
extension NSError.Codes {
	// Speech framework doesn't expose a typed error code enum
	public var asSpeechRecognitionCode: Int { rawValue }
}
#endif

#if canImport(UserNotifications)
import UserNotifications
@available(macOS 10.14, *)
extension NSError.Codes {
	public var asUserNotificationsCode: UNError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(CoreBluetooth)
import CoreBluetooth
extension NSError.Codes {
	public var asCoreBluetoothCode: CBError.Code? { .init(rawValue: rawValue) }
	public var asCoreBluetoothATTCode: CBATTError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(MapKit)
import MapKit
extension NSError.Codes {
	public var asMapKitCode: MKError.Code? { .init(rawValue: UInt(rawValue)) }
}
#endif

#if canImport(EventKit)
import EventKit
extension NSError.Codes {
	public var asEventKitCode: EKError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(Contacts)
import Contacts
extension NSError.Codes {
	public var asContactsCode: CNError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(HomeKit)
import HomeKit
extension NSError.Codes {
	public var asHomeKitCode: HMError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(MediaPlayer)
import MediaPlayer
@available(macOS 10.14.2, *)
extension NSError.Codes {
	public var asMediaPlayerCode: MPError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(GameKit)
import GameKit
extension NSError.Codes {
	public var asGameKitCode: GKError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(Messages)
import Messages
extension NSError.Codes {
	public var asMessagesCode: MSMessageErrorCode? { .init(rawValue: rawValue) }
}
#endif

#if canImport(QuickLook) && !os(macOS)
import QuickLook
@available(iOS 13.0, *)
extension NSError.Codes {
	public var asQuickLookCode: QLThumbnailError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(WatchConnectivity)
import WatchConnectivity
extension NSError.Codes {
	public var asWatchConnectivityCode: WCError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(Metal)
import Metal
extension NSError.Codes {
	// Metal errors use MTLCommandBufferError enum
	public var asMetalCode: MTLCommandBufferError.Code? { .init(rawValue: UInt(rawValue)) }
}
#endif

#if canImport(CoreML)
import CoreML
extension NSError.Codes {
	public var asCoreMLCode: MLModelError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(ARKit) && os(iOS)
import ARKit
extension NSError.Codes {
	public var asARKitCode: ARError.Code? { .init(rawValue: rawValue) }
}
#endif

#if canImport(RealityKit)
import RealityKit
extension NSError.Codes {
	// RealityKit doesn't expose a typed error code enum
	public var asRealityKitCode: Int { rawValue }
}
#endif

#endif
