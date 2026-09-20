import GiftUI
import GiftUIHostConfiguration
import SignalAnalyzerTargetHost
import Testing

private struct StaticNRFABIInputHandler: StaticSignalAnalyzerNRFInputHandler {
    private(set) var events: [NormalizedPointerEvent] = []

    mutating func handle(
        _ event: NormalizedPointerEvent
    ) -> StaticSignalAnalyzerNRFInputHandling {
        events.append(event)
        return .consumed
    }
}

@Test func staticNRFInputABIPreservesTypedAdmissionAndProvenance() throws {
    var input = StaticSignalAnalyzerNRFInputABI(sourceRawValue: 73)
    input.installPhysicalPresentation(rawValue: 19)

    let optionalDownOutcome = input.admit(
        phaseRawValue: PointerPhase.down.rawValue,
        x: 101,
        y: 103,
        observedPresentationRevisionRawValue: 19,
        priorPhysicalSequenceIsCompleteRawValue: 0
    )
    let optionalMoveOutcome = input.admit(
        phaseRawValue: PointerPhase.move.rawValue,
        x: 107,
        y: 109,
        observedPresentationRevisionRawValue: 19,
        priorPhysicalSequenceIsCompleteRawValue: 0
    )
    let optionalUpOutcome = input.admit(
        phaseRawValue: PointerPhase.up.rawValue,
        x: 113,
        y: 127,
        observedPresentationRevisionRawValue: 19,
        priorPhysicalSequenceIsCompleteRawValue: 0
    )
    let down = try #require(optionalDownOutcome)
    let move = try #require(optionalMoveOutcome)
    let up = try #require(optionalUpOutcome)
    #expect(down.disposition == .queued)
    #expect(move.disposition == .queued)
    #expect(up.disposition == .queued)
    #expect(down.rejection == StaticSignalAnalyzerNRFInputABIOutcome.noRejection)
    #expect(down.packedValue == 0x00FF)
    #expect(input.pendingCount == 3)

    var handler = StaticNRFABIInputHandler()
    #expect(
        input.runOpportunity(into: &handler)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 3,
                    dispatchedActionCount: 0,
                    cancelledOrRejectedCount: 0
                )
            )
    )
    let downEvent = try #require(handler.events.first)
    let moveEvent = try #require(handler.events.dropFirst().first)
    let upEvent = try #require(handler.events.last)
    #expect(downEvent.source == InputSourceID(rawValue: 73))
    #expect(downEvent.presentationRevision == PresentationRevision(rawValue: 19))
    #expect(downEvent.sequence == PointerSequenceID(rawValue: 0))
    #expect(
        [downEvent.ordinal, moveEvent.ordinal, upEvent.ordinal] == [
            InputOrdinal(rawValue: 0),
            InputOrdinal(rawValue: 1),
            InputOrdinal(rawValue: 2),
        ])
}

@Test func staticNRFInputABIRejectsMalformedCValuesBeforeAdmission() {
    var input = StaticSignalAnalyzerNRFInputABI(sourceRawValue: 73)
    input.installPhysicalPresentation(rawValue: 19)

    #expect(
        input.admit(
            phaseRawValue: 3,
            x: 0,
            y: 0,
            observedPresentationRevisionRawValue: 19,
            priorPhysicalSequenceIsCompleteRawValue: 0
        ) == nil
    )
    #expect(
        input.admit(
            phaseRawValue: PointerPhase.down.rawValue,
            x: 480,
            y: 0,
            observedPresentationRevisionRawValue: 19,
            priorPhysicalSequenceIsCompleteRawValue: 0
        ) == nil
    )
    #expect(
        input.admit(
            phaseRawValue: PointerPhase.down.rawValue,
            x: 0,
            y: 320,
            observedPresentationRevisionRawValue: 19,
            priorPhysicalSequenceIsCompleteRawValue: 0
        ) == nil
    )
    #expect(
        input.admit(
            phaseRawValue: PointerPhase.down.rawValue,
            x: 0,
            y: 0,
            observedPresentationRevisionRawValue: 19,
            priorPhysicalSequenceIsCompleteRawValue: 2
        ) == nil
    )
    #expect(input.pendingCount == 0)
}

@Test func staticNRFInputABIPacksExactRejectionVocabulary() throws {
    var input = StaticSignalAnalyzerNRFInputABI(sourceRawValue: 73)
    input.installPhysicalPresentation(rawValue: 19)

    let optionalStale = input.admit(
        phaseRawValue: PointerPhase.down.rawValue,
        x: 0,
        y: 0,
        observedPresentationRevisionRawValue: 18,
        priorPhysicalSequenceIsCompleteRawValue: 0
    )
    let stale = try #require(optionalStale)
    #expect(stale.disposition == .dropped)
    #expect(stale.rejection == HostNormalizedInputRejection.stalePresentation.rawValue)
    #expect(stale.packedValue == 0x0102)

    input.quiesce()
    let optionalUnavailable = input.admit(
        phaseRawValue: PointerPhase.down.rawValue,
        x: 0,
        y: 0,
        observedPresentationRevisionRawValue: 19,
        priorPhysicalSequenceIsCompleteRawValue: 0
    )
    let unavailable = try #require(optionalUnavailable)
    #expect(unavailable.disposition == .sourceQuiesced)
    #expect(unavailable.rejection == HostNormalizedInputRejection.inputUnavailable.rawValue)
    #expect(unavailable.packedValue == 0x0303)
}

@Test func staticNRFInputABIDrainsInsideOwnedOpportunity() {
    var input = StaticSignalAnalyzerNRFInputABI(sourceRawValue: 73)
    input.installPhysicalPresentation(rawValue: 19)
    for phase in [PointerPhase.down, .move, .up] {
        #expect(
            input.admit(
                phaseRawValue: phase.rawValue,
                x: 131,
                y: 137,
                observedPresentationRevisionRawValue: 19,
                priorPhysicalSequenceIsCompleteRawValue: 0
            )?.disposition == .queued
        )
    }

    var handler = StaticNRFABIInputHandler()
    #expect(
        input.runOpportunity(into: &handler)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 3,
                    dispatchedActionCount: 0,
                    cancelledOrRejectedCount: 0
                )
            )
    )
    #expect(handler.events.count == 3)
    #expect(input.pendingCount == 0)
}
