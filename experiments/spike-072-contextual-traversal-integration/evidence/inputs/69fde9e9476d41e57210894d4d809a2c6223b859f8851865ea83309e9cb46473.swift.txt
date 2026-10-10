public enum _GiftUIObservableChangeReportOutcome: UInt8, Equatable, Sendable {
    case dirtied = 0
    case coalesced = 1
    case staleAttachment = 2
    case invalidPhaseContained = 3
    case invalidPhaseSafetyNotProven = 4
    case reentrancyViolation = 5
    case invariantViolation = 6
}

public struct _GiftUIObservationAttachment: Equatable, Sendable {
    public let slot: UInt16
    public let generation: UInt32

    package init(slot: UInt16, generation: UInt32) {
        self.slot = slot
        self.generation = generation
    }
}

public struct _GiftUIObservableChangeSink: ~Copyable {
    private let storedAttachment: _GiftUIObservationAttachment
    private let reportRoute:
        (_GiftUIObservationAttachment) ->
            _GiftUIObservableChangeReportOutcome

    package init(
        attachment: _GiftUIObservationAttachment,
        reportRoute:
            @escaping (_GiftUIObservationAttachment) ->
            _GiftUIObservableChangeReportOutcome
    ) {
        storedAttachment = attachment
        self.reportRoute = reportRoute
    }

    public var attachment: _GiftUIObservationAttachment {
        storedAttachment
    }

    public mutating func reportChange()
        -> _GiftUIObservableChangeReportOutcome
    {
        reportRoute(storedAttachment)
    }
}

public protocol _GiftUIObservableReference {
    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment?

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    )
}

