#if GIFTUI_NRF_EMBEDDED
    package enum StaticSignalAnalyzerNRFEmbeddedActionDispatchResult {
        case applied(mutationApplied: Bool)
        case failure(SignalAnalyzerRuntimeCondition, mutationApplied: Bool)
    }

    /// Applies a gesture-admitted action in a serialized model/repository turn.
    /// The caller owns the fact regions and retires the application on failure.
    package enum StaticSignalAnalyzerNRFEmbeddedActionDispatcher {
        package static func dispatch(
            actionCode: UInt16,
            modelGeneration: UInt32,
            model: inout StaticSignalAnalyzerNRFModelLocation,
            repository: inout StaticSignalAnalyzerNRFRepositoryProducer,
            admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission,
            captureStorage: UnsafeMutableRawBufferPointer
        ) -> Bool {
            if case .applied = dispatchTyped(
                actionCode: actionCode, modelGeneration: modelGeneration,
                model: &model, repository: &repository, admission: &admission,
                captureStorage: captureStorage)
            {
                return true
            }
            return false
        }

        package static func dispatchTyped(
            actionCode: UInt16, modelGeneration: UInt32,
            model: inout StaticSignalAnalyzerNRFModelLocation,
            repository: inout StaticSignalAnalyzerNRFRepositoryProducer,
            admission: inout StaticSignalAnalyzerNRFCaptureFactAdmission,
            captureStorage: UnsafeMutableRawBufferPointer
        ) -> StaticSignalAnalyzerNRFEmbeddedActionDispatchResult {
            guard model.activeGeneration == modelGeneration, model.beginMutation()
            else { return .failure(.mutationPhaseViolation, mutationApplied: false) }
            let intent = withUnsafeMutablePointer(to: &model) { location in
                StaticSignalAnalyzerNRFModelHandle(
                    location: location,
                    generation: modelGeneration)?.dispatch(actionRawValue: actionCode)
            }
            guard model.endMutation(), let intent else {
                return .failure(.observableStateInvariantViolation, mutationApplied: model.isDirty)
            }
            let produced: StaticSignalAnalyzerNRFRepositoryProductionOutcome
            switch intent {
            case .start:
                produced = repository.start(admission: &admission, captureStorage: captureStorage)
            case .stop: produced = repository.stop(admission: &admission)
            case .clear:
                produced = repository.clear(admission: &admission, captureStorage: captureStorage)
            case .visibleWindowChanged: produced = .accepted
            }
            switch model.applyAdmittedBatch(from: &admission, captureStorage: captureStorage) {
            case .applied:
                guard produced == .accepted || produced == .terminalFailureAdmitted else {
                    return .failure(.reservedFailureCapacityExhausted, mutationApplied: true)
                }
                return .applied(mutationApplied: true)
            case .failure(let condition, let applied, _):
                return .failure(condition, mutationApplied: applied || model.isDirty)
            case .unavailable:
                return .failure(.mutationPhaseViolation, mutationApplied: model.isDirty)
            }
        }
    }
#endif
