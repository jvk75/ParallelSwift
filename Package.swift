// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ParallelSwift",
    products: [
        .library(
            name: "ParallelSwift",
            targets: ["ParallelSwift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ParallelSwift",
            dependencies: []),
        .testTarget(
            name: "ParallelSwiftTests",
            dependencies: ["ParallelSwift"]),
    ]
)
