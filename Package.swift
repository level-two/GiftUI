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
        .library(name: "GiftUIPlatformLinux", targets: ["GiftUIPlatformLinux"]),
        .library(
            name: "GiftUIPlatformRaspberryPi",
            targets: ["GiftUIPlatformRaspberryPi"]
        ),
        .library(
            name: "GiftUIExampleThermostatView",
            targets: ["GiftUIExampleThermostatView"]
        ),
        .executable(name: "GiftUIExampleThermostat", targets: ["GiftUIExampleThermostat"]),
        .executable(
            name: "GiftUIExampleThermostatRaspberryPi",
            targets: ["GiftUIExampleThermostatRaspberryPi"]
        ),
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
        .target(
            name: "CGiftUILinux",
            publicHeadersPath: "include"
        ),
        .target(
            name: "GiftUIPlatformLinux",
            dependencies: [
                "GiftUI",
                "GiftUIBackendFramebuffer",
                "GiftUIRuntimeDynamic",
                "CGiftUILinux",
            ]
        ),
        .target(
            name: "GiftUIPlatformRaspberryPi",
            dependencies: [
                "GiftUI",
                "GiftUIPlatformLinux",
            ]
        ),
        .target(
            name: "GiftUIExampleThermostatView",
            dependencies: ["GiftUI"]
        ),
        .executableTarget(
            name: "GiftUIExampleThermostat",
            dependencies: [
                "GiftUI",
                "GiftUIExampleThermostatView",
                "GiftUISimulatorMac",
            ]
        ),
        .executableTarget(
            name: "GiftUIExampleThermostatRaspberryPi",
            dependencies: [
                "GiftUIExampleThermostatView",
                "GiftUIPlatformRaspberryPi",
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
        .testTarget(
            name: "GiftUIPlatformLinuxTests",
            dependencies: [
                "GiftUI",
                "GiftUIBackendFramebuffer",
                "GiftUIPlatformLinux",
            ]
        ),
        .testTarget(
            name: "GiftUIPlatformRaspberryPiTests",
            dependencies: ["GiftUIPlatformRaspberryPi"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
