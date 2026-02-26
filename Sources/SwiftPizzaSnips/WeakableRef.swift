/// for when a protocol or generic type may or may not be a class/reference semantic, but it contains a back reference to the object it's a property on.
/// if it IS a class, it can't be made `weak` because the protocol doesn't (can't probably) be constrained to class types only
/// this instead creates a closure that captures the object, weakly if it's a class.
///
/// Scenario where you might want to use this:
/// ```swift
/// class SomeGenericType<Parent> {
/// 	// can't be weak cuz `Parent` is NOT class bound
/// 	@WeakableRef
///		var parentBackref: Parent?
///	}
///
///	class ClassParent {
///		let concrete: SomeGenericType<ClassParent>
///
///		init() {
///			self.concrete = .init()
///
///			self.concrete.parentBackref = self
///		}
///	}
///
///	struct StructParent {
///		let concrete: SomeGenericType<StructParent>
///
///		init() {
///			self.concrete = .init()
///
///			self.concrete.parentBackref = self
///		}
///	}
///	```
@propertyWrapper
public struct WeakableRef<T> {
	private var _wrappedValue: () -> T?

	public var wrappedValue: T? {
		get { _wrappedValue() }
		set {
			if T.self is AnyObject.Type {
				let reference = newValue as AnyObject

				_wrappedValue = { [weak reference] in reference as? T }
			} else {
				_wrappedValue = { newValue }
			}
		}
	}

	public init(wrappedValue: T?) {
		_wrappedValue = { nil }
		self.wrappedValue = wrappedValue
	}
}
