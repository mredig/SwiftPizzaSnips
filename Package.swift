// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let snipsExcludes: [String]
let testsExcludes: [String]
let testResources: [Resource]
let dependencies: [Package.Dependency]
let spsDeps: [Target.Dependency]
#if canImport(FoundationNetworking)
snipsExcludes = ["CoreData"]
testsExcludes = ["Foo.xcdatamodeld"]
testResources = [.copy("sample.bin")]
dependencies = [
	.package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "3.7.0")),
]
spsDeps = [
	.targetItem(
		name: "SPSLinuxSupport",
		condition: .when(platforms: [.linux, .windows, .openbsd, .android]))
]
#else
snipsExcludes = []
testsExcludes = []
testResources = [
	.copy("sample.bin"),
	.process("Foo.xcdatamodeld")
]
dependencies = []
spsDeps = []
#endif

var targets: [Target] = [
	.target(
		name: "SwiftPizzaSnips",
		dependencies: spsDeps,
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

#if canImport(FoundationNetworking)
targets.append(
	.target(
		name: "SPSLinuxSupport",
		dependencies: [
			.product(name: "Crypto", package: "swift-crypto")
		]))
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
	targets: targets)
