import Foundation
import Testing
import SwiftPizzaSnips

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(CloudKit)
import CloudKit
#endif

#if canImport(CoreData)
import CoreData
#endif

#if canImport(StoreKit)
import StoreKit
#endif

#if canImport(AVFoundation)
import AVFoundation
#endif

#if canImport(CoreLocation)
import CoreLocation
#endif

#if canImport(Photos)
import Photos
#endif

#if canImport(HealthKit)
import HealthKit
#endif

#if canImport(PassKit)
import PassKit
#endif

#if canImport(UserNotifications)
import UserNotifications
#endif

#if canImport(CoreBluetooth)
import CoreBluetooth
#endif

#if canImport(MapKit)
import MapKit
#endif

#if canImport(EventKit)
import EventKit
#endif

#if canImport(Contacts)
import Contacts
#endif

#if canImport(HomeKit)
import HomeKit
#endif

#if canImport(MediaPlayer)
import MediaPlayer
#endif

#if canImport(GameKit)
import GameKit
#endif

#if canImport(Messages)
import Messages
#endif

#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

#if canImport(CoreSpotlight)
import CoreSpotlight
#endif

#if canImport(Metal)
import Metal
#endif

#if canImport(Vision)
import Vision
#endif

#if canImport(CoreML)
import CoreML
#endif

struct ErrorDomainTests {
	@Test func testFoundationDomains() {
		#expect(ErrorDomain.cocoaError.rawValue == NSCocoaErrorDomain)
		#expect(ErrorDomain.urlError.rawValue == NSURLErrorDomain)
		#expect(ErrorDomain.posixError.rawValue == NSPOSIXErrorDomain)
		#expect(ErrorDomain.machError.rawValue == NSMachErrorDomain)
		#expect(ErrorDomain.osStatus.rawValue == NSOSStatusErrorDomain)
	}
	
	@Test func testNSErrorDomainProperty() {
		let error = NSError(domain: NSURLErrorDomain, code: -1009)
		#expect(error.errorDomain == .urlError)
		#expect(error.errorDomain.rawValue == NSURLErrorDomain)
	}
	
	@Test func testStringLiteralConformance() {
		let customDomain: ErrorDomain = "com.example.custom"
		#expect(customDomain.rawValue == "com.example.custom")
	}
	
	@Test func testEquality() {
		let domain1 = ErrorDomain(NSURLErrorDomain)
		let domain2 = ErrorDomain.urlError
		#expect(domain1 == domain2)
		
		let customDomain1: ErrorDomain = "custom"
		let customDomain2 = ErrorDomain("custom")
		#expect(customDomain1 == customDomain2)
	}
	
	#if canImport(CloudKit)
	@Test func testCloudKitDomain() {
		#expect(ErrorDomain.cloudKitError.rawValue == CKErrorDomain)
		
		let error = NSError(domain: CKErrorDomain, code: 1)
		#expect(error.errorDomain == .cloudKitError)
	}
	#endif

	#if canImport(StoreKit)
	@available(watchOS 6.2, *)
	@Test func testStoreKitDomain() {
		#expect(ErrorDomain.storeKitError.rawValue == SKErrorDomain)
		
		let error = NSError(domain: SKErrorDomain, code: 0)
		#expect(error.errorDomain == .storeKitError)
	}
	#endif
	
	#if canImport(AVFoundation)
	@Test func testAVFoundationDomain() {
		#expect(ErrorDomain.avFoundationError.rawValue == AVFoundationErrorDomain)
	}
	#endif
	
	#if canImport(CoreLocation)
	@Test func testCoreLocationDomain() {
		#expect(ErrorDomain.locationError.rawValue == kCLErrorDomain)
		
		let error = NSError(domain: kCLErrorDomain, code: 0)
		#expect(error.errorDomain == .locationError)
	}
	#endif
	
	#if canImport(Photos)
	@available(macOS 10.15, iOS 13, tvOS 13.0, *)
	@Test func testPhotosDomain() {
		#expect(ErrorDomain.photosError.rawValue == PHPhotosErrorDomain)
	}
	#endif
	
	#if canImport(HealthKit)
	@available(macOS 13.0, *)
	@Test func testHealthKitDomain() {
		#expect(ErrorDomain.healthKitError.rawValue == HKErrorDomain)
	}
	#endif
	
