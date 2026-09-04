// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "GiftUIToolchainProbe",
    products: [
        .executable(
            name: "GiftUIToolchainProbe",
            targets: ["GiftUIToolchainProbe"]
        )
    ],
    targets: [
        .executableTarget(name: "GiftUIToolchainProbe")
    ]
)
