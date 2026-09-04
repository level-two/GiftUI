// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GiftUI",
    platforms: [
        .macOS(.v15)
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
        .target(
            name: "GiftUITextResources",
            dependencies: ["GiftUI"]
        ),
        .target(
            name: "GiftUIReferenceTextResources",
            dependencies: ["GiftUI", "GiftUITextResources"],
            exclude: ["Generated/generation-manifest.json"]
        ),
        .target(
            name: "GiftUITextResourceFailureAdapterFixture",
            dependencies: ["GiftUIFailureCore", "GiftUITextResources"]
        ),
        .target(
            name: "GiftUICapabilityFailureAdapterFixture",
            dependencies: ["GiftUICapabilities", "GiftUIFailureCore"]
        ),
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
            dependencies: ["GiftUIFailureCore", "GiftUIFailureDiagnostics"]
        ),
        .testTarget(
            name: "GiftUICapabilitiesTests",
            dependencies: ["GiftUICapabilities"]
        ),
        .testTarget(
            name: "GiftUITextResourcesTests",
            dependencies: ["GiftUI", "GiftUITextResources"]
        ),
        .testTarget(
            name: "GiftUIReferenceTextResourcesTests",
            dependencies: [
                "GiftUI",
                "GiftUIReferenceTextResources",
                "GiftUITextResources",
            ]
        ),
        .testTarget(
            name: "GiftUITextResourceOwnerAdapterTests",
            dependencies: [
                "GiftUIFailureCore",
                "GiftUIFailureDiagnostics",
                "GiftUITextResourceFailureAdapterFixture",
                "GiftUITextResources",
            ]
        ),
        .testTarget(
            name: "GiftUICapabilityAdapterTests",
            dependencies: ["GiftUI", "GiftUICapabilities"]
        ),
        .testTarget(
            name: "GiftUICapabilityFailureAdapterTests",
            dependencies: [
                "GiftUICapabilityFailureAdapterFixture",
                "GiftUICapabilities",
                "GiftUIFailureCore",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
