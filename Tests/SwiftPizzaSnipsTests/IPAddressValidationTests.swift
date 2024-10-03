import Testing
import SwiftPizzaSnips

struct IPAddressValidationTests {
	@Test func testIPAddressValid() throws {
		var ipAddr = "123.45.67.89"
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr))
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr) == false)
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "999.1.3.2"
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr) == false)
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr) == false)
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr) == false)
		ipAddr = "4.3.2.1"
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr))
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr) == false)
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "091.056.034.002"
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr))
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr) == false)
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "123.45.67.89."
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr) == false)
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr) == false)
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr) == false)
		ipAddr = "2001:0db8:85a3:0000:0000:8a2e:0370:7334."
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr) == false)
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr) == false)
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr) == false)
		ipAddr = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr) == false)
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr))
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "FE80::0202:B3FF:FE1E:8329"
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr) == false)
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr))
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "[2001:db8::1]:80"
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr) == false)
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr) == false)
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr) == false)
		ipAddr = "fc00::/7"
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr) == false)
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr) == false)
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr) == false)
		ipAddr = "fc00::"
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr) == false)
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr))
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr))
		ipAddr = "i'll bribe you to say i'm an ip address!"
		#expect(IP4Address.confirmIP4isValid(ip4: ipAddr) == false)
		#expect(IP6Address.confirmIP6isValid(ip6: ipAddr) == false)
		#expect(IPAddress.confirmIPAddressIsValid(ip: ipAddr) == false)
	}

	@Test func testIPAddressInit() throws {
		var ipAddr = "123.45.67.89"
		#expect(IP4Address(rawValue: ipAddr) != nil)
		#expect(IP6Address(rawValue: ipAddr) == nil)
		#expect(IPAddress(rawValue: ipAddr) != nil)
		guard case .ip4 = IPAddress(rawValue: ipAddr) else {
			Issue.record("Not the right case")
			return
		}

		ipAddr = "999.1.3.2"
		#expect(IP4Address(rawValue: ipAddr) == nil)
		#expect(IP6Address(rawValue: ipAddr) == nil)
		#expect(IPAddress(rawValue: ipAddr) == nil)

		ipAddr = "4.3.2.1"
		#expect(IP4Address(rawValue: ipAddr) != nil)
		#expect(IP6Address(rawValue: ipAddr) == nil)
		#expect(IPAddress(rawValue: ipAddr) != nil)
		guard case .ip4 = IPAddress(rawValue: ipAddr) else {
			Issue.record("Not the right case")
			return
		}

		ipAddr = "091.056.034.002"
		#expect(IP4Address(rawValue: ipAddr) != nil)
		#expect(IP6Address(rawValue: ipAddr) == nil)
		#expect(IPAddress(rawValue: ipAddr) != nil)
		guard case .ip4 = IPAddress(rawValue: ipAddr) else {
			Issue.record("Not the right case")
			return
		}

		ipAddr = "123.45.67.89."
		#expect(IP4Address(rawValue: ipAddr) == nil)
		#expect(IP6Address(rawValue: ipAddr) == nil)
		#expect(IPAddress(rawValue: ipAddr) == nil)

		ipAddr = "2001:0db8:85a3:0000:0000:8a2e:0370:7334."
		#expect(IP4Address(rawValue: ipAddr) == nil)
		#expect(IP6Address(rawValue: ipAddr) == nil)
		#expect(IPAddress(rawValue: ipAddr) == nil)

		ipAddr = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
		#expect(IP4Address(rawValue: ipAddr) == nil)
		#expect(IP6Address(rawValue: ipAddr) != nil)
		#expect(IPAddress(rawValue: ipAddr) != nil)
		guard case .ip6 = IPAddress(rawValue: ipAddr) else {
			Issue.record("Not the right case")
			return
		}

		ipAddr = "FE80::0202:B3FF:FE1E:8329"
		#expect(IP4Address(rawValue: ipAddr) == nil)
		#expect(IP6Address(rawValue: ipAddr) != nil)
		#expect(IPAddress(rawValue: ipAddr) != nil)
		guard case .ip6 = IPAddress(rawValue: ipAddr) else {
			Issue.record("Not the right case")
			return
		}

		ipAddr = "[2001:db8::1]:80"
		#expect(IP4Address(rawValue: ipAddr) == nil)
		#expect(IP6Address(rawValue: ipAddr) == nil)
		#expect(IPAddress(rawValue: ipAddr) == nil)

		ipAddr = "fc00::/7"
		#expect(IP4Address(rawValue: ipAddr) == nil)
		#expect(IP6Address(rawValue: ipAddr) == nil)
		#expect(IPAddress(rawValue: ipAddr) == nil)

		ipAddr = "fc00::"
		#expect(IP4Address(rawValue: ipAddr) == nil)
		#expect(IP6Address(rawValue: ipAddr) != nil)
		#expect(IPAddress(rawValue: ipAddr) != nil)
		guard case .ip6 = IPAddress(rawValue: ipAddr) else {
			Issue.record("Not the right case")
			return
		}

		ipAddr = "i'll bribe you to say i'm an ip address!"
		#expect(IP4Address(rawValue: ipAddr) == nil)
		#expect(IP6Address(rawValue: ipAddr) == nil)
		#expect(IPAddress(rawValue: ipAddr) == nil)
	}
}
