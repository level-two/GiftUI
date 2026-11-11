import GiftUI
import GiftUILayout
import GiftUITextResources

@testable import GiftUISemanticCore

private struct FixtureNode {
    let identity: UInt16
    let primitive: SemanticLayoutPrimitive
    let children: [UInt16]
    let modifiers: [SemanticLayoutModifier]
    let scalars: [UInt32]

    init(
        _ identity: UInt16,
        _ primitive: SemanticLayoutPrimitive,
        children: [UInt16] = [],
        modifiers: [SemanticLayoutModifier] = [],
        scalars: [UInt32] = []
    ) {
        self.identity = identity
        self.primitive = primitive
        self.children = children
        self.modifiers = modifiers
        self.scalars = scalars
    }
}

private struct FixtureView: SemanticLayoutView {
    let nodes: [UInt16: FixtureNode]
    let rootIdentity: UInt16
    var scopeCount: UInt16 {
        UInt16(nodes.values.reduce(0) { $0 + 1 + $1.modifiers.count })
    }

    func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        nodes[identity]?.primitive
    }
    func childCount(of identity: UInt16) -> UInt16? {
        nodes[identity].map { UInt16($0.children.count) }
    }
    func child(of identity: UInt16, at index: UInt16) -> UInt16? {
        guard let children = nodes[identity]?.children, Int(index) < children.count else {
            return nil
        }
        return children[Int(index)]
    }
    func modifierCount(of identity: UInt16) -> UInt16? {
        nodes[identity].map { UInt16($0.modifiers.count) }
    }
    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        guard let modifiers = nodes[identity]?.modifiers, Int(index) < modifiers.count else {
            return nil
        }
        return identity &+ 100 &+ index
    }
    func modifier(of identity: UInt16, at index: UInt16) -> SemanticLayoutModifier? {
        guard let modifiers = nodes[identity]?.modifiers, Int(index) < modifiers.count else {
            return nil
        }
        return modifiers[Int(index)]
    }
    func textScalarCount(of identity: UInt16) -> UInt16? {
        guard nodes[identity]?.primitive == .text else { return nil }
        return UInt16(nodes[identity]?.scalars.count ?? 0)
    }
    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        guard let node = nodes[identity], node.primitive == .text, Int(index) < node.scalars.count
        else { return nil }
        return node.scalars[Int(index)]
    }
}

private struct FixtureMetrics: CanonicalTextMetricsView {
    private let reference: Bool
    private let overflow: UInt8
    private let resource = FontResourceID(
        rawValue: TextResourceDigest(
            word0: 1, word1: 2, word2: 3, word3: 4,
            word4: 5, word5: 6, word6: 7, word7: 8))
    init(reference: Bool = false, overflow: UInt8 = 0) {
        self.reference = reference
        self.overflow = overflow
    }
    var descriptor: TextResourceDescriptor {
        TextResourceDescriptor(
            schemaVersion: 1, resource: resource, instanceCount: 1,
            realizationCount: 1, canonicalManifestByteCount: 1)
    }
    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        guard index == 0 else { return nil }
        return FontInstanceDescriptor(
            id: FontInstanceID(resource: resource, instanceIndex: 0),
            lineMetrics: overflow == 1
                ? FontLineMetrics(ascent: .max, descent: 1, lineGap: 0)
                : reference
                    ? FontLineMetrics(ascent: 16, descent: 4, lineGap: 0)
                    : FontLineMetrics(ascent: 7, descent: 3, lineGap: 2),
            replacementGlyph: GlyphID(rawValue: reference ? 0 : 9),
            glyphCount: reference ? 97 : 10, mappingCount: reference ? 2 : 3)
    }
    func mapping(at index: UInt16, in instance: FontInstanceID) -> ScalarGlyphMappingRecord? { nil }
    func mapScalar(_ scalarValue: UInt32, in instance: FontInstanceID) -> GlyphMapping? {
        guard instance == FontInstanceID(resource: resource, instanceIndex: 0) else { return nil }
        if reference {
            return switch scalarValue {
            case 0x41: .exact(GlyphID(rawValue: 1))
            case 0x00b0: .exact(GlyphID(rawValue: 96))
            default: .replacement(GlyphID(rawValue: 0))
            }
        }
        return switch scalarValue {
        case 0x41: .exact(GlyphID(rawValue: 1))
        case 0x42: .exact(GlyphID(rawValue: 2))
        case 0x00b0: .exact(GlyphID(rawValue: 3))
        default: .replacement(GlyphID(rawValue: 9))
        }
    }
    func metrics(for glyph: GlyphID, in instance: FontInstanceID) -> GlyphMetrics? {
        let advance: Int32
        if overflow == 2 {
            advance = .max
        } else if reference {
            switch glyph.rawValue {
            case 1: advance = 11
            case 96, 0: advance = 7
            default: return nil
            }
        } else {
            switch glyph.rawValue {
            case 1: advance = 4
            case 2: advance = 5
            case 3: advance = 3
            case 9: advance = 6
            default: return nil
            }
        }
        return GlyphMetrics(
            advanceX: advance, offsetX: 0, offsetY: 0,
            inkSize: Size(width: overflow == 2 ? 0 : advance, height: 10)!)
    }
}

