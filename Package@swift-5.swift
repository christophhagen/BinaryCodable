// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "BinaryCodable",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v4)],
    products: [
        .library(
            name: "BinaryCodable",
            targets: ["BinaryCodable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.5")
    ],
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
