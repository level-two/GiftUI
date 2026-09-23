import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIRuntimeStatic
import SignalAnalyzerHost
import SignalAnalyzerPresentation

/// Resolves admitted nRF pointer input against one committed Static interaction
/// candidate and dispatches through the current observable model generation.
package struct StaticSignalAnalyzerNRFInteractionSession: ~Copyable {
    private var presentationRevision: PresentationRevision?
    private var activeSource: InputSourceID?
    private var activeSequence: PointerSequenceID?
    private var lastOrdinal: InputOrdinal?
    private var capture = PointerActionCapture<UInt32>()
    private var opportunityIsActive = false

    package init() {}

    package var hasPhysicalPresentation: Bool { presentationRevision != nil }

    package mutating func installPhysicalPresentation(
        _ revision: PresentationRevision
    ) {
        cancelSequence()
        presentationRevision = revision
    }

    package mutating func quiesce() {
        opportunityIsActive = false
        presentationRevision = nil
        cancelSequence()
    }

    fileprivate mutating func beginOpportunity(
        root: UnsafeMutablePointer<
            StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
        >
    ) -> Bool {
        guard presentationRevision != nil, !opportunityIsActive else {
            return false
        }
        root.pointee.setExecutionPhase(.mutating)
        opportunityIsActive = true
        return true
    }

    fileprivate mutating func handle(
        _ event: NormalizedPointerEvent,
        interaction: UnsafeMutablePointer<StaticInteractionState<UInt32>>,
        root: UnsafeMutablePointer<
            StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
        >
    ) -> StaticSignalAnalyzerNRFInputHandling {
        guard opportunityIsActive,
            event.presentationRevision == presentationRevision
        else {
            cancelSequence()
            return .cancelledOrRejected
        }

        switch event.phase {
        case .down:
            return handleDown(event, interaction: interaction)
        case .move:
            return handleMove(event, interaction: interaction)
        case .up:
            return handleUp(
                event,
                interaction: interaction,
                root: root
            )
        }
    }

    fileprivate mutating func endOpportunity(
        root: UnsafeMutablePointer<
            StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
        >
    ) -> Bool {
        guard opportunityIsActive else { return false }
        root.pointee.setExecutionPhase(.idle)
        opportunityIsActive = false
        return true
    }

    private mutating func handleDown(
        _ event: NormalizedPointerEvent,
        interaction: UnsafeMutablePointer<StaticInteractionState<UInt32>>
    ) -> StaticSignalAnalyzerNRFInputHandling {
        guard event.ordinal.rawValue == 0 else {
            cancelSequence()
            return .cancelledOrRejected
        }
        cancelSequence()
        activeSource = event.source
        activeSequence = event.sequence
        lastOrdinal = event.ordinal
        switch ExecutionGestureAdapter.down(
            at: event.position,
            capture: &capture,
            resolver: interaction.pointee
        ) {
        case .captured, .ignored:
            return .consumed
        case .continued, .activationAdmitted, .cancelled:
            cancelSequence()
            return .cancelledOrRejected
        }
    }

    private mutating func handleMove(
        _ event: NormalizedPointerEvent,
        interaction: UnsafeMutablePointer<StaticInteractionState<UInt32>>
    ) -> StaticSignalAnalyzerNRFInputHandling {
        guard validateContinuation(event) else {
            cancelSequence()
            return .cancelledOrRejected
        }
        switch ExecutionGestureAdapter.move(
            at: event.position,
            capture: &capture,
            resolver: interaction.pointee
        ) {
        case .continued:
            return .consumed
        case .cancelled, .ignored:
            return .cancelledOrRejected
        case .captured, .activationAdmitted:
            cancelSequence()
            return .cancelledOrRejected
        }
    }

    private mutating func handleUp(
        _ event: NormalizedPointerEvent,
        interaction: UnsafeMutablePointer<StaticInteractionState<UInt32>>,
        root: UnsafeMutablePointer<
            StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
        >
    ) -> StaticSignalAnalyzerNRFInputHandling {
        guard validateContinuation(event) else {
            cancelSequence()
            return .cancelledOrRejected
        }
        defer { cancelSequence() }
        switch ExecutionGestureAdapter.up(
            at: event.position,
            capture: &capture,
            resolver: interaction.pointee
        ) {
        case .activationAdmitted(let admitted):
            var dispatcher = StaticSignalAnalyzerActionDispatcher.make(
                records: interaction.pointee,
                root: root
            )
            return dispatcher.dispatch(admitted) == .dispatched
                ? .dispatched
                : .cancelledOrRejected
        case .cancelled, .ignored, .captured, .continued:
            return .cancelledOrRejected
        }
    }

    private mutating func validateContinuation(
        _ event: NormalizedPointerEvent
    ) -> Bool {
        guard activeSource == event.source,
            activeSequence == event.sequence,
            let previous = lastOrdinal,
            previous.rawValue < UInt32.max,
            event.ordinal.rawValue == previous.rawValue + 1
        else { return false }
        lastOrdinal = event.ordinal
        return true
    }

    private mutating func cancelSequence() {
        activeSource = nil
        activeSequence = nil
        lastOrdinal = nil
        capture.cancel()
    }
}

/// A scoped adapter over caller-owned, address-stable Static application
/// storage. No pointer retained here may outlive one synchronous opportunity.
package struct StaticSignalAnalyzerNRFInteractionHandler:
    StaticSignalAnalyzerNRFInputHandler
{
    private let session: UnsafeMutablePointer<StaticSignalAnalyzerNRFInteractionSession>
    private let interaction: UnsafeMutablePointer<StaticInteractionState<UInt32>>
    private let root:
        UnsafeMutablePointer<
            StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
        >

    package init(
        session: UnsafeMutablePointer<StaticSignalAnalyzerNRFInteractionSession>,
        interaction: UnsafeMutablePointer<StaticInteractionState<UInt32>>,
        root: UnsafeMutablePointer<
            StaticObservableRootAdapter<SignalAnalyzerViewModel, UInt32>
        >
    ) {
        self.session = session
        self.interaction = interaction
        self.root = root
    }

    package mutating func beginOpportunity() -> Bool {
        session.pointee.beginOpportunity(root: root)
    }

    package mutating func handle(
        _ event: NormalizedPointerEvent
    ) -> StaticSignalAnalyzerNRFInputHandling {
        session.pointee.handle(
            event,
            interaction: interaction,
            root: root
        )
    }

    package mutating func endOpportunity() -> Bool {
        session.pointee.endOpportunity(root: root)
    }
}
