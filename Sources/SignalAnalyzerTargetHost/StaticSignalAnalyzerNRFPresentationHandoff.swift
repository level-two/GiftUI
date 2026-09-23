import GiftUI
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIHostConfiguration
import GiftUIRenderCore
import GiftUIRuntimeCore

package enum StaticSignalAnalyzerNRFPresentationHandoffResult: Equatable, Sendable {
    case interaction(StaticSignalAnalyzerNRFInteractionCandidateResult)
    case offered(FrameOfferResult, RuntimeInteractionCandidateResolution)
}

/// Joins the preflighted render plan, generated actions, and physical offer.
/// Interaction and input become current only after an accepted offer.
package enum StaticSignalAnalyzerNRFPresentationHandoff {
    package static func offerPreflighted<Target: DisplayTarget>(
        semantic: borrowing StaticSignalAnalyzerNRFUTF8RenderView,
        layout: borrowing StaticSignalAnalyzerNRFResolvedLayoutView,
        drawingPlan: borrowing StaticSignalAnalyzerNRFDrawingWorkspace,
        occurrences: borrowing StaticSignalAnalyzerNRFInteractionOccurrences,
        expectedHeader: RenderPlanHeader,
        workspace: inout StaticSignalAnalyzerNRFRenderWorkspace,
        application: inout StaticSignalAnalyzerNRFApplicationOwner,
        endpoint: inout StaticSignalAnalyzerNRFEndpoint<Target>,
        provenance: FrameProvenance,
        presentationRevision: PresentationRevision
    ) -> StaticSignalAnalyzerNRFPresentationHandoffResult {
        let interaction = application.buildInteractionCandidate(
            occurrences: occurrences,
            limits: GeneratedSignalAnalyzerPresets.nrf52840Static()
                .runtimeLimits.interaction
        )
        guard interaction == .ready else { return .interaction(interaction) }
        let offer = StaticSignalAnalyzerNRFRenderOffer.offer(
            semantic: semantic,
            layout: layout,
            drawingPlan: drawingPlan,
            expectedHeader: expectedHeader,
            workspace: &workspace,
            endpoint: &endpoint,
            provenance: provenance
        )
        let resolution = application.resolveInteractionCandidate(
            offer: offer,
            presentationRevision: presentationRevision
        )
        return .offered(offer, resolution)
    }
}
