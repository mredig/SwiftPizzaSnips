/*
NOTE regarding entire file:

I've really not tested ANY of these things. I read about it on twitter and thought it'd be a neat thing to add to 
these utilities. All I can confirm is that it builds!
*/


#if os(macOS) && DEBUG
import AppKit

/// [ref](https://mjtsai.com/blog/2024/03/22/_eventfirstresponderchaindescription/#comment-4059578)
public extension NSApplication {
	var firstResponderChainDescription: String {
		(value(forKey: "_eventFirstResponderChainDescription") as? String) ?? "<Description Unavailable>"
	}
}

@available(macOS 10.15, *)
extension DefaultsManager.KeyWithDefault where Value == Bool, StoredValue == Value {
	/// Alternatively can be set via passing this argument to the app while launching: `-_NS_4445425547 YES`
	///
	/// Requires relaunching the app. This menu is magic. It gives you information on the RESPONDOR CHAIN 🤯
	public static let enableDebugMenu = Self("_NS_4445425547", defaultValue: false)
}

#endif

#if os(iOS) && DEBUG
import UIKit
import CoreImage

public extension UIApplication {
	/// This might be macOS only, but untested.
	var firstResponderChainDescription: String {
		(value(forKey: "_eventFirstResponderChainDescription") as? String) ?? "<Description Unavailable>"
	}
}

public enum iOSRenderDebugOption: CInt {
	case colorBlendedLayers = 0x02
	case colorHitsGreenMissesRed = 0x13
	case colorCopiedImages = 0x01
	case colorLayerFormats = 0x14
	case colorImmediately = 0x03
	case colorMisalignedImages = 0x0E
	case colorOffscreenRenderedYellow = 0x11
	case colorCompositingFastPathBlue = 0x12
	case flashUpdatedRegions = 0x00
}

///	Convenience for using CARenderServerSetDebugOption()
///
///	[ref](https://twitter.com/CoreSerena/status/1778083259466817720) and [ref2](https://bryce.co/on-device-render-debugging/)
public func setIOSDebugOverlay(option: iOSRenderDebugOption, on flag: Bool) throws {
	let quartzCorePath = "/System/Library/Frameworks/QuartzCore.framework/QuartzCore"
	guard 
		let quartzCoreHandle = dlopen(quartzCorePath, RTLD_NOW)
	else { throw SimpleError(message: "Unable to open Quartz Core") }
	defer { dlclose(quartzCoreHandle) }

	guard
		let functionAddress = dlsym(quartzCoreHandle, "CARenderServerSetDebugOption")
	else { throw SimpleError(message: "Unable to retrieve function address for 'CARenderServerSetDebugOption'") }

	typealias functionType = @convention(c) (CInt, CInt, CInt) -> Void

	let actualFunction = unsafeBitCast(functionAddress, to: functionType.self)

	actualFunction(0, option.rawValue, flag ? 1 : 0)
}
#endif
