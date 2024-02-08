import Foundation

#if DEBUG
public func getAllMethodNames(for class: AnyObject.Type?) {
	var methodCount: UInt32 = 0
	let methods = class_copyMethodList(`class`, &methodCount)
	for i in 0..<Int(methodCount) {
		guard
			let method = methods?.advanced(by: i).pointee
		else { continue }
		let methodName = NSStringFromSelector(method_getName(method))

		print(methodName)
	}
}

private func getPropertyType(for property: objc_property_t) -> String? {
	guard
		let attributesChars = property_getAttributes(property)
	else { return nil }
	let attributes = String(validatingUTF8: attributesChars)
	return attributes
}

public func getAllPropertyNames(for class: AnyObject.Type?) {
	var count: Int32 = 0
	let properties = class_copyPropertyList(`class`, &count)
	for i in 0..<Int(count) {
		guard
			let property = properties?.advanced(by: i).pointee
		else { continue }
		let propertyNameChars = property_getName(property)
		guard
			let propertyName = String(validatingUTF8: propertyNameChars)
		else { continue }
		if let typeInfo = getPropertyType(for: property) {
			print("\(typeInfo): ", terminator: "")
		}
		print(propertyName)
	}
}

public func getAllIVars(for class: AnyObject.Type?) {
	var count: Int32 = 0
	let ivars = class_copyIvarList(`class`, &count)
	for i in 0..<Int(count) {
		guard
			let ivar = ivars?.advanced(by: i).pointee
		else { continue }
		guard
			let ivarNameChars = ivar_getName(ivar),
			let ivarEncodingChars = ivar_getTypeEncoding(ivar),
			let ivarName = String(validatingUTF8: ivarNameChars),
			let ivarEncoding = String(validatingUTF8: ivarEncodingChars)
		else {
			print("missing info on \(ivar)")
			continue
		}

		print("\(ivarEncoding): \(ivarName)")
	}
}

public func getProtocolConformances(for class: AnyObject.Type?) {
	var count: Int32 = 0
	let protocols = class_copyProtocolList(`class`, &count)
	for i in 0..<Int(count) {
		guard
			let prot = protocols?.advanced(by: i).pointee
		else { continue }

		let protNameChars = protocol_getName(prot)

		guard
			let protName = String(validatingUTF8: protNameChars)
		else { continue }
		print(protName)
	}
}
#endif
