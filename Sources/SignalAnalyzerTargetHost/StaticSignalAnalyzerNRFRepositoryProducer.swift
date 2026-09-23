import SignalAnalyzerDomain

package enum StaticSignalAnalyzerNRFRepositoryProductionOutcome: Equatable {
    case accepted
    case notRunning
    case terminalFailureAdmitted
    case rejected
}

/// Address-free repository/source policy. Callers lend the fixed capture and
/// fact regions only for one synchronous producer turn.
package struct StaticSignalAnalyzerNRFRepositoryProducer {
    private var source = StaticSignalAnalyzerNRFDeterministicSource()
    private var history = StaticSignalAnalyzerNRFCaptureHistory()
    package private(set) var acquisitionState: AcquisitionState = .idle
    private var isObserved = false
    private var isTerminal = false

    package init(initialRevision: UInt32 = 0) {
        history = StaticSignalAnalyzerNRFCaptureHistory(initialRevision: initialRevision)
    }

    package var nextScheduledDelay: Duration? {
        source.nextScheduledDelay
    }

    package mutating func startObservation(
        admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission,
        captureStorage: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFRepositoryProductionOutcome {
        guard !isTerminal, !isObserved,
            admission.beginProducer(.bootstrap)
        else { return .rejected }
        defer { admission.endProducer() }
        guard admission.canAdmitSnapshot,
            var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: captureStorage),
            let snapshot = history.snapshot(in: &regions),
            let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
                storage: captureStorage,
                revision: snapshot.revision,
                count: snapshot.count,
                duration: snapshot.duration,
                retainedLowerBound: snapshot.retainedLowerBound,
                baselineLevels: snapshot.baselineLevels
            ),
            case .accepted = admission.admitSnapshot(view),
            case .accepted = admission.admitAcquisitionState(acquisitionState)
        else { return fail(admission: &admission) }
        isObserved = true
        return .accepted
    }

    package mutating func start(
        admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission,
        captureStorage: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFRepositoryProductionOutcome {
        guard !isTerminal, isObserved else { return .rejected }
        guard acquisitionState != .running else { return .accepted }
        guard admission.beginProducer(.action) else { return .rejected }
        defer { admission.endProducer() }
        guard source.start() != nil,
            var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: captureStorage)
        else { return fail(admission: &admission) }
        while let transition = source.takeInitialTransition() {
            if history.revision == .max {
                return failRevision(admission: &admission)
            }
            guard admit(transition, in: &regions, admission: &admission)
            else { return fail(admission: &admission) }
        }
        acquisitionState = .running
        guard case .accepted = admission.admitAcquisitionState(.running)
        else { return fail(admission: &admission) }
        return .accepted
    }

    package mutating func pollScheduled(
        admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission,
        captureStorage: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFRepositoryProductionOutcome {
        guard !isTerminal, acquisitionState == .running,
            let generation = source.activeGeneration
        else { return .notRunning }
        guard admission.beginProducer(.transition) else { return .rejected }
        defer { admission.endProducer() }
        if history.revision == .max {
            return failRevision(admission: &admission)
        }
        guard let transition = source.deliverScheduledTransition(generation: generation),
            var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: captureStorage),
            admit(transition, in: &regions, admission: &admission)
        else { return fail(admission: &admission) }
        return .accepted
    }

    package mutating func stop(
        admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission
    ) -> StaticSignalAnalyzerNRFRepositoryProductionOutcome {
        guard !isTerminal else { return .rejected }
        guard acquisitionState == .running else { return .accepted }
        guard admission.beginProducer(.action) else { return .rejected }
        defer { admission.endProducer() }
        source.stop()
        acquisitionState = .stopped
        guard case .accepted = admission.admitAcquisitionState(.stopped)
        else { return fail(admission: &admission) }
        return .accepted
    }

    package mutating func clear(
        admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission,
        captureStorage: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFRepositoryProductionOutcome {
        guard !isTerminal, admission.beginProducer(.action) else { return .rejected }
        defer { admission.endProducer() }
        if history.revision == .max {
            return failRevision(admission: &admission)
        }
        guard var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: captureStorage),
            case .accepted(revision: let revision, change: let change) =
                history.clear(in: &regions),
            case .accepted = admission.admitCaptureMutation(
                revision: revision, change: change
            )
        else { return fail(admission: &admission) }
        return .accepted
    }

    package mutating func shutdown() {
        source.shutdown()
        isTerminal = true
    }

    private mutating func admit(
        _ transition: SignalTransition,
        in regions: inout StaticSignalAnalyzerNRFCaptureRegions,
        admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission
    ) -> Bool {
        guard
            case .accepted(revision: let revision, change: let change) =
                history.receive(transition, in: &regions)
        else { return false }
        guard
            case .accepted = admission.admitCaptureMutation(
                revision: revision, change: change
            )
        else { return false }
        return true
    }

    private mutating func fail(
        admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission
    ) -> StaticSignalAnalyzerNRFRepositoryProductionOutcome {
        source.stop()
        isTerminal = true
        return .rejected
    }

    private mutating func failRevision(
        admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission
    ) -> StaticSignalAnalyzerNRFRepositoryProductionOutcome {
        source.stop()
        isTerminal = true
        guard let diagnostic = Self.revisionExhaustedDiagnostic() else {
            return .rejected
        }
        acquisitionState = .failed(diagnostic)
        // The reserved failure remains admissible even when the producer's
        // ordinary compact quota is already exhausted.
        _ = admission.admitAcquisitionState(.failed(diagnostic))
        guard
            case .accepted = admission.admitOperationalFailure(
                conditionRawValue: 5, originRawValue: 2,
                affectedScopeRawValue: 3, containmentRawValue: 1,
                diagnostic: diagnostic
            )
        else { return .rejected }
        return .terminalFailureAdmitted
    }

    private static func revisionExhaustedDiagnostic() -> SignalAnalyzerDiagnostic? {
        var bytes:
            (
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8, UInt8
            ) = (
                99, 97, 112, 116, 117, 114, 101, 32, 114, 101, 118, 105, 115,
                105, 111, 110, 32, 101, 120, 104, 97, 117, 115, 116, 101, 100
            )
        return withUnsafeBytes(of: &bytes) { raw in
            SignalAnalyzerDiagnostic(exactUTF8: raw.bindMemory(to: UInt8.self))
        }
    }
}
