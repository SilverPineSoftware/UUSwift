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
    targets: [
        .target(
            name: "UUSwift",
            dependencies: [],
            path: "UUSwift",
            exclude: ["UUSwift-Info.plist"])
    ],
    swiftLanguageVersions: [
            .v4_2,
            .v5
    ]
)