struct ScopeFact<ID: Equatable>: Equatable {
    let identity: ID
    let bounds: Rect
    let clip: Rect
}
struct LineFact<ID: Equatable>: Equatable {
    let identity: ID
    let index: UInt16
    let bounds: Rect
    let baseline: Point
    let clip: Rect
}
struct GlyphFact<ID: Equatable>: Equatable {
    let identity: ID
    let line: UInt16
    let index: UInt16
    let instance: FontInstanceID
    let glyph: GlyphID
    let baseline: Point
    let clip: Rect
}
enum TraceEvent<ID: Equatable>: Equatable {
    case begin
    case scope(ID)
    case line(ID, UInt16)
    case glyph(ID, UInt16, UInt16, UInt16)
    case publish
    case discard
}
struct FixtureSink<ID: Equatable & Sendable>: LayoutResultSink, LayoutResultSinkState {
    var isLayoutActive = false
    var summary: LayoutSummary?
    var events: [TraceEvent<ID>] = []
    var scopes: [ScopeFact<ID>] = []
    var lines: [LineFact<ID>] = []
    var glyphs: [GlyphFact<ID>] = []
    mutating func begin(summary: LayoutSummary) -> Bool {
        self.summary = summary
        isLayoutActive = true
        events.append(.begin)
        return true
    }
    mutating func stageScope(identity: ID, bounds: Rect, clip: Rect) -> Bool {
        scopes.append(.init(identity: identity, bounds: bounds, clip: clip))
        events.append(.scope(identity))
        return true
    }
    mutating func stageTextLine(
        identity: ID, lineIndex: UInt16, bounds: Rect,
        baseline: Point, clip: Rect
    ) -> Bool {
        lines.append(
            .init(
                identity: identity, index: lineIndex, bounds: bounds,
                baseline: baseline, clip: clip))
        events.append(.line(identity, lineIndex))
        return true
    }
    mutating func stageGlyph(
        identity: ID, lineIndex: UInt16, glyphIndex: UInt16,
        instance: FontInstanceID, glyph: GlyphID,
        baseline: Point, clip: Rect
    ) -> Bool {
        glyphs.append(
            .init(
                identity: identity, line: lineIndex, index: glyphIndex,
                instance: instance, glyph: glyph, baseline: baseline, clip: clip))
        events.append(.glyph(identity, lineIndex, glyphIndex, glyph.rawValue))
        return true
    }
    mutating func publish() -> Bool {
        events.append(.publish)
        isLayoutActive = false
        return true
    }
    mutating func discard() {
        events.append(.discard)
        isLayoutActive = false
    }
}

