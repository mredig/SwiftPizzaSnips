import Foundation

public protocol FixedWidthFloatingPoint: BinaryFloatingPoint {
	associatedtype BitRepresentation: FixedWidthInteger
	var bitPattern: BitRepresentation { get }
}

public extension FixedWidthFloatingPoint {
	var bigEndian: BitRepresentation {
		bitPattern.bigEndian
	}
	var littleEndian: BitRepresentation {
		bitPattern.littleEndian
	}
	var leadingZeroBitCount: Int {
		bitPattern.leadingZeroBitCount
	}
	var nonzeroBitCount: Int {
		bitPattern.nonzeroBitCount
	}
	var byteSwapped: BitRepresentation {
		bitPattern.byteSwapped
	}
}

extension Float: FixedWidthFloatingPoint {}
extension Double: FixedWidthFloatingPoint {}
#if arch(arm64) // see Float16 docs
@available(macOS 11.0, iOS 14.0, tvOS 14.0, *)
extension Float16: FixedWidthFloatingPoint {}
#endif
#if arch(x86_64)
//extension Float80: FixedWidthFloatingPoint {}
// There is no UInt80, so there's no `bitPattern` to correlate. 
#endif
