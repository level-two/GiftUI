import CycleTable
import GiftUI
import GiftUIDrawing
import GiftUIObservableState
import GiftUISemanticCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import CycleSchema
import CyclePresentation

private typealias Payload = SemanticRecordPayload
enum CycleRoles: SemanticDeclarationRoles {
    static func role<V>(of type: V.Type) -> SemanticRecordingRole? {
        if V.self == CycleScene<CycleDomain>.self { return .init(rawValue: 1) }
        if V.self == CycleScene<CycleDomain>.Body.self { return .init(rawValue: 2) }
        if V.self == CycleRoot<CycleDomain>.self { return .init(rawValue: 3) }
        if V.self == CycleRoot<CycleDomain>.Body.self { return .init(rawValue: 4) }
        if V.self == TupleView3<Text<CycleDomain>, Button<CycleAction, Text<CycleDomain>>, CycleTrace<CycleDomain>>.self { return .init(rawValue: 5) }
        if V.self == Text<CycleDomain>.self { return .init(rawValue: 6) }
        if V.self == Button<CycleAction, Text<CycleDomain>>.self { return .init(rawValue: 7) }
        if V.self == CycleTrace<CycleDomain>.self { return .init(rawValue: 8) }
        if V.self == CycleAction.self { return .init(rawValue: 9) }
        return nil
    }
    static func modifierDiscriminator<V>(of type: V.Type) -> UInt16 { 0 }
}
private struct Backing: ~Copyable {
    var records: InlineArray<252, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<756, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<196, Payload?> = .init(repeating: nil)
    var scalars: InlineArray<448, UInt32> = .init(repeating: 0)
}
private func exercise(_ semantic: borrowing SemanticRecordStore, models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, dynamic: Bool) throws(SemanticExpansionError) -> Int {
    var checks = 0
    func expect(_ okay: Bool) { checks += 1; precondition(okay) }
    let limits = SemanticExpansionLimits(maximumDepth: 34, maximumSemanticNodes: 48, maximumBodyEvaluations: 14, maximumModifierApplications: 50, maximumActionOccurrences: 6)!
    do throws(ObservableStateError) {
        expect(root.belongs(to: models))
        var foreignNamespace = ObservableModelOwnerNamespace()
        #if hasFeature(Embedded)
        var foreign = StaticObservableModelStorage<CycleOwnedModel, CycleModelSchema>(identity: try foreignNamespace.issue(), schema: 1, needsCapture: false)!
        #else
        var ownership = ObservableModelOwnership(identity: try foreignNamespace.issue(), captureLimit: 0)!
        var backing: InlineArray<2, CycleOwnedModel?> = .init { _ in nil }
        #endif
        func rejectForeign(_ other: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>) throws(ObservableStateError) {
            expect(!root.belongs(to: other))
            var pendingBacking = CyclePendingBacking()
            do throws(SemanticExpansionError) {
                try pendingBacking.withLifetime { (codec) throws(SemanticExpansionError) in
                    let rejected = semantic.expand(CycleScene<CycleDomain>(show: true), roles: CycleRoles.self, codec: codec, limits: limits, binding: ObservableSemanticBodyBinding(models: other.borrowedScope(), root: root.borrowedRoot(), domain: CycleDomain.self))
                    guard case .bindingFailure(.incompatibleAssociation) = rejected else { preconditionFailure("foreign owner accepted") }
                    checks += 1
                    expect(other.phase == .mutating && models.phase == .mutating)
                }
            } catch { preconditionFailure("pending semantic storage") }
            expect(pendingBacking.isClear())
        }
        #if hasFeature(Embedded)
        try foreign.withLifetime(rejectForeign)
        #else
        var modelSpan = backing.mutableSpan
        try withObservableModelScope(ownership: &ownership, models: &modelSpan,
            schema: 1, needsCapture: false, rejectForeign)
        #endif
        for show in [true, true, false, true] {
            try models.beginFrame()
            try models.withDiscovery { () throws(ObservableStateError) in
                guard case .success = root.beginCandidate() else { preconditionFailure("begin candidate") }
            }
            var pendingBacking = CyclePendingBacking()
            do throws(SemanticExpansionError) {
                try pendingBacking.withLifetime { (codec) throws(SemanticExpansionError) in
                    let result = semantic.expand(CycleScene<CycleDomain>(show: show), roles: CycleRoles.self, codec: codec, limits: limits, binding: ObservableSemanticBodyBinding(models: models.borrowedScope(), root: root.borrowedRoot(), domain: CycleDomain.self))
                    guard case .success = result else { preconditionFailure("finite State expansion") }
                    do throws(DrawingError) {
                        try withCycleValues(dynamic: dynamic) { (values) throws(DrawingError) in
                            try CanvasSemanticTransfer.stage(from: semantic, pending: codec, into: values, table: CycleValueTable())
                            expect(values.count == (show ? 1 : 0))
                            #if !hasFeature(Embedded)
                            if dynamic { checks += cycleDynamicDrawing(semantic: semantic, models: models, values: values, shown: show) }
                            else { checks += cycleStaticDrawing(semantic: semantic, models: models, values: values, shown: show) }
                            #else
                            checks += cycleStaticDrawing(semantic: semantic, models: models, values: values, shown: show)
                            #endif
                            values.discard()
                            expect(values.releaseCount == (show ? 1 : 0))
                        }
                    } catch { preconditionFailure("Canvas transfer") }
                }
            } catch { preconditionFailure("pending semantic storage") }
            expect(pendingBacking.isClear())
            try models.withDiscovery { () throws(ObservableStateError) in
                guard case .success = root.finishCandidate(.publish) else { preconditionFailure("State publish") }
            }
            try models.endFrame()
            expect(models.phase == .mutating)
            // Actual semantic publication is outside the ObservableState typed-error scope.
            do throws(SemanticExpansionError) { try semantic.publishCandidate() }
            catch { preconditionFailure("semantic publication") }
        }
    } catch { preconditionFailure("model phase") }
    return checks
}
private func withSemantic(models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, dynamic: Bool) -> Int {
    do throws(SemanticExpansionError) {
        var namespace = SemanticRecordOwnerNamespace()
        let limits = SemanticRecordLimits(records: 126, paths: 378, depth: 34, fanout: 5, payloads: 98, textScalars: 224, payloadBytes: UInt32(98 * MemoryLayout<Payload?>.stride + 224 * 4))!
        #if !hasFeature(Embedded)
        if dynamic {
            let storage = DynamicSemanticRecordStorage(limits: limits, owner: try namespace.issue())
            let before = storage.retainedExtents
            precondition(before.records >= 252 && before.paths >= 756 && before.payloads >= 196 && before.scalars >= 448)
            let result = try storage.withLifetime { (semantic) throws(SemanticExpansionError) in
                try exercise(semantic, models: models, root: root, dynamic: dynamic)
            }
            let after = storage.retainedExtents
            precondition(before.recordBytes == after.recordBytes && before.pathBytes == after.pathBytes)
            precondition(before.payloadBytes == after.payloadBytes && before.controlBytes == after.controlBytes)
            return result + 3
        }
        #endif
        var storage = StaticSemanticRecordStorage(limits: limits, owner: try namespace.issue())
        var backing = Backing()
        var records = backing.records.mutableSpan; var paths = backing.paths.mutableSpan
        var payloads = backing.payloads.mutableSpan; var scalars = backing.scalars.mutableSpan
        return try storage.withLifetime(records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
            try exercise(semantic, models: models, root: root, dynamic: dynamic)
        }
    } catch { preconditionFailure("semantic owner") }
}
public func giftuiP07CycleSemantic() -> Int {
    var checks = cycleStaticDrawingRollback() + cycleAdmissionBackingProbe() + cycleFactoryProbe() + cycleFactoryCapacityProbe() + cycleConfiguredLimitProbe()
    do throws(ObservableStateError) {
        var namespace = ObservableModelOwnerNamespace()
        var storage = CycleStaticRootStorage(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        let staticLayout = storage.storageLayout
        precondition(staticLayout.models == 2 && staticLayout.claims == 4 && staticLayout.pins == 2 && staticLayout.captures == 0)
        precondition(staticLayout.pinBytes == 2 * MemoryLayout<Bool>.size)
        checks += 2
        checks += try storage.withLifetime { (models, root) throws(ObservableStateError) in
            withSemantic(models: models, root: root, dynamic: false)
        }
        #if !hasFeature(Embedded)
        checks += cycleDynamicStorageEdges() + cycleDynamicDrawingRollback()
        let dynamic = DynamicObservableRootAdapter<CycleOwnedModel, SemanticCompleteIdentity>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
        let dynamicLayout = dynamic.storageLayout
        precondition(dynamicLayout.models == staticLayout.models && dynamicLayout.claims == staticLayout.claims && dynamicLayout.pins == staticLayout.pins)
        precondition(dynamicLayout.modelBytes == staticLayout.modelBytes && dynamicLayout.pinBytes == staticLayout.pinBytes)
        precondition(dynamicLayout.liveBytes == staticLayout.liveBytes && dynamicLayout.candidateBytes == staticLayout.candidateBytes)
        checks += 3
        checks += try dynamic.withLifetime { (models, root) throws(ObservableStateError) in
            withSemantic(models: models, root: root, dynamic: true)
        }
        #endif
    } catch { preconditionFailure("root owner") }
    return checks
}

private func withCycleValues(dynamic: Bool, _ body: (borrowing CanvasStagedValues<SemanticRecordReference, CycleValueTable>) throws(DrawingError) -> Void) throws(DrawingError) {
    let limits = StaticCanvasLimits(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: 32)!
    #if !hasFeature(Embedded)
    if dynamic {
        var storage = DynamicCanvasCallableStorage<SemanticRecordReference, CycleValueTable>(capacity: 1)
        return try storage.withLifetime(table: CycleValueTable(), limits: limits, body)
    }
    #endif
    var storage = StaticCanvasValueStorage()
    var backing: InlineArray<1, CanvasStagedEntry<SemanticRecordReference, CycleValueTable.CaptureStorage>?> = .init(repeating: nil)
    var entries = backing.mutableSpan
    try storage.withLifetime(entries: &entries, table: CycleValueTable(), capacity: 1, limits: limits, body)
}

// Concrete attempt-owned capture backing; it is not a consumer payload pool.
struct CycleSemanticCodec: CanvasSemanticPayloadCodec, ~Escapable {
    typealias Roles = CycleRoles
    typealias Table = CycleValueTable
    typealias Sink = CycleRecordSink
    let state: UnsafeMutablePointer<CanvasPendingMetadata>
    let captures: UnsafeMutableBufferPointer<CycleValueTable.CaptureStorage?>
    let payloadOrdinals: UnsafeMutableBufferPointer<UInt16>
    let capacity: UInt16

    @_lifetime(borrow state, borrow captures, borrow payloadOrdinals)
    init(
        state: borrowing UnsafeMutablePointer<CanvasPendingMetadata>,
        captures: borrowing UnsafeMutableBufferPointer<CycleValueTable.CaptureStorage?>,
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
        captures: borrowing UnsafeMutableBufferPointer<CycleValueTable.CaptureStorage?>,
        payloadOrdinals: borrowing UnsafeMutableBufferPointer<UInt16>, capacity: UInt16
    ) -> Self {
        Self(state: state, captures: captures, payloadOrdinals: payloadOrdinals, capacity: capacity)
    }
    @_lifetime(copy self, copy state)
    borrowing func makeSink(state: consuming SemanticRecordSinkState) -> CycleRecordSink {
        CycleRecordSink(state: consume state, codec: self)
    }
}

struct CycleRecordSink: SemanticExpansionSink, ~Escapable {
    typealias Identity = SemanticCompleteIdentity
    var state: SemanticRecordSinkState
    let codec: CycleSemanticCodec

    @_lifetime(copy state, copy codec)
    init(state: consuming SemanticRecordSinkState, codec: borrowing CycleSemanticCodec) {
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

struct CyclePendingBacking: ~Copyable {
    var metadata = CanvasPendingMetadata()
    var captures: InlineArray<48, CycleValueTable.CaptureStorage?> = .init(repeating: nil)
    var payloadOrdinals: InlineArray<48, UInt16> = .init(repeating: .max)
    static var capacity: UInt16 { 48 }
    borrowing func isClear() -> Bool {
        for index in 0..<captures.count {
            if case .some = captures[index] { return false }
            if payloadOrdinals[index] != .max { return false }
        }
        return true
    }
    static var paddingBytes: Int {
        let fields = MemoryLayout<CanvasPendingMetadata>.size
            + MemoryLayout<InlineArray<48, CycleValueTable.CaptureStorage?>>.size
            + MemoryLayout<InlineArray<48, UInt16>>.size
        precondition(MemoryLayout<Self>.size >= fields)
        return MemoryLayout<Self>.size - fields
    }
    mutating func withLifetime<Result>(
        _ body: (borrowing CycleSemanticCodec) throws(SemanticExpansionError) -> Result
    ) throws(SemanticExpansionError) -> Result {
        var captures = captures.mutableSpan
        var ordinals = payloadOrdinals.mutableSpan
        return try withCanvasSemanticPayloadCodec(
            metadata: &metadata, captures: &captures, payloadOrdinals: &ordinals,
            capacity: Self.capacity, codec: CycleSemanticCodec.self, body)
    }
}