private struct FixtureWorkspace<ID: Equatable & Sendable>: LayoutWorkspace {
    let maximumScopes: UInt16 = 512
    let maximumDepth: UInt16 = 64
    let maximumTextScalars: UInt16 = 4096
    let maximumTextLines: UInt16 = 512
    let maximumPositionedGlyphs: UInt16 = 4096
    var isLayoutActive = false
    private var scopes: [(ID, LayoutMeasurement, LayoutPlacement?)] = []
    private var lines: [LayoutTextLine<ID>] = []
    private var glyphs: [LayoutPositionedGlyph<ID>] = []
    private var depth: [ID] = []
    mutating func acquireLayout() -> Bool {
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        scopes.removeAll()
        lines.removeAll()
        glyphs.removeAll()
        depth.removeAll()
        return true
    }
    mutating func appendScope(identity: borrowing ID, measurement: LayoutMeasurement) -> Bool {
        let target = copy identity
        guard isLayoutActive, scopes.count < Int(maximumScopes),
            !scopes.contains(where: { $0.0 == target })
        else { return false }
        scopes.append((copy identity, measurement, nil))
        return true
    }
    var scopeCount: UInt16 { UInt16(scopes.count) }
    func scopeIdentity(at index: UInt16) -> ID? {
        Int(index) < scopes.count ? scopes[Int(index)].0 : nil
    }
    func measurement(for identity: borrowing ID) -> LayoutMeasurement? {
        let target = copy identity
        return scopes.first { $0.0 == target }?.1
    }
    mutating func storeMeasurement(_ measurement: LayoutMeasurement, for identity: borrowing ID)
        -> Bool
    {
        let target = copy identity
        guard let i = scopes.firstIndex(where: { $0.0 == target }) else { return false }
        scopes[i].1 = measurement
        return true
    }
    mutating func storePlacement(_ placement: LayoutPlacement, for identity: borrowing ID) -> Bool {
        let target = copy identity
        guard let i = scopes.firstIndex(where: { $0.0 == target }), scopes[i].2 == nil else {
            return false
        }
        scopes[i].2 = placement
        return true
    }
    func placement(for identity: borrowing ID) -> LayoutPlacement? {
        let target = copy identity
        return scopes.first { $0.0 == target }?.2
    }
    var textLineCount: UInt16 { UInt16(lines.count) }
    mutating func appendTextLine(_ line: LayoutTextLine<ID>) -> Bool {
        guard lines.count < Int(maximumTextLines) else { return false }
        lines.append(line)
        return true
    }
    func textLine(at index: UInt16) -> LayoutTextLine<ID>? {
        Int(index) < lines.count ? lines[Int(index)] : nil
    }
    mutating func storeTextLine(_ line: LayoutTextLine<ID>, at index: UInt16) -> Bool {
        guard Int(index) < lines.count else { return false }
        lines[Int(index)] = line
        return true
    }
    var positionedGlyphCount: UInt16 { UInt16(glyphs.count) }
    mutating func appendPositionedGlyph(_ glyph: LayoutPositionedGlyph<ID>) -> Bool {
        guard glyphs.count < Int(maximumPositionedGlyphs) else { return false }
        glyphs.append(glyph)
        return true
    }
    func positionedGlyph(at index: UInt16) -> LayoutPositionedGlyph<ID>? {
        Int(index) < glyphs.count ? glyphs[Int(index)] : nil
    }
    mutating func storePositionedGlyph(_ glyph: LayoutPositionedGlyph<ID>, at index: UInt16) -> Bool
    {
        guard Int(index) < glyphs.count else { return false }
        glyphs[Int(index)] = glyph
        return true
    }
    mutating func pushScope(_ identity: borrowing ID) -> Bool {
        guard depth.count < Int(maximumDepth) else { return false }
        depth.append(copy identity)
        return true
    }
    mutating func popScope() { if !depth.isEmpty { depth.removeLast() } }
    mutating func resetLayout() {
        scopes.removeAll()
        lines.removeAll()
        glyphs.removeAll()
        depth.removeAll()
        isLayoutActive = false
    }
}

private struct CanonicalTrace: Equatable {
    let result: LayoutResult
    let summary: LayoutSummary?
    let events: [TraceEvent<UInt16>]
    let scopes: [ScopeFact<UInt16>]
    let lines: [LineFact<UInt16>]
    let glyphs: [GlyphFact<UInt16>]
}

private struct ExpandedNode {
    let payload: SemanticStandardPayload
    let parent: UInt16
    let kind: SemanticRuntimeRecord.Kind
    let scalars: [UInt32]
}

private func primitivePayload(_ primitive: SemanticLayoutPrimitive) -> (
    SemanticStandardPayload, SemanticRuntimeRecord.Kind
) {
    switch primitive {
    case .proxy: (.action(role: 1, code: 0), .action)
    case .vStack(let alignment, let spacing):
        (.vStack(.init(alignment: alignment, spacing: spacing)), .primitive)
    case .hStack(let alignment, let spacing):
        (.hStack(.init(alignment: alignment, spacing: spacing)), .primitive)
    case .zStack(let alignment): (.zStack(.init(alignment: alignment)), .primitive)
    case .spacer(let minLength): (.spacer(.init(minLength: minLength)), .primitive)
    case .text: (.text, .primitive)
    case .canvas: preconditionFailure("Canvas is outside T4/T5 baseline corpus")
    }
}

