import GiftUI

public struct PortableModel: _GiftUIObservableReference {
    public init() {}

    public mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    public mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

public struct PortableHost: _GiftUIObservableStateHost {
    @State private var model = PortableModel()

    public init() {}

    public mutating func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor
    >(_ visitor: inout Visitor) {
        visitor.visit(&_model, declarationOrdinal: 0)
    }
}

public func verifyRawValues() -> Bool {
    _GiftUIObservableChangeReportOutcome.dirtied.rawValue == 0
        && _GiftUIObservableChangeReportOutcome.coalesced.rawValue == 1
        && _GiftUIObservableChangeReportOutcome.staleAttachment.rawValue == 2
        && _GiftUIObservableChangeReportOutcome.invalidPhaseContained.rawValue == 3
        && _GiftUIObservableChangeReportOutcome.invalidPhaseSafetyNotProven.rawValue == 4
        && _GiftUIObservableChangeReportOutcome.reentrancyViolation.rawValue == 5
        && _GiftUIObservableChangeReportOutcome.invariantViolation.rawValue == 6
}
