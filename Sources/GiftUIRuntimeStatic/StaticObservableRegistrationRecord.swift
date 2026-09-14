import GiftUI
import GiftUIExecution
import GiftUIObservableState

package struct StaticObservableRegistrationRecord {
    private var bridge = ObservableStateRegistrationBridge()
    private var attachment: _GiftUIObservationAttachment?
    private var phase: ExecutionPhase = .idle

    package init() {}

    package var isActive: Bool {
        bridge.isActive
    }

    package var isDirty: Bool {
        bridge.isDirty
    }

    package mutating func beginAttachment(
        slot: UInt16 = 0,
        generation: UInt32
    ) -> ObservableStateError? {
        let candidate = _GiftUIObservationAttachment(
            slot: slot,
            generation: generation
        )
        if let failure = bridge.beginAttachment(candidate) {
            return failure
        }
        attachment = candidate
        return nil
    }

    package mutating func makeSink(
        reportRoute:
            @escaping (
                _GiftUIObservationAttachment
            ) -> _GiftUIObservableChangeReportOutcome
    ) -> _GiftUIObservableChangeSink? {
        bridge.makeSink(reportRoute: reportRoute)
    }

    package mutating func acceptAttachmentReturn(
        _ returned: _GiftUIObservationAttachment?
    ) -> ObservableStateError? {
        let failure = bridge.acceptAttachmentReturn(returned)
        if failure != nil {
            attachment = nil
        }
        return failure
    }

    package mutating func setExecutionPhase(_ phase: ExecutionPhase) {
        self.phase = phase
    }

    package mutating func acceptReport(
        _ reported: _GiftUIObservationAttachment
    ) -> _GiftUIObservableChangeReportOutcome {
        bridge.acceptReport(reported, phase: phase)
    }

    package mutating func retire() -> ObservableStateError? {
        guard let attachment else { return .invariantViolation }
        let failure = bridge.retire(attachment)
        if failure == nil {
            self.attachment = nil
        }
        return failure
    }

    package mutating func shutdown() -> Bool {
        attachment = nil
        return bridge.shutdown()
    }
}