private func modifierPayload(_ modifier: SemanticLayoutModifier) -> SemanticStandardPayload {
    switch modifier {
    case .passthrough: .disabled(false)
    case .padding(let edges, let length): .padding(.init(edges: edges, length: length))
    case .paddingInsets(let insets): .insets(.init(insets: insets))
    case .fixedFrame(let width, let height, let alignment):
        .fixedFrame(.init(width: width, height: height, alignment: alignment))
    case .flexibleFrame(let minWidth, let maxWidth, let minHeight, let maxHeight, let alignment):
        .flexibleFrame(
            .init(
                minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight,
                alignment: alignment))
    }
}

private func appendExpanded(
    _ identity: UInt16, parent: UInt16, view: FixtureView,
    expanded: inout [ExpandedNode], identities: inout [UInt16: UInt16]
) {
    let node = view.nodes[identity]!
    var wrappedParent = parent
    for modifierIndex in node.modifiers.indices.reversed() {
        let ordinal = UInt16(expanded.count)
        let scope = identity &+ 100 &+ UInt16(modifierIndex)
        identities[scope] = ordinal
        expanded.append(
            .init(
                payload: modifierPayload(node.modifiers[modifierIndex]), parent: wrappedParent,
                kind: .modifier, scalars: []))
        wrappedParent = ordinal
    }
    let (payload, kind) = primitivePayload(node.primitive)
    let primitiveOrdinal = UInt16(expanded.count)
    identities[identity] = primitiveOrdinal
    expanded.append(
        .init(payload: payload, parent: wrappedParent, kind: kind, scalars: node.scalars))
    for child in node.children {
        appendExpanded(
            child, parent: primitiveOrdinal, view: view, expanded: &expanded,
            identities: &identities)
    }
}

private func seedFixture(_ view: FixtureView, _ store: borrowing SemanticRecordStore)
    throws(SemanticExpansionError) -> [UInt16: UInt16]
{
    var expanded: [ExpandedNode] = []
    var identities: [UInt16: UInt16] = [:]
    appendExpanded(
        view.rootIdentity, parent: .max, view: view, expanded: &expanded, identities: &identities)
    let bank = store.expansionBank(try store.beginCandidate())!
    var scalarCursor = 0
    for (ordinal, node) in expanded.enumerated() {
        var record = SemanticRuntimeRecord()
        record.parent = node.parent
        record.kind = node.kind
        record.payload = UInt16(ordinal)
        record.firstTextScalar = UInt16(scalarCursor)
        record.textScalarCount = UInt16(node.scalars.count)
        for scalar in node.scalars {
            bank.scalars[scalarCursor] = scalar
            scalarCursor += 1
        }
        bank.records[ordinal] = record
        bank.payloads[ordinal] = .standard(node.payload)
        if node.parent != .max {
            let parent = Int(node.parent)
            let previous = bank.records[parent].lastChild
            if previous == .max {
                bank.records[parent].firstChild = UInt16(ordinal)
            } else {
                bank.records[Int(previous)].nextSibling = UInt16(ordinal)
            }
            bank.records[parent].lastChild = UInt16(ordinal)
        }
    }
    bank.metadata.pointee.records = UInt16(expanded.count)
    bank.metadata.pointee.payloads = UInt16(expanded.count)
    bank.metadata.pointee.scalars = UInt16(scalarCursor)
    bank.metadata.pointee.phase = .candidate
    return identities
}

private func normalize<ID: Equatable & Sendable>(
    _ sink: FixtureSink<ID>, map: (ID) -> UInt16
) -> (
    summary: LayoutSummary?, events: [TraceEvent<UInt16>], scopes: [ScopeFact<UInt16>],
    lines: [LineFact<UInt16>], glyphs: [GlyphFact<UInt16>]
) {
    let events = sink.events.map { event -> TraceEvent<UInt16> in
        switch event {
        case .begin: .begin
        case .scope(let identity): .scope(map(identity))
        case .line(let identity, let index): .line(map(identity), index)
        case .glyph(let identity, let line, let index, let glyph):
            .glyph(map(identity), line, index, glyph)
        case .publish: .publish
        case .discard: .discard
        }
    }
    return (
        sink.summary, events,
        sink.scopes.map { .init(identity: map($0.identity), bounds: $0.bounds, clip: $0.clip) },
        sink.lines.map {
            .init(
                identity: map($0.identity), index: $0.index, bounds: $0.bounds,
                baseline: $0.baseline, clip: $0.clip)
        },
        sink.glyphs.map {
            .init(
                identity: map($0.identity), line: $0.line, index: $0.index, instance: $0.instance,
                glyph: $0.glyph, baseline: $0.baseline, clip: $0.clip)
        }
    )
}

