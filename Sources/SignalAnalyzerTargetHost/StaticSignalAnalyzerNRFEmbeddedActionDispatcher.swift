#if GIFTUI_NRF_EMBEDDED
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
            guard model.activeGeneration == modelGeneration,
                model.beginMutation()
            else { return false }
            let intent = withUnsafeMutablePointer(to: &model) { location in
                StaticSignalAnalyzerNRFModelHandle(
                    location: location, generation: modelGeneration
                )?.dispatch(actionRawValue: actionCode)
            }
            guard model.endMutation(), let intent else { return false }
            let produced: StaticSignalAnalyzerNRFRepositoryProductionOutcome
            switch intent {
            case .start:
                produced = repository.start(
                    admission: &admission, captureStorage: captureStorage
                )
            case .stop:
                produced = repository.stop(admission: &admission)
            case .clear:
                produced = repository.clear(
                    admission: &admission, captureStorage: captureStorage
                )
            case .visibleWindowChanged:
                produced = .accepted
            }
            guard
                case .applied = model.applyAdmittedBatch(
                    from: &admission, captureStorage: captureStorage
                )
            else { return false }
            return produced == .accepted
        }
    }
#endif
