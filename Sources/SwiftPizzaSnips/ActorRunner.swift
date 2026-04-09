@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public protocol ActorRunner: Actor {}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
extension ActorRunner {
	public func runIsloated<Success: Sendable, Failure: Error>(_ block: @Sendable (isolated Self) throws(Failure) -> Success) throws(Failure) -> Success {
		try block(self)
	}
}