private func runBaseline<M: CanonicalTextMetricsView>(
    _ fixture: FixtureView, identities: [UInt16: UInt16], proposal: ProposedSize,
    limits: LayoutLimits, metrics: M
) -> CanonicalTrace {
    var workspace = FixtureWorkspace<UInt16>()
    var sink = FixtureSink<UInt16>()
    let result = layout(
        semantic: fixture, metrics: metrics, proposal: proposal, limits: limits,
        workspace: &workspace, sink: &sink)
    let normalized = normalize(sink) { identities[$0]! }
    return .init(
        result: result, summary: normalized.summary, events: normalized.events,
        scopes: normalized.scopes, lines: normalized.lines, glyphs: normalized.glyphs)
}

private func runBank<M: CanonicalTextMetricsView>(
    _ fixture: FixtureView, store: borrowing SemanticRecordStore,
    proposal: ProposedSize, limits: LayoutLimits, metrics: M
) throws(SemanticExpansionError) -> (trace: CanonicalTrace, identities: [UInt16: UInt16]) {
    let identities = try seedFixture(fixture, store)
    var trace: CanonicalTrace!
    try store.withCandidateView { view in
        var workspace = BankLayoutWorkspace()
        var sink = OracleSink()
        let result = layout(
            semantic: SemanticRecordLayoutView(view), metrics: metrics,
            proposal: proposal, limits: limits, workspace: &workspace, sink: &sink)
        let normalizedSink = normalizeBank(sink)
        trace = .init(
            result: result, summary: normalizedSink.summary,
            events: normalizedSink.events, scopes: normalizedSink.scopes,
            lines: normalizedSink.lines, glyphs: normalizedSink.glyphs)
    }
    try store.discardCandidate()
    _ = identities
    return (trace, identities)
}

private func normalizeBank(_ sink: OracleSink) -> (
    summary: LayoutSummary?, events: [TraceEvent<UInt16>], scopes: [ScopeFact<UInt16>],
    lines: [LineFact<UInt16>], glyphs: [GlyphFact<UInt16>]
) {
    (sink.traceSummary, sink.traceEvents, sink.scopeFacts, sink.lineFacts, sink.glyphFacts)
}

private struct DifferentialCase {
    let view: FixtureView
    let proposal: ProposedSize
    let metrics: FixtureMetrics
    let limits: LayoutLimits
}

private func fixture(_ nodes: [FixtureNode], root: UInt16 = 1) -> FixtureView {
    FixtureView(
        nodes: Dictionary(uniqueKeysWithValues: nodes.map { ($0.identity, $0) }), rootIdentity: root
    )
}

