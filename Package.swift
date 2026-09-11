// swift-tools-version: 6.2

import CompilerPluginSupport
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
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            exact: "603.0.2"
        )
    ],
    targets: [
        .macro(
            name: "GiftUIMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(name: "GiftUI", dependencies: ["GiftUIMacros"]),
        .target(name: "GiftUIFailureCore"),
        .target(
            name: "GiftUIFailureDiagnostics",
            dependencies: ["GiftUIFailureCore"]
        ),
        .target(name: "GiftUICapabilities"),
        .target(
            name: "GiftUISemanticCore",
            dependencies: ["GiftUI"]
        ),
        .target(
            name: "GiftUITextResources",
            dependencies: ["GiftUI"]
        ),
        .target(
            name: "GiftUILayout",
            dependencies: ["GiftUI", "GiftUISemanticCore", "GiftUITextResources"]
        ),
        .target(
            name: "GiftUILayoutFailureAdapterFixture",
            dependencies: ["GiftUIFailureCore", "GiftUILayout"]
        ),
        .target(
            name: "GiftUIRenderCore",
            dependencies: ["GiftUI", "GiftUITextResources"]
        ),
        .target(
            name: "GiftUIRenderLowering",
            dependencies: [
                "GiftUI",
                "GiftUISemanticCore",
                "GiftUILayout",
                "GiftUITextResources",
                "GiftUIRenderCore",
            ]
        ),
        .target(
            name: "GiftUIExecution",
            dependencies: ["GiftUI", "GiftUIRenderCore"]
        ),
        .target(
            name: "GiftUIFailureExecution",
            dependencies: ["GiftUIFailureCore", "GiftUIExecution"]
        ),
        .target(
            name: "GiftUIObservableState",
            dependencies: ["GiftUI", "GiftUISemanticCore", "GiftUIExecution"]
        ),
        .target(
            name: "GiftUIObservableStateFailureAdapterFixture",
            dependencies: ["GiftUIFailureCore", "GiftUIObservableState"]
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
        .target(
            name: "GiftUISemanticFailureAdapterFixture",
            dependencies: ["GiftUIFailureCore", "GiftUISemanticCore"]
        ),
        .testTarget(
            name: "GiftUITests",
            dependencies: ["GiftUI"]
        ),
        .testTarget(
            name: "GiftUIMacrosTests",
            dependencies: [
                "GiftUIMacros",
                .product(
                    name: "SwiftSyntaxMacrosTestSupport",
                    package: "swift-syntax"
                ),
            ]
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
            name: "GiftUISemanticCoreTests",
            dependencies: ["GiftUI", "GiftUIObservableState", "GiftUISemanticCore"]
        ),
        .testTarget(
            name: "GiftUITextResourcesTests",
            dependencies: ["GiftUI", "GiftUITextResources"]
        ),
        .testTarget(
            name: "GiftUILayoutTests",
            dependencies: [
                "GiftUI",
                "GiftUILayout",
                "GiftUIReferenceTextResources",
                "GiftUISemanticCore",
                "GiftUITextResources",
            ]
        ),
        .testTarget(
            name: "GiftUILayoutFailureAdapterTests",
            dependencies: [
                "GiftUIFailureCore",
                "GiftUILayout",
                "GiftUILayoutFailureAdapterFixture",
            ]
        ),
        .testTarget(
            name: "GiftUIRenderCoreTests",
            dependencies: ["GiftUI", "GiftUIRenderCore", "GiftUITextResources"]
        ),
        .testTarget(
            name: "GiftUIRenderLoweringTests",
            dependencies: [
                "GiftUI",
                "GiftUILayout",
                "GiftUIRenderCore",
                "GiftUIRenderLowering",
                "GiftUISemanticCore",
                "GiftUITextResources",
            ]
        ),
        .testTarget(
            name: "GiftUIExecutionTests",
            dependencies: ["GiftUI", "GiftUIExecution", "GiftUIRenderCore"]
        ),
        .testTarget(
            name: "GiftUIFailureExecutionTests",
            dependencies: [
                "GiftUIExecution",
                "GiftUIFailureCore",
                "GiftUIFailureDiagnostics",
                "GiftUIFailureExecution",
                "GiftUIRenderCore",
            ]
        ),
        .testTarget(
            name: "GiftUIObservableStateTests",
            dependencies: [
                "GiftUI",
                "GiftUISemanticCore",
                "GiftUIExecution",
                "GiftUIObservableState",
            ]
        ),
        .testTarget(
            name: "GiftUIObservableStateFailureAdapterTests",
            dependencies: [
                "GiftUIFailureCore",
                "GiftUIFailureDiagnostics",
                "GiftUIObservableState",
                "GiftUIObservableStateFailureAdapterFixture",
            ]
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
        .testTarget(
            name: "GiftUISemanticFailureAdapterTests",
            dependencies: [
                "GiftUIFailureCore",
                "GiftUISemanticCore",
                "GiftUISemanticFailureAdapterFixture",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
