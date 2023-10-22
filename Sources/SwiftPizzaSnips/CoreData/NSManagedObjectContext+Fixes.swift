import Foundation
import CoreData

extension NSManagedObjectContext {
	/// Just a wrapper around `mergePolicy` that is much easier to use
	public var mergeConflictResolutionPolicy: NSMergePolicyType? {
		get {
			guard let mergePolicy = mergePolicy as? NSMergePolicy else { return nil }
			switch mergePolicy {
			case NSErrorMergePolicy as? NSMergePolicy:
				return .errorMergePolicyType
			case NSMergeByPropertyStoreTrumpMergePolicy as? NSMergePolicy:
				return .mergeByPropertyStoreTrumpMergePolicyType
			case NSMergeByPropertyObjectTrumpMergePolicy as? NSMergePolicy:
				return .mergeByPropertyObjectTrumpMergePolicyType
			case NSOverwriteMergePolicy as? NSMergePolicy:
				return .overwriteMergePolicyType
			case NSRollbackMergePolicy as? NSMergePolicy:
				return .rollbackMergePolicyType
			default:
				return nil
			}
		}
		set {
			guard let newValue else {
				return
			}
			switch newValue {
			case .errorMergePolicyType:
				mergePolicy = NSErrorMergePolicy
			case .mergeByPropertyStoreTrumpMergePolicyType:
				mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
			case .mergeByPropertyObjectTrumpMergePolicyType:
				mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
			case .overwriteMergePolicyType:
				mergePolicy = NSOverwriteMergePolicy
			case .rollbackMergePolicyType:
				mergePolicy = NSRollbackMergePolicy
			@unknown default:
				print("Unknown error policy - use `mergePolicy` for now. No change made.")
			}
		}
	}

	public func noThrowSave(file: StaticString = #file, line: UInt = #line) {
		do {
			try save()
		} catch {
			print("Error saving core data context (\(line):\(file)) - \(error)")
		}
	}
}

