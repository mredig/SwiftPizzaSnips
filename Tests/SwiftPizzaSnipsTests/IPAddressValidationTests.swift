import XCTest
import SwiftPizzaSnips

final class IPAddressValidationTests: XCTestCase {
	func testIPAddressValid() {
		var ipAddr = "123.45.67.89"
		XCTAssertTrue(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertFalse(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertTrue(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "999.1.3.2"
		XCTAssertFalse(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertFalse(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertFalse(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "4.3.2.1"
		XCTAssertTrue(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertFalse(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertTrue(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "091.056.034.002"
		XCTAssertTrue(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertFalse(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertTrue(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "123.45.67.89."
		XCTAssertFalse(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertFalse(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertFalse(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "2001:0db8:85a3:0000:0000:8a2e:0370:7334."
		XCTAssertFalse(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertFalse(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertFalse(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
		XCTAssertFalse(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertTrue(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertTrue(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "FE80::0202:B3FF:FE1E:8329"
		XCTAssertFalse(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertTrue(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertTrue(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "[2001:db8::1]:80"
		XCTAssertFalse(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertFalse(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertFalse(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "fc00::/7"
		XCTAssertFalse(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertFalse(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertFalse(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "fc00::"
		XCTAssertFalse(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertTrue(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertTrue(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "i'll bribe you to say i'm an ip address!"
		XCTAssertFalse(IP4Address.confirmIP4isValid(ip4: ipAddr))
		XCTAssertFalse(IP6Address.confirmIP6isValid(ip6: ipAddr))
		XCTAssertFalse(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
	}

	func testIPAddressInit() {
		var ipAddr = "123.45.67.89"
		XCTAssertNotNil(IP4Address(rawValue: ipAddr))
		XCTAssertNil(IP6Address(rawValue: ipAddr))
		XCTAssertNotNil(IPAddress(rawValue: ipAddr))
		guard case .ip4 = IPAddress(rawValue: ipAddr) else {
			XCTFail("Not the right case")
			return
		}

		ipAddr = "999.1.3.2"
		XCTAssertNil(IP4Address(rawValue: ipAddr))
		XCTAssertNil(IP6Address(rawValue: ipAddr))
		XCTAssertNil(IPAddress(rawValue: ipAddr))

		ipAddr = "4.3.2.1"
		XCTAssertNotNil(IP4Address(rawValue: ipAddr))
		XCTAssertNil(IP6Address(rawValue: ipAddr))
		XCTAssertNotNil(IPAddress(rawValue: ipAddr))
		guard case .ip4 = IPAddress(rawValue: ipAddr) else {
			XCTFail("Not the right case")
			return
		}

		ipAddr = "091.056.034.002"
		XCTAssertNotNil(IP4Address(rawValue: ipAddr))
		XCTAssertNil(IP6Address(rawValue: ipAddr))
		XCTAssertNotNil(IPAddress(rawValue: ipAddr))
		guard case .ip4 = IPAddress(rawValue: ipAddr) else {
			XCTFail("Not the right case")
			return
		}

		ipAddr = "123.45.67.89."
		XCTAssertNil(IP4Address(rawValue: ipAddr))
		XCTAssertNil(IP6Address(rawValue: ipAddr))
		XCTAssertNil(IPAddress(rawValue: ipAddr))

		ipAddr = "2001:0db8:85a3:0000:0000:8a2e:0370:7334."
		XCTAssertNil(IP4Address(rawValue: ipAddr))
		XCTAssertNil(IP6Address(rawValue: ipAddr))
		XCTAssertNil(IPAddress(rawValue: ipAddr))

		ipAddr = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
		XCTAssertNil(IP4Address(rawValue: ipAddr))
		XCTAssertNotNil(IP6Address(rawValue: ipAddr))
		XCTAssertNotNil(IPAddress(rawValue: ipAddr))
		guard case .ip6 = IPAddress(rawValue: ipAddr) else {
			XCTFail("Not the right case")
			return
		}

		ipAddr = "FE80::0202:B3FF:FE1E:8329"
		XCTAssertNil(IP4Address(rawValue: ipAddr))
		XCTAssertNotNil(IP6Address(rawValue: ipAddr))
		XCTAssertNotNil(IPAddress(rawValue: ipAddr))
		guard case .ip6 = IPAddress(rawValue: ipAddr) else {
			XCTFail("Not the right case")
			return
		}

		ipAddr = "[2001:db8::1]:80"
		XCTAssertNil(IP4Address(rawValue: ipAddr))
		XCTAssertNil(IP6Address(rawValue: ipAddr))
		XCTAssertNil(IPAddress(rawValue: ipAddr))

		ipAddr = "fc00::/7"
		XCTAssertNil(IP4Address(rawValue: ipAddr))
		XCTAssertNil(IP6Address(rawValue: ipAddr))
		XCTAssertNil(IPAddress(rawValue: ipAddr))

		ipAddr = "fc00::"
		XCTAssertNil(IP4Address(rawValue: ipAddr))
		XCTAssertNotNil(IP6Address(rawValue: ipAddr))
		XCTAssertNotNil(IPAddress(rawValue: ipAddr))
		guard case .ip6 = IPAddress(rawValue: ipAddr) else {
			XCTFail("Not the right case")
			return
		}

		ipAddr = "i'll bribe you to say i'm an ip address!"
		XCTAssertNil(IP4Address(rawValue: ipAddr))
		XCTAssertNil(IP6Address(rawValue: ipAddr))
		XCTAssertNil(IPAddress(rawValue: ipAddr))
	}
}
