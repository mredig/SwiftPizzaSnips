import Foundation
import Testing
import SwiftPizzaSnips

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(CloudKit)
import CloudKit
#endif

#if canImport(StoreKit)
import StoreKit
#endif

#if canImport(AVFoundation)
import AVFoundation
#endif

#if canImport(Photos)
import Photos
#endif

#if canImport(CoreData)
import CoreData
#endif

#if canImport(CoreLocation)
import CoreLocation
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

#if canImport(QuickLook)
import QuickLook
#endif

#if canImport(WatchConnectivity)
import WatchConnectivity
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

#if canImport(ARKit)
import ARKit
#endif

#if canImport(RealityKit)
import RealityKit
#endif

struct TypedCodesTests {
	
	@Test func testCodesInitialization() {
		let code1 = NSError.Codes(rawValue: 42)
		#expect(code1.rawValue == 42)
		
		let code2 = NSError.Codes(42)
		#expect(code2.rawValue == 42)
		
		let code3: NSError.Codes = 42
		#expect(code3.rawValue == 42)
	}
	
	@Test func testCodesEquality() {
		let code1 = NSError.Codes(100)
		let code2 = NSError.Codes(100)
		let code3 = NSError.Codes(200)
		
		#expect(code1 == code2)
		#expect(code1 != code3)
	}
	
	@Test func testURLErrorCodeConversion() {
		let notConnectedCode = NSError.Codes(URLError.Code.notConnectedToInternet.rawValue)
		let urlErrorCode = notConnectedCode.asURLErrorCode
		#expect(urlErrorCode == .notConnectedToInternet)
		
		let timedOutCode = NSError.Codes(URLError.Code.timedOut.rawValue)
		#expect(timedOutCode.asURLErrorCode == .timedOut)
		
		let badURLCode = NSError.Codes(URLError.Code.badURL.rawValue)
		#expect(badURLCode.asURLErrorCode == .badURL)
	}
	
	@Test func testCocoaErrorCodeConversion() {
		let fileNotFoundCode = NSError.Codes(CocoaError.Code.fileNoSuchFile.rawValue)
		let cocoaErrorCode = fileNotFoundCode.asCocoaErrorCode
		#expect(cocoaErrorCode == .fileNoSuchFile)
		
		let fileReadCode = NSError.Codes(CocoaError.Code.fileReadNoPermission.rawValue)
		#expect(fileReadCode.asCocoaErrorCode == .fileReadNoPermission)
	}
	
	@Test func testURLErrorFromNSError() {
		let nsError = NSError(domain: NSURLErrorDomain, code: URLError.Code.notConnectedToInternet.rawValue)
		let codes = NSError.Codes(nsError.code)
		#expect(codes.asURLErrorCode == .notConnectedToInternet)
	}
	
	@Test func testCocoaErrorFromNSError() {
		let nsError = NSError(domain: NSCocoaErrorDomain, code: CocoaError.Code.fileNoSuchFile.rawValue)
		let codes = NSError.Codes(nsError.code)
		#expect(codes.asCocoaErrorCode == .fileNoSuchFile)
	}
	
	#if canImport(CloudKit)
	@Test func testCloudKitCodeConversion() {
		let networkFailureCode = NSError.Codes(CKError.Code.networkFailure.rawValue)
		#expect(networkFailureCode.asCloudKitCode == .networkFailure)
		
		let notAuthenticatedCode = NSError.Codes(CKError.Code.notAuthenticated.rawValue)
		#expect(notAuthenticatedCode.asCloudKitCode == .notAuthenticated)
	}
	#endif
	
	#if canImport(StoreKit)
	@available(watchOS 6.2, *)
	@Test func testStoreKitCodeConversion() {
		let paymentCancelledCode = NSError.Codes(SKError.Code.paymentCancelled.rawValue)
		#expect(paymentCancelledCode.asStoreKitCode == .paymentCancelled)
		
		let unknownCode = NSError.Codes(SKError.Code.unknown.rawValue)
		#expect(unknownCode.asStoreKitCode == .unknown)
	}
	#endif
	
