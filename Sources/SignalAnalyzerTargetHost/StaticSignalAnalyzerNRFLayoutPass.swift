import GiftUI
import GiftUIHostConfiguration
import GiftUILayout
import GiftUIReferenceTextResources

/// Resolves the generated hierarchy into the exact in-place nRF layout
/// regions before any Canvas or render work begins.
package enum StaticSignalAnalyzerNRFLayoutPass {
    package static func run(
        semantic: borrowing StaticSignalAnalyzerNRFUTF8LayoutView,
        workspace: inout StaticSignalAnalyzerNRFLayoutWorkspace,
        sink: inout StaticSignalAnalyzerNRFResolvedLayoutStorage
    ) -> LayoutResult {
        guard let proposal = ProposedSize(width: 480, height: 320) else {
            return .failure(.invariantViolation)
        }
        return layout(
            semantic: semantic,
            metrics: GiftUIReferenceTextResources.targetPackage.metrics,
            proposal: proposal,
            limits: GeneratedSignalAnalyzerPresets.nrf52840Static().runtimeLimits.layout,
            workspace: &workspace,
            sink: &sink
        )
    }
}
