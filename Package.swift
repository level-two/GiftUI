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
        .library(name: "GiftUIBackendRGB565", targets: ["GiftUIBackendRGB565"]),
        .library(name: "GiftUIInputADS7846", targets: ["GiftUIInputADS7846"]),
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
        .library(
            name: "GiftUIExampleThermostatPortableView",
            targets: ["GiftUIExampleThermostatPortableView"]
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
        .target(name: "GiftUIBuiltinFont"),
        .target(
            name: "GiftUIBackendFramebuffer",
            dependencies: [
                "GiftUI",
                "GiftUIBuiltinFont",
            ]
        ),
        .target(
            name: "GiftUIBackendRGB565",
            dependencies: [
                "GiftUI",
                "GiftUIBuiltinFont",
            ]
        ),
        .target(
            name: "GiftUIInputADS7846",
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
                "GiftUIBackendRGB565",
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
                "GiftUIRuntimeDynamic",
            ]
        ),
        .target(
            name: "GiftUIExampleThermostatPortableView",
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
                "GiftUIRuntimeDynamic",
            ]
        ),
        .testTarget(
            name: "GiftUIBackendFramebufferTests",
            dependencies: ["GiftUIBackendFramebuffer"]
        ),
        .testTarget(
            name: "GiftUIBackendRGB565Tests",
            dependencies: [
                "GiftUIBackendFramebuffer",
                "GiftUIBackendRGB565",
                "GiftUIExampleThermostatPortableView",
                "GiftUIRuntimeStatic",
            ]
        ),
        .testTarget(
            name: "GiftUIInputADS7846Tests",
            dependencies: [
                "GiftUIExampleThermostatPortableView",
                "GiftUIInputADS7846",
                "GiftUIRuntimeStatic",
            ]
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
            name: "GiftUIRuntimeConformanceTests",
            dependencies: [
                "GiftUIExampleThermostatPortableView",
                "GiftUIRuntimeDynamic",
                "GiftUIRuntimeStatic",
            ]
        ),
        .testTarget(
            name: "GiftUIPlatformLinuxTests",
            dependencies: [
                "GiftUI",
                "GiftUIBackendFramebuffer",
                "GiftUIBackendRGB565",
                "GiftUIDynamicConveniences",
                "GiftUIPlatformLinux",
                "GiftUIRuntimeDynamic",
            ]
        ),
        .testTarget(
            name: "GiftUIPlatformRaspberryPiTests",
            dependencies: ["GiftUIPlatformRaspberryPi"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
