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
        .library(
            name: "GiftUIDynamicConveniences",
            targets: ["GiftUIDynamicConveniences"]
        ),
        .library(name: "SignalAnalyzerDomain", targets: ["SignalAnalyzerDomain"]),
        .library(name: "SignalAnalyzerData", targets: ["SignalAnalyzerData"]),
        .library(
            name: "SignalAnalyzerPresentation",
            targets: ["SignalAnalyzerPresentation"]
        ),
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
            name: "GiftUIDynamicConveniences",
            dependencies: ["GiftUI"]
        ),
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
            name: "GiftUISurfaceCore",
            dependencies: ["GiftUI", "GiftUICapabilities", "GiftUIRenderCore"]
        ),
        .target(
            name: "GiftUIRasterCore",
            dependencies: [
                "GiftUI",
                "GiftUICapabilities",
                "GiftUIRenderCore",
                "GiftUISurfaceCore",
                "GiftUITextResources",
            ]
        ),
        .target(
            name: "GiftUIDisplayCore",
            dependencies: [
                "GiftUI",
                "GiftUICapabilities",
                "GiftUIFailureCore",
                "GiftUISurfaceCore",
            ]
        ),
        .target(
            name: "GiftUIBackendIntegration",
            dependencies: [
                "GiftUICapabilities",
                "GiftUIDisplayCore",
                "GiftUIExecution",
                "GiftUIFailureCore",
                "GiftUIRasterCore",
                "GiftUIRenderCore",
                "GiftUISurfaceCore",
                "GiftUITextResources",
            ]
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
            name: "GiftUIRenderFailureAdapterFixture",
            dependencies: ["GiftUIFailureCore", "GiftUIRenderLowering"]
        ),
        .target(
            name: "GiftUIDrawing",
            dependencies: [
                "GiftUI",
                "GiftUISemanticCore",
                "GiftUILayout",
                "GiftUIRenderLowering",
                "GiftUIRenderCore",
                "GiftUIExecution",
                "GiftUITextResources",
            ]
        ),
        .target(
            name: "GiftUIDrawingFailureAdapterFixture",
            dependencies: ["GiftUIDrawing", "GiftUIFailureCore"]
        ),
        .target(
            name: "GiftUIExecution",
            dependencies: ["GiftUI", "GiftUIRenderCore"]
        ),
        .target(
            name: "GiftUIInteraction",
            dependencies: [
                "GiftUI",
                "GiftUIExecution",
                "GiftUILayout",
                "GiftUISemanticCore",
            ]
        ),
        .target(
            name: "GiftUIInteractionFailureAdapterFixture",
            dependencies: [
                "GiftUIFailureCore",
                "GiftUIFailureExecution",
                "GiftUIInteraction",
            ]
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
            name: "GiftUIRuntimeCore",
            dependencies: [
                "GiftUI",
                "GiftUIDrawing",
                "GiftUIExecution",
                "GiftUIInteraction",
                "GiftUILayout",
                "GiftUIObservableState",
                "GiftUIRenderCore",
                "GiftUIRenderLowering",
                "GiftUISemanticCore",
                "GiftUITextResources",
            ]
        ),
        .target(
            name: "GiftUIRuntimeDynamic",
            dependencies: [
                "GiftUI",
                "GiftUIDrawing",
                "GiftUIExecution",
                "GiftUIInteraction",
                "GiftUILayout",
                "GiftUIObservableState",
                "GiftUIRenderCore",
                "GiftUIRenderLowering",
                "GiftUIRuntimeCore",
                "GiftUISemanticCore",
            ]
        ),
        .target(
            name: "GiftUIRuntimeStatic",
            dependencies: [
                "GiftUI",
                "GiftUIDrawing",
                "GiftUIExecution",
                "GiftUIInteraction",
                "GiftUILayout",
                "GiftUIObservableState",
                "GiftUIRenderCore",
                "GiftUIRenderLowering",
                "GiftUIRuntimeCore",
                "GiftUISemanticCore",
            ]
        ),
        .target(
            name: "GiftUIRuntimeFailureAdapterFixture",
            dependencies: [
                "GiftUIFailureCore",
                "GiftUIFailureExecution",
                "GiftUIRuntimeCore",
            ]
        ),
        .target(
            name: "GiftUIHostConfiguration",
            dependencies: [
                "GiftUI",
                "GiftUIBackendIntegration",
                "GiftUICapabilities",
                "GiftUIDisplayCore",
                "GiftUIExecution",
                "GiftUIFailureCore",
                "GiftUIRasterCore",
                "GiftUIRuntimeCore",
                "GiftUISurfaceCore",
                "GiftUITextResources",
            ]
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
        .target(name: "SignalAnalyzerDomain"),
        .target(
            name: "SignalAnalyzerData",
            dependencies: ["SignalAnalyzerDomain"]
        ),
        .target(
            name: "SignalAnalyzerPresentation",
            dependencies: ["GiftUI", "GiftUIFailureCore", "SignalAnalyzerDomain"]
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
            name: "GiftUISurfaceCoreTests",
            dependencies: [
                "GiftUI",
                "GiftUICapabilities",
                "GiftUIRenderCore",
                "GiftUISurfaceCore",
            ]
        ),
        .testTarget(
            name: "GiftUIRasterCoreTests",
            dependencies: [
                "GiftUI",
                "GiftUICapabilities",
                "GiftUIRasterCore",
                "GiftUIRenderCore",
                "GiftUISurfaceCore",
                "GiftUITextResources",
            ]
        ),
        .testTarget(
            name: "GiftUIDisplayCoreTests",
            dependencies: [
                "GiftUI",
                "GiftUICapabilities",
                "GiftUIDisplayCore",
                "GiftUIFailureCore",
                "GiftUISurfaceCore",
            ]
        ),
        .testTarget(
            name: "GiftUIBackendIntegrationTests",
            dependencies: [
                "GiftUIBackendIntegration",
                "GiftUICapabilities",
                "GiftUIDisplayCore",
                "GiftUIExecution",
                "GiftUIFailureCore",
                "GiftUIRasterCore",
                "GiftUIRenderCore",
                "GiftUISurfaceCore",
                "GiftUITextResources",
            ]
        ),
        .testTarget(
            name: "GiftUIRenderLoweringTests",
            dependencies: [
                "GiftUI",
                "GiftUIFailureCore",
                "GiftUILayout",
                "GiftUIRenderCore",
                "GiftUIRenderFailureAdapterFixture",
                "GiftUIRenderLowering",
                "GiftUISemanticCore",
                "GiftUITextResources",
            ]
        ),
        .testTarget(
            name: "GiftUIRenderFailureAdapterTests",
            dependencies: [
                "GiftUIFailureCore",
                "GiftUIRenderFailureAdapterFixture",
                "GiftUIRenderLowering",
            ]
        ),
        .testTarget(
            name: "GiftUIDrawingTests",
            dependencies: [
                "GiftUI",
                "GiftUIDrawing",
                "GiftUIDrawingFailureAdapterFixture",
                "GiftUIExecution",
                "GiftUIFailureCore",
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
            name: "GiftUIInteractionTests",
            dependencies: [
                "GiftUI",
                "GiftUIExecution",
                "GiftUIInteraction",
            ]
        ),
        .testTarget(
            name: "GiftUIInteractionFailureAdapterTests",
            dependencies: [
                "GiftUIExecution",
                "GiftUIFailureCore",
                "GiftUIFailureDiagnostics",
                "GiftUIFailureExecution",
                "GiftUIInteraction",
                "GiftUIInteractionFailureAdapterFixture",
            ]
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
            name: "GiftUIRuntimeCoreTests",
            dependencies: [
                "GiftUI",
                "GiftUIDrawing",
                "GiftUIExecution",
                "GiftUIInteraction",
                "GiftUILayout",
                "GiftUIObservableState",
                "GiftUIRenderCore",
                "GiftUIRenderLowering",
                "GiftUIRuntimeCore",
                "GiftUISemanticCore",
            ]
        ),
        .testTarget(
            name: "GiftUIRuntimeDynamicTests",
            dependencies: ["GiftUIDynamicConveniences", "GiftUIRuntimeDynamic"]
        ),
        .testTarget(
            name: "GiftUIRuntimeStaticTests",
            dependencies: ["GiftUIRuntimeStatic"]
        ),
        .testTarget(
            name: "GiftUIRuntimeConformanceTests",
            dependencies: [
                "GiftUIRuntimeCore",
                "GiftUIRuntimeDynamic",
                "GiftUIRuntimeStatic",
            ]
        ),
        .testTarget(
            name: "GiftUIRuntimeFailureAdapterTests",
            dependencies: [
                "GiftUIExecution",
                "GiftUIFailureCore",
                "GiftUIFailureExecution",
                "GiftUIRuntimeCore",
                "GiftUIRuntimeFailureAdapterFixture",
            ]
        ),
        .testTarget(
            name: "GiftUIHostConfigurationTests",
            dependencies: ["GiftUIHostConfiguration"]
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
        .testTarget(
            name: "SignalAnalyzerDomainTests",
            dependencies: ["SignalAnalyzerDomain"]
        ),
        .testTarget(
            name: "SignalAnalyzerDataTests",
            dependencies: ["SignalAnalyzerData"]
        ),
        .testTarget(
            name: "SignalAnalyzerPresentationTests",
            dependencies: ["SignalAnalyzerPresentation"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
