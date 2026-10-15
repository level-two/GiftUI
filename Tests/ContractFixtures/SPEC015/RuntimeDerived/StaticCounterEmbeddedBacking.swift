import P08CounterTable
import P08CounterSchema
import GiftUI
import GiftUIDrawing
@testable import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
@testable import GiftUIRuntimeCore
import GiftUISemanticCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif


// Target disassembly derives this minimum; strict numeric materialization,
// C-symbol comparison and complete fit remain separately unvalidated.
#if hasFeature(Embedded)
let counterEmbeddedSlotBytes = 32000
let counterEmbeddedSlotCount = 4
struct CounterEmbeddedElements<Element> {
    let start: UnsafeMutablePointer<Element>
    let count: Int
    var mutableSpan: MutableSpan<Element> {
        @_lifetime(&self)
        mutating get { MutableSpan(_unsafeStart: start, count: count) }
    }
}
struct CounterEmbeddedSemanticBacking {
    var records: CounterEmbeddedElements<SemanticRuntimeRecord>
    var paths: CounterEmbeddedElements<SemanticPathEntry>
    var payloads: CounterEmbeddedElements<CounterPayload?>
    var scalars: CounterEmbeddedElements<UInt32>
}
struct CounterEmbeddedRegion {
    let offset: Int
    let count: Int
    let size: Int
    let stride: Int
    let alignment: Int
    let extent: Int
}
struct CounterEmbeddedLayout {
    private(set) var regions: InlineArray<25, CounterEmbeddedRegion?> = .init(repeating: nil)
    private(set) var cursor = 0
    private(set) var maximumAlignment = 1
    private(set) var fields = 0
    private(set) var slotBytes = 0
    private(set) var totalBytes = 0
    @inline(__always)
    init?(suppliedByteCount: Int, r1Surplus: Int = 0) {
        guard suppliedByteCount > 0, r1Surplus >= 0 else { return nil }
        guard append(RuntimeProfileLimits.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(StaticSemanticRecordStorage.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(SemanticRuntimeRecord.self, count: 128, limit: suppliedByteCount) else { return nil }
        guard append(SemanticPathEntry.self, count: 384, limit: suppliedByteCount) else { return nil }
        guard append(CounterPayload?.self, count: 256, limit: suppliedByteCount) else { return nil }
        guard append(UInt32.self, count: 128, limit: suppliedByteCount) else { return nil }
        guard append(StaticCanvasValueStorage.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(UInt8.self, count: 1024, limit: suppliedByteCount) else { return nil }
        guard append(UInt8.self, count: 1056, limit: suppliedByteCount) else { return nil }
        guard append(UInt8.self, count: 20, limit: suppliedByteCount) else { return nil }
        guard append(UInt8.self, count: 112, limit: suppliedByteCount) else { return nil }
        guard append(StaticCounterLayoutWorkspace.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(StaticCounterResolvedLayoutStorage.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(InlineArray<64, SemanticRecordReference?>.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(QualifiedRender.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(CounterStaticCandidate.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(CounterStaticHits.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(CounterStaticCommitted.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(CounterStaticCommitted.self, count: 1, limit: suppliedByteCount, surplus: r1Surplus) else { return nil }
        guard append(CounterStaticHits.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(CounterControl.self, count: 1, limit: suppliedByteCount) else { return nil }
        guard append(Bool.self, count: 1, limit: suppliedByteCount) else { return nil }
        let remainder = cursor % maximumAlignment
        let padding = remainder == 0 ? 0 : maximumAlignment - remainder
        let end = cursor.addingReportingOverflow(padding)
        guard !end.overflow, end.partialValue <= suppliedByteCount else { return nil }
        slotBytes = end.partialValue
        let total = slotBytes.multipliedReportingOverflow(by: counterEmbeddedSlotCount)
        guard !total.overflow else { return nil }
        totalBytes = total.partialValue
    }
    @inline(__always)
    private mutating func append<T: ~Copyable>(_ type: T.Type, count: Int, limit: Int, surplus: Int = 0) -> Bool {
        let size = MemoryLayout<T>.size, stride = MemoryLayout<T>.stride, alignment = MemoryLayout<T>.alignment
        guard count >= 0, stride >= size, alignment > 0, fields < regions.count else { return false }
        let product = stride.multipliedReportingOverflow(by: count)
        let remainder = cursor % alignment
        let start = cursor.addingReportingOverflow(remainder == 0 ? 0 : alignment - remainder)
        guard !product.overflow, !start.overflow else { return false }
        let retained = product.partialValue.addingReportingOverflow(surplus)
        guard !retained.overflow else { return false }
        let end = start.partialValue.addingReportingOverflow(retained.partialValue)
        guard !end.overflow, end.partialValue <= limit else { return false }
        regions[fields] = .init(offset: start.partialValue, count: count, size: size, stride: stride, alignment: alignment, extent: retained.partialValue)
        fields += 1; cursor = end.partialValue; maximumAlignment = max(maximumAlignment, alignment)
        return true
    }
}
func counterEmbeddedField<T: ~Copyable>(_ bytes: UnsafeMutableRawBufferPointer,
    _ type: T.Type, region: CounterEmbeddedRegion) -> UnsafeMutablePointer<T> {
    precondition(region.size == MemoryLayout<T>.size && region.stride == MemoryLayout<T>.stride && region.alignment == MemoryLayout<T>.alignment)
    let end = region.offset.addingReportingOverflow(region.extent)
    precondition(region.offset >= 0 && !end.overflow && end.partialValue <= bytes.count)
    let absolute = UInt(bitPattern: bytes.baseAddress!).addingReportingOverflow(UInt(region.offset))
    precondition(!absolute.overflow && absolute.partialValue % UInt(region.alignment) == 0)
    return UnsafeMutableRawPointer(bitPattern: absolute.partialValue)!.bindMemory(to: T.self, capacity: region.count)
}
#endif
func counterSelectedProfileBacking(_ backing: UnsafeMutableRawBufferPointer?, slot: Int) -> UnsafeMutableRawBufferPointer? {
    #if hasFeature(Embedded)
    guard let backing else { preconditionFailure("Embedded counter requires caller backing") }
    precondition((0..<counterEmbeddedSlotCount).contains(slot))
    let total = counterEmbeddedSlotCount.multipliedReportingOverflow(by: counterEmbeddedSlotBytes)
    let start = slot.multipliedReportingOverflow(by: counterEmbeddedSlotBytes)
    let end = start.partialValue.addingReportingOverflow(counterEmbeddedSlotBytes)
    precondition(!total.overflow && !start.overflow && !end.overflow && backing.count == total.partialValue)
    return UnsafeMutableRawBufferPointer(rebasing: backing[start.partialValue..<end.partialValue])
    #else
    return nil
    #endif
}
