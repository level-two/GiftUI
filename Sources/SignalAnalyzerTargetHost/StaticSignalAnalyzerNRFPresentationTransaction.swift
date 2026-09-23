import GiftUI
import GiftUIDisplayCore
import GiftUIExecution

package enum StaticSignalAnalyzerNRFPresentationTransactionResult: Equatable, Sendable {
    case unboundRoot
    case semantic(StaticSignalAnalyzerNRFSemanticPublicationResult)
    case preparation(StaticSignalAnalyzerNRFPreparationFailure)
    case handoff(StaticSignalAnalyzerNRFPresentationHandoffResult)
}

/// Publishes generated semantics and completes one physical presentation
/// while the application's bound model and five profile regions are lent.
package enum StaticSignalAnalyzerNRFPresentationTransaction {
    package static func present<Target: DisplayTarget>(
        application: borrowing StaticSignalAnalyzerNRFApplicationOwner,
        profile: inout StaticSignalAnalyzerNRFProductionProfileBinding,
        endpoint: inout StaticSignalAnalyzerNRFEndpoint<Target>,
        provenance: FrameProvenance,
        renderSnapshotVersion: UInt32,
        presentationRevision: PresentationRevision
    ) -> StaticSignalAnalyzerNRFPresentationTransactionResult {
        let borrowed = application.withGeneratedPresentationTransaction {
            inputs, committer -> StaticSignalAnalyzerNRFPresentationTransactionResult in
            let publication = StaticSignalAnalyzerNRFSemanticPublication.publish(
                inputs: &inputs,
                revision: provenance.semanticRevision.rawValue,
                profile: &profile
            )
            guard case .published = publication else {
                return .semantic(publication)
            }
            let prepared =
                StaticSignalAnalyzerNRFPresentationPreparation
                .withPreparedCandidate(
                    inputs: &inputs,
                    profile: &profile,
                    cycle: provenance.cycle,
                    semanticRevision: provenance.semanticRevision,
                    renderSnapshotVersion: renderSnapshotVersion
                ) { semantic, layout, drawing, occurrences, header, workspace in
                    StaticSignalAnalyzerNRFPresentationHandoff.offerPreflighted(
                        semantic: semantic,
                        layout: layout,
                        drawingPlan: drawing,
                        occurrences: occurrences,
                        expectedHeader: header,
                        workspace: &workspace,
                        committer: &committer,
                        endpoint: &endpoint,
                        provenance: provenance,
                        presentationRevision: presentationRevision
                    )
                }
            switch prepared {
            case .ready(let handoff):
                return .handoff(handoff)
            case .failure(let failure):
                return .preparation(failure)
            }
        }
        return borrowed ?? .unboundRoot
    }
}
