import SignalAnalyzerDomain

package enum StaticSignalAnalyzerNRFSealedFactApplyOutcome: Equatable {
    case applied
    case rejected
    case storageInvariantViolation
}

package enum StaticSignalAnalyzerNRFBatchApplyOutcome: Equatable {
    case applied(factCount: UInt16)
    case unavailable
    case rejected
    case storageInvariantViolation
}

extension StaticSignalAnalyzerNRFModelLocation {
    /// One synchronous application opportunity. No source callback or action
    /// dispatch occurs while the sealed facts mutate the model.
    package mutating func applyAdmittedBatch(
        from admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission,
        captureStorage: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFBatchApplyOutcome {
        guard activeGeneration != nil, !isMutating,
            admission.sealedCompactCount == 0,
            admission.sealedSnapshotCount == 0,
            admission.sealedOperationalFailureCount == 0
        else { return .unavailable }
        let pendingCount =
            UInt16(admission.pendingSnapshotCount)
            + UInt16(admission.pendingOperationalFailureCount)
            + admission.pendingCompactCount
        guard pendingCount > 0 else { return .applied(factCount: 0) }
        guard admission.seal(), beginMutation() else { return .unavailable }
        var appliedCount: UInt16 = 0
        while let fact = admission.takeNextSealed() {
            let outcome = applySealedFact(fact, captureStorage: captureStorage)
            guard outcome == .applied else {
                admission.discardAll()
                _ = endMutation()
                switch outcome {
                case .applied: return .unavailable
                case .rejected: return .rejected
                case .storageInvariantViolation: return .storageInvariantViolation
                }
            }
            appliedCount += 1
        }
        guard endMutation(), appliedCount == pendingCount else {
            admission.discardAll()
            return .storageInvariantViolation
        }
        return .applied(factCount: appliedCount)
    }

    /// Applies one already sealed fact only within the owner's serialized
    /// model mutation phase. The caller keeps capture storage alive and stable.
    package mutating func applySealedFact(
        _ fact: StaticSignalAnalyzerNRFSealedCaptureFact,
        captureStorage: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFSealedFactApplyOutcome {
        guard activeGeneration != nil, isMutating else { return .rejected }
        switch fact {
        case .snapshot(let snapshot):
            guard
                let view = StaticSignalAnalyzerNRFCaptureSnapshotView(
                    storage: captureStorage,
                    revision: snapshot.revision,
                    count: snapshot.count,
                    duration: snapshot.duration,
                    retainedLowerBound: snapshot.retainedLowerBound,
                    baselineLevels: snapshot.baselineLevels
                ), var regions = StaticSignalAnalyzerNRFCaptureRegions(storage: captureStorage)
            else { return .storageInvariantViolation }
            return installCaptureSnapshot(view, in: &regions) ? .applied : .rejected

        case .compact(let compact):
            switch compact.payload {
            case .captureMutation(let mutation):
                guard let publication = mutation.publication,
                    var regions = StaticSignalAnalyzerNRFCaptureRegions(
                        storage: captureStorage
                    )
                else { return .storageInvariantViolation }
                switch applyCaptureMutation(
                    revision: publication.revision,
                    change: publication.change,
                    in: &regions
                ) {
                case .applied: return .applied
                case .rejected: return .rejected
                case .storageInvariantViolation: return .storageInvariantViolation
                }
            case .acquisitionState(let state):
                return setAcquisitionState(state) ? .applied : .rejected
            }

        case .operationalFailure(let failure):
            return setAcquisitionState(.failed(failure.diagnostic)) ? .applied : .rejected
        }
    }
}
