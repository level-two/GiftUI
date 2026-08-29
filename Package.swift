// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GiftUI",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "GiftUI", targets: ["GiftUI"]),
        .library(name: "GiftUIFailureCore", targets: ["GiftUIFailureCore"]),
    ],
    targets: [
        .target(name: "GiftUI"),
        .target(name: "GiftUIFailureCore"),
        .testTarget(
            name: "GiftUITests",
            dependencies: ["GiftUI"]
        ),
        .testTarget(
            name: "GiftUIFailureCoreTests",
            dependencies: ["GiftUIFailureCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
