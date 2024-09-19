import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
public extension DefaultsManager {
	private static var migrations: [Migration] = []

	package static func clearMigrations() {
		migrations.removeAll()
	}

	/// Be sure to run these as *early* as possible in your app. Probably in `appDidFinishLaunching`, but earlier if you access DefaultsManager prior.
	/// Also, in case you're unfamiliar with the concept of migrations, NEVER delete previous migrations. ALWAYS just add additional migrations.
	/// Finally, after you've added all your migrations, run `runMigrations` prior to any `DefaultsManager.shared` usage! (yes,
	/// you can use `DefaultsManager.shared` in your migrations)
	static func addMigration(_ migration: Migration) {
		migrations.append(migration)
	}

	/// Make sure to add all your migrations (`addMigration()`) prior to calling this, and make sure you call this prior to
	/// any `DefaultsManager.shared` usage!
	static func runMigrations() {
		let lastRunMigration = DefaultsManager.shared[.defaultsVersion]

		let migrations = migrations
			.filter {
				Int($0.migrationVersion) > lastRunMigration
			}
			.sorted(by: { a, b in
				a.migrationVersion < b.migrationVersion
			})

		for migration in migrations {
			migration.onMigrate()
			DefaultsManager.shared[.defaultsVersion] = Int(migration.migrationVersion)
		}
	}

	struct Migration {
		/// Serves for both ordering and checkpoints. Every time you add a new migration, the newer migration should be incremented by one from the previous.
		///
		public let migrationVersion: UInt32

		public let onMigrate: () -> Void

		public init(migrationVersion: UInt32, onMigrate: @escaping () -> Void) {
			self.migrationVersion = migrationVersion
			self.onMigrate = onMigrate
		}
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6, *)
extension DefaultsManager.KeyWithDefault where Value == Int, StoredValue == Int {
	static let defaultsVersion = Self(
		"com.pizzaSnips.defaultsVersion",
		defaultValue: -1)
}
