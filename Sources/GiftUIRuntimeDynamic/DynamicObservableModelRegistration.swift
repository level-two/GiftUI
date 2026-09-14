import GiftUI
import GiftUIExecution
import GiftUIObservableState

package final class DynamicObservableModelRegistration<Model>
where Model: _GiftUIObservableReference {
    private let storage = DynamicObservableModelStorage<Model>()
    private var bridge = ObservableStateRegistrationBridge()
    private var attachment: _GiftUIObservationAttachment?
    private var phase: ExecutionPhase = .idle
    private(set) package var isDirty = false

    package init() {}

    package var isActive: Bool {
        bridge.isActive
    }

    package func bind(
        _ state: inout State<Model>,
        generation: UInt32,
        replacementRoute: @escaping (Model) -> Void
    ) -> ObservableStateResult {
        if isActive {
            return storage.bind(&state, replacementRoute: replacementRoute)
        }

        let binding = storage.bind(&state, replacementRoute: replacementRoute)
        guard binding == .success(.materialized) else {
            storage.removeModel()
            return .failure(.invariantViolation)
        }

        let candidate = _GiftUIObservationAttachment(
            slot: 0,
            generation: generation
        )
        if let failure = bridge.beginAttachment(candidate) {
            storage.removeModel()
            return .failure(failure)
        }
        guard
            let sink = bridge.makeSink(reportRoute: { [weak self] reported in
                self?.acceptReport(reported) ?? .staleAttachment
            })
        else {
            storage.removeModel()
            return .failure(.invariantViolation)
        }
        let returned = storage.attachChangeSink(consume sink)
        if let failure = bridge.acceptAttachmentReturn(returned) {
            if returned != nil {
                _ = storage.detachChangeSink(candidate)
            }
            storage.removeModel()
            return .failure(failure)
        }

        attachment = candidate
        return binding
    }

    package func setExecutionPhase(_ phase: ExecutionPhase) {
        self.phase = phase
    }

    package borrowing func withModel<Result>(
        _ body: (borrowing Model) -> Result
    ) -> Result? {
        storage.withModel(body)
    }

    package func retire() -> ObservableStateResult {
        guard let attachment else {
            return .failure(.invariantViolation)
        }
        if let failure = bridge.retire(attachment) {
            return .failure(failure)
        }
        _ = storage.detachChangeSink(attachment)
        storage.removeModel()
        self.attachment = nil
        isDirty = false
        return .success(.associationsCommitted)
    }

    private func acceptReport(
        _ reported: _GiftUIObservationAttachment
    ) -> _GiftUIObservableChangeReportOutcome {
        if let failure = bridge.acceptReport(reported) {
            return failure == .staleAttachment ? .staleAttachment : .invariantViolation
        }
        guard phase == .mutating else {
            return .invalidPhaseSafetyNotProven
        }
        guard !isDirty else { return .coalesced }
        isDirty = true
        return .dirtied
    }
}
