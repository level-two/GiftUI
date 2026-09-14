import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIHostConfiguration

private struct InputSink: ExecutionAdmissionSink {
    typealias StateChangeFact = UInt8
    typealias CompletionFact = UInt8

    var maximumPointers: Int
    var forcedResult: ExecutionAdmissionResult? = nil
    private(set) var pointers: [NormalizedPointerEvent] = []

    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome {
        let result =
            forcedResult
            ?? (pointers.count < maximumPointers ? .queued : .capacityRefused)
        if result == .queued { pointers.append(pointer) }
        return outcome(result)
    }

    mutating func submit(stateChange: UInt8) -> ExecutionAdmissionOutcome {
        _ = stateChange
        return outcome(.invalidValue)
    }

    mutating func submit(completion: UInt8) -> ExecutionAdmissionOutcome {
        _ = completion
        return outcome(.invalidValue)
    }

    private func outcome(_ result: ExecutionAdmissionResult) -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(
            result: result,
            context: ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            )
        )
    }
}

private let inputSource = InputSourceID(rawValue: 0)
private let otherInputSource = InputSourceID(rawValue: 1)
private let presentedRevision = PresentationRevision(rawValue: 7)
private let inputPoint = Point(x: 4, y: 5)

@Test func localDropsConsumeNoRuntimeSequenceOrQueueCapacity() {
    var gate = HostNormalizedInputGate(configuredSource: inputSource)
    var sink = InputSink(maximumPointers: 8)

    #expect(
        submitDown(to: &gate, sink: &sink, revision: nil)
            == .dropped(.presentationNotEstablished)
    )
    gate.installPhysicalPresentation(presentedRevision)
    #expect(
        submitDown(to: &gate, sink: &sink, source: otherInputSource)
            == .dropped(.unknownSource)
    )
    #expect(
        submitDown(to: &gate, sink: &sink, malformed: true)
            == .dropped(.malformed)
    )
    #expect(
        submitDown(
            to: &gate,
            sink: &sink,
            revision: PresentationRevision(rawValue: 6)
        ) == .dropped(.stalePresentation)
    )

    let accepted = submitDown(to: &gate, sink: &sink)
    guard case .queued(let event) = accepted else {
        Issue.record("expected first submitted down")
        return
    }
    #expect(event.sequence == PointerSequenceID(rawValue: 0))
    #expect(event.ordinal == InputOrdinal(rawValue: 0))
    #expect(event.presentationRevision == presentedRevision)
    #expect(sink.pointers == [event])
}

@Test func phasesUseExactSequenceAndOrdinalSuccessors() {
    var gate = HostNormalizedInputGate(configuredSource: inputSource)
    gate.installPhysicalPresentation(presentedRevision)
    var sink = InputSink(maximumPointers: 3)

    _ = submitDown(to: &gate, sink: &sink)
    let move = gate.submit(
        phase: .move,
        position: inputPoint,
        source: inputSource,
        observedPresentationRevision: presentedRevision,
        isMalformed: false,
        priorPhysicalSequenceIsComplete: false,
        to: &sink
    )
    let up = gate.submit(
        phase: .up,
        position: inputPoint,
        source: inputSource,
        observedPresentationRevision: presentedRevision,
        isMalformed: false,
        priorPhysicalSequenceIsComplete: false,
        to: &sink
    )

    guard case .queued(let moveEvent) = move,
        case .queued(let upEvent) = up
    else {
        Issue.record("expected complete queued sequence")
        return
    }
    #expect(moveEvent.sequence == PointerSequenceID(rawValue: 0))
    #expect(moveEvent.ordinal == InputOrdinal(rawValue: 1))
    #expect(upEvent.sequence == PointerSequenceID(rawValue: 0))
    #expect(upEvent.ordinal == InputOrdinal(rawValue: 2))
}