	#if canImport(PassKit)
	@Test func testPassKitDomain() {
		#expect(ErrorDomain.passKitError.rawValue == PKPassKitErrorDomain)
	}
	#endif
	
	#if canImport(UserNotifications)
	@available(macOS 10.14, *)
	@Test func testUserNotificationsDomain() {
		#expect(ErrorDomain.userNotificationsError.rawValue == UNErrorDomain)
	}
	#endif
	
	#if canImport(CoreBluetooth)
	@Test func testCoreBluetoothDomains() {
		#expect(ErrorDomain.coreBluetoothError.rawValue == CBErrorDomain)
		#expect(ErrorDomain.coreBluetoothATTError.rawValue == CBATTErrorDomain)
	}
	#endif
	
	#if canImport(MapKit)
	@Test func testMapKitDomain() {
		#expect(ErrorDomain.mapKitError.rawValue == MKErrorDomain)
	}
	#endif
	
	#if canImport(EventKit)
	@Test func testEventKitDomain() {
		#expect(ErrorDomain.eventKitError.rawValue == EKErrorDomain)
	}
	#endif
	
	#if canImport(Contacts)
	@Test func testContactsDomain() {
		#expect(ErrorDomain.contactsError.rawValue == CNErrorDomain)
	}
	#endif
	
	#if canImport(HomeKit)
	@Test func testHomeKitDomain() {
		#expect(ErrorDomain.homeKitError.rawValue == HMErrorDomain)
	}
	#endif
	
	#if canImport(MediaPlayer)
	@Test func testMediaPlayerDomain() {
		#expect(ErrorDomain.mediaPlayerError.rawValue == MPErrorDomain)
	}
	#endif
	
	#if canImport(GameKit)
	@Test func testGameKitDomain() {
		#expect(ErrorDomain.gameKitError.rawValue == GKErrorDomain)
	}
	#endif
	
	#if canImport(Messages)
	@Test func testMessagesDomain() {
		#expect(ErrorDomain.messagesError.rawValue == MSMessagesErrorDomain)
	}
	#endif
	
	#if canImport(WatchConnectivity)
	@Test func testWatchConnectivityDomain() {
		#expect(ErrorDomain.watchConnectivityError.rawValue == WCErrorDomain)
	}
	#endif
	
	#if canImport(CoreSpotlight) && !os(tvOS)
	@Test func testCoreSpotlightDomain() {
		#expect(ErrorDomain.coreSpotlightError.rawValue == CSIndexErrorDomain)
	}
	#endif
	
	#if canImport(Metal)
	@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
	@Test func testMetalDomains() {
		#expect(ErrorDomain.metalCommandBufferError.rawValue == MTLCommandBufferErrorDomain)
		#expect(ErrorDomain.metalCaptureError.rawValue == MTLCaptureErrorDomain)
		
		#if compiler(>=6.0)
		if #available(iOS 14.0, tvOS 14.0, macOS 10.16, *) {
			#expect(ErrorDomain.metalCounterError.rawValue == MTLCounterErrorDomain)
		}
		if #available(macOS 15.0, iOS 18.0, tvOS 18.0, *) {
			#expect(ErrorDomain.metalLogStateError.rawValue == MTLLogStateErrorDomain)
		}
		#endif
		
		#expect(ErrorDomain.metalLibraryError.rawValue == MTLLibraryErrorDomain)
	}
	#endif
	
	#if canImport(Vision)
	@Test func testVisionDomain() {
		#expect(ErrorDomain.visionError.rawValue == VNErrorDomain)
	}
	#endif
	
	#if canImport(CoreML)
	@Test func testCoreMLDomain() {
		#expect(ErrorDomain.coreMLError.rawValue == MLModelErrorDomain)
	}
	#endif
	
	@Test func testURLErrorCreation() {
		let error = URLError(.notConnectedToInternet)
		let nsError = error as NSError
		#expect(nsError.errorDomain == .urlError)
	}
	
	@Test func testCocoaErrorCreation() {
		let error = CocoaError(.fileNoSuchFile)
		let nsError = error as NSError
		#expect(nsError.errorDomain == .cocoaError)
	}
}
