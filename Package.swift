// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "GiftUI",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "GiftUI", targets: ["GiftUI"]),
        .library(name: "GiftUIRuntimeDynamic", targets: ["GiftUIRuntimeDynamic"]),
        .library(name: "GiftUIBackendFramebuffer", targets: ["GiftUIBackendFramebuffer"]),
        .library(name: "GiftUISimulatorMac", targets: ["GiftUISimulatorMac"]),
        .executable(name: "GiftUIExampleThermostat", targets: ["GiftUIExampleThermostat"]),
    ],
    targets: [
        .target(name: "GiftUI"),
        .target(
            name: "GiftUIRuntimeDynamic",
            dependencies: ["GiftUI"]
        ),
        .target(
            name: "GiftUIBackendFramebuffer",
            dependencies: ["GiftUI"]
        ),
        .target(
            name: "GiftUISimulatorMac",
            dependencies: [
                "GiftUI",
                "GiftUIBackendFramebuffer",
                "GiftUIRuntimeDynamic",
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("CoreGraphics"),
            ]
        ),
        .executableTarget(
            name: "GiftUIExampleThermostat",
            dependencies: [
                "GiftUI",
                "GiftUIRuntimeDynamic",
                "GiftUIBackendFramebuffer",
                "GiftUISimulatorMac",
            ]
        ),
        .testTarget(
            name: "GiftUITests",
            dependencies: ["GiftUI"]
        ),
        .testTarget(
            name: "GiftUIRuntimeDynamicTests",
            dependencies: ["GiftUIRuntimeDynamic"]
        ),
        .testTarget(
            name: "GiftUIBackendFramebufferTests",
            dependencies: ["GiftUIBackendFramebuffer"]
        ),
        .testTarget(
            name: "GiftUIIntegrationTests",
            dependencies: [
                "GiftUI",
                "GiftUIRuntimeDynamic",
                "GiftUIBackendFramebuffer",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
