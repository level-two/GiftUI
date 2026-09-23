import GiftUI
import GiftUIExecution

package struct StaticSignalAnalyzerNRFPresentationIdentity: Equatable, Sendable {
    package let provenance: FrameProvenance
    package let presentationRevision: PresentationRevision
}

/// Owns bounded numeric correlation for consecutive Static nRF opportunities.
/// A refused offer consumes its candidate identities without reusing them.
package struct StaticSignalAnalyzerNRFPresentationIdentityOwner {
    private var cycles = RunCycleIDAllocator()
    private var semantics = SemanticRevisionAllocator()
    private var candidates = CandidateFrameIDAllocator()
    private var presentations = PresentationRevisionAllocator()

    package init() {
        // The packed semantic table reserves revision zero for unpublished
        // storage, while the other identity domains may start at zero.
        _ = semantics.reserve()
    }

    package mutating func reserve() -> StaticSignalAnalyzerNRFPresentationIdentity? {
        guard let cycle = cycles.reserve(),
            let semanticRevision = semantics.reserve(),
            let candidateFrame = candidates.reserve(),
            let presentationRevision = presentations.reserve()
        else { return nil }
        return StaticSignalAnalyzerNRFPresentationIdentity(
            provenance: FrameProvenance(
                cycle: cycle,
                semanticRevision: semanticRevision,
                candidateFrame: candidateFrame
            ),
            presentationRevision: presentationRevision
        )
    }
}
