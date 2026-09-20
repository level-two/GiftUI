import GiftUI
import GiftUIExecution
import GiftUIHostConfiguration
import SignalAnalyzerTargetHost
import Testing

private let nrfInputSource = InputSourceID(rawValue: 41)
private let nrfPresentationRevision = PresentationRevision(rawValue: 17)
private let nrfInputContext = ExecutionContext(
    cycle: RunCycleID(rawValue: 3),
    semanticRevision: SemanticRevision(rawValue: 5),
    candidateFrame: CandidateFrameID(rawValue: 7),
    phase: .idle
)

@Test func staticNRFInputAssignsProvenanceAndDrainsInOrder() throws {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    #expect(
        StaticSignalAnalyzerNRFInputCoordinator.capacity
            == preset.runtimeLimits.execution.maximumInputEvents
    )
    var coordinator = StaticSignalAnalyzerNRFInputCoordinator(
        source: nrfInputSource,
        context: nrfInputContext
    )
    let point = Point(x: 19, y: 23)

    #expect(
        coordinator.admit(
            phase: .down,
            position: point,
            source: nrfInputSource,
            observedPresentationRevision: nil
        ) == .dropped(.presentationNotEstablished)
    )
    coordinator.installPhysicalPresentation(nrfPresentationRevision)
    #expect(coordinator.inputIsEligible)

    for phase in [PointerPhase.down, .move, .up] {
        guard
            case .queued = coordinator.admit(
                phase: phase,
                position: point,
                source: nrfInputSource,
                observedPresentationRevision: nrfPresentationRevision
            )
        else {
            Issue.record("expected normalized event admission")
            return
        }
    }
    #expect(coordinator.pendingCount == 3)

    let optionalDown = coordinator.takeNext()
    let optionalMove = coordinator.takeNext()
    let optionalUp = coordinator.takeNext()
    let down = try #require(optionalDown)
    let move = try #require(optionalMove)
    let up = try #require(optionalUp)
    #expect([down.phase, move.phase, up.phase] == [.down, .move, .up])
    #expect([down.ordinal.rawValue, move.ordinal.rawValue, up.ordinal.rawValue] == [0, 1, 2])
    #expect(down.sequence == PointerSequenceID(rawValue: 0))
    #expect(move.sequence == down.sequence)
    #expect(up.sequence == down.sequence)
    #expect(down.source == nrfInputSource)
    #expect(down.presentationRevision == nrfPresentationRevision)
    #expect(down.position == point)
    #expect(coordinator.takeNext() == nil)
}

@Test func staticNRFInputCapacityCancelsTheFirstExcessSequence() throws {
    var coordinator = StaticSignalAnalyzerNRFInputCoordinator(
        source: nrfInputSource,
        context: nrfInputContext
    )
    coordinator.installPhysicalPresentation(nrfPresentationRevision)
    let point = Point(x: 29, y: 31)

    for _ in 0 ..< 2 {
        for phase in [PointerPhase.down, .move, .up] {
            guard
                case .queued = coordinator.admit(
                    phase: phase,
                    position: point,
                    source: nrfInputSource,
                    observedPresentationRevision: nrfPresentationRevision
                )
            else {
                Issue.record("expected event within the generated six-event bound")
                return
            }
        }
    }
    #expect(coordinator.pendingCount == StaticSignalAnalyzerNRFInputCoordinator.capacity)
    #expect(
        coordinator.admit(
            phase: .down,
            position: point,
            source: nrfInputSource,
            observedPresentationRevision: nrfPresentationRevision
        ) == .sequenceCancelled(.runtimeCapacityRefused)
    )

    var drained: [NormalizedPointerEvent] = []
    while let event = coordinator.takeNext() {
        drained.append(event)
    }
    #expect(drained.count == 6)
    #expect(drained.map(\.sequence.rawValue) == [0, 0, 0, 1, 1, 1])
    #expect(drained.map(\.ordinal.rawValue) == [0, 1, 2, 0, 1, 2])

    guard
        case .queued(let replacement) = coordinator.admit(
            phase: .down,
            position: point,
            source: nrfInputSource,
            observedPresentationRevision: nrfPresentationRevision,
            priorPhysicalSequenceIsComplete: true
        )
    else {
        Issue.record("expected fixed storage reuse after a refused physical sequence")
        return
    }
    #expect(replacement.sequence == PointerSequenceID(rawValue: 3))
    #expect(replacement.ordinal == InputOrdinal(rawValue: 0))
    #expect(coordinator.pendingCount == 1)
}

@Test func staticNRFInputRejectsStalePresentationAndQuiescesStorage() {
    var coordinator = StaticSignalAnalyzerNRFInputCoordinator(
        source: nrfInputSource,
        context: nrfInputContext
    )
    coordinator.installPhysicalPresentation(nrfPresentationRevision)
    let point = Point(x: 37, y: 43)

    #expect(
        coordinator.admit(
            phase: .down,
            position: point,
            source: nrfInputSource,
            observedPresentationRevision: PresentationRevision(rawValue: 16)
        ) == .dropped(.stalePresentation)
    )
    guard
        case .queued = coordinator.admit(
            phase: .down,
            position: point,
            source: nrfInputSource,
            observedPresentationRevision: nrfPresentationRevision
        )
    else {
        Issue.record("expected current presentation admission")
        return
    }
    coordinator.quiesce()

    #expect(!coordinator.inputIsEligible)
    #expect(coordinator.pendingCount == 0)
    #expect(coordinator.takeNext() == nil)
    #expect(
        coordinator.admit(
            phase: .up,
            position: point,
            source: nrfInputSource,
            observedPresentationRevision: nrfPresentationRevision
        ) == .sourceQuiesced(.inputUnavailable)
    )
}
