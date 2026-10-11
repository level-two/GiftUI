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

private typealias Payload = CanvasSemanticPayload<CanvasTable.CaptureStorage>
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
private func exercise(_ semantic: borrowing SemanticRecordStore<Payload>, scope: borrowing ObservableModelScope<CanvasModel, CounterModelSchema>, key: _GiftUIModelKey<CounterModelSchema>, trace: UnsafeMutablePointer<CanvasTrace>, dynamic: Bool) throws(SemanticExpansionError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ okay: Bool) { checks += 1; precondition(okay) }
    let expansion = SemanticExpansionLimits(maximumDepth: 34, maximumSemanticNodes: 48, maximumBodyEvaluations: 14, maximumModifierApplications: 50, maximumActionOccurrences: 6)!
    let table = CanvasTable()
    var published: SemanticRecordReference?
    // Success, partial transfer failure, then clean retry on the same two banks.
    for attempt in 0..<3 {
        let result = semantic.expand(CounterCanvasRoot<CanvasDomain>(model: key), roles: Roles.self, codec: CanvasSemanticPayloadCodec<Roles, CanvasTable>.self, limits: expansion, binding: Binding(models: scope.borrowedScope()))
        guard case .success = result else { preconditionFailure("Canvas expansion failed") }
        do throws(SemanticExpansionError) { try semantic.publishCandidate(); preconditionFailure("pending published") }
        catch { expect(error == .invariantViolation) }
        do throws(SemanticExpansionError) { try semantic.withCandidateView { _ in preconditionFailure("pending borrowed") } }
        catch { expect(error == .invariantViolation) }
        do throws(DrawingError) {
            try withValues(dynamic: dynamic, capacity: attempt == 1 ? 1 : 2) { (values) throws(DrawingError) in
                do throws(DrawingError) { try CanvasSemanticTransfer.stage(from: semantic, into: values, table: table) }
                catch {
                    expect(attempt == 1 && error == .capacityExhausted)
                    expect(values.count == 0 && values.releaseCount == 1)
                    return
                }
                expect(attempt != 1 && values.count == 2)
                var sink = Sink()
                do throws(SemanticExpansionError) {
                    try semantic.withCandidateView { (bank) throws(SemanticExpansionError) in
                        expect(bank.payloadCount == 3)
                        for index: UInt16 in 1..<3 {
                            guard case .canvas(.none) = bank.payload(at: index)! else { preconditionFailure("retained Canvas in semantic bank") }
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
                    guard case .canvas(.none) = bank.payload(at: index)! else { preconditionFailure("published Canvas value") }; checks += 1
                }
            }
        }
    }
    return checks
}
package func giftuiP06Semantic(scope: borrowing ObservableModelScope<CanvasModel, CounterModelSchema>, key: _GiftUIModelKey<CounterModelSchema>, trace: UnsafeMutablePointer<CanvasTrace>, dynamic: Bool) -> UInt32 {
    do throws(SemanticExpansionError) {
        var namespace = SemanticRecordOwnerNamespace()
        let limits = SemanticRecordLimits(records: 126, paths: 378, depth: 34, fanout: 5, payloads: 98, textScalars: 224, payloadBytes: UInt32(98 * MemoryLayout<Payload?>.stride + 224 * 4))!
        #if !hasFeature(Embedded)
        if dynamic {
            let storage = DynamicSemanticRecordStorage<Payload>(limits: limits, owner: try namespace.issue())
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
