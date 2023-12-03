import Foundation

public struct IP4Address: RawRepresentable, Codable, Hashable {
	public let rawValue: String

	public init?(rawValue: String) {
		guard
			Self.confirmIP4isValid(ip4: rawValue)
		else { return nil }
		self.rawValue = rawValue
	}

	public static func confirmIP4isValid(ip4: String) -> Bool {
		var sin = sockaddr_in()
		return ip4.withCString { cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) } == 1
	}
}

public struct IP6Address: RawRepresentable {
	public let rawValue: String

	public init?(rawValue: String) {
		guard
			Self.confirmIP6isValid(ip6: rawValue)
		else { return nil }
		self.rawValue = rawValue
	}

	public static func confirmIP6isValid(ip6: String) -> Bool {
		var sin6 = sockaddr_in6()
		return ip6.withCString { cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) } == 1
	}
}


public enum IPAddress {
	case ip4(IP4Address)
	case ip6(IP6Address)

	public init?(rawValue: String) {
		if let ip4 = IP4Address(rawValue: rawValue) {
			self = .ip4(ip4)
		} else if let ip6 = IP6Address(rawValue: rawValue) {
			self = .ip6(ip6)
		} else {
			return nil
		}
	}

	public static func confirmIPAddressIsValid(ip: String) -> Bool {
		IP4Address.confirmIP4isValid(ip4: ip) || IP6Address.confirmIP6isValid(ip6: ip)
	}
}
