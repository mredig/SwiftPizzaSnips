// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let snipsExcludes: [String]
let testsExcludes: [String]
let testResources: [Resource]
let dependencies: [Package.Dependency]
#if canImport(FoundationNetworking)
snipsExcludes = ["CoreData"]
testsExcludes = ["Foo.xcdatamodeld"]
testResources = [.copy("sample.bin")]
dependencies = [
	.package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "3.7.0")),
]
#else
snipsExcludes = []
testsExcludes = []
testResources = [
	.copy("sample.bin"),
	.process("Foo.xcdatamodeld")
]
dependencies = []
#endif

let package = Package(
    name: "SwiftPizzaSnips",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftPizzaSnips",
            targets: ["SwiftPizzaSnips"]),
    ],
	dependencies: dependencies,
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "SPSLinuxSupport"),
        .target(
            name: "SwiftPizzaSnips",
			dependencies: [
				.targetItem(
					name: "SPSLinuxSupport",
					condition: .when(platforms: [.linux, .windows, .openbsd, .android]))
			],
			exclude: snipsExcludes,
			swiftSettings: [
				.enableUpcomingFeature("BareSlashRegexLiterals"),
			]),
        .testTarget(
            name: "SwiftPizzaSnipsTests",
            dependencies: ["SwiftPizzaSnips"],
			exclude: testsExcludes,
			resources: testResources,
			swiftSettings: [
				.enableUpcomingFeature("BareSlashRegexLiterals"),
			]),
    ]
)
