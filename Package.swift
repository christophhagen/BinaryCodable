// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BinaryCodable",
    platforms: [.macOS(.v10_13), .iOS(.v12), .tvOS(.v12), .watchOS(.v4)],
    products: [
        .library(
            name: "BinaryCodable",
            targets: ["BinaryCodable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "BinaryCodable",
            dependencies: []),
        .testTarget(
            name: "BinaryCodableTests",
            dependencies: ["BinaryCodable"]),
    ],
    swiftLanguageModes: [.v6]
)
