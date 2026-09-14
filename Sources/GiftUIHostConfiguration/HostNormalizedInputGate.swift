import GiftUI
import GiftUIExecution

package enum HostNormalizedInputRejection: UInt8, Equatable, Sendable {
    case unknownSource = 0
    case presentationNotEstablished = 1
    case stalePresentation = 2
    case inputUnavailable = 3
    case malformed = 4
    case outOfOrder = 5
    case resynchronizationNotProven = 6
    case sequenceExhausted = 7
    case ordinalExhausted = 8
    case runtimeCapacityRefused = 9
    case runtimeUnavailable = 10
    case runtimeInvalidValue = 11
    case runtimeInvalidProvenance = 12
}

package enum HostNormalizedInputDisposition: Equatable, Sendable {
    case queued(NormalizedPointerEvent)
    case dropped(HostNormalizedInputRejection)
    case sequenceCancelled(HostNormalizedInputRejection)
    case sourceQuiesced(HostNormalizedInputRejection)
}

package struct HostNormalizedInputGate: Sendable {
    private enum PhysicalSequenceState: UInt8, Sendable {
        case synchronized = 0
        case active = 1
        case cancelled = 2
        case quiescent = 3
    }

    private let configuredSource: InputSourceID
    private var sequenceAllocator: TargetInputSequenceGate
    private var state: PhysicalSequenceState = .synchronized
    private var activeSequence: PointerSequenceID?
    private var lastAdmittedOrdinal: InputOrdinal?
    private var physicalPresentationRevision: PresentationRevision?

    package init(
        configuredSource: InputSourceID,
        nextSubmittedSequenceRaw: UInt32? = 0
    ) {
        self.configuredSource = configuredSource
        sequenceAllocator = TargetInputSequenceGate(
            nextSubmittedSequenceRaw: nextSubmittedSequenceRaw
        )
    }

    package var inputIsEligible: Bool {
        physicalPresentationRevision != nil && state != .quiescent
    }

    package mutating func installPhysicalPresentation(
        _ revision: PresentationRevision
    ) {
        guard state != .quiescent else { return }
        physicalPresentationRevision = revision
    }

    package mutating func quiesce() {
        physicalPresentationRevision = nil
        cancelCurrentSequence()
        state = .quiescent
    }

    package mutating func submit<Sink: ExecutionAdmissionSink>(
        phase: PointerPhase,
        position: Point,
        source: InputSourceID,
        observedPresentationRevision: PresentationRevision?,
        isMalformed: Bool,
        priorPhysicalSequenceIsComplete: Bool,
        to sink: inout Sink
    ) -> HostNormalizedInputDisposition {
        guard state != .quiescent else {
            return .sourceQuiesced(.inputUnavailable)
        }
        guard source == configuredSource else {
            cancelCurrentSequence()
            return .dropped(.unknownSource)
        }
        guard let currentRevision = physicalPresentationRevision else {
            cancelCurrentSequence()
            sequenceAllocator.abandonUnsubmittedPhysicalInput()
            return .dropped(.presentationNotEstablished)
        }
        guard observedPresentationRevision == currentRevision else {
            cancelCurrentSequence()
            sequenceAllocator.abandonUnsubmittedPhysicalInput()
            return .dropped(.stalePresentation)
        }
        guard !isMalformed else {
            cancelCurrentSequence()
            sequenceAllocator.abandonUnsubmittedPhysicalInput()
            return .dropped(.malformed)
        }

        switch phase {
        case .down:
            return submitDown(
                position: position,
                source: source,
                revision: currentRevision,
                priorPhysicalSequenceIsComplete: priorPhysicalSequenceIsComplete,
                to: &sink
            )
        case .move, .up:
            return submitLaterPhase(
                phase: phase,
                position: position,
                source: source,
                revision: currentRevision,
                to: &sink
            )
        }
    }

    private mutating func submitDown<Sink: ExecutionAdmissionSink>(
        position: Point,
        source: InputSourceID,
        revision: PresentationRevision,
        priorPhysicalSequenceIsComplete: Bool,
        to sink: inout Sink
    ) -> HostNormalizedInputDisposition {
        if state == .active || state == .cancelled {
            guard priorPhysicalSequenceIsComplete else {
                cancelCurrentSequence()
                return .dropped(.resynchronizationNotProven)
            }
            cancelCurrentSequence()
        }
        guard let sequence = sequenceAllocator.beginSubmittedDown() else {
            quiesce()
            return .sourceQuiesced(.sequenceExhausted)
        }
        let event = NormalizedPointerEvent(
            phase: .down,
            position: position,
            source: source,
            sequence: sequence,
            ordinal: InputOrdinal(rawValue: 0),
            presentationRevision: revision
        )
        let result = sink.submit(pointer: event).result
        guard result == .queued else {
            state = .active
            activeSequence = sequence
            lastAdmittedOrdinal = InputOrdinal(rawValue: 0)
            return cancel(for: result)
        }
        state = .active
        activeSequence = sequence
        lastAdmittedOrdinal = event.ordinal
        return .queued(event)
    }

    private mutating func submitLaterPhase<Sink: ExecutionAdmissionSink>(
        phase: PointerPhase,
        position: Point,
        source: InputSourceID,
        revision: PresentationRevision,
        to sink: inout Sink
    ) -> HostNormalizedInputDisposition {
        guard state == .active,
            let sequence = activeSequence,
            let previousOrdinal = lastAdmittedOrdinal
        else {
            cancelCurrentSequence()
            return .dropped(.outOfOrder)
        }
        let successor = previousOrdinal.rawValue.addingReportingOverflow(1)
        guard !successor.overflow else {
            cancelCurrentSequence()
            return .sequenceCancelled(.ordinalExhausted)
        }
        let event = NormalizedPointerEvent(
            phase: phase,
            position: position,
            source: source,
            sequence: sequence,
            ordinal: InputOrdinal(rawValue: successor.partialValue),
            presentationRevision: revision
        )
        let result = sink.submit(pointer: event).result
        guard result == .queued else { return cancel(for: result) }
        lastAdmittedOrdinal = event.ordinal
        if phase == .up {
            state = .synchronized
            activeSequence = nil
            lastAdmittedOrdinal = nil
        }
        return .queued(event)
    }

    private mutating func cancel(
        for result: ExecutionAdmissionResult
    ) -> HostNormalizedInputDisposition {
        let reason: HostNormalizedInputRejection =
            switch result {
            case .queued: .runtimeInvalidValue
            case .capacityRefused: .runtimeCapacityRefused
            case .unavailable: .runtimeUnavailable
            case .invalidValue: .runtimeInvalidValue
            case .invalidProvenance: .runtimeInvalidProvenance
            }
        cancelCurrentSequence()
        if result == .unavailable {
            quiesce()
            return .sourceQuiesced(reason)
        }
        return .sequenceCancelled(reason)
    }

    private mutating func cancelCurrentSequence() {
        if state == .active { state = .cancelled }
    }
}
