import GiftUI
import GiftUIObservableState
import CycleSchema
import CyclePresentation
import CycleTable

package struct CycleOwnedModel: ~Copyable, ObservableStateModel, ObservableModelMutation {
    package typealias Schema = CycleModelSchema
    package enum Mutation { case increment }
    package var value: UInt8
    private var sink: _GiftUIObservableChangeSink?
    package static func materialize(_ seed: Schema.Seed) -> Self { Self(value: seed.value) }
    package var isEmptyReplacement: Bool { false }
    package mutating func attach(_ sink: consuming _GiftUIObservableChangeSink) -> _GiftUIObservationAttachment? {
        let attachment = sink.attachment
        self.sink = consume sink
        return attachment
    }
    package mutating func detach(_ attachment: _GiftUIObservationAttachment) -> Bool {
        guard sink?.attachment == attachment else { return false }
        sink = nil
        return true
    }
    package mutating func reportChange() -> _GiftUIObservableChangeReportOutcome { sink?.reportChange() ?? .coalesced }
    package borrowing func preflight(_ mutation: Mutation) throws(ObservableStateError) -> UInt8 {
        let next = value.addingReportingOverflow(1)
        guard !next.overflow else { throw .invariantViolation }
        return next.partialValue
    }
    package mutating func commit(_ prepared: UInt8) -> Bool {
        let changed = value != prepared
        value = prepared
        return changed
    }
}
package enum CycleDomain: CycleReadDomain {
    package typealias Slot = ObservableModelReadSlot<CycleOwnedModel>
    package static func bind(_ key: _GiftUIModelKey<CycleModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int {
        try slots[0].ownership.pointee.bind(key, schema: 1)
    }
    package static func CycleRead_value(at index: Int, slots: Span<Slot>) -> UInt8 {
        switch slots[index].model.pointee {
        case .some(let model): return model.value
        case .none: preconditionFailure("validated slot absent")
        }
    }
}
package enum CycleHandler {
    // The finite domain and mutation result are concrete compile-time bindings.
    package static func operation(_ action: CycleAction) -> CycleOwnedModel.Mutation {
        switch action { case .increment: .increment }
    }
}
package typealias CycleValueTable = CycleSchemaCanvasTable<CycleDomain>
