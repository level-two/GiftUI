import GiftUI

struct ObservableStateRegistrationLifecycle: Equatable, Sendable {
    private enum State: Equatable, Sendable {
        case vacant
        case attaching(_GiftUIObservationAttachment, reportAttempted: Bool)
        case active(_GiftUIObservationAttachment)
        case retired
        case shutdown
    }

    private var state: State = .vacant

    var isActive: Bool {
        if case .active = state { return true }
        return false
    }

    var isShutdown: Bool {
        state == .shutdown
    }

    mutating func beginAttachment(
        _ attachment: _GiftUIObservationAttachment
    ) -> ObservableStateError? {
        switch state {
        case .vacant, .retired:
            state = .attaching(attachment, reportAttempted: false)
            return nil
        case .attaching, .active:
            return .reentrancyViolation
        case .shutdown:
            return .invalidPhaseSafetyNotProven
        }
    }

    mutating func acceptAttachmentReturn(
        _ returned: _GiftUIObservationAttachment?
    ) -> ObservableStateError? {
        guard
            case .attaching(let expected, let reportAttempted) = state
        else {
            return .invariantViolation
        }
        guard !reportAttempted, returned == expected else {
            state = .retired
            return .staleAttachment
        }
        state = .active(expected)
        return nil
    }

    mutating func acceptReport(
        _ attachment: _GiftUIObservationAttachment
    ) -> ObservableStateError? {
        switch state {
        case .attaching(let expected, _):
            state = .attaching(expected, reportAttempted: true)
            return .staleAttachment
        case .active(let expected):
            return attachment == expected ? nil : .staleAttachment
        case .vacant, .retired, .shutdown:
            return .staleAttachment
        }
    }

    mutating func retire(
        attachment: _GiftUIObservationAttachment
    ) -> ObservableStateError? {
        guard case .active(let expected) = state else {
            return .invariantViolation
        }
        guard attachment == expected else {
            return .invariantViolation
        }
        state = .retired
        return nil
    }

    mutating func shutdown() -> Bool {
        guard state != .shutdown else { return false }
        let requiresDetach: Bool =
            switch state {
            case .attaching, .active:
                true
            case .vacant, .retired, .shutdown:
                false
            }
        state = .shutdown
        return requiresDetach
    }
}
