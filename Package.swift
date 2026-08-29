// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GiftUI",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "GiftUI", targets: ["GiftUI"]),
    ],
    targets: [
        .target(name: "GiftUI"),
        .testTarget(
            name: "GiftUITests",
            dependencies: ["GiftUI"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
