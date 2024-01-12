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
//        .package(url: "https://github.com/iShape-Swift/iFixFloat", from: "1.2.0"),
//        .package(url: "https://github.com/iShape-Swift/iShape", from: "1.3.0")
        .package(path: "../iFixFloat"),
        .package(path: "../iShape"),
    ],
    targets: [
        .target(
            name: "iOverlay",
            dependencies: ["iFixFloat", "iShape"]),
        .testTarget(
            name: "iOverlayTests",
            dependencies: ["iOverlay"],
            resources: [
                .process("Overlay")
            ])
    ]
)
