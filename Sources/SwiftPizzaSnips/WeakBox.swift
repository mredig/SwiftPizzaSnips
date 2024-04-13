import Foundation

public class WeakBox<T: AnyObject> {
	public weak var content: T?

	public init(content: T?) {
		self.content = content
	}
}

extension WeakBox: Equatable where T: Equatable {
	public static func == (lhs: WeakBox<T>, rhs: WeakBox<T>) -> Bool {
		lhs.content == rhs.content
	}
}
extension WeakBox: Hashable where T: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(content)
	}
}
