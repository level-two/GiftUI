import GiftUI

enum RecordingCyclePath: UInt8, Equatable, Sendable {
    case unchanged = 0
    case publishedAndOffered = 1
}

enum RecordingCycleEventKind: UInt8, Equatable, Sendable {
    case wakeTransition = 0
    case wakeTaken = 1
    case admitting = 2
    case mutating = 3
    case deriving = 4
    case publishing = 5
    case offering = 6
    case finalizing = 7
    case resultSelected = 8
    case idleAuthoritativeState = 9
}

struct RecordingCycleEvent: Equatable, Sendable {
    let kind: RecordingCycleEventKind
    let context: ExecutionContext
    let wakeReasons: ExecutionWakeReasons
    let committedPresentationRevision: PresentationRevision?
}

protocol RecordingCycleEventSink: Sendable {
    mutating func record(_ event: borrowing RecordingCycleEvent)
}

enum RecordingCycleOwnerFailure: UInt8, Equatable, Sendable {
    case injected = 0
}

struct RecordingCycleCoordinator<Sink, Requester>:
    ExecutionOpportunityRunner, Sendable
where
    Sink: RecordingCycleEventSink,
    Requester: ExecutionWakeRequester & Sendable
{
    typealias OwnerFailure = RecordingCycleOwnerFailure

    private let path: RecordingCyclePath
    private let emptyAdmission: AdmissionSummary
    private var phases = ExecutionPhaseMachine()
    private var cycles = RunCycleIDAllocator()
    private var semanticRevisions = SemanticRevisionAllocator()
    private var candidateFrames = CandidateFrameIDAllocator()
    private var presentationRevisions = PresentationRevisionAllocator()
    private(set) var wakeAccumulator: ExecutionWakeAccumulator<Requester>
    private(set) var sink: Sink
    private var committedPresentationRevision: PresentationRevision?

    init?(
        path: RecordingCyclePath,
        limits: ExecutionLimits,
        sink: Sink,
        requester: Requester
    ) {
        guard
            let emptyAdmission = AdmissionSummary(
                inputEventCount: 0,
                stateChangeFactCount: 0,
                completionFactCount: 0,
                semanticActionCount: 0,
                includesDirtyRederivation: false,
                includesPresentationRecovery: false,
                limits: limits
            )
        else { return nil }
        self.path = path
        self.emptyAdmission = emptyAdmission
        self.sink = sink
        wakeAccumulator = ExecutionWakeAccumulator(requester: requester)
    }

    mutating func requestWake(_ reasons: ExecutionWakeReasons) {
        let wasOutstanding = wakeAccumulator.wakeOutstanding
        wakeAccumulator.accumulate(reasons)
        guard !wasOutstanding, wakeAccumulator.wakeOutstanding else { return }
        record(.wakeTransition, wakeReasons: wakeAccumulator.accumulatedReasons)
    }

    mutating func runOpportunity() -> RunCycleResult<RecordingCycleOwnerFailure> {
        guard phases.context.phase == .idle else {
            return .failure(
                phases.context,
                .execution(.reentrancyViolation),
                nil
            )
        }
        let taken = wakeAccumulator.takeAtIdleOpportunity(phase: phases.context.phase) ?? []
        record(.wakeTaken, wakeReasons: taken)
        if let failure = phases.beginCycle(reservingFrom: &cycles) {
            return .failure(
                phases.context,
                .execution(failure),
                nil
            )
        }
        record(.admitting)
        transition(to: .mutating, event: .mutating)
        transition(to: .deriving, event: .deriving)

        let summary: RunCycleSummary?
        switch path {
        case .unchanged:
            summary = unchangedSummary()
        case .publishedAndOffered:
            summary = publishedSummary()
        }
        guard let summary else {
            let context = phases.context
            finalize(resultSelected: true)
            return .failure(
                context,
                .execution(.invariantViolation),
                nil
            )
        }

        finalize(resultSelected: true)
        switch path {
        case .unchanged:
            return .operational(.noChange, summary)
        case .publishedAndOffered:
            return .success(summary)
        }
    }

    private mutating func unchangedSummary() -> RunCycleSummary? {
        guard let cycle = phases.context.cycle else { return nil }
        return RunCycleSummary(
            cycle: cycle,
            admission: emptyAdmission,
            semanticRevision: phases.context.semanticRevision,
            semanticDisposition: .unchanged,
            logicalFrameDisposition: .notProduced,
            committedPresentationRevision: committedPresentationRevision,
            presentationIntentState: .satisfied,
            presentationPending: nil,
            operationalEvents: .noChange
        )
    }

    private mutating func publishedSummary() -> RunCycleSummary? {
        guard
            let cycle = phases.context.cycle,
            let semantic = semanticRevisions.reserve(),
            let candidate = candidateFrames.reserve(),
            let presentation = presentationRevisions.reserve()
        else { return nil }
        transition(to: .publishing, event: .publishing)
        guard phases.recordPublishedSemanticRevision(semantic) == nil,
            phases.recordCandidateFrame(candidate) == nil
        else { return nil }
        transition(to: .offering, event: .offering)
        committedPresentationRevision = presentation
        return RunCycleSummary(
            cycle: cycle,
            admission: emptyAdmission,
            semanticRevision: semantic,
            semanticDisposition: .published,
            logicalFrameDisposition: .committed,
            committedPresentationRevision: presentation,
            presentationIntentState: .satisfied,
            presentationPending: nil,
            operationalEvents: []
        )
    }

    private mutating func transition(
        to phase: ExecutionPhase,
        event: RecordingCycleEventKind
    ) {
        guard phases.transition(to: phase) == nil else { return }
        record(event)
    }

    private mutating func finalize(resultSelected: Bool) {
        transition(to: .finalizing, event: .finalizing)
        if resultSelected { record(.resultSelected) }
        guard phases.transition(to: .idle) == nil else { return }
        record(.idleAuthoritativeState)
    }

    private mutating func record(
        _ kind: RecordingCycleEventKind,
        wakeReasons: ExecutionWakeReasons = []
    ) {
        sink.record(
            RecordingCycleEvent(
                kind: kind,
                context: phases.context,
                wakeReasons: wakeReasons,
                committedPresentationRevision: committedPresentationRevision
            )
        )
    }
}
