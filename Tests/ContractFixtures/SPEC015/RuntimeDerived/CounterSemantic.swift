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
struct CounterSemanticCodec: CanvasSemanticPayloadCodec, ~Escapable {
    typealias Roles = CounterRoles
    typealias Table = CounterValueTable
    typealias Sink = CounterRecordSink
    let state: UnsafeMutablePointer<CanvasPendingMetadata>
    let captures: UnsafeMutableBufferPointer<CounterValueTable.CaptureStorage?>
    let payloadOrdinals: UnsafeMutableBufferPointer<UInt16>
    let capacity: UInt16

    @_lifetime(borrow state, borrow captures, borrow payloadOrdinals)
    init(
        state: borrowing UnsafeMutablePointer<CanvasPendingMetadata>,
        captures: borrowing UnsafeMutableBufferPointer<CounterValueTable.CaptureStorage?>,
        payloadOrdinals: borrowing UnsafeMutableBufferPointer<UInt16>, capacity: UInt16
    ) {
        self.state = copy state
        self.captures = copy captures
        self.payloadOrdinals = copy payloadOrdinals
        self.capacity = capacity
    }
    @_lifetime(borrow state, borrow captures, borrow payloadOrdinals)
    static func makeCodec(
        state: borrowing UnsafeMutablePointer<CanvasPendingMetadata>,
        captures: borrowing UnsafeMutableBufferPointer<CounterValueTable.CaptureStorage?>,
        payloadOrdinals: borrowing UnsafeMutableBufferPointer<UInt16>, capacity: UInt16
    ) -> Self {
        Self(state: state, captures: captures, payloadOrdinals: payloadOrdinals, capacity: capacity)
    }
    @_lifetime(copy self, copy state)
    borrowing func makeSink(state: consuming SemanticRecordSinkState) -> CounterRecordSink {
        CounterRecordSink(state: consume state, codec: self)
    }
}

struct CounterRecordSink: SemanticExpansionSink, ~Escapable {
    typealias Identity = SemanticCompleteIdentity
    var state: SemanticRecordSinkState
    let codec: CounterSemanticCodec

    @_lifetime(copy state, copy codec)
    init(state: consuming SemanticRecordSinkState, codec: borrowing CounterSemanticCodec) {
        self.state = consume state
        self.codec = copy codec
    }
    var stagingFailure: SemanticExpansionError? { state.stagingFailure }
    var maximumStructuralOccurrences: UInt16 { state.maximumStructuralOccurrences }
    var maximumBodyEvaluations: UInt16 { state.maximumBodyEvaluations }
    var maximumSemanticOccurrences: UInt16 { state.maximumSemanticOccurrences }
    var maximumModifierApplications: UInt16 { state.maximumModifierApplications }
    var maximumActionOccurrences: UInt16 { state.maximumActionOccurrences }
    mutating func beginExpansion() -> Bool { state.beginExpansion() }
    mutating func stageStructuralOccurrence(identity: borrowing Identity) -> Bool {
        state.stageStructuralOccurrence(identity: identity)
    }
    mutating func stageBodyEvaluation(identity: borrowing Identity) -> Bool {
        state.stageBodyEvaluation(identity: identity)
    }
    mutating func stageSemanticOccurrence<Value: _GiftUISemanticPrimitivePayload>(
        identity: borrowing Identity, payload: borrowing Value
    ) -> Bool {
        let error = codec.primitive(payload, writer: state.payloadWriter())
        return state.stageSemanticResult(error)
    }
    mutating func stageModifierApplication<Value: _GiftUISemanticModifierPayload>(
        identity: borrowing Identity, payload: borrowing Value, chainIndex: UInt16
    ) -> Bool {
        let error = codec.modifier(payload, chainIndex: chainIndex, writer: state.payloadWriter())
        return state.stageModifierResult(error)
    }
    mutating func stageActionOccurrence<Value: GiftUIAction>(
        identity: borrowing Identity, action: borrowing Value
    ) -> Bool {
        let error = codec.action(action, writer: state.payloadWriter())
        return state.stageActionResult(error)
    }
    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool {
        state.publishExpansion(summary)
    }
    mutating func discardExpansion() { state.discardExpansion() }
    mutating func resetExpansion() { state.resetExpansion() }
}

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
            capacity: Self.capacity, codec: CounterSemanticCodec.self, body)
    }
}
