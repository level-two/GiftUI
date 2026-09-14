import GiftUI

package struct ObservableStateRegistrationBridge {
    private var lifecycle = ObservableStateRegistrationLifecycle()
    private var pendingAttachment: _GiftUIObservationAttachment?
    private var sinkWasIssued = false

    package init() {}

    package var isActive: Bool {
        lifecycle.isActive
    }

    package mutating func beginAttachment(
        _ attachment: _GiftUIObservationAttachment
    ) -> ObservableStateError? {
        if let failure = lifecycle.beginAttachment(attachment) {
            return failure
        }
        pendingAttachment = attachment
        sinkWasIssued = false
        return nil
    }

    package mutating func makeSink(
        reportRoute:
            @escaping (
                _GiftUIObservationAttachment
            ) -> _GiftUIObservableChangeReportOutcome
    ) -> _GiftUIObservableChangeSink? {
        guard let pendingAttachment, !sinkWasIssued else { return nil }
        sinkWasIssued = true
        return _GiftUIObservableChangeSink(
            attachment: pendingAttachment,
            reportRoute: reportRoute
        )
    }

    package mutating func acceptAttachmentReturn(
        _ returned: _GiftUIObservationAttachment?
    ) -> ObservableStateError? {
        guard sinkWasIssued else { return .invariantViolation }
        let failure = lifecycle.acceptAttachmentReturn(returned)
        pendingAttachment = nil
        sinkWasIssued = false
        return failure
    }

    package mutating func acceptReport(
        _ attachment: _GiftUIObservationAttachment
    ) -> ObservableStateError? {
        lifecycle.acceptReport(attachment)
    }

    package mutating func retire(
        _ attachment: _GiftUIObservationAttachment
    ) -> ObservableStateError? {
        lifecycle.retire(attachment: attachment)
    }

    package mutating func shutdown() -> Bool {
        pendingAttachment = nil
        sinkWasIssued = false
        return lifecycle.shutdown()
    }
}
