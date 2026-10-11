import GiftUI
import GiftUIDrawing
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import CounterSchema
import CounterCanvas
import CounterCanvasTable

struct ProbeModel: ~Copyable { let value: UInt8 }
enum ProbeDomain: CounterReadDomain {
    typealias Slot = ObservableModelReadSlot<ProbeModel>
    static func bind(_ key: _GiftUIModelKey<CounterModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int {
        try slots[0].ownership.pointee.bind(key, schema: 1)
    }
    static func CounterRead_value(at index: Int, slots: Span<Slot>) -> UInt8 {
        switch slots[index].model.pointee {
        case .some(let model): model.value
        case .none: preconditionFailure("absent model")
        }
    }
}
typealias Table = CounterSchemaCanvasTable<ProbeDomain>

@main struct Main {
    static func main() {
        var began = 0
        var outcome: DrawingError?
        var released: UInt16 = 0
        withUnsafeMutablePointer(to: &began) { count in
            do throws(ObservableStateError) {
                var namespace = ObservableModelOwnerNamespace()
                var storage = StaticObservableModelStorage<ProbeModel, CounterModelSchema>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
                try storage.withLifetime { (models) throws(ObservableStateError) in
                    var ticket = try models.materialize(ProbeModel(value: 7))
                    try models.withFrame { () throws(ObservableStateError) in
                        try models.pin(ticket.key)
                        let key = ticket.key
                        let stale = _GiftUIModelKey<CounterModelSchema>(ownerInstance: key._giftUIOwnerInstance, allocationGeneration: key._giftUIAllocationGeneration + 1, slot: key._giftUISlot)
                        var staged = StaticCanvasValueStorage()
                        var backing: InlineArray<1, CanvasStagedEntry<UInt16, Table.CaptureStorage>?> = .init(repeating: nil)
                        var span = backing.mutableSpan
                        do throws(DrawingError) {
                            try staged.withLifetime(entries: &span, table: Table(), capacity: 1, limits: StaticCanvasLimits(maximumStaticCallableCases: 2, maximumStaticCaptureBytes: 32)!) { (values) throws(DrawingError) in
                                try values.stage(identity: 1, value: Table.payload(CounterTrace<ProbeDomain>(model: stale, offset: 0))!, table: Table())
                                var source = ObservableCanvasInvocationSource(models: models.borrowedScope(), values: values.borrowedValues(), table: Table())
                                let operations = _GiftUIDrawingOperations(
                                    beginPath: { pointer, _, _ in
                                        pointer.assumingMemoryBound(to: Int.self).pointee += 1
                                        return _GiftUIDrawingStatus.capacityExhausted.rawValue
                                    }, endPath: { _, _, _ in 0 }, movePath: { _, _, _, _, _ in 0 },
                                    addLineToPath: { _, _, _, _, _ in 0 }, strokePath: { _, _, _, _, _, _, _, _, _ in 0 })
                                var context = GraphicsContext(storage: UnsafeMutableRawPointer(count), generation: 1, operations: operations)
                                do throws(DrawingError) { try source.invokeCanvas(at: 1, context: &context, size: Size(width: 5, height: 7)!) }
                                catch { outcome = error }
                                source.releaseCanvas(at: 1)
                                released = values.releaseCount
                                context.invalidate()
                            }
                        } catch { preconditionFailure("unexpected staging failure") }
                    }
                    try models.release(&ticket)
                }
            } catch { preconditionFailure("unexpected owner failure") }
        }
        print("stale-key draw: beginPathCalls=\(began) invalidModelAccess=\(outcome == .invalidModelAccess) capacityExhausted=\(outcome == .capacityExhausted) releases=\(released)")
        precondition(began == 1 && outcome == .capacityExhausted && released == 1)
    }
}
