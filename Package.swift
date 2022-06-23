// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "BinaryCodable",
    products: [
        .library(
            name: "BinaryCodable",
            targets: ["BinaryCodable"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "BinaryCodable",
            dependencies: []),
        .testTarget(
            name: "BinaryCodableTests",
            dependencies: ["BinaryCodable"]),
    ]
)
