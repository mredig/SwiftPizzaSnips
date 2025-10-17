#if canImport(Foundation)
public struct ErrorDomain: RawRepEquatable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
	public let rawValue: String

	public init(rawValue: String) {
		self.rawValue = rawValue
	}

	public init(_ rawValue: String) {
		self.init(rawValue: rawValue)
	}

	public init(stringLiteral value: String) {
		self.init(value)
	}
}

extension NSError {
	public var errorDomain: ErrorDomain {
		ErrorDomain(domain)
	}
}

extension ErrorDomain {
	// MARK: - Foundation & System
	public static let cocoaError = ErrorDomain(NSCocoaErrorDomain)
	public static let urlError = ErrorDomain(NSURLErrorDomain)
	public static let posixError = ErrorDomain(NSPOSIXErrorDomain)
	public static let machError = ErrorDomain(NSMachErrorDomain)
	public static let osStatus = ErrorDomain(NSOSStatusErrorDomain)
}

#if canImport(CloudKit)
import CloudKit
extension ErrorDomain {
	public static let cloudKitError = ErrorDomain(CKErrorDomain)
}
#endif

#if canImport(StoreKit)
import StoreKit
@available(watchOS 6.2, *)
extension ErrorDomain {
	public static let storeKitError = ErrorDomain(SKErrorDomain)
}
#endif

#if canImport(AVFoundation)
import AVFoundation
extension ErrorDomain {
	public static let avFoundationError = ErrorDomain(AVFoundationErrorDomain)
}
#endif

#if canImport(CoreLocation)
import CoreLocation
extension ErrorDomain {
	public static let locationError = ErrorDomain(kCLErrorDomain)
}
#endif

#if canImport(Photos)
import Photos
@available(macOS 10.15, iOS 13, tvOS 13.0, *)
extension ErrorDomain {
	public static let photosError = ErrorDomain(PHPhotosErrorDomain)
}
#endif

#if canImport(HealthKit)
import HealthKit
@available(macOS 13.0, *)
extension ErrorDomain {
	public static let healthKitError = ErrorDomain(HKErrorDomain)
}
#endif

#if canImport(PassKit)
import PassKit
extension ErrorDomain {
	public static let passKitError = ErrorDomain(PKPassKitErrorDomain)
}
#endif

#if canImport(Speech)
import Speech
@available(macOS 14, iOS 17, *)
extension ErrorDomain {
	public static let speechRecognitionError = ErrorDomain(SFSpeechError.errorDomain)
}
#endif

#if canImport(UserNotifications)
import UserNotifications
@available(macOS 10.14, *)
extension ErrorDomain {
	public static let userNotificationsError = ErrorDomain(UNErrorDomain)
}
#endif

#if canImport(CoreBluetooth)
import CoreBluetooth
extension ErrorDomain {
	public static let coreBluetoothError = ErrorDomain(CBErrorDomain)
	public static let coreBluetoothATTError = ErrorDomain(CBATTErrorDomain)
}
#endif

#if canImport(MapKit)
import MapKit
extension ErrorDomain {
	public static let mapKitError = ErrorDomain(MKErrorDomain)
}
#endif

#if canImport(EventKit)
import EventKit
extension ErrorDomain {
	public static let eventKitError = ErrorDomain(EKErrorDomain)
}
#endif

#if canImport(Contacts)
import Contacts
extension ErrorDomain {
	public static let contactsError = ErrorDomain(CNErrorDomain)
}
#endif

#if canImport(HomeKit)
import HomeKit
extension ErrorDomain {
	public static let homeKitError = ErrorDomain(HMErrorDomain)
}
#endif

#if canImport(MediaPlayer)
import MediaPlayer
extension ErrorDomain {
	public static let mediaPlayerError = ErrorDomain(MPErrorDomain)
}
#endif

#if canImport(GameKit)
import GameKit
extension ErrorDomain {
	public static let gameKitError = ErrorDomain(GKErrorDomain)
}
#endif

#if canImport(Messages)
import Messages
extension ErrorDomain {
	public static let messagesError = ErrorDomain(MSMessagesErrorDomain)
}
#endif

#if canImport(WatchConnectivity)
import WatchConnectivity
extension ErrorDomain {
	public static let watchConnectivityError = ErrorDomain(WCErrorDomain)
}
#endif

#if canImport(CoreSpotlight) && !os(tvOS)
import CoreSpotlight
extension ErrorDomain {
	public static let coreSpotlightError = ErrorDomain(CSIndexErrorDomain)
}
#endif

#if canImport(Metal)
import Metal
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension ErrorDomain {
	public static let metalCommandBufferError = ErrorDomain(MTLCommandBufferErrorDomain)
	public static let metalCaptureError = ErrorDomain(MTLCaptureErrorDomain)
	@available(iOS 14.0, tvOS 14.0, *)
	public static let metalCounterError = ErrorDomain(MTLCounterErrorDomain)
	public static let metalLibraryError = ErrorDomain(MTLLibraryErrorDomain)
	@available(macOS 15.0, iOS 18.0, tvOS 18.0, *)
	public static let metalLogStateError = ErrorDomain(MTLLogStateErrorDomain)
}
#endif

#if canImport(Vision)
import Vision
extension ErrorDomain {
	public static let visionError = ErrorDomain(VNErrorDomain)
}
#endif

#if canImport(CoreML)
import CoreML
extension ErrorDomain {
	public static let coreMLError = ErrorDomain(MLModelErrorDomain)
}
#endif

#endif
