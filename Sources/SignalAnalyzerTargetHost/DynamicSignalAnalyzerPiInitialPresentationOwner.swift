import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIInteraction
import GiftUIRuntimeCore
import SignalAnalyzerPresentation

package enum DynamicSignalAnalyzerPiInitialPresentationState: UInt8, Equatable, Sendable {
    case ready = 0
    case inputEligible = 1
    case quiescent = 2
}

package enum DynamicSignalAnalyzerPiInitialPresentationFailure: Equatable, Sendable {
    case invalidLifecycle
    case presentation(DynamicSignalAnalyzerPresentationFailure)
    case offer(FrameOfferResult)
    case interaction
}

package enum DynamicSignalAnalyzerPiInitialPresentationResult: Equatable, Sendable {
    case presented(DynamicSignalAnalyzerPresentationSummary)
    case failure(DynamicSignalAnalyzerPiInitialPresentationFailure)
}

/// Owns the first production Dynamic presentation transaction for the Pi host.
/// Input becomes eligible only after the physical target accepts the frame and
/// the matching interaction candidate commits.
package struct DynamicSignalAnalyzerPiInitialPresentationOwner<Target>
where Target: DisplayTarget {
    private var pipeline: DynamicSignalAnalyzerPresentationPipeline
    private var endpoint: DynamicSignalAnalyzerPiEndpoint<Target>
    private let provenance: FrameProvenance
    private let presentationRevision: PresentationRevision

    package private(set) var state: DynamicSignalAnalyzerPiInitialPresentationState = .ready

    package init?(
        target: consuming Target,
        limits: RuntimeProfileLimits,
        maximumRecordedTraversalIdentities: UInt16,
        effectivePresentation: EffectiveRasterPresentation,
        provenance: FrameProvenance,
        presentationRevision: PresentationRevision
    ) {
        guard
            let pipeline = DynamicSignalAnalyzerPresentationPipeline(
                limits: limits,
                maximumRecordedTraversalIdentities: maximumRecordedTraversalIdentities,
                logicalWidth: 240,
                logicalHeight: 240
            ),
            let endpoint = DynamicSignalAnalyzerPiEndpointFactory.make(
                target: target,
                provenance: provenance,
                effectivePresentation: effectivePresentation
            )
        else { return nil }
        self.pipeline = pipeline
        self.endpoint = endpoint
        self.provenance = provenance
        self.presentationRevision = presentationRevision
    }

    package var inputIsEligible: Bool { state == .inputEligible }

    package var eligibleActionCount: UInt16 {
        inputIsEligible ? pipeline.committedActionCount : 0
    }

    package mutating func presentInitial(
        model: SignalAnalyzerViewModel
    ) -> DynamicSignalAnalyzerPiInitialPresentationResult {
        guard state == .ready else { return .failure(.invalidLifecycle) }

        let result = pipeline.derive(
            model: model,
            cycle: provenance.cycle,
            semanticRevision: provenance.semanticRevision
        )
        let summary: DynamicSignalAnalyzerPresentationSummary
        switch result {
        case .success(let value):
            summary = value
        case .failure(let failure):
            return .failure(.presentation(failure))
        }

        let offer = pipeline.offer(
            endpoint: &endpoint,
            provenance: provenance,
            expectedHeader: summary.render
        )
        guard offer.disposition == .accepted else {
            _ = pipeline.resolveInteraction(
                offer: offer,
                presentationRevision: presentationRevision
            )
            return .failure(.offer(offer))
        }
        guard
            pipeline.resolveInteraction(
                offer: offer,
                presentationRevision: presentationRevision
            ) == .committed(presentationRevision)
        else { return .failure(.interaction) }

        state = .inputEligible
        return .presented(summary)
    }

    package mutating func quiesce() {
        state = .quiescent
    }
}
