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
// The single scalar derivation serves runtime region storage and measurement.
// The visitor receives copied numeric metadata synchronously, never a capability.
struct CounterEmbeddedLayoutSummary {
    var cursor = 0
    var maximumAlignment = 1
    var fields = 0
    var slotBytes = 0
    var totalBytes = 0
    @inline(__always)
    fileprivate mutating func append<T: ~Copyable>(_ type: T.Type, count: Int, surplus: Int = 0,
        visit: (Int, CounterEmbeddedRegion) -> Void) -> Bool {
        let size = MemoryLayout<T>.size, stride = MemoryLayout<T>.stride, alignment = MemoryLayout<T>.alignment
        guard count >= 0, stride >= size, alignment > 0, fields < 25 else { return false }
        let product = stride.multipliedReportingOverflow(by: count)
        let remainder = cursor % alignment
        let start = cursor.addingReportingOverflow(remainder == 0 ? 0 : alignment - remainder)
        guard !product.overflow, !start.overflow else { return false }
        let retained = product.partialValue.addingReportingOverflow(surplus)
        guard !retained.overflow else { return false }
        let end = start.partialValue.addingReportingOverflow(retained.partialValue)
        guard !end.overflow else { return false }
        visit(fields, .init(offset: start.partialValue, count: count, size: size, stride: stride, alignment: alignment, extent: retained.partialValue))
        fields += 1; cursor = end.partialValue; maximumAlignment = max(maximumAlignment, alignment)
        return true
    }
}
@inline(__always)
func counterDeriveEmbeddedLayout(r1Surplus: Int = 0,
    _ visit: (Int, CounterEmbeddedRegion) -> Void) -> CounterEmbeddedLayoutSummary? {
    guard r1Surplus >= 0 else { return nil }
    var state = CounterEmbeddedLayoutSummary()
    guard state.append(RuntimeProfileLimits.self, count: 1, visit: visit) else { return nil }
    guard state.append(StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>.self, count: 1, visit: visit) else { return nil }
    guard state.append(StaticSemanticRecordStorage.self, count: 1, visit: visit) else { return nil }
    guard state.append(SemanticRuntimeRecord.self, count: 128, visit: visit) else { return nil }
    guard state.append(SemanticPathEntry.self, count: 384, visit: visit) else { return nil }
    guard state.append(CounterPayload?.self, count: 256, visit: visit) else { return nil }
    guard state.append(UInt32.self, count: 128, visit: visit) else { return nil }
    guard state.append(StaticCanvasValueStorage.self, count: 1, visit: visit) else { return nil }
    guard state.append(CanvasStagedEntry<SemanticRecordReference, CounterValueTable.CaptureStorage>?.self, count: 1, visit: visit) else { return nil }
    guard state.append(UInt8.self, count: 1024, visit: visit) else { return nil }
    guard state.append(UInt8.self, count: 1056, visit: visit) else { return nil }
    guard state.append(UInt8.self, count: 20, visit: visit) else { return nil }
    guard state.append(UInt8.self, count: 112, visit: visit) else { return nil }
    guard state.append(StaticCounterLayoutWorkspace.self, count: 1, visit: visit) else { return nil }
    guard state.append(StaticCounterResolvedLayoutStorage.self, count: 1, visit: visit) else { return nil }
    guard state.append(InlineArray<64, SemanticRecordReference?>.self, count: 1, visit: visit) else { return nil }
    guard state.append(StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>.self, count: 1, visit: visit) else { return nil }
    guard state.append(QualifiedRender.self, count: 1, visit: visit) else { return nil }
    guard state.append(CounterStaticCandidate.self, count: 1, visit: visit) else { return nil }
    guard state.append(CounterStaticHits.self, count: 1, visit: visit) else { return nil }
    guard state.append(CounterStaticCommitted.self, count: 1, visit: visit) else { return nil }
    guard state.append(CounterStaticCommitted.self, count: 1, surplus: r1Surplus, visit: visit) else { return nil }
    guard state.append(CounterStaticHits.self, count: 1, visit: visit) else { return nil }
    guard state.append(CounterControl.self, count: 1, visit: visit) else { return nil }
    guard state.append(Bool.self, count: 1, visit: visit) else { return nil }
    let remainder = state.cursor % state.maximumAlignment
    let padding = remainder == 0 ? 0 : state.maximumAlignment - remainder
    let end = state.cursor.addingReportingOverflow(padding)
    guard !end.overflow else { return nil }
    state.slotBytes = end.partialValue
    let total = state.slotBytes.multipliedReportingOverflow(by: counterEmbeddedSlotCount)
    guard !total.overflow else { return nil }
    state.totalBytes = total.partialValue
    return state
}
// All arithmetic and fields share the same derivation. Runtime binding still
// rejects every region beyond supplied storage before any pointer binding/init.
@inline(__always)
func counterVisitEmbeddedLayout(suppliedByteCount: Int, r1Surplus: Int = 0,
    _ visit: (Int, CounterEmbeddedRegion) -> Void) -> CounterEmbeddedLayoutSummary? {
    guard suppliedByteCount > 0,
          let summary = counterDeriveEmbeddedLayout(r1Surplus: r1Surplus, visit),
          summary.slotBytes <= suppliedByteCount else { return nil }
    return summary
}
struct CounterEmbeddedLayout {
    private(set) var regions: InlineArray<25, CounterEmbeddedRegion?>
    private(set) var cursor: Int
    private(set) var maximumAlignment: Int
    private(set) var fields: Int
    private(set) var slotBytes: Int
    private(set) var totalBytes: Int
    @inline(__always)
    init?(suppliedByteCount: Int, r1Surplus: Int = 0) {
        var collected: InlineArray<25, CounterEmbeddedRegion?> = .init(repeating: nil)
        guard let summary = counterVisitEmbeddedLayout(suppliedByteCount: suppliedByteCount, r1Surplus: r1Surplus,
            { index, region in collected[index] = region }) else { return nil }
        regions = collected
        cursor = summary.cursor; maximumAlignment = summary.maximumAlignment; fields = summary.fields
        slotBytes = summary.slotBytes; totalBytes = summary.totalBytes
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