	#if canImport(AVFoundation)
	@Test func testAVFoundationCodeConversion() {
		let unknownCode = NSError.Codes(AVError.Code.unknown.rawValue)
		#expect(unknownCode.asAVFoundationCode == .unknown)
		
		let fileFormatNotRecognizedCode = NSError.Codes(AVError.Code.fileFormatNotRecognized.rawValue)
		#expect(fileFormatNotRecognizedCode.asAVFoundationCode == .fileFormatNotRecognized)
	}
	#endif
	
	#if canImport(Photos)
	@available(macOS 10.15, iOS 15, tvOS 13.0, *)
	@Test func testPhotosCodeConversion() {
		let invalidResourceCode = NSError.Codes(PHPhotosError.Code.invalidResource.rawValue)
		#expect(invalidResourceCode.asPHPhotosCode == .invalidResource)
	}
	#endif
	
	#if canImport(CoreData)
	@Test func testCoreDataCodeConversion() {
		// CoreData errors use CocoaError domain
		let persistentStoreInvalidCode = NSError.Codes(NSPersistentStoreInvalidTypeError)
		let cocoaCode = persistentStoreInvalidCode.asCoreDataCode
		#expect(cocoaCode.rawValue == NSPersistentStoreInvalidTypeError)
	}
	#endif
	
	#if canImport(CoreLocation)
	@Test func testCoreLocationCodeConversion() {
		let deniedCode = NSError.Codes(CLError.Code.denied.rawValue)
		#expect(deniedCode.asCoreLocationCode == .denied)
		
		let networkCode = NSError.Codes(CLError.Code.network.rawValue)
		#expect(networkCode.asCoreLocationCode == .network)
	}
	#endif
	
	#if canImport(HealthKit)
	@available(macOS 13.0, iOS 14.0, *)
	@Test func testHealthKitCodeConversion() {
		let noDataCode = NSError.Codes(HKError.Code.errorNoData.rawValue)
		#expect(noDataCode.asHealthKitCode == .errorNoData)
	}
	#endif
	
	#if canImport(PassKit)
	@available(iOS 15.0, *)
	@Test func testPassKitCodeConversion() {
		let unknownCode = NSError.Codes(PKPaymentError.Code.couponCodeExpiredError.rawValue)
		#expect(unknownCode.asPassKitCode == .couponCodeExpiredError)
	}
	#endif


	#if canImport(Speech)
	@Test func speechCodeConversion() {
		let unknownCode = NSError.Codes(456)
		#expect(unknownCode.asSpeechRecognitionCode == 456)
	}
	#endif

	#if canImport(UserNotifications)
	@available(macOS 10.14, *)
	@Test func testUserNotificationsCodeConversion() {
		let notificationsNotAllowedCode = NSError.Codes(UNError.Code.notificationsNotAllowed.rawValue)
		#expect(notificationsNotAllowedCode.asUserNotificationsCode == .notificationsNotAllowed)
	}
	#endif
	
	#if canImport(CoreBluetooth)
	@Test func testCoreBluetoothCodeConversion() {
		let unknownCode = NSError.Codes(CBError.Code.unknown.rawValue)
		#expect(unknownCode.asCoreBluetoothCode == .unknown)
		
		let invalidParametersCode = NSError.Codes(CBATTError.Code.invalidHandle.rawValue)
		#expect(invalidParametersCode.asCoreBluetoothATTCode == .invalidHandle)
	}
	#endif
	
	#if canImport(MapKit)
	@Test func testMapKitCodeConversion() {
		let unknownCode = NSError.Codes(Int(MKError.Code.unknown.rawValue))
		#expect(unknownCode.asMapKitCode == .unknown)
		
		let serverFailureCode = NSError.Codes(Int(MKError.Code.serverFailure.rawValue))
		#expect(serverFailureCode.asMapKitCode == .serverFailure)
	}
	#endif
	
