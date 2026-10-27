import GiftUI
import GiftUIDrawing
import GiftUISemanticCore
import P08CounterTable
import P08CounterSchema
import P08CounterPresentation

package typealias CounterPayload = SemanticRecordPayload

// Finite type metadata only. These inert samples expose the existing API's
// opaque modifier types; no sample is expanded, bound, stored or used as input.
// All occurrence paths and child positions come from actual traversal.
package enum CounterRoles: SemanticDeclarationRoles {
    @inlinable
    @inline(__always)
    static func matches<V, Sample>(_ type: V.Type, _ sample: Sample) -> Bool { V.self == Sample.self }
    package static func role<V>(of type: V.Type) -> SemanticRecordingRole? {
        if V.self == CounterAction.self { return .init(rawValue: 6) }
        if V.self == CounterScreen<CounterDomain>.self { return .init(rawValue: 1) }
        if V.self == CounterScreen<CounterDomain>.Body.self { return .init(rawValue: 2) }
        if V.self == Text<CounterDomain>.self { return .init(rawValue: 3) }
        if V.self == Button<CounterAction, Text<CounterDomain>>.self { return .init(rawValue: 4) }
        if V.self == CounterCanvas<CounterDomain>.self { return .init(rawValue: 5) }
        let label = Text<CounterDomain>("")
        let button = try! Button(action: CounterAction.increment) { Text<CounterDomain>("") }
        let disabled = button.disabled(false)
        // The key is used solely to select the generic opaque frame type.
        let canvas = CounterCanvas<CounterDomain>(model: .init(ownerInstance: 0, allocationGeneration: 0, slot: 0)).frame(width: 48, height: 16)
        if matches(type, disabled) { return .init(rawValue: 7) }
        if matches(type, canvas) { return .init(rawValue: 8) }
        let stack = try! VStack(spacing: 4) { label; label; disabled; disabled; canvas }
        if matches(type, stack) { return .init(rawValue: 10) }
        if matches(type, TupleView5(label, label, disabled, disabled, canvas)) { return .init(rawValue: 9) }
        return nil
    }
    package static func modifierDiscriminator<V>(of type: V.Type) -> UInt16 { 0 }
}

// Concrete attempt-owned capture backing; it is not a consumer payload pool.
typealias CounterSemanticCodec = CanvasSemanticPayloadCodec<CounterRoles, CounterValueTable>
struct CounterPendingBacking: ~Copyable {
    var metadata = CanvasPendingMetadata()
    var captures: InlineArray<24, CounterValueTable.CaptureStorage?> = .init(repeating: nil)
    var payloadOrdinals: InlineArray<24, UInt16> = .init(repeating: .max)
    static var capacity: UInt16 { 24 }
    static var paddingBytes: Int {
        let fields = MemoryLayout<CanvasPendingMetadata>.size
            + MemoryLayout<InlineArray<24, CounterValueTable.CaptureStorage?>>.size
            + MemoryLayout<InlineArray<24, UInt16>>.size
        precondition(MemoryLayout<Self>.size >= fields)
        return MemoryLayout<Self>.size - fields
    }
    mutating func withLifetime<Result>(
        _ body: (borrowing CounterSemanticCodec) throws(SemanticExpansionError) -> Result
    ) throws(SemanticExpansionError) -> Result {
        var captures = captures.mutableSpan
        var ordinals = payloadOrdinals.mutableSpan
        return try withCanvasSemanticPayloadCodec(
            metadata: &metadata, captures: &captures, payloadOrdinals: &ordinals,
            capacity: Self.capacity, roles: CounterRoles.self, table: CounterValueTable.self, body)
    }
}