private func t4T5Cases() -> [DifferentialCase] {
    let unconstrained = ProposedSize()!
    let normal = LayoutLimits(
        maximumScopes: 98, maximumDepth: 13, maximumTextScalars: 224, maximumTextLines: 98,
        maximumPositionedGlyphs: 224)!
    let ref = FixtureMetrics(reference: true)
    let standard = FixtureMetrics()
    var cases: [DifferentialCase] = []
    func add(
        _ nodes: [FixtureNode], _ proposal: ProposedSize = unconstrained,
        _ metrics: FixtureMetrics = standard, _ limits: LayoutLimits = normal
    ) {
        cases.append(
            .init(view: fixture(nodes), proposal: proposal, metrics: metrics, limits: limits))
    }

    // T4 Generic/Layout: mirrors each non-application LayoutStackTests fixture.
    add(
        [FixtureNode(1, .vStack(alignment: .center, spacing: 3))],
        ProposedSize(width: 20, height: 10)!)
    add([
        FixtureNode(1, .vStack(alignment: .center, spacing: 2), children: [2, 3, 4, 5, 6]),
        FixtureNode(2, .spacer(minLength: 0)),
        FixtureNode(3, .spacer(minLength: 0)),
        FixtureNode(4, .spacer(minLength: 0)),
        FixtureNode(5, .spacer(minLength: 0)),
        FixtureNode(6, .spacer(minLength: 0)),
    ])
    add(
        [
            FixtureNode(1, .hStack(alignment: .bottom, spacing: 2), children: [2, 3, 4, 5, 6]),
            FixtureNode(2, .spacer(minLength: 0)),
            FixtureNode(3, .spacer(minLength: 0)),
            FixtureNode(4, .spacer(minLength: 0)),
            FixtureNode(5, .spacer(minLength: 0)),
            FixtureNode(6, .spacer(minLength: 0)),
        ], ProposedSize(width: 1, height: 1)!)
    add([
        FixtureNode(1, .proxy, children: [2]),
        FixtureNode(2, .vStack(alignment: .leading, spacing: 4), children: [3, 4]),
        FixtureNode(3, .spacer(minLength: 0)), FixtureNode(4, .spacer(minLength: 0)),
    ])
    add(
        [
            FixtureNode(1, .vStack(alignment: .leading, spacing: 0), children: [2, 3, 4]),
            FixtureNode(2, .spacer(minLength: 0)), FixtureNode(3, .spacer(minLength: 0)),
            FixtureNode(4, .spacer(minLength: 0)),
        ], ProposedSize(width: 7, height: 8)!)
    add([
        FixtureNode(1, .vStack(alignment: .leading, spacing: 1), children: [2, 3]),
        FixtureNode(2, .spacer(minLength: 4)), FixtureNode(3, .spacer(minLength: 5)),
    ])
    add(
        [
            FixtureNode(1, .vStack(alignment: .leading, spacing: 1), children: [2, 3]),
            FixtureNode(2, .spacer(minLength: 4)), FixtureNode(3, .spacer(minLength: 5)),
        ], ProposedSize(height: 3)!)
    add([FixtureNode(1, .spacer(minLength: 99))], ProposedSize(width: 30, height: 30)!)
    add([
        FixtureNode(1, .vStack(alignment: .leading, spacing: 0), children: [2]),
        FixtureNode(2, .spacer(minLength: 99), modifiers: [.passthrough]),
    ])
    add(
        [FixtureNode(1, .spacer(minLength: 0), modifiers: [.padding(edges: .all, length: 2)])],
        ProposedSize(width: 3, height: 10)!)
    add([
        FixtureNode(
            1, .spacer(minLength: 0),
            modifiers: [.padding(edges: .all, length: 1), .padding(edges: .all, length: 2)])
    ])
    add([
        FixtureNode(
            1, .zStack(alignment: Alignment(horizontal: .center, vertical: .bottom)),
            children: [2, 3]),
        FixtureNode(
            2, .spacer(minLength: 0),
            modifiers: [.paddingInsets(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 4)!)]),
        FixtureNode(3, .spacer(minLength: 0), modifiers: [.padding(edges: .all, length: 3)]),
    ])
    add(
        [
            FixtureNode(
                1, .hStack(alignment: .center, spacing: 0), children: [2],
                modifiers: [.fixedFrame(width: 100, height: 10, alignment: .center)]),
            FixtureNode(2, .spacer(minLength: 0)),
        ], ProposedSize(width: 50, height: 5)!)
    add(
        [
            FixtureNode(
                1, .hStack(alignment: .center, spacing: 0), children: [2],
                modifiers: [
                    .flexibleFrame(
                        minWidth: 100, maxWidth: nil, minHeight: nil, maxHeight: nil,
                        alignment: .center)
                ]),
            FixtureNode(2, .spacer(minLength: 0)),
        ], ProposedSize(width: 50, height: 5)!)
    add(
        [
            FixtureNode(
                1, .spacer(minLength: 0),
                modifiers: [
                    .flexibleFrame(
                        minWidth: nil, maxWidth: .infinity, minHeight: nil, maxHeight: nil,
                        alignment: .leading)
                ])
        ], ProposedSize(width: 21, height: 9)!)
    add([
        FixtureNode(
            1, .spacer(minLength: 0),
            modifiers: [
                .flexibleFrame(
                    minWidth: nil, maxWidth: .infinity, minHeight: nil, maxHeight: nil,
                    alignment: .leading)
            ])
    ])
    add(
        [
            FixtureNode(
                1, .spacer(minLength: 0),
                modifiers: [
                    .padding(edges: .all, length: 2),
                    .fixedFrame(width: 8, height: 6, alignment: .center),
                ])
        ], ProposedSize(width: 12, height: 10)!)
    add(
        [
            FixtureNode(
                1, .spacer(minLength: 0),
                modifiers: [
                    .fixedFrame(width: 100, height: nil, alignment: .center),
                    .padding(edges: .all, length: 10),
                ])
        ], ProposedSize(width: 50)!)

    // T5 Text: the retained test vectors and metric modes, including failure paths.
    let textVectors: [([UInt32], ProposedSize, [SemanticLayoutModifier], FixtureMetrics)] = [
        ([0x41, 0x00b0, 0x2603], unconstrained, [], standard),
        ([0x0d, 0x0a, 0x41, 0x0a, 0x0d, 0x42], unconstrained, [], standard),
        ([], unconstrained, [], standard),
        ([0x41, 0x42, 0x41], ProposedSize(width: 8)!, [], standard),
        ([0x41, 0x42, 0x41], ProposedSize(width: 0)!, [], standard),
        ([0x41, 0x42, 0x0a, 0x41], unconstrained, [], standard),
        ([0x41, 0x42], ProposedSize(width: 3)!, [], standard),
        ([0x0a, 0x0a, 0x41, 0x0a], unconstrained, [], standard),
        ([0x41, 0x42], unconstrained, [.padding(edges: .all, length: 2)], standard),
        ([0x41, 0x0a, 0x42], ProposedSize(height: 5)!, [], standard),
        ([0x41, 0x00b0, 0x2603], unconstrained, [], ref),
        ([], unconstrained, [], FixtureMetrics(overflow: 1)),
        ([0x41, 0x41], unconstrained, [], FixtureMetrics(overflow: 2)),
    ]
    for (scalars, proposal, modifiers, metrics) in textVectors {
        add([FixtureNode(1, .text, modifiers: modifiers, scalars: scalars)], proposal, metrics)
    }

    // T6 combined canonical corpus and profile-equivalence graph.
    add(
        [
            FixtureNode(1, .vStack(alignment: .leading, spacing: 2), children: [2, 3, 5]),
            FixtureNode(
                2, .text, modifiers: [.padding(edges: .all, length: 1)], scalars: [0x41, 0x00b0]),
            FixtureNode(3, .hStack(alignment: .center, spacing: 0), children: [4]),
            FixtureNode(4, .spacer(minLength: 2)),
            FixtureNode(5, .zStack(alignment: .leading), children: [6]),
            FixtureNode(
                6, .spacer(minLength: 0),
                modifiers: [
                    .flexibleFrame(
                        minWidth: 4, maxWidth: .infinity, minHeight: 3, maxHeight: .points(5),
                        alignment: .center)
                ]),
        ],
        ProposedSize(width: 80, height: 60)!, ref)
    return cases
}

