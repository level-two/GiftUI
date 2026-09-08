import GiftUI

struct RecordingPartialDerivation: OptionSet, Equatable, Sendable {
    let rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue & 0x1F
    }

    static let semantic = Self(rawValue: 0x01)
    static let layout = Self(rawValue: 0x02)
    static let actionTable = Self(rawValue: 0x04)
    static let routing = Self(rawValue: 0x08)
    static let immutableRenderInput = Self(rawValue: 0x10)
}

enum RecordingPrepublicationFailurePoint: UInt8, Equatable, Sendable {
    case semantic = 0
    case layout = 1
    case actionTable = 2
    case routing = 3
    case immutableRenderInput = 4

    var partialResults: RecordingPartialDerivation {
        switch self {
        case .semantic:
            return .semantic
        case .layout:
            return [.semantic, .layout]
        case .actionTable:
            return [.semantic, .layout, .actionTable]
        case .routing:
            return [.semantic, .layout, .actionTable, .routing]
        case .immutableRenderInput:
            return [
                .semantic,
                .layout,
                .actionTable,
                .routing,
                .immutableRenderInput,
            ]
        }
    }
}

struct RecordingDerivationRecovery<Requester>: Sendable
where Requester: ExecutionWakeRequester & Sendable {
    private(set) var publishedRevision: SemanticRevision?
    private(set) var stagedResults: RecordingPartialDerivation = []
    private(set) var discardedResults: RecordingPartialDerivation = []
    private(set) var appliedEffectCount: UInt16 = 0
    private(set) var isDirty = false
    private(set) var cycleActive = false
    private(set) var wakeAccumulator: ExecutionWakeAccumulator<Requester>

    init(
        publishedRevision: SemanticRevision?,
        requester: Requester
    ) {
        self.publishedRevision = publishedRevision
        wakeAccumulator = ExecutionWakeAccumulator(requester: requester)
    }

    mutating func beginMutationCycle(
        applying effectCount: UInt16
    ) -> ExecutionError? {
        guard !cycleActive else { return .reentrancyViolation }
        let (total, overflow) = appliedEffectCount.addingReportingOverflow(effectCount)
        guard !overflow else { return .arithmeticOverflow }
        appliedEffectCount = total
        cycleActive = true
        return nil
    }

    mutating func stage(
        through point: RecordingPrepublicationFailurePoint
    ) -> ExecutionError? {
        guard cycleActive else { return .invalidPhase }
        stagedResults = point.partialResults
        return nil
    }

    mutating func fail(
        at point: RecordingPrepublicationFailurePoint,
        cycle: RunCycleID,
        admission: AdmissionSummary,
        committedPresentationRevision: PresentationRevision?
    ) -> RunCycleResult<RecordingCycleOwnerFailure>? {
        guard cycleActive else { return nil }
        stagedResults = point.partialResults
        discardedResults = stagedResults
        stagedResults = []

        let disposition: SemanticCycleDisposition
        if appliedEffectCount > 0 || isDirty {
            isDirty = true
            disposition = .dirty
            wakeAccumulator.accumulate(.semanticDirty)
        } else {
            disposition = .unchanged
        }
        cycleActive = false

        guard
            let summary = RunCycleSummary(
                cycle: cycle,
                admission: admission,
                semanticRevision: publishedRevision,
                semanticDisposition: disposition,
                logicalFrameDisposition: .notProduced,
                committedPresentationRevision: committedPresentationRevision,
                presentationIntentState: .satisfied,
                presentationPending: nil,
                operationalEvents: []
            )
        else { return nil }

        let context = ExecutionContext(
            cycle: cycle,
            semanticRevision: publishedRevision,
            candidateFrame: nil,
            phase: .deriving
        )
        return .failure(context, .focusedOwner(.injected), summary)
    }

    mutating func takeRecoveryWakeAtIdle() -> ExecutionWakeReasons? {
        wakeAccumulator.takeAtIdleOpportunity(phase: .idle)
    }

    mutating func beginRecovery() -> ExecutionError? {
        guard !cycleActive else { return .reentrancyViolation }
        guard isDirty, !wakeAccumulator.wakeOutstanding else {
            return .invalidPhase
        }
        cycleActive = true
        return nil
    }

    mutating func completeRecovery(
        publishing semanticRevision: SemanticRevision
    ) -> ExecutionError? {
        guard cycleActive, isDirty else { return .invalidPhase }
        publishedRevision = semanticRevision
        stagedResults = []
        discardedResults = []
        isDirty = false
        cycleActive = false
        return nil
    }
}
