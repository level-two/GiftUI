import GiftUI

/// Finite schema storage bridge. This is internal host-generated storage, not
/// an authored reference or an access facade. Services are not part of its seed.
package protocol ObservableStateModel: ~Copyable {
    associatedtype Schema: _GiftUIModelSchema
    static func materialize(_ seed: Schema.Seed) -> Self
    var isEmptyReplacement: Bool { get }
    mutating func attach(_ sink: consuming _GiftUIObservableChangeSink)
        -> _GiftUIObservationAttachment?
    mutating func detach(_ attachment: _GiftUIObservationAttachment) -> Bool
    mutating func reportChange() -> _GiftUIObservableChangeReportOutcome
}
