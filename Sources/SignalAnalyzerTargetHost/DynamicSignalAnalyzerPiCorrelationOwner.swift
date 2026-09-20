import GiftUI
import GiftUIExecution

package struct DynamicSignalAnalyzerPiPresentationCorrelation: Equatable, Sendable {
    package let provenance: FrameProvenance
    package let presentationRevision: PresentationRevision
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

    package func reservePresentation(
        for cycle: RunCycleID
    ) -> DynamicSignalAnalyzerPiPresentationCorrelation? {
        guard
            let semanticRevision = semantics.reserve(),
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
