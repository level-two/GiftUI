import GiftUI
import Testing

@testable import GiftUIExecution

private func sequence(_ rawValue: UInt32) -> PointerSequenceID {
    PointerSequenceID(rawValue: rawValue)
}

private func ordinal(_ rawValue: UInt32) -> InputOrdinal {
    InputOrdinal(rawValue: rawValue)
}

@Test
func targetGateConsumesOnlySubmittedDownSequences() {
    var gate = TargetInputSequenceGate()
    #expect(gate.sequenceForUnsubmittedPhysicalInput == sequence(0))

    gate.abandonUnsubmittedPhysicalInput()
    gate.abandonUnsubmittedPhysicalInput()
    #expect(gate.sequenceForUnsubmittedPhysicalInput == sequence(0))

    #expect(gate.beginSubmittedDown() == sequence(0))
    #expect(gate.sequenceForUnsubmittedPhysicalInput == sequence(1))
    #expect(gate.beginSubmittedDown() == sequence(1))
}

@Test
func targetGateReservesMaximumThenPermanentlyExhausts() {
    var gate = TargetInputSequenceGate(nextSubmittedSequenceRaw: .max)
    #expect(gate.beginSubmittedDown() == sequence(.max))
    #expect(gate.beginSubmittedDown() == nil)
    gate.abandonUnsubmittedPhysicalInput()
    #expect(gate.sequenceForUnsubmittedPhysicalInput == nil)
}

@Test
func firstDownAndLaterPhasesUseExactZeroAndSuccessors() {
    var state = InputSourceSequenceState()
    #expect(
        state.validate(
            phase: .down,
            sequence: sequence(0),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: false
        ) == .accepted
    )
    #expect(state.mode == .active)
    #expect(
        state.validate(
            phase: .move,
            sequence: sequence(0),
            ordinal: ordinal(1),
            targetGateAllowsResynchronization: false
        ) == .accepted
    )
    #expect(
        state.validate(
            phase: .up,
            sequence: sequence(0),
            ordinal: ordinal(2),
            targetGateAllowsResynchronization: false
        ) == .accepted
    )
    #expect(state.mode == .synchronized)
}

@Test
func gapsDuplicatesDecreasesAndWrongSequencesCancelWithoutBaselineAdvance() {
    let invalidLaterPhases: [(PointerSequenceID, InputOrdinal)] = [
        (sequence(0), ordinal(0)),
        (sequence(0), ordinal(2)),
        (sequence(1), ordinal(1)),
    ]

    for (badSequence, badOrdinal) in invalidLaterPhases {
        var state = InputSourceSequenceState()
        #expect(
            state.validate(
                phase: .down,
                sequence: sequence(0),
                ordinal: ordinal(0),
                targetGateAllowsResynchronization: false
            ) == .accepted
        )
        #expect(
            state.validate(
                phase: .move,
                sequence: badSequence,
                ordinal: badOrdinal,
                targetGateAllowsResynchronization: false
            ) == .invalidProvenance
        )
        #expect(state.mode == .cancelled)
        #expect(state.sequence == sequence(0))
        #expect(state.ordinal == ordinal(0))
    }
}

@Test
func cancelledSequenceConsumesExactSuffixWithoutDispatch() {
    var state = InputSourceSequenceState()
    #expect(
        state.validate(
            phase: .down,
            sequence: sequence(0),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: false
        ) == .accepted
    )
    state.cancelCurrentSequence()

    #expect(
        state.validate(
            phase: .move,
            sequence: sequence(0),
            ordinal: ordinal(1),
            targetGateAllowsResynchronization: false
        ) == .consumedWhileCancelled
    )
    #expect(
        state.validate(
            phase: .up,
            sequence: sequence(0),
            ordinal: ordinal(2),
            targetGateAllowsResynchronization: false
        ) == .consumedWhileCancelled
    )
    #expect(state.mode == .synchronized)
}

@Test
func replacementDownRequiresIndependentTargetProofAndExactRuntimeSequence() {
    var state = InputSourceSequenceState()
    #expect(
        state.validate(
            phase: .down,
            sequence: sequence(0),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: false
        ) == .accepted
    )
    #expect(
        state.validate(
            phase: .down,
            sequence: sequence(1),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: false
        ) == .invalidProvenance
    )
    #expect(state.mode == .cancelled)
    #expect(
        state.validate(
            phase: .down,
            sequence: sequence(2),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: true
        ) == .invalidProvenance
    )
    #expect(state.sequence == sequence(0))
    #expect(
        state.validate(
            phase: .down,
            sequence: sequence(1),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: true
        ) == .accepted
    )
}

@Test
func ordinalExhaustionCancelsAndSequenceExhaustionQuiesces() {
    var ordinalState = InputSourceSequenceState()
    #expect(
        ordinalState.validate(
            phase: .down,
            sequence: sequence(0),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: false
        ) == .accepted
    )
    ordinalState = InputSourceSequenceState.fixture(
        mode: .active,
        sequence: sequence(0),
        ordinal: ordinal(.max)
    )
    #expect(
        ordinalState.validate(
            phase: .move,
            sequence: sequence(0),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: false
        ) == .invalidProvenance
    )
    #expect(ordinalState.mode == .cancelled)
    #expect(
        ordinalState.validate(
            phase: .down,
            sequence: sequence(1),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: true
        ) == .accepted
    )

    var sequenceState = InputSourceSequenceState.fixture(
        mode: .synchronized,
        sequence: sequence(.max),
        ordinal: ordinal(1)
    )
    #expect(
        sequenceState.validate(
            phase: .down,
            sequence: sequence(0),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: false
        ) == .unavailable
    )
    #expect(sequenceState.mode == .quiescent)
    #expect(
        sequenceState.validate(
            phase: .down,
            sequence: sequence(0),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: true
        ) == .unavailable
    )
}

@Test
func boundedSourcesMaintainIndependentSequenceAndOrdinalState() {
    var first = InputSourceSequenceState()
    var second = InputSourceSequenceState()

    #expect(
        first.validate(
            phase: .down,
            sequence: sequence(0),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: false
        ) == .accepted
    )
    #expect(second.mode == .synchronized)
    #expect(second.sequence == nil)
    #expect(
        second.validate(
            phase: .down,
            sequence: sequence(0),
            ordinal: ordinal(0),
            targetGateAllowsResynchronization: false
        ) == .accepted
    )
    #expect(first.sequence == sequence(0))
    #expect(second.sequence == sequence(0))
}

extension InputSourceSequenceState {
    fileprivate static func fixture(
        mode: Mode,
        sequence: PointerSequenceID?,
        ordinal: InputOrdinal?
    ) -> Self {
        Self(mode: mode, sequence: sequence, ordinal: ordinal)
    }
}
