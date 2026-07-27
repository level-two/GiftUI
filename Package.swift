// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "GiftUI",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "GiftUI", targets: ["GiftUI"]),
        .library(
            name: "GiftUIDynamicConveniences",
            targets: ["GiftUIDynamicConveniences"]
        ),
        .library(name: "GiftUIRuntimeDynamic", targets: ["GiftUIRuntimeDynamic"]),
        .library(name: "GiftUIRuntimeStatic", targets: ["GiftUIRuntimeStatic"]),
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
            name: "GiftUIDynamicConveniences",
            dependencies: ["GiftUI"]
        ),
        .target(
            name: "GiftUIRuntimeDynamic",
            dependencies: ["GiftUI"]
        ),
        .target(
            name: "GiftUIRuntimeStatic",
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
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedLibrary("dl", .when(platforms: [.linux])),
            ]
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
                "CGiftUILinux",
            ]
        ),
        .target(
            name: "GiftUIExampleThermostatView",
            dependencies: [
                "GiftUI",
                "GiftUIDynamicConveniences",
            ]
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
            dependencies: [
                "GiftUIDynamicConveniences",
                "GiftUIRuntimeDynamic",
            ]
        ),
        .testTarget(
            name: "GiftUIRuntimeStaticTests",
            dependencies: ["GiftUIRuntimeStatic"]
        ),
        .testTarget(
            name: "GiftUIDynamicConveniencesTests",
            dependencies: [
                "GiftUI",
                "GiftUIDynamicConveniences",
            ]
        ),
        .testTarget(
            name: "GiftUIBackendFramebufferTests",
            dependencies: ["GiftUIBackendFramebuffer"]
        ),
        .testTarget(
            name: "GiftUIIntegrationTests",
            dependencies: [
                "GiftUI",
                "GiftUIDynamicConveniences",
                "GiftUIRuntimeDynamic",
                "GiftUIBackendFramebuffer",
            ]
        ),
        .testTarget(
            name: "GiftUIPlatformLinuxTests",
            dependencies: [
                "GiftUI",
                "GiftUIBackendFramebuffer",
                "GiftUIDynamicConveniences",
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
