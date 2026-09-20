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

private struct StaticNRFRecordingInputHandler: StaticSignalAnalyzerNRFInputHandler {
    private(set) var events: [NormalizedPointerEvent] = []

    mutating func handle(
        _ event: NormalizedPointerEvent
    ) -> StaticSignalAnalyzerNRFInputHandling {
        events.append(event)
        return switch event.phase {
        case .down: .consumed
        case .move: .cancelledOrRejected
        case .up: .dispatched
        }
    }
}

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

    var handler = StaticNRFRecordingInputHandler()
    #expect(
        coordinator.runOpportunity(into: &handler)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 3,
                    dispatchedActionCount: 1,
                    cancelledOrRejectedCount: 1
                )
            )
    )
    let down = try #require(handler.events.first)
    let move = try #require(handler.events.dropFirst().first)
    let up = try #require(handler.events.last)
    #expect([down.phase, move.phase, up.phase] == [.down, .move, .up])
    #expect([down.ordinal.rawValue, move.ordinal.rawValue, up.ordinal.rawValue] == [0, 1, 2])
    #expect(down.sequence == PointerSequenceID(rawValue: 0))
    #expect(move.sequence == down.sequence)
    #expect(up.sequence == down.sequence)
    #expect(down.source == nrfInputSource)
    #expect(down.presentationRevision == nrfPresentationRevision)
    #expect(down.position == point)
    #expect(coordinator.pendingCount == 0)
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

    var handler = StaticNRFRecordingInputHandler()
    guard case .completed = coordinator.runOpportunity(into: &handler) else {
        Issue.record("expected bounded opportunity drain")
        return
    }
    let drained = handler.events
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
    #expect(
        coordinator.admit(
            phase: .up,
            position: point,
            source: nrfInputSource,
            observedPresentationRevision: nrfPresentationRevision
        ) == .sourceQuiesced(.inputUnavailable)
    )
}

@Test func staticNRFInputDrainsOnlyThroughSerializedOpportunity() {
    var coordinator = StaticSignalAnalyzerNRFInputCoordinator(
        source: nrfInputSource,
        context: nrfInputContext
    )
    coordinator.installPhysicalPresentation(nrfPresentationRevision)
    let point = Point(x: 47, y: 53)
    for phase in [PointerPhase.down, .move, .up] {
        guard
            case .queued = coordinator.admit(
                phase: phase,
                position: point,
                source: nrfInputSource,
                observedPresentationRevision: nrfPresentationRevision
            )
        else {
            Issue.record("expected event admission before opportunity")
            return
        }
    }

    var handler = StaticNRFRecordingInputHandler()
    #expect(
        coordinator.runOpportunity(into: &handler)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 3,
                    dispatchedActionCount: 1,
                    cancelledOrRejectedCount: 1
                )
            )
    )
    #expect(handler.events.map(\.phase) == [.down, .move, .up])
    #expect(coordinator.pendingCount == 0)
    #expect(
        coordinator.runOpportunity(into: &handler)
            == .completed(
                StaticSignalAnalyzerNRFInputDrainSummary(
                    eventCount: 0,
                    dispatchedActionCount: 0,
                    cancelledOrRejectedCount: 0
                )
            )
    )

    coordinator.quiesce()
    #expect(
        coordinator.runOpportunity(into: &handler)
            == .rejected(.application(.unavailable))
    )
}