package func exerciseT4T5Baseline(_ store: borrowing SemanticRecordStore)
    throws(SemanticExpansionError) -> UInt32
{
    var assertions: UInt32 = 0
    let cases = t4T5Cases()
    for (index, differential) in cases.enumerated() {
        let (bank, identities) = try runBank(
            differential.view, store: store, proposal: differential.proposal,
            limits: differential.limits, metrics: differential.metrics)
        let baseline = runBaseline(
            differential.view, identities: identities, proposal: differential.proposal,
            limits: differential.limits, metrics: differential.metrics)
        precondition(bank == baseline, "Generic/Layout runtime-bank differential mismatch")
        assertions += 1
        if index == cases.count - 1 {
            let summary = bank.summary!
            precondition(bank.result == .success(summary))
            precondition(summary.scopeCount == 8)
            precondition(summary.textScalarCount == 2)
            precondition(summary.textLineCount == 1)
            precondition(summary.positionedGlyphCount == 2)
            precondition(
                bank.events == [
                    .begin, .scope(0), .scope(1), .scope(2), .line(2, 0),
                    .glyph(2, 0, 0, 1), .glyph(2, 0, 1, 96),
                    .scope(3), .scope(4), .scope(5), .scope(6), .scope(7), .publish,
                ])
            assertions += 5
        }
    }
    return assertions
}
