import GiftUI
import GiftUILayout
import GiftUITextResources
import GiftUIRuntimeStatic
@testable import GiftUISemanticCore

// Hand-seeded canonical records isolate the new borrowed adapter. Expected
// rectangles come from SPEC007 and retained Stack/Text baseline fixture rules,
// never from the production Layout output or another call to that engine.
private struct Node {
    let payload: SemanticStandardPayload
    let parent: UInt16
    var kind: SemanticRuntimeRecord.Kind = .primitive
    var text: [UInt32] = []
}
private struct OracleSink: LayoutResultSink, LayoutResultSinkState {
    var isLayoutActive = false
    var scopes: [Rect] = []
    var clips: [Rect] = []
    var lines: [Rect] = []
    var glyphs: [Point] = []
    mutating func begin(summary: LayoutSummary) -> Bool { isLayoutActive = true; return true }
    mutating func stageScope(identity: SemanticRecordReference, bounds: Rect, clip: Rect) -> Bool { scopes.append(bounds); clips.append(clip); return true }
    mutating func stageTextLine(identity: SemanticRecordReference, lineIndex: UInt16, bounds: Rect, baseline: Point, clip: Rect) -> Bool { lines.append(bounds); return true }
    mutating func stageGlyph(identity: SemanticRecordReference, lineIndex: UInt16, glyphIndex: UInt16, instance: FontInstanceID, glyph: GlyphID, baseline: Point, clip: Rect) -> Bool { glyphs.append(baseline); return true }
    mutating func publish() -> Bool { isLayoutActive = false; return true }
    mutating func discard() { isLayoutActive = false }
}
private struct Backing: ~Copyable {
    var metadata: InlineArray<2, SemanticRecordBankMetadata> = .init(repeating: .init())
    var records: InlineArray<252, SemanticRuntimeRecord> = .init(repeating: .init())
    var paths: InlineArray<756, SemanticPathEntry> = .init(repeating: .init())
    var payloads: InlineArray<196, SemanticStandardPayload?> = .init(repeating: nil)
    var scalars: InlineArray<448, UInt32> = .init(repeating: 0)
    mutating func run(owner: SemanticRecordOwnerIdentity) throws(SemanticExpansionError) -> UInt32 {
        var m = metadata.mutableSpan; var r = records.mutableSpan; var p = paths.mutableSpan; var v = payloads.mutableSpan; var s = scalars.mutableSpan
        return try withSemanticRecordStore(metadata: &m, records: &r, paths: &p, payloads: &v, scalars: &s, limits: .init(records: 126, paths: 378, depth: 34, fanout: 5, payloads: 98, textScalars: 224, payloadBytes: 65536)!, owner: owner) { (store) throws(SemanticExpansionError) in try exercise(store) }
    }
}
private func rectangle(_ x: Int32, _ y: Int32, _ w: Int32, _ h: Int32) -> Rect { Rect(origin: .init(x: x, y: y), size: .init(width: w, height: h)!)! }
private func seed(_ nodes: [Node], _ store: borrowing SemanticRecordStore<SemanticStandardPayload>, corrupt: Bool = false) throws(SemanticExpansionError) {
    let bank = store.expansionBank(try store.beginCandidate())!
    var scalarCount = 0
    for (index, node) in nodes.enumerated() {
        var record = SemanticRuntimeRecord(); record.parent = node.parent; record.kind = node.kind; record.payload = UInt16(index)
        record.firstTextScalar = UInt16(scalarCount); record.textScalarCount = UInt16(node.text.count)
        for scalar in node.text { bank.scalars[scalarCount] = scalar; scalarCount += 1 }
        bank.records[index] = record; bank.payloads[index] = node.payload
        if node.parent != .max {
            let parent = Int(node.parent)
            let previous = bank.records[parent].lastChild
            if previous == .max { bank.records[parent].firstChild = UInt16(index) }
            else { bank.records[Int(previous)].nextSibling = UInt16(index) }
            bank.records[parent].lastChild = UInt16(index)
        }
    }
    if corrupt { bank.records[0].firstChild = 125 }
    bank.metadata.pointee.records = UInt16(nodes.count); bank.metadata.pointee.payloads = UInt16(nodes.count)
    bank.metadata.pointee.scalars = UInt16(scalarCount); bank.metadata.pointee.phase = .candidate
}
private func exercise(_ store: borrowing SemanticRecordStore<SemanticStandardPayload>) throws(SemanticExpansionError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ yes: Bool) { checks += 1; precondition(yes) }
    let normal = LayoutLimits(maximumScopes: 98, maximumDepth: 13, maximumTextScalars: 224, maximumTextLines: 98, maximumPositionedGlyphs: 224)!
    // Equal share and early remainder; absent/too-small proposal keeps minima;
    // horizontal cap does not compress children; ZStack overlays; empty stack.
    for scenario in 0..<6 {
        let payload: SemanticStandardPayload = scenario == 2 ? .hStack(.init(alignment: .bottom, spacing: 2)) : scenario == 3 ? .zStack(.init(alignment: .center)) : .vStack(.init(alignment: .leading, spacing: scenario == 1 ? 1 : 0))
        var nodes = [Node(payload: payload, parent: .max)]
        let count = scenario == 5 ? 0 : scenario == 1 ? 2 : 3
        for index in 0..<count { nodes.append(Node(payload: .spacer(.init(minLength: scenario == 1 ? Int32(index + 4) : 0)), parent: 0)) }
        try seed(nodes, store)
        try store.withCandidateView { view in
            var workspace = BankLayoutWorkspace(); var sink = OracleSink()
            let proposal = scenario == 4 ? ProposedSize()! : ProposedSize(width: scenario == 2 ? 1 : 7, height: scenario == 1 ? 3 : 8)!
            let result = layout(semantic: SemanticRecordLayoutView(view), metrics: StaticTextMetricsView(), proposal: proposal, limits: normal, workspace: &workspace, sink: &sink)
            guard case .success = result else { preconditionFailure() }
            let expected: [Rect]
            switch scenario {
            case 0: expected = [rectangle(0,0,0,8), rectangle(0,0,0,3), rectangle(0,3,0,3), rectangle(0,6,0,2)]
            case 1: expected = [rectangle(0,0,0,3), rectangle(0,0,0,4), rectangle(0,5,0,5)]
            case 2: expected = [rectangle(0,0,1,0), rectangle(0,0,0,0), rectangle(2,0,0,0), rectangle(4,0,0,0)]
            case 3: expected = Array(repeating: rectangle(0,0,0,0), count: 4)
            case 4: expected = Array(repeating: rectangle(0,0,0,0), count: 4)
            default: expected = [rectangle(0,0,0,0)]
            }
            expect(sink.scopes == expected); expect(!workspace.isLayoutActive && !sink.isLayoutActive)
        }
        try store.discardCandidate()
    }
    for scenario in 0..<3 {
        let scalars: [UInt32] = scenario == 0 ? [65,66,67] : scenario == 1 ? [13,10,65,10,13,66] : []
        try seed([Node(payload: .text, parent: .max, text: scalars)], store)
        try store.withCandidateView { view in
            var workspace = BankLayoutWorkspace(); var sink = OracleSink()
            let result = layout(semantic: SemanticRecordLayoutView(view), metrics: StaticTextMetricsView(), proposal: scenario == 0 ? ProposedSize(width: 8)! : ProposedSize()!, limits: normal, workspace: &workspace, sink: &sink)
            guard case .success(let summary) = result else { preconditionFailure() }
            expect(summary.textScalarCount == scalars.count)
            if scenario == 0 { expect(sink.lines == [rectangle(0,0,8,10), rectangle(0,12,4,10)]); expect(sink.glyphs == [.init(x:0,y:7),.init(x:4,y:7),.init(x:0,y:19)]) }
            else if scenario == 1 { expect(sink.lines.map { $0.size.width } == [0,4,0,4]); expect(sink.glyphs == [.init(x:0,y:19), .init(x:0,y:43)]) }
            else { expect(sink.lines == [rectangle(0,0,0,10)]); expect(sink.glyphs.isEmpty) }
        }
        try store.discardCandidate()
    }
    let modifiers: [SemanticStandardPayload] = [
        .padding(.init(edges: .all, length: 2)),
        .insets(.init(insets: .init(top: 1, leading: 2, bottom: 3, trailing: 4)!)),
        .fixedFrame(.init(width: 8, height: 6, alignment: .init(horizontal: .center, vertical: .bottom))),
        .flexibleFrame(.init(minWidth: 8, maxWidth: nil, minHeight: 6, maxHeight: nil, alignment: .center)),
        .disabled(true)
    ]
    let expectedModifiers: [[Rect]] = [
        [rectangle(0,0,4,4), rectangle(2,2,0,0)],
        [rectangle(0,0,6,4), rectangle(2,1,0,0)],
        [rectangle(0,0,8,6), rectangle(4,6,0,0)],
        [rectangle(0,0,8,6), rectangle(4,3,0,0)],
        [rectangle(0,0,0,0), rectangle(0,0,0,0)]
    ]
    for (index, modifier) in modifiers.enumerated() {
        try seed([Node(payload: modifier, parent: .max, kind: .modifier), Node(payload: .spacer(.init(minLength: 0)), parent: 0)], store)
        try store.withCandidateView { view in
            var workspace = BankLayoutWorkspace(); var sink = OracleSink()
            let result = layout(semantic: SemanticRecordLayoutView(view), metrics: StaticTextMetricsView(), proposal: ProposedSize()!, limits: normal, workspace: &workspace, sink: &sink)
            guard case .success = result else { preconditionFailure() }
            expect(sink.scopes == expectedModifiers[index])
        }
        try store.discardCandidate()
    }
    // Exact existing depth13 and scope98 ceilings, then one less configured slot.
    for dimension in 0..<2 {
        let count = dimension == 0 ? 13 : 98
        var nodes: [Node] = []
        for index in 0..<count {
            let parent: UInt16 = index == 0 ? .max : dimension == 0 ? UInt16(index - 1) : UInt16((index - 1) / 5)
            let payload: SemanticStandardPayload = dimension == 0 && index < count - 1 ? .disabled(false) : .vStack(.init(alignment: .leading, spacing: 0))
            nodes.append(Node(payload: payload, parent: parent, kind: dimension == 0 && index < count - 1 ? .modifier : .primitive))
        }
        try seed(nodes, store)
        try store.withCandidateView { view in
            for excess in [false,true] {
                var workspace = BankLayoutWorkspace(); var sink = OracleSink()
                let limits = LayoutLimits(maximumScopes: dimension == 1 && excess ? 97 : 98, maximumDepth: dimension == 0 && excess ? 12 : 13, maximumTextScalars: 224, maximumTextLines: 98, maximumPositionedGlyphs: 224)!
                let result = layout(semantic: SemanticRecordLayoutView(view), metrics: StaticTextMetricsView(), proposal: ProposedSize()!, limits: limits, workspace: &workspace, sink: &sink)
                if excess { expect(result == .failure(.capacityExhausted)); expect(sink.scopes.isEmpty) }
                else { guard case .success(let summary) = result else { preconditionFailure() }; expect(summary.scopeCount == count); expect(sink.scopes.count == count) }
                expect(!workspace.isLayoutActive && !sink.isLayoutActive)
            }
        }
        try store.discardCandidate()
    }
    // Malformed canonical link lookup fails before publishing, releases Layout
    // workspace and scoped bank reader; discard proves no retained consumer.
    try seed([Node(payload: .vStack(.init(alignment: .leading, spacing: 0)), parent: .max)], store, corrupt: true)
    try store.withCandidateView { view in
        var workspace = BankLayoutWorkspace(); var sink = OracleSink()
        let result = layout(semantic: SemanticRecordLayoutView(view), metrics: StaticTextMetricsView(), proposal: ProposedSize()!, limits: normal, workspace: &workspace, sink: &sink)
        expect(result == .failure(.invariantViolation)); expect(sink.scopes.isEmpty); expect(!workspace.isLayoutActive && !sink.isLayoutActive)
        // Wrong revision/ordinal references are rejected by every projection.
        let adapter = SemanticRecordLayoutView(view)
        let wrong = SemanticRecordReference(owner: view.rootReference.owner, bank: view.rootReference.bank, revision: view.rootReference.revision, ordinal: 125)
        expect(adapter.childCount(of: wrong) == nil); expect(adapter.modifierCount(of: wrong) == nil); expect(adapter.textScalar(of: wrong, at: 0) == nil)
    }
    try store.discardCandidate()
    return checks
}
@_cdecl("giftui_p05_layout_oracle") public func giftuiP05LayoutOracle() -> UInt32 {
    do throws(SemanticExpansionError) { var namespace = SemanticRecordOwnerNamespace(); var backing = Backing(); return try backing.run(owner: namespace.issue()) }
    catch { preconditionFailure() }
}
