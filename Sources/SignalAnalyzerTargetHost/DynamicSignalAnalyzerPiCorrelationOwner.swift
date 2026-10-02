import GiftUI
import GiftUIExecution

package struct DynamicSignalAnalyzerPiPresentationCorrelation: Equatable, Sendable {
    package let provenance: FrameProvenance
    package let presentationRevision: PresentationRevision

    package init(provenance: FrameProvenance, presentationRevision: PresentationRevision) {
        self.provenance = provenance
        self.presentationRevision = presentationRevision
    }
}

/// Reserves production identities only when their corresponding stage begins.
package final class DynamicSignalAnalyzerPiCorrelationOwner {
    private var cycles = RunCycleIDAllocator()
    private var semantics = SemanticRevisionAllocator()
    private var candidates = CandidateFrameIDAllocator()
    private var presentations = PresentationRevisionAllocator()

    package init() {}

    package func reserveOpportunityCycle() -> RunCycleID? {
        cycles.reserve()
    }

    package func reserveSemanticRevision() -> SemanticRevision? { semantics.reserve() }

    package func reservePresentation(for cycle: RunCycleID)
        -> DynamicSignalAnalyzerPiPresentationCorrelation?
    {
        guard let semanticRevision = reserveSemanticRevision() else { return nil }
        return reservePresentation(for: cycle, semanticRevision: semanticRevision)
    }

    package func reservePresentation(
        for cycle: RunCycleID, semanticRevision: SemanticRevision
    ) -> DynamicSignalAnalyzerPiPresentationCorrelation? {
        guard
            let candidateFrame = candidates.reserve(),
            let presentationRevision = presentations.reserve()
        else { return nil }
        return DynamicSignalAnalyzerPiPresentationCorrelation(
            provenance: FrameProvenance(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidateFrame: candidateFrame
            ),
            presentationRevision: presentationRevision
        )
    }

    package func reserveInitialPresentation()
        -> DynamicSignalAnalyzerPiPresentationCorrelation?
    {
        guard let cycle = reserveOpportunityCycle() else { return nil }
        return reservePresentation(for: cycle)
    }
}
