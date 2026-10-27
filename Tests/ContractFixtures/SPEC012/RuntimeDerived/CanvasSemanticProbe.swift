import GiftUI
import GiftUIDrawing
import GiftUILayout
import GiftUIRenderCore
import GiftUISemanticCore
import GiftUITextResources
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import CounterSchema
import CounterCanvas
import CounterCanvasTable

private typealias Payload = SemanticRecordPayload
private typealias ProbeSemanticRoles = Roles

private struct ProbeSemanticCodec: CanvasSemanticPayloadCodec, ~Escapable {
    typealias Roles = ProbeSemanticRoles
    typealias Table = CanvasTable
    typealias Sink = ProbeRecordSink
    let state: UnsafeMutablePointer<CanvasPendingMetadata>
    let captures: UnsafeMutableBufferPointer<CanvasTable.CaptureStorage?>
    let payloadOrdinals: UnsafeMutableBufferPointer<UInt16>
    let capacity: UInt16

    @_lifetime(borrow state, borrow captures, borrow payloadOrdinals)
    init(
        state: borrowing UnsafeMutablePointer<CanvasPendingMetadata>,
        captures: borrowing UnsafeMutableBufferPointer<CanvasTable.CaptureStorage?>,
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
        captures: borrowing UnsafeMutableBufferPointer<CanvasTable.CaptureStorage?>,
        payloadOrdinals: borrowing UnsafeMutableBufferPointer<UInt16>, capacity: UInt16
    ) -> Self {
        Self(state: state, captures: captures, payloadOrdinals: payloadOrdinals, capacity: capacity)
    }
    @_lifetime(copy self, copy state)
    borrowing func makeSink(state: consuming SemanticRecordSinkState) -> ProbeRecordSink {
        ProbeRecordSink(state: consume state, codec: self)
    }
}

private struct ProbeRecordSink: SemanticExpansionSink, ~Escapable {
    typealias Identity = SemanticCompleteIdentity
    var state: SemanticRecordSinkState
    let codec: ProbeSemanticCodec

