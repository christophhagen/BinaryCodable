// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "BinaryCodable",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v4)],
    products: [
        .library(
            name: "BinaryCodable",
            targets: ["BinaryCodable"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BinaryCodable",
            dependencies: []),
        .testTarget(
            name: "BinaryCodableTests",
            dependencies: ["BinaryCodable"]),
    ],
    swiftLanguageVersions: [.v5]
)
