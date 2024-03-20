import Foundation
import CoreData

@available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
extension CoreDataStack {
	public struct Configuration: Withable {
		public var modelURL: URL
		public var storeOption: StoreOption = .sql(config: nil)
		public var mainContextDefaultMergePolicy: NSMergePolicyType = .errorMergePolicyType

		public var mainContextAutomaticallyMergeChanges = true

		public var newBackgroundContextDefaultMergePolicy: NSMergePolicyType = .errorMergePolicyType

		public init(modelURL: URL) {
			self.modelURL = modelURL
		}

		public enum StoreOption: Withable {
			case inMemory
			case sql(config: SQLConfiguration?)
			case custom((NSPersistentContainer) throws -> Void)

			public static let sqlDefaults: Self = .sql(config: nil)

			public struct SQLConfiguration: Withable {
				var storeURL: URL = NSPersistentContainer.defaultDirectoryURL()
				var modelConfiguration: String?

				/// [more info](https://developer.apple.com/documentation/coredata/nspersistentstorecoordinator/store_options)
				var readOnly: Bool?
				/// [more info](https://developer.apple.com/documentation/coredata/nspersistentstorecoordinator/store_options)
				var pragmas: [String: Any]?
				/// [more info](https://developer.apple.com/documentation/coredata/nspersistentstorecoordinator/store_options)
				var analyze: Bool?
				/// [more info](https://developer.apple.com/documentation/coredata/nspersistentstorecoordinator/store_options)
				var vacuum: Bool?
				#if !os(macOS) && !os(Linux)
				/// [more info](https://developer.apple.com/documentation/coredata/nspersistentstorecoordinator/store_options)
				var protectionKey: FileProtectionType?
				#endif

				public init(
					storeURL: URL = NSPersistentContainer.defaultDirectoryURL()
				) {
					self.storeURL = storeURL
				}
			}
		}
	}
}