    @_lifetime(copy state, copy codec)
    init(state: consuming SemanticRecordSinkState, codec: borrowing ProbeSemanticCodec) {
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

private enum Roles: SemanticDeclarationRoles {
    static func role<V>(of type: V.Type) -> SemanticRecordingRole? {
        if V.self == CounterCanvasRoot<CanvasDomain>.self { return .init(rawValue: 1) }
        if V.self == CounterCanvasRoot<CanvasDomain>.Body.self { return .init(rawValue: 2) }
        if V.self == TupleView<CounterTrace<CanvasDomain>, CounterTrace<CanvasDomain>>.self { return .init(rawValue: 3) }
        if V.self == CounterTrace<CanvasDomain>.self { return .init(rawValue: 4) }
        return nil
    }
    static func modifierDiscriminator<V>(of type: V.Type) -> UInt16 { 0 }
}
private struct Binding: SemanticStatefulBinding, ~Copyable, ~Escapable {
    typealias Domain = CanvasDomain
    typealias Identity = SemanticCompleteIdentity
    typealias Failure = UInt8
    let models: ObservableModelScope<CanvasModel, CounterModelSchema>
    @_lifetime(copy models)
    init(models: consuming ObservableModelScope<CanvasModel, CounterModelSchema>) { self.models = consume models }
    borrowing func evaluate<V: View>(_ declaration: borrowing V, beforeBody: () -> SemanticExpansionError?, body: (borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure) -> V.Body) -> SemanticBodyEvaluation<V.Body, UInt8> where V.Domain == Domain, V.Body.Domain == Domain {
        if let error = beforeBody() { return .semanticFailure(error) }
        do throws(_GiftUIAccessFailure) { return .body(try models.withRead(Domain.self, body)) }
        catch { return .accessFailure(error) }
    }
    borrowing func evaluateStateful<V: View & _GiftUIObservableStateHost>(_ declaration: borrowing V, structuralIdentity: Identity, beforeBody: () -> SemanticExpansionError?, body: (borrowing V, borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure) -> V.Body) -> SemanticBodyEvaluation<V.Body, UInt8> where V.Domain == Domain, V.Body.Domain == Domain { .bindingFailure(1) }
}
private struct Backing: ~Copyable {
    var records: InlineArray<252, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<756, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<196, Payload?> = .init(repeating: nil)
    var scalars: InlineArray<448, UInt32> = .init(repeating: 0)
}
private struct Sink: LayoutResultSink, LayoutResultSinkState {
    var isLayoutActive = false
    var count = 0
    var identities: InlineArray<3, SemanticRecordReference?> = .init(repeating: nil)
    var bounds: InlineArray<3, Rect?> = .init(repeating: nil)
    mutating func begin(summary: LayoutSummary) -> Bool { isLayoutActive = true; count = 0; return true }
    mutating func stageScope(identity: SemanticRecordReference, bounds: Rect, clip: Rect) -> Bool { guard count < 3 else { return false }; identities[count] = identity; self.bounds[count] = bounds; count += 1; return true }
    mutating func stageTextLine(identity: SemanticRecordReference, lineIndex: UInt16, bounds: Rect, baseline: Point, clip: Rect) -> Bool { false }
    mutating func stageGlyph(identity: SemanticRecordReference, lineIndex: UInt16, glyphIndex: UInt16, instance: FontInstanceID, glyph: GlyphID, baseline: Point, clip: Rect) -> Bool { false }
    mutating func publish() -> Bool { isLayoutActive = false; return true }
    mutating func discard() { isLayoutActive = false }
}
private func withValues(dynamic: Bool, capacity: UInt16, _ body: (borrowing CanvasStagedValues<SemanticRecordReference, CanvasTable>) throws(DrawingError) -> Void) throws(DrawingError) {
    let limits = StaticCanvasLimits(maximumStaticCallableCases: 2, maximumStaticCaptureBytes: 32)!
    #if !hasFeature(Embedded)
    if dynamic {
        var storage = DynamicCanvasCallableStorage<SemanticRecordReference, CanvasTable>(capacity: capacity)
        return try storage.withLifetime(table: CanvasTable(), limits: limits, body)
    }
    #endif
    var storage = StaticCanvasValueStorage()
    var backing: InlineArray<2, CanvasStagedEntry<SemanticRecordReference, CanvasTable.CaptureStorage>?> = .init(repeating: nil)
    var entries = backing.mutableSpan
    try storage.withLifetime(entries: &entries, table: CanvasTable(), capacity: capacity, limits: limits, body)
}
private func pendingIsolation(
    semantic: borrowing SemanticRecordStore,
    pending: borrowing ProbeSemanticCodec,
    scope: borrowing ObservableModelScope<CanvasModel, CounterModelSchema>,
    key: _GiftUIModelKey<CounterModelSchema>, dynamic: Bool,
    expansion: SemanticExpansionLimits
) throws(SemanticExpansionError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ value: Bool) { checks += 1; precondition(value) }
    // The main fixture's fresh store has owner0. A separately checked live
    // attempt uses owner1; refusal must preserve both actual capture pools.
    var namespace = SemanticRecordOwnerNamespace()
    _ = try namespace.issue()
    var foreignStorage = StaticSemanticRecordStorage(limits: semantic.limits, owner: try namespace.issue())
    var foreignBacking = Backing()
    var records = foreignBacking.records.mutableSpan
    var paths = foreignBacking.paths.mutableSpan
    var payloads = foreignBacking.payloads.mutableSpan
    var scalars = foreignBacking.scalars.mutableSpan
    var metadata = CanvasPendingMetadata()
    var captureBacking: InlineArray<48, CanvasTable.CaptureStorage?> = .init(repeating: nil)
    var ordinalBacking: InlineArray<48, UInt16> = .init(repeating: .max)
    var captures = captureBacking.mutableSpan
    var ordinals = ordinalBacking.mutableSpan
    try foreignStorage.withLifetime(records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (foreign) throws(SemanticExpansionError) in
        try withCanvasSemanticPayloadCodec(metadata: &metadata, captures: &captures,
            payloadOrdinals: &ordinals, capacity: 48, codec: ProbeSemanticCodec.self) { (other) throws(SemanticExpansionError) in
            let result = foreign.expand(CounterCanvasRoot<CanvasDomain>(model: key), roles: Roles.self,
                codec: other, limits: expansion, binding: Binding(models: scope.borrowedScope()))
            guard case .success = result else { preconditionFailure("foreign pending setup") }
            expect(other.pendingCount == 2 && other.initializedCaptureCount == 2)
            expect(pending.pendingCount == 2 && pending.initializedCaptureCount == 2)
            do throws(DrawingError) {
                try withValues(dynamic: dynamic, capacity: 2) { values in
                    do throws(DrawingError) {
                        try CanvasSemanticTransfer.stage(from: semantic, pending: other, into: values, table: CanvasTable())
                        preconditionFailure("foreign pending accepted")
                    } catch { expect(error == .invariantViolation) }
                    expect(values.count == 0 && values.releaseCount == 0)
                }
            } catch { preconditionFailure("foreign pending values") }
            do throws(SemanticExpansionError) {
                try semantic.discardCandidate(using: other)
                preconditionFailure("foreign pending discarded")
            } catch { expect(error == .invariantViolation) }
            expect(other.pendingCount == 2 && other.initializedCaptureCount == 2)
            expect(pending.pendingCount == 2 && pending.initializedCaptureCount == 2)
            try foreign.discardCandidate(using: other)
            expect(other.pendingStorageIsClear)
            do throws(SemanticExpansionError) {
                try semantic.discardCandidate(using: other)
                preconditionFailure("unbound pending discarded")
            } catch { expect(error == .invariantViolation) }
            expect(pending.pendingCount == 2 && pending.initializedCaptureCount == 2)
            // HStack plus the first Canvas populate a pending slot before the
            // second Canvas exceeds this independent semantic node bound.
            let early = SemanticExpansionLimits(maximumDepth: 34, maximumSemanticNodes: 2,
                maximumBodyEvaluations: 14, maximumModifierApplications: 50, maximumActionOccurrences: 6)!
            let failure = foreign.expand(CounterCanvasRoot<CanvasDomain>(model: key), roles: Roles.self,
                codec: other, limits: early, binding: Binding(models: scope.borrowedScope()))
            guard case .semanticFailure(.capacityExhausted) = failure else { preconditionFailure("populated early failure") }
            expect(other.pendingStorageIsClear)
        }
    }
    return checks
}

private func exercise(_ semantic: borrowing SemanticRecordStore, scope: borrowing ObservableModelScope<CanvasModel, CounterModelSchema>, key: _GiftUIModelKey<CounterModelSchema>, trace: UnsafeMutablePointer<CanvasTrace>, dynamic: Bool) throws(SemanticExpansionError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ okay: Bool) { checks += 1; precondition(okay) }
    let expansion = SemanticExpansionLimits(maximumDepth: 34, maximumSemanticNodes: 48, maximumBodyEvaluations: 14, maximumModifierApplications: 50, maximumActionOccurrences: 6)!
    let table = CanvasTable()
    var published: SemanticRecordReference?
    // Success, partial transfer failure, then clean retry on the same two banks.
    for attempt in 0..<3 {
        var pending = CanvasPendingMetadata()
        var captureBacking: InlineArray<48, CanvasTable.CaptureStorage?> = .init(repeating: nil)
        var ordinalBacking: InlineArray<48, UInt16> = .init(repeating: .max)
        var captures = captureBacking.mutableSpan
        var ordinals = ordinalBacking.mutableSpan
        try withCanvasSemanticPayloadCodec(metadata: &pending, captures: &captures,
            payloadOrdinals: &ordinals, capacity: expansion.maximumSemanticNodes,
            codec: ProbeSemanticCodec.self) { (codec) throws(SemanticExpansionError) in
            let result = semantic.expand(CounterCanvasRoot<CanvasDomain>(model: key), roles: Roles.self, codec: codec, limits: expansion, binding: Binding(models: scope.borrowedScope()))
            guard case .success = result else { preconditionFailure("Canvas expansion failed") }
            expect(codec.pendingCount == 2 && codec.initializedCaptureCount == 2)
            if attempt == 0 {
                checks += try pendingIsolation(semantic: semantic, pending: codec, scope: scope,
                    key: key, dynamic: dynamic, expansion: expansion)
            }
            do throws(SemanticExpansionError) { try semantic.publishCandidate(); preconditionFailure("pending published") }
            catch { expect(error == .invariantViolation) }
            do throws(SemanticExpansionError) { try semantic.withCandidateView { _ in preconditionFailure("pending borrowed") } }
            catch { expect(error == .invariantViolation) }
            do throws(DrawingError) {
                try withValues(dynamic: dynamic, capacity: attempt == 1 ? 1 : 2) { (values) throws(DrawingError) in
                    do throws(DrawingError) { try CanvasSemanticTransfer.stage(from: semantic, pending: codec, into: values, table: table) }
                    catch {
                        expect(attempt == 1 && error == .capacityExhausted)
                        expect(values.count == 0 && values.releaseCount == 1)
                        expect(codec.pendingStorageIsClear)
                        return
                    }
                    expect(attempt != 1 && values.count == 2)
                    expect(codec.pendingStorageIsClear)
                    var sink = Sink()
                    do throws(SemanticExpansionError) {
                        try semantic.withCandidateView { (bank) throws(SemanticExpansionError) in
                            expect(bank.payloadCount == 3)
                            for index: UInt16 in 1..<3 {
                                guard case .canvas = bank.payload(at: index)! else { preconditionFailure("retained Canvas in semantic bank") }
                                checks += 1
                            }
                            let render = SemanticRecordRenderView(bank)
                            expect(render.semanticScopeCount == 3)
                            expect(render.scope(at: values.identity(at: 0)!) == .canvas)
                            expect(render.scope(at: values.identity(at: 1)!) == .canvas)
                            var workspace = BankLayoutWorkspace()
                            let result = layout(semantic: SemanticRecordLayoutView(bank), metrics: StaticTextMetricsView(), proposal: ProposedSize(width: 20, height: 10)!, limits: LayoutLimits(maximumScopes: 98, maximumDepth: 13, maximumTextScalars: 224, maximumTextLines: 98, maximumPositionedGlyphs: 224)!, workspace: &workspace, sink: &sink)
                            guard case .success = result else { preconditionFailure("Canvas layout failed") }
                            expect(sink.count == 3)
                            expect(sink.identities[1] == values.identity(at: 0) && sink.identities[2] == values.identity(at: 1))
                            // SPEC007 HStack proposes an absent main axis; SPEC012
                            // Canvas resolves that absent dimension to zero.
                            expect(sink.bounds[1]?.size == Size(width: 0, height: 10)!)
                            expect(sink.bounds[2]?.origin == Point(x: 0, y: 0))
                        }
                    } catch { preconditionFailure("consumer borrow failed") }
                    var source = ObservableCanvasInvocationSource(models: scope.borrowedScope(), values: values.borrowedValues(), table: table)
                    trace.pointee.readCount = 0
                    for index: UInt16 in 0..<2 {
                        var workspace = CanvasWorkspace(trace: trace)
                        let ordinal = index + 1
                        try workspace.withCanvasContext(identity: ordinal, surfaceOrigin: Point(x: Int32(ordinal * 10), y: 20), inheritedClip: CanvasLayout().rootBounds) { (context) throws(DrawingError) in
                            try source.invokeCanvas(at: values.identity(at: index)!, context: &context, size: sink.bounds[Int(index + 1)]!.size)
                        }
                        source.releaseCanvas(at: values.identity(at: index)!)
                    }
                    expect(trace.pointee.readCount == 2 && trace.pointee.reads[0] == 3 && trace.pointee.reads[1] == 3)
                    expect(values.releaseCount == 2)
                }
            } catch { preconditionFailure("unexpected transfer error") }
            if attempt == 1 {
                try semantic.withPublishedView { bank in expect(bank.rootReference == published) }
                do throws(SemanticExpansionError) { try semantic.withCandidateView { _ in preconditionFailure("failed transfer candidate retained") } }
                catch { expect(error == .invariantViolation) }
            } else {
                try semantic.publishCandidate()
                try semantic.withPublishedView { bank in
                    published = bank.rootReference
                    for index: UInt16 in 1..<3 {
                        guard case .canvas = bank.payload(at: index)! else { preconditionFailure("published Canvas value") }; checks += 1
                    }
                }
            }
        }
        // Both the successful transfers and the partial failure release every
        // typed pending capture before the same banks serve the next attempt.
        var pendingCleared = true
        for index in 0..<captures.count {
            if case .some = captures[index] { pendingCleared = false }
            if ordinals[index] != .max { pendingCleared = false }
        }
        expect(pendingCleared)
    }
    return checks
}
package func giftuiP06Semantic(scope: borrowing ObservableModelScope<CanvasModel, CounterModelSchema>, key: _GiftUIModelKey<CounterModelSchema>, trace: UnsafeMutablePointer<CanvasTrace>, dynamic: Bool) -> UInt32 {
    do throws(SemanticExpansionError) {
        var namespace = SemanticRecordOwnerNamespace()
        let limits = SemanticRecordLimits(records: 126, paths: 378, depth: 34, fanout: 5, payloads: 98, textScalars: 224, payloadBytes: UInt32(98 * MemoryLayout<Payload?>.stride + 224 * 4))!
        #if !hasFeature(Embedded)
        if dynamic {
            let storage = DynamicSemanticRecordStorage(limits: limits, owner: try namespace.issue())
            return try storage.withLifetime { (semantic) throws(SemanticExpansionError) in
                try exercise(semantic, scope: scope, key: key, trace: trace, dynamic: true)
            }
        }
        #endif
        var storage = StaticSemanticRecordStorage(limits: limits, owner: try namespace.issue())
        var backing = Backing()
        var records = backing.records.mutableSpan; var paths = backing.paths.mutableSpan
        var payloads = backing.payloads.mutableSpan; var scalars = backing.scalars.mutableSpan
        return try storage.withLifetime(records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (semantic) throws(SemanticExpansionError) in
            try exercise(semantic, scope: scope, key: key, trace: trace, dynamic: false)
        }
    } catch { preconditionFailure("semantic owner failed") }
}
