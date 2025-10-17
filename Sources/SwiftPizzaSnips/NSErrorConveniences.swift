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

extension ErrorDomain {
	// MARK: - Foundation & System
	static let cocoaError = ErrorDomain(NSCocoaErrorDomain)
	static let urlError = ErrorDomain(NSURLErrorDomain)
	static let posixError = ErrorDomain(NSPOSIXErrorDomain)
	static let machError = ErrorDomain(NSMachErrorDomain)
	static let osStatus = ErrorDomain(NSOSStatusErrorDomain)
}

#if canImport(CloudKit)
import CloudKit
extension ErrorDomain {
	static let cloudKitError = ErrorDomain(CKErrorDomain)
}
#endif

#if canImport(StoreKit)
import StoreKit
@available(watchOS 6.2, *)
extension ErrorDomain {
	static let storeKitError = ErrorDomain(SKErrorDomain)
}
#endif

#if canImport(AVFoundation)
import AVFoundation
extension ErrorDomain {
	static let avFoundationError = ErrorDomain(AVFoundationErrorDomain)
}
#endif

#if canImport(CoreLocation)
import CoreLocation
extension ErrorDomain {
	static let locationError = ErrorDomain(kCLErrorDomain)
}
#endif

#if canImport(Photos)
import Photos
@available(macOS 10.15, iOS 13, tvOS 13.0, *)
extension ErrorDomain {
	static let photosError = ErrorDomain(PHPhotosErrorDomain)
}
#endif

#if canImport(HealthKit)
import HealthKit
@available(macOS 13.0, *)
extension ErrorDomain {
	static let healthKitError = ErrorDomain(HKErrorDomain)
}
#endif

#if canImport(PassKit)
import PassKit
extension ErrorDomain {
	static let passKitError = ErrorDomain(PKPassKitErrorDomain)
}
#endif

#if canImport(Speech)
import Speech
@available(macOS 14, iOS 17, *)
extension ErrorDomain {
	static let speechRecognitionError = ErrorDomain(SFSpeechError.errorDomain)
}
#endif

#if canImport(UserNotifications)
import UserNotifications
@available(macOS 10.14, *)
extension ErrorDomain {
	static let userNotificationsError = ErrorDomain(UNErrorDomain)
}
#endif

#if canImport(CoreBluetooth)
import CoreBluetooth
extension ErrorDomain {
	static let coreBluetoothError = ErrorDomain(CBErrorDomain)
	static let coreBluetoothATTError = ErrorDomain(CBATTErrorDomain)
}
#endif

#if canImport(MapKit)
import MapKit
extension ErrorDomain {
	static let mapKitError = ErrorDomain(MKErrorDomain)
}
#endif

#if canImport(EventKit)
import EventKit
extension ErrorDomain {
	static let eventKitError = ErrorDomain(EKErrorDomain)
}
#endif

#if canImport(Contacts)
import Contacts
extension ErrorDomain {
	static let contactsError = ErrorDomain(CNErrorDomain)
}
#endif

#if canImport(HomeKit)
import HomeKit
extension ErrorDomain {
	static let homeKitError = ErrorDomain(HMErrorDomain)
}
#endif

#if canImport(MediaPlayer)
import MediaPlayer
extension ErrorDomain {
	static let mediaPlayerError = ErrorDomain(MPErrorDomain)
}
#endif

#if canImport(GameKit)
import GameKit
extension ErrorDomain {
	static let gameKitError = ErrorDomain(GKErrorDomain)
}
#endif

#if canImport(Messages)
import Messages
extension ErrorDomain {
	static let messagesError = ErrorDomain(MSMessagesErrorDomain)
}
#endif

#if canImport(WatchConnectivity)
import WatchConnectivity
extension ErrorDomain {
	static let watchConnectivityError = ErrorDomain(WCErrorDomain)
}
#endif

#if canImport(CoreSpotlight) && !os(tvOS)
import CoreSpotlight
extension ErrorDomain {
	static let coreSpotlightError = ErrorDomain(CSIndexErrorDomain)
}
#endif

#if canImport(Metal)
import Metal
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension ErrorDomain {
	static let metalCommandBufferError = ErrorDomain(MTLCommandBufferErrorDomain)
//	static let metalIOError = ErrorDomain(MTLIOErrorDomain)
	static let metalCaptureError = ErrorDomain(MTLCaptureErrorDomain)
	@available(iOS 14.0, tvOS 14.0, *)
	static let metalCounterError = ErrorDomain(MTLCounterErrorDomain)
	static let metalLibraryError = ErrorDomain(MTLLibraryErrorDomain)
	@available(macOS 15.0, iOS 18.0, tvOS 18.0, *)
	static let metalLogStateError = ErrorDomain(MTLLogStateErrorDomain)
//	static let metal4CommandQueueError = ErrorDomain(MTL4CommandQueueErrorDomain)
}
#endif

#if canImport(Vision)
import Vision
extension ErrorDomain {
	static let visionError = ErrorDomain(VNErrorDomain)
}
#endif

#if canImport(CoreML)
import CoreML
extension ErrorDomain {
	static let coreMLError = ErrorDomain(MLModelErrorDomain)
}
#endif
