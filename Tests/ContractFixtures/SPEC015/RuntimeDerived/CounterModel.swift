import GiftUI
import GiftUIObservableState
import P08CounterSchema
import P08CounterPresentation
import P08CounterTable

package struct CounterOwnedModel: ~Copyable, ObservableStateModel, ObservableModelMutation {
    package typealias Schema = CounterModelSchema
    package enum Mutation { case increment, reset, fact(UInt8) }
    package private(set) var value: UInt8
    private var sink: _GiftUIObservableChangeSink?
    package init(value: UInt8) { precondition(value <= 9); self.value = value }
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
        switch mutation {
        case .increment: return value < 9 ? value + 1 : 9
        case .reset: return 0
        case .fact(let next):
            guard next <= 9 else { throw .invariantViolation }
            return next
        }
    }
    package mutating func commit(_ prepared: UInt8) -> Bool {
        precondition(prepared <= 9)
        let changed = value != prepared
        value = prepared
        return changed
    }
}
package enum CounterDomain: CounterReadDomain {
    package typealias Slot = ObservableModelReadSlot<CounterOwnedModel>
    package static func bind(_ key: _GiftUIModelKey<CounterModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int {
        try slots[0].ownership.pointee.bind(key, schema: 1)
    }
    package static func CounterRead_value(at index: Int, slots: Span<Slot>) -> UInt8 {
        switch slots[index].model.pointee {
        case .some(let model): return model.value
        case .none: preconditionFailure("validated counter slot absent")
        }
    }
}
package enum CounterHandler {
    package static func operation(_ action: CounterAction) -> CounterOwnedModel.Mutation {
        switch action { case .increment: .increment; case .reset: .reset }
    }
}
package typealias CounterValueTable = P08CounterSchemaCanvasTable<CounterDomain>
