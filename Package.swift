// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UUSwift",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_15)
    ],
    
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "UUSwift",
            targets: ["UUSwift"]),
    ],
	dependencies: [
		// Here we define our package's external dependencies
		// and from where they can be fetched:
		.package(
			url: "https://github.com/SilverPineSoftware/UUSwiftCore.git",
			from: "1.1.3"
		),
		.package(
			url: "https://github.com/SilverPineSoftware/UUSwiftUX.git",
			from: "1.0.7"
		),
		.package(
			url: "https://github.com/SilverPineSoftware/UUSwiftImage.git",
			from: "1.1.2"
		),
		.package(
			url: "https://github.com/SilverPineSoftware/UUSwiftNetworking.git",
			from: "1.0.9"
		)
	],

    targets: [
        .target(
            name: "UUSwift",
            dependencies: ["UUSwiftCore", "UUSwiftUX", "UUSwiftImage", "UUSwiftNetworking" ],
            path: "UUSwift",
            exclude: ["Info.plist"])
    ],
    swiftLanguageVersions: [
            .v4_2,
            .v5
    ]
)

