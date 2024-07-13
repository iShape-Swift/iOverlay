// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "iOverlay",
    products: [
        .library(
            name: "iOverlay",
            targets: ["iOverlay"]),
    ],
    dependencies: [
        .package(url: "https://github.com/iShape-Swift/iFixFloat", .upToNextMajor(from: "1.7.0")),
        .package(url: "https://github.com/iShape-Swift/iShape", .upToNextMajor(from: "1.12.0")),
        .package(url: "https://github.com/iShape-Swift/iTree", .upToNextMajor(from: "0.5.0")),
//        .package(path: "../iTree"),
//        .package(path: "../iFixFloat"),
//        .package(path: "../iShape")
    ],
    targets: [
        .target(
            name: "iOverlay",
            dependencies: ["iFixFloat", "iShape", "iTree"]),
        .testTarget(
            name: "iOverlayTests",
            dependencies: ["iOverlay"],
            resources: [
                .process("Overlay")
            ])
    ]
)
