import SignalAnalyzerDomain

package enum StaticSignalAnalyzerNRFProducerCategory: UInt8 {
    case transition = 0
    case bootstrap = 1
    case action = 2

    fileprivate var limit: UInt16 {
        switch self {
        case .transition: 20
        case .bootstrap: 2
        case .action: 6
        }
    }
}

package enum StaticSignalAnalyzerNRFCaptureAdmissionOutcome: Equatable {
    case accepted(sequence: UInt32)
    case producerUnavailable
    case producerCapacityExhausted
    case snapshotCapacityExhausted
    case reservedFailureCapacityExhausted
    case compactCapacityExhausted
    case sequenceExhausted
    case unrepresentable
}

package enum StaticSignalAnalyzerNRFSealedCaptureFact {
    case snapshot(StaticSignalAnalyzerNRFSnapshotFact)
    case compact(StaticSignalAnalyzerNRFCompactPresentationFact)
    case operationalFailure(StaticSignalAnalyzerNRFOperationalFailureFact)

    package var sequence: UInt32 {
        switch self {
        case .snapshot(let fact): fact.sequence
        case .compact(let fact): fact.sequence
        case .operationalFailure(let fact): fact.sequence
        }
    }

    package var captureMutation: (revision: UInt32, change: SignalCaptureChange)? {
        switch self {
        case .snapshot: nil
        case .operationalFailure: nil
        case .compact(let fact):
            if case .captureMutation(let mutation) = fact.payload {
                mutation.publication
            } else {
                nil
            }
        }
    }

    package var acquisitionState: AcquisitionState? {
        if case .compact(let fact) = self,
            case .acquisitionState(let state) = fact.payload
        {
            return state
        }
        return nil
    }

    package var operationalFailure: StaticSignalAnalyzerNRFOperationalFailureFact? {
        if case .operationalFailure(let fact) = self { return fact }
        return nil
    }
}

