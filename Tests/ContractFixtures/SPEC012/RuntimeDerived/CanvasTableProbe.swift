import GiftUI
import GiftUIDrawing
import SignalAnalyzerDomain
import CounterSchema
import CounterCanvas
import CounterCanvasTable
import AnalyzerSchema
import AnalyzerCanvas
import AnalyzerCanvasTable

private struct CounterSlot {
    let value: UInt8
    let trace: UnsafeMutablePointer<CanvasTrace>
}

private enum TableCounterDomain: CounterReadDomain {
    typealias Slot = CounterSlot

    static func bind(_ key: _GiftUIModelKey<CounterModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int {
        guard key._giftUIOwnerInstance == 7 else { throw .wrongOwner }
        guard key._giftUIAllocationGeneration == 3, key._giftUISlot == 0 else { throw .staleModel }
        return 0
    }

    static func CounterRead_value(at index: Int, slots: Span<Slot>) -> UInt8 {
        let slot = slots[index]
        slot.trace.pointee.readCount += 1
        return slot.value
    }
}

private struct AnalyzerSlot {
    let count: UInt16
    let trace: UnsafeMutablePointer<CanvasTrace>
}

private enum TableAnalyzerDomain: AnalyzerReadDomain {
    typealias Slot = AnalyzerSlot

    static func bind(_ key: _GiftUIModelKey<AnalyzerModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int {
        guard key._giftUIOwnerInstance == 9 else { throw .wrongOwner }
        guard key._giftUIAllocationGeneration == 0, key._giftUISlot == 0 else { throw .staleModel }
        return 0
    }

    static func AnalyzerRead_state_acquisitionState(at index: Int, slots: Span<Slot>) -> AcquisitionState { .running }
    static func AnalyzerRead_state_capture_count(at index: Int, slots: Span<Slot>) -> UInt16 { slots[index].count }
    static func AnalyzerRead_state_capture_transition(_ position: Int, at index: Int, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> SignalTransition {
        let slot = slots[index]
        guard position >= 0, position < Int(slot.count) else { throw .outOfBounds }
        slot.trace.pointee.readCount += 1
        return SignalTransition(channelID: SignalChannelID(rawValue: 3), timestamp: .zero, level: .high)
    }
}

public func giftuiP06FiniteTables() -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ condition: Bool) { checks += 1; precondition(condition) }
    var trace = CanvasTrace()
    withUnsafeMutablePointer(to: &trace) { pointer in
        let key = _GiftUIModelKey<CounterModelSchema>(ownerInstance: 7, allocationGeneration: 3, slot: 0)
        let value = CounterTrace<TableCounterDomain>(model: key, offset: 2)
        let empty = EmptyCanvas<TableCounterDomain>()
        var table = CounterSchemaCanvasTable<TableCounterDomain>()
        expect(table.callableCaseCount == 2)
        expect(table.captureByteCount(for: 0) == nil)
        expect(table.captureByteCount(for: 1) == UInt16(MemoryLayout<CounterTrace<TableCounterDomain>>.stride))
        expect(table.captureByteCount(for: 2) == UInt16(MemoryLayout<EmptyCanvas<TableCounterDomain>>.stride))
        expect(table.captureByteCount(for: 3) == nil)
        expect(CounterSchemaCanvasTable<TableCounterDomain>.payload(_GiftUISpacerPayload(minLength: 0)) == nil)
        guard let first = CounterSchemaCanvasTable<TableCounterDomain>.payload(value),
              let second = CounterSchemaCanvasTable<TableCounterDomain>.payload(empty)
        else { preconditionFailure("missing generated Counter payload") }
        expect(CounterSchemaCanvasTable<TableCounterDomain>.caseID(for: first) == 1)
        expect(CounterSchemaCanvasTable<TableCounterDomain>.caseID(for: second) == 2)
        var slots: InlineArray<1, CounterSlot> = .init(repeating: CounterSlot(value: 7, trace: pointer))
        var workspace = CanvasWorkspace(trace: pointer)
        do throws(DrawingError) {
            try workspace.withCanvasContext(identity: 1, surfaceOrigin: Point(x: 10, y: 20), inheritedClip: CanvasLayout().rootBounds) { (context) throws(DrawingError) in
                let read = _GiftUIFrameRead<TableCounterDomain>(slots: slots.span)
                try table.invoke(id: 1, captures: first, context: &context, size: Size(width: 5, height: 7)!, read: read)
                try table.invoke(id: 2, captures: second, context: &context, size: Size(width: 5, height: 7)!, read: read)
                do throws(DrawingError) {
                    try table.invoke(id: 2, captures: first, context: &context, size: Size(width: 5, height: 7)!, read: read)
                    preconditionFailure("mismatched witness accepted")
                } catch { expect(error == .invariantViolation) }
            }
        } catch { preconditionFailure("Counter witness failed") }
        expect(pointer.pointee.readCount == 1)
        expect(pointer.pointee.strokes == 1)
        expect(pointer.pointee.endpoints[0] == Point(x: 5, y: 7))

        let analyzerKey = _GiftUIModelKey<AnalyzerModelSchema>(ownerInstance: 9, allocationGeneration: 0, slot: 0)
        let analyzer = AnalyzerTrace<TableAnalyzerDomain>(model: analyzerKey, index: 1)
        var analyzerTable = AnalyzerSchemaCanvasTable<TableAnalyzerDomain>()
        expect(analyzerTable.callableCaseCount == 1)
        expect(analyzerTable.captureByteCount(for: 0) == nil)
        expect(analyzerTable.captureByteCount(for: 1) == UInt16(MemoryLayout<AnalyzerTrace<TableAnalyzerDomain>>.stride))
        expect(analyzerTable.captureByteCount(for: 2) == nil)
        expect(AnalyzerSchemaCanvasTable<TableAnalyzerDomain>.payload(_GiftUISpacerPayload(minLength: 0)) == nil)
        guard let analyzerPayload = AnalyzerSchemaCanvasTable<TableAnalyzerDomain>.payload(analyzer)
        else { preconditionFailure("missing generated Analyzer payload") }
        expect(AnalyzerSchemaCanvasTable<TableAnalyzerDomain>.caseID(for: analyzerPayload) == 1)
        var analyzerSlots: InlineArray<1, AnalyzerSlot> = .init(repeating: AnalyzerSlot(count: 2, trace: pointer))
        do throws(DrawingError) {
            try workspace.withCanvasContext(identity: 1, surfaceOrigin: Point(x: 10, y: 20), inheritedClip: CanvasLayout().rootBounds) { (context) throws(DrawingError) in
                let analyzerRead = _GiftUIFrameRead<TableAnalyzerDomain>(slots: analyzerSlots.span)
                try analyzerTable.invoke(id: 1, captures: analyzerPayload, context: &context, size: Size(width: 5, height: 7)!, read: analyzerRead)
                do throws(DrawingError) {
                    try analyzerTable.invoke(id: 0, captures: analyzerPayload, context: &context, size: Size(width: 5, height: 7)!, read: analyzerRead)
                    preconditionFailure("invalid Analyzer ID accepted")
                } catch { expect(error == .invariantViolation) }
            }
        } catch { preconditionFailure("Analyzer witness failed") }
        expect(pointer.pointee.readCount == 2)
        expect(pointer.pointee.strokes == 2)
        expect(pointer.pointee.endpoints[0] == Point(x: 5, y: 7))
    }
    return checks
}
