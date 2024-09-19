#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
public typealias Bag = Set<AnyCancellable>
#endif