@Test func configuredBoundSucceedsAndFirstExcessCancelsNewSequence() {
    var gate = HostNormalizedInputGate(configuredSource: inputSource)
    gate.installPhysicalPresentation(presentedRevision)
    let configuredLimit = Int(
        GeneratedSignalAnalyzerPresets.nrf52840Static()
            .runtimeLimits.execution.maximumInputEvents
    )
    #expect(configuredLimit == 6)
    var sink = InputSink(maximumPointers: configuredLimit)

    for _ in 0 ..< 2 {
        _ = submitDown(to: &gate, sink: &sink)
        _ = gate.submit(
            phase: .move,
            position: inputPoint,
            source: inputSource,
            observedPresentationRevision: presentedRevision,
            isMalformed: false,
            priorPhysicalSequenceIsComplete: false,
            to: &sink
        )
        _ = gate.submit(
            phase: .up,
            position: inputPoint,
            source: inputSource,
            observedPresentationRevision: presentedRevision,
            isMalformed: false,
            priorPhysicalSequenceIsComplete: false,
            to: &sink
        )
    }
    #expect(sink.pointers.count == configuredLimit)

    #expect(
        submitDown(to: &gate, sink: &sink)
            == .sequenceCancelled(.runtimeCapacityRefused)
    )
    #expect(sink.pointers.count == configuredLimit)
    #expect(
        gate.submit(
            phase: .move,
            position: inputPoint,
            source: inputSource,
            observedPresentationRevision: presentedRevision,
            isMalformed: false,
            priorPhysicalSequenceIsComplete: false,
            to: &sink
        ) == .dropped(.outOfOrder)
    )
}

@Test func replacementDownRequiresCompletedPhysicalSequenceProof() {
    var gate = HostNormalizedInputGate(configuredSource: inputSource)
    gate.installPhysicalPresentation(presentedRevision)
    var sink = InputSink(maximumPointers: 8)

    _ = submitDown(to: &gate, sink: &sink)
    #expect(
        submitDown(to: &gate, sink: &sink)
            == .dropped(.resynchronizationNotProven)
    )
    let replacement = submitDown(
        to: &gate,
        sink: &sink,
        priorPhysicalSequenceIsComplete: true
    )
    guard case .queued(let event) = replacement else {
        Issue.record("expected proven replacement down")
        return
    }
    #expect(event.sequence == PointerSequenceID(rawValue: 1))
    #expect(event.ordinal == InputOrdinal(rawValue: 0))
}

@Test func maximumSequenceIsSubmittedOnceThenSourceQuiesces() {
    var gate = HostNormalizedInputGate(
        configuredSource: inputSource,
        nextSubmittedSequenceRaw: .max
    )
    gate.installPhysicalPresentation(presentedRevision)
    var sink = InputSink(maximumPointers: 8)

    guard case .queued(let event) = submitDown(to: &gate, sink: &sink) else {
        Issue.record("expected maximum sequence down")
        return
    }
    #expect(event.sequence == PointerSequenceID(rawValue: .max))
    #expect(
        submitDown(
            to: &gate,
            sink: &sink,
            priorPhysicalSequenceIsComplete: true
        ) == .sourceQuiesced(.sequenceExhausted)
    )
    #expect(!gate.inputIsEligible)
}

@Test(arguments: [
    (
        ExecutionAdmissionResult.unavailable,
        HostNormalizedInputDisposition.sourceQuiesced(.runtimeUnavailable)
    ),
    (.invalidValue, .sequenceCancelled(.runtimeInvalidValue)),
    (.invalidProvenance, .sequenceCancelled(.runtimeInvalidProvenance)),
])
func runtimeRejectionVocabularyIsPreservedAndCancels(
    runtimeResult: ExecutionAdmissionResult,
    expected: HostNormalizedInputDisposition
) {
    var gate = HostNormalizedInputGate(configuredSource: inputSource)
    gate.installPhysicalPresentation(presentedRevision)
    var sink = InputSink(maximumPointers: 8, forcedResult: runtimeResult)

    #expect(submitDown(to: &gate, sink: &sink) == expected)
}

private func submitDown(
    to gate: inout HostNormalizedInputGate,
    sink: inout InputSink,
    source: InputSourceID = inputSource,
    revision: PresentationRevision? = presentedRevision,
    malformed: Bool = false,
    priorPhysicalSequenceIsComplete: Bool = false
) -> HostNormalizedInputDisposition {
    gate.submit(
        phase: .down,
        position: inputPoint,
        source: source,
        observedPresentationRevision: revision,
        isMalformed: malformed,
        priorPhysicalSequenceIsComplete: priorPhysicalSequenceIsComplete,
        to: &sink
    )
}
