import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIInteraction
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
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

package enum DynamicSignalAnalyzerPiInputRejection: UInt8, Equatable, Sendable {
    case inputIneligible = 0
    case stalePresentation = 1
    case outOfOrder = 2
}

package enum DynamicSignalAnalyzerPiInputResult: Equatable, Sendable {
    case captured
    case continued
    case dispatched(InteractionDispatchResult)
    case ignored
    case cancelled
    case rejected(DynamicSignalAnalyzerPiInputRejection)
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
    private var activeInputSource: InputSourceID?
    private var activeInputSequence: PointerSequenceID?
    private var lastInputOrdinal: InputOrdinal?
    private var capturedAction: CapturedAction<DynamicSemanticIdentity>?

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

    package borrowing func eligibleAction(
        at index: UInt16
    ) -> BoundActionRecord<DynamicSemanticIdentity>? {
        guard inputIsEligible else { return nil }
        return pipeline.committedAction(at: index)
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

    package mutating func handle(
        _ event: NormalizedPointerEvent
    ) -> DynamicSignalAnalyzerPiInputResult {
        guard inputIsEligible else { return .rejected(.inputIneligible) }
        guard event.presentationRevision == presentationRevision else {
            cancelInputSequence()
            return .rejected(.stalePresentation)
        }

        switch event.phase {
        case .down:
            guard event.ordinal.rawValue == 0 else {
                cancelInputSequence()
                return .rejected(.outOfOrder)
            }
            activeInputSource = event.source
            activeInputSequence = event.sequence
            lastInputOrdinal = event.ordinal
            switch pipeline.resolveDown(at: event.position) {
            case .captured(let captured):
                capturedAction = captured
                return .captured
            case .ignored:
                capturedAction = nil
                return .ignored
            case .cancelled, .continued, .activationAdmitted:
                cancelInputSequence()
                return .cancelled
            }
        case .move, .up:
            guard activeInputSource == event.source,
                activeInputSequence == event.sequence,
                let previous = lastInputOrdinal,
                previous.rawValue < UInt32.max,
                event.ordinal.rawValue == previous.rawValue + 1
            else {
                cancelInputSequence()
                return .rejected(.outOfOrder)
            }
            lastInputOrdinal = event.ordinal
            guard let capturedAction else {
                if event.phase == .up { cancelInputSequence() }
                return .ignored
            }
            if event.phase == .move {
                switch pipeline.resolveMove(capturedAction, at: event.position) {
                case .continued:
                    return .continued
                case .cancelled, .ignored:
                    self.capturedAction = nil
                    return .cancelled
                case .captured, .activationAdmitted:
                    cancelInputSequence()
                    return .cancelled
                }
            }
            defer { cancelInputSequence() }
            switch pipeline.resolveUp(capturedAction, at: event.position) {
            case .activationAdmitted(let admitted):
                return .dispatched(pipeline.dispatch(admitted))
            case .cancelled, .ignored:
                return .cancelled
            case .captured, .continued:
                return .cancelled
            }
        }
    }

    package mutating func quiesce() {
        cancelInputSequence()
        state = .quiescent
    }

    private mutating func cancelInputSequence() {
        activeInputSource = nil
        activeInputSequence = nil
        lastInputOrdinal = nil
        capturedAction = nil
    }
}
