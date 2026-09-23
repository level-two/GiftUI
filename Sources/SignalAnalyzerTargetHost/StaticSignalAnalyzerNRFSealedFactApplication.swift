import SignalAnalyzerDomain

package enum StaticSignalAnalyzerNRFSealedFactApplyOutcome: Equatable {
    case applied
    case rejected
    case storageInvariantViolation
}

extension StaticSignalAnalyzerNRFModelLocation {
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
