enum RecordingFixtureOwnerFailure: UInt32, Equatable, Sendable {
    case stateChange = 0x0101_0001
    case completion = 0x0202_0002
    case semantic = 0x0303_0003
    case layout = 0x0404_0004
    case immutableRenderInput = 0x0505_0005
}

struct RecordingCleanupFaults: OptionSet, Equatable, Sendable {
    let rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue & 0x1F
    }

    static let partialResultDiscard = Self(rawValue: 0x01)
    static let candidateAbort = Self(rawValue: 0x02)
    static let scratchRelease = Self(rawValue: 0x04)
    static let borrowRelease = Self(rawValue: 0x08)
    static let diagnosticWrite = Self(rawValue: 0x10)
}

struct RecordingMandatoryCleanup: OptionSet, Equatable, Sendable {
    let rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue & 0x0F
    }

    static let partialResultsDiscarded = Self(rawValue: 0x01)
    static let candidateAborted = Self(rawValue: 0x02)
    static let scratchReleased = Self(rawValue: 0x04)
    static let borrowsReleased = Self(rawValue: 0x08)
    static let all: Self = [
        .partialResultsDiscarded,
        .candidateAborted,
        .scratchReleased,
        .borrowsReleased,
    ]
}

struct RecordingFocusedFailureSelection: Equatable, Sendable {
    private(set) var firstFailure: RecordingFixtureOwnerFailure?
    private(set) var detectingContext: ExecutionContext?
    private(set) var observedCleanupFaults: RecordingCleanupFaults = []
    private(set) var completedCleanup: RecordingMandatoryCleanup = []
    private(set) var summaryProduced = false

    mutating func captureFirstFocusedFailure(
        _ failure: RecordingFixtureOwnerFailure,
        context: ExecutionContext
    ) {
        guard firstFailure == nil else { return }
        firstFailure = failure
        detectingContext = context
    }

    mutating func completeMandatoryCleanup(
        injecting cleanupFaults: RecordingCleanupFaults,
        summary: RunCycleSummary
    ) -> RunCycleResult<RecordingFixtureOwnerFailure>? {
        guard let firstFailure, let detectingContext else { return nil }

        observedCleanupFaults = cleanupFaults
        completedCleanup = .all
        summaryProduced = true
        return .failure(
            detectingContext,
            .focusedOwner(firstFailure),
            summary
        )
    }
}
