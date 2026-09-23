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
    case compactCapacityExhausted
    case sequenceExhausted
    case unrepresentable
}

/// Capture-mutation admission over the two exact profile regions. All
/// counters, producer state, and sequence state reside in active ring reserve.
package struct StaticSignalAnalyzerNRFCaptureFactAdmission: ~Copyable {
    private var active: StaticSignalAnalyzerNRFCompactFactRing
    private var sealed: StaticSignalAnalyzerNRFCompactFactRing
    private let metadata: UnsafeMutableRawPointer

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
        metadata.storeBytes(of: nextSequence, toByteOffset: 8, as: UInt32.self)
        metadata.storeBytes(of: UInt8.max, toByteOffset: 18, as: UInt8.self)
        metadata.storeBytes(of: UInt8(1), toByteOffset: 19, as: UInt8.self)
    }

    package var pendingCompactCount: UInt16 { active.count }
    package var sealedCompactCount: UInt16 { sealed.count }

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

    package mutating func seal() -> Bool {
        guard isAvailable, activeProducer == nil, active.seal(into: &sealed) else {
            return false
        }
        for offset in stride(from: 12, through: 16, by: 2) {
            metadata.storeBytes(of: UInt16(0), toByteOffset: offset, as: UInt16.self)
        }
        return true
    }

    package mutating func takeNextSealed() -> StaticSignalAnalyzerNRFCompactCaptureFact? {
        sealed.takeFirst()
    }

    package mutating func quiesce() {
        metadata.storeBytes(of: UInt8(0), toByteOffset: 19, as: UInt8.self)
        endProducer()
    }

    package mutating func discardAll() {
        quiesce()
        active.discard()
        sealed.discard()
    }

    private var isAvailable: Bool {
        metadata.load(fromByteOffset: 19, as: UInt8.self) == 1
    }

    private var activeProducer: StaticSignalAnalyzerNRFProducerCategory? {
        StaticSignalAnalyzerNRFProducerCategory(
            rawValue: metadata.load(fromByteOffset: 18, as: UInt8.self)
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