	#if canImport(EventKit)
	@Test func testEventKitCodeConversion() {
		let eventNotMutableCode = NSError.Codes(EKError.Code.eventNotMutable.rawValue)
		#expect(eventNotMutableCode.asEventKitCode == .eventNotMutable)
	}
	#endif
	
	#if canImport(Contacts)
	@Test func testContactsCodeConversion() {
		let authorizationDeniedCode = NSError.Codes(CNError.Code.authorizationDenied.rawValue)
		#expect(authorizationDeniedCode.asContactsCode == .authorizationDenied)
	}
	#endif
	
	#if canImport(HomeKit)
	@Test func testHomeKitCodeConversion() {
		let invalidParameterCode = NSError.Codes(HMError.Code.invalidParameter.rawValue)
		#expect(invalidParameterCode.asHomeKitCode == .invalidParameter)
	}
	#endif
	
	#if canImport(MediaPlayer)
	@available(macOS 10.14.2, *)
	@Test func testMediaPlayerCodeConversion() {
		let unknownCode = NSError.Codes(MPError.Code.unknown.rawValue)
		#expect(unknownCode.asMediaPlayerCode == .unknown)
	}
	#endif
	
	#if canImport(GameKit)
	@Test func testGameKitCodeConversion() {
		let unknownCode = NSError.Codes(GKError.Code.unknown.rawValue)
		#expect(unknownCode.asGameKitCode == .unknown)
		
		let cancelledCode = NSError.Codes(GKError.Code.cancelled.rawValue)
		#expect(cancelledCode.asGameKitCode == .cancelled)
	}
	#endif
	
	#if canImport(Messages)
	@Test func testMessagesCodeConversion() {
		let unknownCode = NSError.Codes(MSMessageErrorCode.unknown.rawValue)
		#expect(unknownCode.asMessagesCode == .unknown)
	}
	#endif

	#if canImport(WatchConnectivity)
	@Test func testWatchConnectivityCodeConversion() {
		let sessionNotActivatedCode = NSError.Codes(WCError.Code.sessionNotActivated.rawValue)
		#expect(sessionNotActivatedCode.asWatchConnectivityCode == .sessionNotActivated)
	}
	#endif
	
	#if canImport(Metal)
	@Test func testMetalCodeConversion() {
		// Metal uses UInt for error codes
		let noneCode = NSError.Codes(Int(MTLCommandBufferError.Code.timeout.rawValue))
		#expect(noneCode.asMetalCode == .timeout)

		let internalCode = NSError.Codes(Int(MTLCommandBufferError.Code.internal.rawValue))
		#expect(internalCode.asMetalCode == .internal)
	}
	#endif

	#if canImport(CoreML)
	@Test func testCoreMLCodeConversion() {
		let genericCode = NSError.Codes(MLModelError.Code.generic.rawValue)
		#expect(genericCode.asCoreMLCode == .generic)
		
		let featureTypeCode = NSError.Codes(MLModelError.Code.featureType.rawValue)
		#expect(featureTypeCode.asCoreMLCode == .featureType)
	}
	#endif
	
	#if canImport(ARKit) && os(iOS)
	@Test func testARKitCodeConversion() {
		let unsupportedConfigurationCode = NSError.Codes(ARError.Code.unsupportedConfiguration.rawValue)
		#expect(unsupportedConfigurationCode.asARKitCode == .unsupportedConfiguration)
	}
	#endif
	
	#if canImport(RealityKit)
	@Test func testRealityKitCodePassthrough() {
		// RealityKit doesn't have typed error codes, so it just returns the raw value
		let code = NSError.Codes(42)
		#expect(code.asRealityKitCode == 42)
	}
	#endif
	
	@Test func testMultipleConversionsFromSameCode() {
		// A code can be converted to multiple types
		let code = NSError.Codes(-1009)
		
		let urlCode = code.asURLErrorCode
		#expect(urlCode.rawValue == -1009)
		
		let cocoaCode = code.asCocoaErrorCode
		#expect(cocoaCode.rawValue == -1009)
		
		// They represent different error types even with the same raw value
		#expect(urlCode == .notConnectedToInternet)
	}
}
