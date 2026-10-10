import GiftUI
import GiftUILayout
import GiftUISemanticCore
import GiftUITextResources
import GiftUIRuntimeStatic
#if GIFTUI_DYNAMIC_PROFILE
import GiftUIRuntimeDynamic
#endif

private typealias D = _GiftUIEmptyReadDomain
private struct GeometryRoot: View {
    typealias Domain = D
    let width: Int32
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure) -> some View<D> {
        Spacer<D>(minLength: 0).frame(width: width, height: 4).padding(2)
    }
}
private struct FrameWitness: View {
    typealias Domain = D
    func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure) -> some View<D> {
        Spacer<D>(minLength: 0).frame(width: 0, height: 4)
    }
}
private enum Roles: SemanticDeclarationRoles {
    static func role<V>(of type: V.Type) -> SemanticRecordingRole? {
        let role: UInt16
        if V.self == GeometryRoot.self { role = 1 }
        else if V.self == GeometryRoot.Body.self { role = 2 }
        else if V.self == FrameWitness.Body.self { role = 3 }
        else if V.self == Spacer<D>.self { role = 4 }
        else { return nil }
        return .init(rawValue: role)
    }
    static func modifierDiscriminator<V>(of type: V.Type) -> UInt16 { 0 }
}
private struct EmptyBinding: SemanticStatefulBinding {
    typealias Domain = D
    typealias Identity = SemanticCompleteIdentity
    typealias Failure = UInt8
    borrowing func evaluate<V: View>(_ declaration: borrowing V, beforeBody: () -> SemanticExpansionError?, body: (borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure) -> V.Body) -> SemanticBodyEvaluation<V.Body, UInt8> where V.Domain == D, V.Body.Domain == D {
        if let error = beforeBody() { return .semanticFailure(error) }
        let empty: InlineArray<0, UInt8> = .init(repeating: 0)
        let read = _GiftUIFrameRead<D>(slots: empty.span)
        do throws(_GiftUIAccessFailure) { return .body(try body(read)) }
        catch { return .accessFailure(error) }
    }
    borrowing func evaluateStateful<V: View & _GiftUIObservableStateHost>(_ declaration: borrowing V, structuralIdentity: Identity, beforeBody: () -> SemanticExpansionError?, body: (borrowing V, borrowing _GiftUIFrameRead<D>) throws(_GiftUIAccessFailure) -> V.Body) -> SemanticBodyEvaluation<V.Body, UInt8> where V.Domain == D, V.Body.Domain == D { .bindingFailure(1) }
}
private struct Backing: ~Copyable {
    var records: InlineArray<252, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<756, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<196, SemanticStandardPayload?> = .init(repeating: nil)
    var scalars: InlineArray<448, UInt32> = .init(repeating: 0)
}
private struct Sink: LayoutResultSink, LayoutResultSinkState {
    var isLayoutActive = false
    var fault: UInt8 = 0
    var count = 0
    var beginCount = 0
    var discardCount = 0
    var publications = 0
    var bounds: InlineArray<98, Rect?> = .init(repeating: nil)
    var clips: InlineArray<98, Rect?> = .init(repeating: nil)
    mutating func begin(summary: LayoutSummary) -> Bool { beginCount += 1; if fault == 1 { return false }; isLayoutActive = true; count = 0; return true }
    mutating func stageScope(identity: SemanticRecordReference, bounds: Rect, clip: Rect) -> Bool { if fault == 2 { return false }; self.bounds[count] = bounds; clips[count] = clip; count += 1; return true }
    mutating func stageTextLine(identity: SemanticRecordReference, lineIndex: UInt16, bounds: Rect, baseline: Point, clip: Rect) -> Bool { false }
    mutating func stageGlyph(identity: SemanticRecordReference, lineIndex: UInt16, glyphIndex: UInt16, instance: FontInstanceID, glyph: GlyphID, baseline: Point, clip: Rect) -> Bool { false }
    mutating func publish() -> Bool { if fault == 3 { return false }; publications += 1; isLayoutActive = false; return true }
    mutating func discard() { discardCount += 1; isLayoutActive = false }
}
private let expansion = SemanticExpansionLimits(maximumDepth: 34, maximumSemanticNodes: 48, maximumBodyEvaluations: 14, maximumModifierApplications: 50, maximumActionOccurrences: 6)!
private func check(_ yes: Bool, _ count: inout UInt32) { count += 1; precondition(yes) }
private func exercise(_ store: borrowing SemanticRecordStore<SemanticStandardPayload>) throws(SemanticExpansionError) -> UInt32 {
    var checks: UInt32 = 0
    var workspace = BankLayoutWorkspace()
    var sink = Sink()
    let limits = LayoutLimits(maximumScopes: 98, maximumDepth: 13, maximumTextScalars: 224, maximumTextLines: 98, maximumPositionedGlyphs: 224)!
    var previous: SemanticRecordReference?
    for iteration in 0..<8 {
        let width: Int32 = iteration == 7 ? -1 : 100
        let result = store.expand(GeometryRoot(width: width), roles: Roles.self, codec: SemanticStandardPayloadCodec<Roles>.self, limits: expansion, binding: EmptyBinding())
        guard case .success = result else { preconditionFailure() }
        try store.withCandidateView { (bank) throws(SemanticExpansionError) in
            let view = SemanticRecordLayoutView(bank)
            check(view.scopeCount == 3, &checks)
            check(bank.recordCount == 4, &checks)
            check(view.primitive(at: view.rootIdentity) == nil, &checks)
            check(view.childCount(of: view.rootIdentity) == 1, &checks)
            if let previous { check(view.childCount(of: previous) == nil, &checks) }
            previous = view.rootIdentity
            let render = SemanticRecordRenderView(bank)
            check(render.semanticScopeCount == 3, &checks)
            check(render.childCount(of: render.rootIdentity) == 1, &checks)
            check(render.scope(at: render.child(of: render.rootIdentity, at: 0)!) == .clipBoundary, &checks)
            for ordinal: UInt16 in 0..<3 {
                let identity = render.semanticIdentity(at: ordinal)!
                check(render.semanticOrdinal(of: identity) == ordinal, &checks)
                check(render.layoutIdentity(for: identity) == identity, &checks)
            }
            check(render.semanticIdentity(at: 3) == nil, &checks)
            let before = sink.publications
            sink.fault = iteration < 4 ? UInt8(iteration) : 0
            var attemptLimits = limits
            if iteration == 4 { attemptLimits = LayoutLimits(maximumScopes: 2, maximumDepth: 13, maximumTextScalars: 224, maximumTextLines: 98, maximumPositionedGlyphs: 224)! }
            if iteration == 5 { attemptLimits = LayoutLimits(maximumScopes: 98, maximumDepth: 2, maximumTextScalars: 224, maximumTextLines: 98, maximumPositionedGlyphs: 224)! }
            let layoutResult = layout(semantic: view, metrics: StaticTextMetricsView(), proposal: ProposedSize(width: 50, height: 20)!, limits: attemptLimits, workspace: &workspace, sink: &sink)
            check(!workspace.isLayoutActive && !sink.isLayoutActive, &checks)
            if iteration == 0 || iteration == 6 {
                guard case .success(let summary) = layoutResult else { preconditionFailure() }
                check(summary.scopeCount == 3 && summary.maximumObservedDepth == 3, &checks)
                check(summary.rootBounds.size == Size(width: 50, height: 8)!, &checks)
                // Independent SPEC007 frame/padding oracle: parent 50, padding
                // 2 proposes46, fixed100 caps46; spacer remains zero-sized.
                check(sink.bounds[0] == Rect(origin: .init(x: 0, y: 0), size: .init(width: 50, height: 8)!)!, &checks)
                check(sink.bounds[1] == Rect(origin: .init(x: 2, y: 2), size: .init(width: 46, height: 4)!)!, &checks)
                check(sink.bounds[2]?.origin == Point(x: 25, y: 4), &checks)
                check(sink.publications == before + 1, &checks)
            } else {
                let expected: LayoutError = iteration == 1 || iteration == 4 || iteration == 5 ? .capacityExhausted : (iteration == 7 ? .invalidDeclaration : .invariantViolation)
                check(layoutResult == .failure(expected), &checks)
                check(sink.publications == before, &checks)
            }
        }
        // Every consumer borrow ended; repeatedly publish/reuse both banks.
        if iteration == 0 || iteration == 6 { try store.publishCandidate() }
        else { try store.discardCandidate() }
    }
    check(sink.discardCount == 2, &checks)
    return checks
}
@_cdecl("giftui_p05_layout") public func giftuiP05Layout() -> UInt32 {
    do throws(SemanticExpansionError) {
        var namespace = SemanticRecordOwnerNamespace()
        let limits = SemanticRecordLimits(records: 126, paths: 378, depth: 34, fanout: 5, payloads: 98, textScalars: 224, payloadBytes: UInt32(98 * MemoryLayout<SemanticStandardPayload?>.stride + 224 * 4))!
        #if GIFTUI_DYNAMIC_PROFILE
        let storage = DynamicSemanticRecordStorage<SemanticStandardPayload>(limits: limits, owner: try namespace.issue())
        return try storage.withLifetime { (store) throws(SemanticExpansionError) in try exercise(store) }
        #else
        var storage = StaticSemanticRecordStorage(limits: limits, owner: try namespace.issue())
        var backing = Backing()
        var records = backing.records.mutableSpan; var paths = backing.paths.mutableSpan
        var payloads = backing.payloads.mutableSpan; var scalars = backing.scalars.mutableSpan
        return try storage.withLifetime(records: &records, paths: &paths, payloads: &payloads, scalars: &scalars) { (store) throws(SemanticExpansionError) in try exercise(store) }
        #endif
    } catch { preconditionFailure() }
}
