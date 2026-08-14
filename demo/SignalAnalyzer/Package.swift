// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SignalAnalyzer",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "SignalAnalyzer", targets: ["SignalAnalyzerApp"])
    ],
    targets: [
        .target(name: "SignalAnalyzerDomain"),
        .target(
            name: "SignalAnalyzerData",
            dependencies: ["SignalAnalyzerDomain"]
        ),
        .target(
            name: "SignalAnalyzerPresentation",
            dependencies: ["SignalAnalyzerDomain"]
        ),
        .executableTarget(
            name: "SignalAnalyzerApp",
            dependencies: [
                "SignalAnalyzerDomain",
                "SignalAnalyzerData",
                "SignalAnalyzerPresentation"
            ]
        ),
        .testTarget(
            name: "SignalAnalyzerDomainTests",
            dependencies: ["SignalAnalyzerDomain"]
        ),
        .testTarget(
            name: "SignalAnalyzerDataTests",
            dependencies: ["SignalAnalyzerDomain", "SignalAnalyzerData"]
        ),
        .testTarget(
            name: "SignalAnalyzerPresentationTests",
            dependencies: ["SignalAnalyzerDomain", "SignalAnalyzerPresentation"]
        )
    ]
)
