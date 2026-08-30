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
        .library(
            name: "GiftUIFailureDiagnostics",
            targets: ["GiftUIFailureDiagnostics"]
        ),
        .library(name: "GiftUICapabilities", targets: ["GiftUICapabilities"]),
    ],
    targets: [
        .target(name: "GiftUI"),
        .target(name: "GiftUIFailureCore"),
        .target(
            name: "GiftUIFailureDiagnostics",
            dependencies: ["GiftUIFailureCore"]
        ),
        .target(name: "GiftUICapabilities"),
        .testTarget(
            name: "GiftUITests",
            dependencies: ["GiftUI"]
        ),
        .testTarget(
            name: "GiftUIFailureCoreTests",
            dependencies: ["GiftUIFailureCore"]
        ),
        .testTarget(
            name: "GiftUIFoundationFailureAdapterTests",
            dependencies: ["GiftUI", "GiftUIFailureCore"]
        ),
        .testTarget(
            name: "GiftUIFailureDiagnosticsTests",
            dependencies: ["GiftUIFailureDiagnostics"]
        ),
        .testTarget(
            name: "GiftUICapabilitiesTests",
            dependencies: ["GiftUICapabilities"]
        ),
        .testTarget(
            name: "GiftUICapabilityAdapterTests",
            dependencies: ["GiftUI", "GiftUICapabilities"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