/// Capture-mutation admission over the two exact profile regions. All
/// counters, producer state, and sequence state reside in active ring reserve.
package struct StaticSignalAnalyzerNRFCaptureFactAdmission: ~Copyable {
    private var active: StaticSignalAnalyzerNRFCompactFactRing
    private var sealed: StaticSignalAnalyzerNRFCompactFactRing
    private let metadata: UnsafeMutableRawPointer
    private let sealedMetadata: UnsafeMutableRawPointer

    package init?(
        activeStorage: UnsafeMutableRawBufferPointer,
        sealedStorage: UnsafeMutableRawBufferPointer,
        nextSequence: UInt32 = 1
    ) {
        guard nextSequence != 0,
            activeStorage.baseAddress != sealedStorage.baseAddress,
            let active = StaticSignalAnalyzerNRFCompactFactRing(storage: activeStorage),
            let sealed = StaticSignalAnalyzerNRFCompactFactRing(storage: sealedStorage)
        else { return nil }
        self.active = consume active
        self.sealed = consume sealed
        metadata = activeStorage.baseAddress!.advanced(by: 3_584)
        sealedMetadata = sealedStorage.baseAddress!.advanced(by: 3_584)
        metadata.storeBytes(of: nextSequence, toByteOffset: 8, as: UInt32.self)
        metadata.storeBytes(of: UInt8.max, toByteOffset: 18, as: UInt8.self)
        metadata.storeBytes(of: UInt8(1), toByteOffset: 19, as: UInt8.self)
    }

    /// Restores the same fixed regions at the next serialized opportunity.
    /// The producer must have ended before the previous borrow returned.
    package init?(
        resumingActiveStorage activeStorage: UnsafeMutableRawBufferPointer,
        sealedStorage: UnsafeMutableRawBufferPointer
    ) {
        guard activeStorage.baseAddress != sealedStorage.baseAddress,
            let active = StaticSignalAnalyzerNRFCompactFactRing(resuming: activeStorage),
            let sealed = StaticSignalAnalyzerNRFCompactFactRing(resuming: sealedStorage)
        else { return nil }
        let activeMetadata = activeStorage.baseAddress!.advanced(by: 3_584)
        let priorSealedMetadata = sealedStorage.baseAddress!.advanced(by: 3_584)
        guard activeMetadata.load(fromByteOffset: 8, as: UInt32.self) != 0,
            activeMetadata.load(fromByteOffset: 18, as: UInt8.self) == UInt8.max,
            activeMetadata.load(fromByteOffset: 19, as: UInt8.self) == 1,
            activeMetadata.load(fromByteOffset: 20, as: UInt8.self) <= 1,
            activeMetadata.load(fromByteOffset: 21, as: UInt8.self) <= 1,
            priorSealedMetadata.load(fromByteOffset: 20, as: UInt8.self) <= 1,
            priorSealedMetadata.load(fromByteOffset: 21, as: UInt8.self) <= 1
        else { return nil }
        self.active = consume active
        self.sealed = consume sealed
        metadata = activeMetadata
        sealedMetadata = priorSealedMetadata
    }

    package var pendingCompactCount: UInt16 { active.count }
    package var sealedCompactCount: UInt16 { sealed.count }
    package var pendingSnapshotCount: UInt8 { activeSnapshot == nil ? 0 : 1 }
    package var sealedSnapshotCount: UInt8 { sealedSnapshot == nil ? 0 : 1 }
    package var pendingOperationalFailureCount: UInt8 { activeFailure == nil ? 0 : 1 }
    package var sealedOperationalFailureCount: UInt8 { sealedFailure == nil ? 0 : 1 }

    /// The producer checks this before copying live records into the one
    /// admitted snapshot slot. The application executor keeps that check and
    /// the subsequent admission in one synchronous turn.
    package var canAdmitSnapshot: Bool {
        guard isAvailable, let producer = activeProducer,
            activeSnapshot == nil, sealedSnapshot == nil,
            metadata.load(fromByteOffset: 8, as: UInt32.self) != 0
        else { return false }
        let count = metadata.load(
            fromByteOffset: countOffset(for: producer), as: UInt16.self
        )
        return count < producer.limit
    }

    package mutating func beginProducer(_ category: StaticSignalAnalyzerNRFProducerCategory)
        -> Bool
    {
        guard isAvailable, activeProducer == nil else { return false }
        metadata.storeBytes(of: category.rawValue, toByteOffset: 18, as: UInt8.self)
        return true
    }

    package mutating func endProducer() {
        metadata.storeBytes(of: UInt8.max, toByteOffset: 18, as: UInt8.self)
    }

    package mutating func admitCaptureMutation(
        revision: UInt32, change: SignalCaptureChange
    ) -> StaticSignalAnalyzerNRFCaptureAdmissionOutcome {
        guard isAvailable, let producer = activeProducer else {
            return .producerUnavailable
        }
        let offset = countOffset(for: producer)
        let count = metadata.load(fromByteOffset: offset, as: UInt16.self)
        guard count < producer.limit else { return .producerCapacityExhausted }
        guard active.count < StaticSignalAnalyzerNRFCompactFactRing.capacity else {
            return .compactCapacityExhausted
        }
        let sequence = metadata.load(fromByteOffset: 8, as: UInt32.self)
        guard sequence != 0 else { return .sequenceExhausted }
        guard
            let mutation = StaticSignalAnalyzerNRFCompactCaptureFact(
                sequence: sequence, revision: revision, change: change
            ),
            let fact = StaticSignalAnalyzerNRFCompactPresentationFact(
                sequence: sequence, payload: .captureMutation(mutation)
            )
        else { return .unrepresentable }
        guard active.append(fact) else { return .compactCapacityExhausted }
        metadata.storeBytes(
            of: sequence == .max ? UInt32(0) : sequence + 1,
            toByteOffset: 8, as: UInt32.self
        )
        metadata.storeBytes(of: count + 1, toByteOffset: offset, as: UInt16.self)
        return .accepted(sequence: sequence)
    }

    package mutating func admitAcquisitionState(
        _ state: AcquisitionState
    ) -> StaticSignalAnalyzerNRFCaptureAdmissionOutcome {
        guard isAvailable, let producer = activeProducer else {
            return .producerUnavailable
        }
        let offset = countOffset(for: producer)
        let count = metadata.load(fromByteOffset: offset, as: UInt16.self)
        guard count < producer.limit else { return .producerCapacityExhausted }
        guard active.count < StaticSignalAnalyzerNRFCompactFactRing.capacity else {
            return .compactCapacityExhausted
        }
        let sequence = metadata.load(fromByteOffset: 8, as: UInt32.self)
        guard sequence != 0 else { return .sequenceExhausted }
        guard
            let fact = StaticSignalAnalyzerNRFCompactPresentationFact(
                sequence: sequence, payload: .acquisitionState(state)
            )
        else { return .unrepresentable }
        guard active.append(fact) else { return .compactCapacityExhausted }
        metadata.storeBytes(
            of: sequence == .max ? UInt32(0) : sequence + 1,
            toByteOffset: 8, as: UInt32.self
        )
        metadata.storeBytes(of: count + 1, toByteOffset: offset, as: UInt16.self)
        return .accepted(sequence: sequence)
    }

    package mutating func admitSnapshot(
        _ snapshot: borrowing StaticSignalAnalyzerNRFCaptureSnapshotView
    ) -> StaticSignalAnalyzerNRFCaptureAdmissionOutcome {
        guard isAvailable, let producer = activeProducer else {
            return .producerUnavailable
        }
        let offset = countOffset(for: producer)
        let count = metadata.load(fromByteOffset: offset, as: UInt16.self)
        guard count < producer.limit else { return .producerCapacityExhausted }
        guard activeSnapshot == nil, sealedSnapshot == nil else {
            return .snapshotCapacityExhausted
        }
        let sequence = metadata.load(fromByteOffset: 8, as: UInt32.self)
        guard sequence != 0 else { return .sequenceExhausted }
        guard
            let fact = StaticSignalAnalyzerNRFSnapshotFact(
                sequence: sequence, snapshot: snapshot
            )
        else { return .unrepresentable }
        metadata.storeBytes(
            of: fact, toByteOffset: 32, as: StaticSignalAnalyzerNRFSnapshotFact.self)
        metadata.storeBytes(of: UInt8(1), toByteOffset: 20, as: UInt8.self)
        metadata.storeBytes(
            of: sequence == .max ? UInt32(0) : sequence + 1,
            toByteOffset: 8, as: UInt32.self
        )
        metadata.storeBytes(of: count + 1, toByteOffset: offset, as: UInt16.self)
        return .accepted(sequence: sequence)
    }

    /// Operational failures have their own physical slot and do not consume
    /// producer quotas or ordinary compact capacity.
    package mutating func admitOperationalFailure(
        conditionRawValue: UInt16,
        originRawValue: UInt8,
        affectedScopeRawValue: UInt8,
        containmentRawValue: UInt8,
        diagnostic: SignalAnalyzerDiagnostic
    ) -> StaticSignalAnalyzerNRFCaptureAdmissionOutcome {
        guard isAvailable else { return .producerUnavailable }
        guard activeFailure == nil, sealedFailure == nil else {
            return .reservedFailureCapacityExhausted
        }
        let sequence = metadata.load(fromByteOffset: 8, as: UInt32.self)
        guard sequence != 0 else { return .sequenceExhausted }
        guard MemoryLayout<StaticSignalAnalyzerNRFOperationalFailureFact>.stride <= 112,
            let fact = StaticSignalAnalyzerNRFOperationalFailureFact(
                sequence: sequence,
                conditionRawValue: conditionRawValue,
                originRawValue: originRawValue,
                affectedScopeRawValue: affectedScopeRawValue,
                containmentRawValue: containmentRawValue,
                diagnostic: diagnostic
            )
        else { return .unrepresentable }
        metadata.storeBytes(
            of: fact, toByteOffset: 80,
            as: StaticSignalAnalyzerNRFOperationalFailureFact.self
        )
        metadata.storeBytes(of: UInt8(1), toByteOffset: 21, as: UInt8.self)
        metadata.storeBytes(
            of: sequence == .max ? UInt32(0) : sequence + 1,
            toByteOffset: 8, as: UInt32.self
        )
        return .accepted(sequence: sequence)
    }

    package mutating func seal() -> Bool {
        guard isAvailable, activeProducer == nil,
            active.count > 0 || activeSnapshot != nil || activeFailure != nil,
            sealed.count == 0, sealedSnapshot == nil, sealedFailure == nil
        else {
            return false
        }
        if active.count > 0, !active.seal(into: &sealed) { return false }
        if let snapshot = activeSnapshot {
            sealedMetadata.storeBytes(
                of: snapshot, toByteOffset: 32, as: StaticSignalAnalyzerNRFSnapshotFact.self
            )
            sealedMetadata.storeBytes(of: UInt8(1), toByteOffset: 20, as: UInt8.self)
            metadata.storeBytes(of: UInt8(0), toByteOffset: 20, as: UInt8.self)
        }
        if let failure = activeFailure {
            sealedMetadata.storeBytes(
                of: failure, toByteOffset: 80,
                as: StaticSignalAnalyzerNRFOperationalFailureFact.self
            )
            sealedMetadata.storeBytes(of: UInt8(1), toByteOffset: 21, as: UInt8.self)
            metadata.storeBytes(of: UInt8(0), toByteOffset: 21, as: UInt8.self)
        }
        for offset in stride(from: 12, through: 16, by: 2) {
            metadata.storeBytes(of: UInt16(0), toByteOffset: offset, as: UInt16.self)
        }
        return true
    }

    package mutating func takeNextSealed() -> StaticSignalAnalyzerNRFSealedCaptureFact? {
        let snapshot = sealedSnapshot
        let failure = sealedFailure
        let compact = sealed.first
        if let snapshot,
            compact == nil || snapshot.sequence < compact!.sequence,
            failure == nil || snapshot.sequence < failure!.sequence
        {
            sealedMetadata.storeBytes(of: UInt8(0), toByteOffset: 20, as: UInt8.self)
            return .snapshot(snapshot)
        }
        if let failure, compact == nil || failure.sequence < compact!.sequence {
            sealedMetadata.storeBytes(of: UInt8(0), toByteOffset: 21, as: UInt8.self)
            return .operationalFailure(failure)
        }
        guard let compact = sealed.takeFirst() else { return nil }
        return .compact(compact)
    }

    package mutating func quiesce() {
        metadata.storeBytes(of: UInt8(0), toByteOffset: 19, as: UInt8.self)
        endProducer()
    }

    package mutating func discardAll() {
        quiesce()
        active.discard()
        sealed.discard()
        metadata.storeBytes(of: UInt8(0), toByteOffset: 20, as: UInt8.self)
        sealedMetadata.storeBytes(of: UInt8(0), toByteOffset: 20, as: UInt8.self)
        metadata.storeBytes(of: UInt8(0), toByteOffset: 21, as: UInt8.self)
        sealedMetadata.storeBytes(of: UInt8(0), toByteOffset: 21, as: UInt8.self)
    }

    private var isAvailable: Bool {
        metadata.load(fromByteOffset: 19, as: UInt8.self) == 1
    }

    private var activeProducer: StaticSignalAnalyzerNRFProducerCategory? {
        StaticSignalAnalyzerNRFProducerCategory(
            rawValue: metadata.load(fromByteOffset: 18, as: UInt8.self)
        )
    }

    private var activeSnapshot: StaticSignalAnalyzerNRFSnapshotFact? {
        guard metadata.load(fromByteOffset: 20, as: UInt8.self) == 1 else { return nil }
        return metadata.load(fromByteOffset: 32, as: StaticSignalAnalyzerNRFSnapshotFact.self)
    }

    private var sealedSnapshot: StaticSignalAnalyzerNRFSnapshotFact? {
        guard sealedMetadata.load(fromByteOffset: 20, as: UInt8.self) == 1 else { return nil }
        return sealedMetadata.load(fromByteOffset: 32, as: StaticSignalAnalyzerNRFSnapshotFact.self)
    }

    private var activeFailure: StaticSignalAnalyzerNRFOperationalFailureFact? {
        guard metadata.load(fromByteOffset: 21, as: UInt8.self) == 1 else { return nil }
        return metadata.load(
            fromByteOffset: 80, as: StaticSignalAnalyzerNRFOperationalFailureFact.self
        )
    }

    private var sealedFailure: StaticSignalAnalyzerNRFOperationalFailureFact? {
        guard sealedMetadata.load(fromByteOffset: 21, as: UInt8.self) == 1 else { return nil }
        return sealedMetadata.load(
            fromByteOffset: 80, as: StaticSignalAnalyzerNRFOperationalFailureFact.self
        )
    }

    private func countOffset(for producer: StaticSignalAnalyzerNRFProducerCategory) -> Int {
        switch producer {
        case .transition: 12
        case .bootstrap: 14
        case .action: 16
        }
    }
}
