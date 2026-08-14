import SignalAnalyzerPresentation
import SwiftUI

@main
@MainActor
struct SignalAnalyzerApp: App {
    private let dependencies = DependencyContainer()

    var body: some Scene {
        WindowGroup("Digital Signal Analyzer") {
            SignalAnalyzerView(viewModel: dependencies.viewModel)
                .preferredColorScheme(.dark)
        }
        .defaultSize(width: 960, height: 660)
        .windowResizability(.contentMinSize)
    }
}
