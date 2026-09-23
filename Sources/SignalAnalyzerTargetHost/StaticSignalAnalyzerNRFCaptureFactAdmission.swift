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
    case compactCapacityExhausted
    case sequenceExhausted
    case unrepresentable
}

package enum StaticSignalAnalyzerNRFSealedCaptureFact {
    case snapshot(StaticSignalAnalyzerNRFSnapshotFact)
    case mutation(StaticSignalAnalyzerNRFCompactCaptureFact)

    package var sequence: UInt32 {
        switch self {
        case .snapshot(let fact): fact.sequence
        case .mutation(let fact): fact.sequence
        }
    }

    package var captureMutation: (revision: UInt32, change: SignalCaptureChange)? {
        switch self {
        case .snapshot: nil
        case .mutation(let fact): fact.publication
        }
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
        metadata = activeStorage.baseAddress!.advanced(by: 2_048)
        sealedMetadata = sealedStorage.baseAddress!.advanced(by: 2_048)
        metadata.storeBytes(of: nextSequence, toByteOffset: 8, as: UInt32.self)
        metadata.storeBytes(of: UInt8.max, toByteOffset: 18, as: UInt8.self)
        metadata.storeBytes(of: UInt8(1), toByteOffset: 19, as: UInt8.self)
    }

    package var pendingCompactCount: UInt16 { active.count }
    package var sealedCompactCount: UInt16 { sealed.count }
    package var pendingSnapshotCount: UInt8 { activeSnapshot == nil ? 0 : 1 }
    package var sealedSnapshotCount: UInt8 { sealedSnapshot == nil ? 0 : 1 }

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
            let fact = StaticSignalAnalyzerNRFCompactCaptureFact(
                sequence: sequence, revision: revision, change: change
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

    package mutating func seal() -> Bool {
        guard isAvailable, activeProducer == nil,
            active.count > 0 || activeSnapshot != nil,
            sealed.count == 0, sealedSnapshot == nil
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
        for offset in stride(from: 12, through: 16, by: 2) {
            metadata.storeBytes(of: UInt16(0), toByteOffset: offset, as: UInt16.self)
        }
        return true
    }

    package mutating func takeNextSealed() -> StaticSignalAnalyzerNRFSealedCaptureFact? {
        let snapshot = sealedSnapshot
        let compact = sealed.first
        if let snapshot, compact == nil || snapshot.sequence < compact!.sequence {
            sealedMetadata.storeBytes(of: UInt8(0), toByteOffset: 20, as: UInt8.self)
            return .snapshot(snapshot)
        }
        guard let compact = sealed.takeFirst() else { return nil }
        return .mutation(compact)
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

    private func countOffset(for producer: StaticSignalAnalyzerNRFProducerCategory) -> Int {
        switch producer {
        case .transition: 12
        case .bootstrap: 14
        case .action: 16
        }
    }
}
