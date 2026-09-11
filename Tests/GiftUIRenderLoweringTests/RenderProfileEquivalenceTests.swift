import GiftUI
import GiftUIFailureCore
import GiftUILayout
import GiftUIRenderCore
import GiftUIRenderFailureAdapterFixture
import GiftUISemanticCore
import GiftUITextResources
import Testing

@testable import GiftUIRenderLowering

@Test
func canonicalCorpusMatchesAcrossRecordingDynamicAndStaticRenderProfiles() {
    for fixture in ProfileRenderFixture.all {
        let recording = runRecordingProfile(fixture)
        let dynamic = runDynamicProfile(fixture)
        let fixed = runStaticProfile(fixture)

        #expect(recording == dynamic, "recording/dynamic mismatch: \(fixture.name)")
        #expect(dynamic == fixed, "dynamic/static mismatch: \(fixture.name)")
        #expect(recording.result.isSuccess, "expected success: \(fixture.name)")
        #expect(recording.failure == nil, "unexpected mapping: \(fixture.name)")
        #expect(recording.limits == fixture.limits)
        #expect(recording.structuralCapacity == fixture.structuralCapacity)
        #expect(recording.foregroundHighWater == fixture.foregroundHighWater)
    }
}

private protocol RenderProfileIdentity: Equatable, Sendable {
    init(ordinal: UInt8)
    var ordinal: UInt8 { get }
}

private struct RecordingRenderIdentity: RenderProfileIdentity {
    let path: (UInt8, UInt8, UInt8)
    let ordinal: UInt8

    init(ordinal: UInt8) {
        self.ordinal = ordinal
        path = (0x38, ordinal, 0xa8)
    }

    static func == (left: Self, right: Self) -> Bool {
        left.path.0 == right.path.0 && left.path.1 == right.path.1
            && left.path.2 == right.path.2 && left.ordinal == right.ordinal
    }
}

private struct DynamicRenderIdentity: RenderProfileIdentity {
    let slot: UInt32
    let ordinal: UInt8

    init(ordinal: UInt8) {
        self.ordinal = ordinal
        slot = 0x8000 + UInt32(ordinal) * 19
    }
}

private enum StaticRenderIdentity: UInt8, RenderProfileIdentity {
    case zero, one, two, three, four, five, six

    init(ordinal: UInt8) {
        self = Self(rawValue: ordinal)!
    }

    var ordinal: UInt8 { rawValue }
}

private struct ProfileRenderNode {
    let scope: SemanticRenderScope
    let children: [UInt8]
    let bounds: Rect
    let clip: Rect
    let lines: [ResolvedRenderTextLine]
    let glyphs: [ResolvedRenderGlyph]
}

private struct ProfileRenderFixture {
    let name: String
    let nodes: [ProfileRenderNode]
    let surfaceBounds: Rect
    let damageMode: RenderDamageMode
    let rootForeground: Color
    let limits: RenderLimits
    let structuralCapacity: RenderWorkspaceCapacity
    let foregroundHighWater: UInt16

    static let all = [nested, painterOrder, partial, omitted, completeDamage]

    private static let surface = rect(0, 0, 40, 20)
    private static let emptyLines: [ResolvedRenderTextLine] = []
    private static let emptyGlyphs: [ResolvedRenderGlyph] = []

    private static let nested = ProfileRenderFixture(
        name: "nested-styles-and-sibling-restoration",
        nodes: [
            node(.structural, [1, 6]),
            node(.foregroundStyle(.green), [2]),
            node(.background(.blue), [3]),
            node(.foregroundStyle(.red), [4]),
            node(.background(Color(red: 128, green: 128, blue: 128)), [5]),
            textNode(baselineX: 2, glyphs: [glyph(0, id: 1, x: 2)]),
            textNode(baselineX: 20, glyphs: [glyph(0, id: 2, x: 20)]),
        ],
        surfaceBounds: surface,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: limits(4, 2, 2),
        structuralCapacity: structure(7, 7, 6, 2),
        foregroundHighWater: 3
    )

    private static let painterOrder = ProfileRenderFixture(
        name: "zstack-painter-order-and-empty-line",
        nodes: [
            node(.structural, [1, 3, 4]),
            node(.background(.green), [2]),
            node(.structural),
            ProfileRenderNode(
                scope: .text,
                children: [],
                bounds: surface,
                clip: surface,
                lines: [
                    line(0, y: 8, glyphCount: 2),
                    ResolvedRenderTextLine(
                        lineIndex: 1,
                        bounds: rect(0, 10, 0, 0),
                        baseline: Point(x: 1, y: 12),
                        clip: surface,
                        glyphCount: 0
                    ),
                    line(2, y: 16, glyphCount: 1),
                ],
                glyphs: [
                    glyph(0, id: 0, x: 1), glyph(0, index: 1, id: 1, x: 5),
                    glyph(2, index: 2, id: 2, x: 1, y: 16),
                ]
            ),
            node(.background(.blue), [5]),
            node(.structural),
        ],
        surfaceBounds: surface,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: limits(4, 3, 2),
        structuralCapacity: structure(6, 6, 3, 3),
        foregroundHighWater: 1
    )

    private static let partialBounds = rect(-10, -5, 60, 30)
    private static let partialClip = rect(30, 10, 20, 20)
    private static let partial = ProfileRenderFixture(
        name: "partial-unclipped-background",
        nodes: [
            node(.background(.green), [1], bounds: partialBounds, clip: partialClip),
            node(.structural, bounds: partialBounds, clip: partialClip),
        ],
        surfaceBounds: surface,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: limits(2, 2, 2),
        structuralCapacity: structure(5, 2, 5, 1),
        foregroundHighWater: 1
    )

    private static let omitted = ProfileRenderFixture(
        name: "off-surface-and-zero-area-omission",
        nodes: [
            node(.structural, [1, 3]),
            node(.background(.green), [2], bounds: partialBounds, clip: rect(50, 50, 10, 10)),
            node(.structural, bounds: partialBounds, clip: rect(50, 50, 10, 10)),
            node(.background(.blue), [4], bounds: rect(5, 5, 0, 10)),
            node(.structural, bounds: rect(5, 5, 0, 10)),
        ],
        surfaceBounds: surface,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: limits(2, 2, 2),
        structuralCapacity: structure(5, 5, 3, 1),
        foregroundHighWater: 1
    )

    private static let completeDamage = ProfileRenderFixture(
        name: "complete-surface-damage-with-smaller-root",
        nodes: [node(.structural, bounds: rect(5, 4, 10, 6), clip: rect(5, 4, 10, 6))],
        surfaceBounds: surface,
        damageMode: .initializeCompleteSurface,
        rootForeground: .black,
        limits: limits(2, 2, 2),
        structuralCapacity: structure(1, 1, 1, 1),
        foregroundHighWater: 1
    )

    private static func node(
        _ scope: SemanticRenderScope,
        _ children: [UInt8] = [],
        bounds: Rect = surface,
        clip: Rect = surface
    ) -> ProfileRenderNode {
        ProfileRenderNode(
            scope: scope,
            children: children,
            bounds: bounds,
            clip: clip,
            lines: emptyLines,
            glyphs: emptyGlyphs
        )
    }

    private static func textNode(
        baselineX: Int32,
        glyphs: [ResolvedRenderGlyph]
    ) -> ProfileRenderNode {
        ProfileRenderNode(
            scope: .text,
            children: [],
            bounds: surface,
            clip: surface,
            lines: [line(0, x: baselineX, y: 8, glyphCount: UInt16(glyphs.count))],
            glyphs: glyphs
        )
    }

    private static func line(
        _ index: UInt16,
        x: Int32 = 1,
        y: Int32,
        glyphCount: UInt16
    ) -> ResolvedRenderTextLine {
        ResolvedRenderTextLine(
            lineIndex: index,
            bounds: surface,
            baseline: Point(x: x, y: y),
            clip: surface,
            glyphCount: glyphCount
        )
    }

    private static func glyph(
        _ line: UInt16,
        index: UInt16 = 0,
        id: UInt16,
        x: Int32,
        y: Int32 = 8
    ) -> ResolvedRenderGlyph {
        ResolvedRenderGlyph(
            lineIndex: line,
            glyphIndex: index,
            instance: ProfileRenderMetrics.instanceID,
            glyph: GlyphID(rawValue: id),
            baseline: Point(x: x, y: y),
            clip: surface
        )
    }

    private static func rect(_ x: Int32, _ y: Int32, _ width: Int32, _ height: Int32) -> Rect {
        Rect(origin: Point(x: x, y: y), size: Size(width: width, height: height)!)!
    }

    private static func limits(_ operations: UInt16, _ glyphs: UInt16, _ clips: UInt16)
        -> RenderLimits
    {
        RenderLimits(
            maximumOperations: operations, maximumPositionedGlyphs: glyphs, maximumClipDepth: clips)!
    }

    private static func structure(
        _ semantic: UInt16, _ layout: UInt16, _ depth: UInt16, _ lines: UInt16
    ) -> RenderWorkspaceCapacity {
        RenderWorkspaceCapacity(
            maximumSemanticScopes: semantic, maximumLayoutScopes: layout,
            maximumTraversalDepth: depth, maximumTextLines: lines)!
    }
}

private struct ProfileSemanticRenderView<Identity: RenderProfileIdentity>: SemanticRenderView {
    let fixture: ProfileRenderFixture
    var rootIdentity: Identity { Identity(ordinal: 0) }
    var semanticScopeCount: UInt16 { UInt16(fixture.nodes.count) }
    var renderSnapshotVersion: UInt32 { 1 }

    func semanticIdentity(at ordinal: UInt16) -> Identity? {
        ordinal < semanticScopeCount ? Identity(ordinal: UInt8(ordinal)) : nil
    }
    func semanticOrdinal(of identity: Identity) -> UInt16? {
        UInt16(identity.ordinal) < semanticScopeCount ? UInt16(identity.ordinal) : nil
    }
    func scope(at identity: Identity) -> SemanticRenderScope? { node(identity)?.scope }
    func layoutIdentity(for identity: Identity) -> Identity? {
        node(identity) == nil ? nil : identity
    }
    func childCount(of identity: Identity) -> UInt16? {
        node(identity).map { UInt16($0.children.count) }
    }
    func child(of identity: Identity, at index: UInt16) -> Identity? {
        guard let children = node(identity)?.children, Int(index) < children.count else {
            return nil
        }
        return Identity(ordinal: children[Int(index)])
    }
    private func node(_ identity: Identity) -> ProfileRenderNode? {
        let index = Int(identity.ordinal)
        return index < fixture.nodes.count ? fixture.nodes[index] : nil
    }
}

private struct ProfileResolvedRenderLayoutView<Identity: RenderProfileIdentity>:
    ResolvedRenderLayoutView
{
    let fixture: ProfileRenderFixture
    var rootIdentity: Identity { Identity(ordinal: 0) }
    var layoutScopeCount: UInt16 { UInt16(fixture.nodes.count) }
    var renderSnapshotVersion: UInt32 { 1 }
    var rootBounds: Rect { fixture.nodes[0].bounds }

    func layoutIdentity(at ordinal: UInt16) -> Identity? {
        ordinal < layoutScopeCount ? Identity(ordinal: UInt8(ordinal)) : nil
    }
    func layoutOrdinal(of identity: Identity) -> UInt16? {
        UInt16(identity.ordinal) < layoutScopeCount ? UInt16(identity.ordinal) : nil
    }
    func bounds(of identity: Identity) -> Rect? { node(identity)?.bounds }
    func clip(of identity: Identity) -> Rect? { node(identity)?.clip }
    func textLineCount(of identity: Identity) -> UInt16? {
        node(identity).map { UInt16($0.lines.count) }
    }
    func textLine(of identity: Identity, at index: UInt16) -> ResolvedRenderTextLine? {
        guard let lines = node(identity)?.lines, Int(index) < lines.count else { return nil }
        return lines[Int(index)]
    }
    func glyph(of identity: Identity, at index: UInt16) -> ResolvedRenderGlyph? {
        guard let glyphs = node(identity)?.glyphs, Int(index) < glyphs.count else { return nil }
        return glyphs[Int(index)]
    }
    private func node(_ identity: Identity) -> ProfileRenderNode? {
        let index = Int(identity.ordinal)
        return index < fixture.nodes.count ? fixture.nodes[index] : nil
    }
}

private struct ProfileRenderMetrics: CanonicalTextMetricsView {
    static let resource = FontResourceID(
        rawValue: TextResourceDigest(
            word0: 1, word1: 2, word2: 3, word3: 4,
            word4: 5, word5: 6, word6: 7, word7: 8
        )
    )
    static let instanceID = FontInstanceID(resource: resource, instanceIndex: 0)
    let descriptor = TextResourceDescriptor(
        schemaVersion: 1,
        resource: resource,
        instanceCount: 1,
        realizationCount: 0,
        canonicalManifestByteCount: 0
    )

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        guard index == 0 else { return nil }
        return FontInstanceDescriptor(
            id: Self.instanceID,
            lineMetrics: FontLineMetrics(ascent: 8, descent: 2, lineGap: 0),
            replacementGlyph: GlyphID(rawValue: 0),
            glyphCount: 3,
            mappingCount: 0
        )
    }

    func mapping(at index: UInt16, in instance: FontInstanceID) -> ScalarGlyphMappingRecord? { nil }

    func metrics(for glyph: GlyphID, in instance: FontInstanceID) -> GlyphMetrics? {
        guard instance == Self.instanceID, glyph.rawValue < 3 else { return nil }
        return GlyphMetrics(
            advanceX: 4,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 1, height: 1)!
        )
    }
}

private protocol ProfileVisitStorage {
    init(capacity: UInt16)
    mutating func clear()
    mutating func visit(_ ordinal: UInt16) -> RenderWorkspaceVisit
}

private struct RecordingVisitStorage: ProfileVisitStorage {
    private var values: [UInt8]
    init(capacity: UInt16) { values = [UInt8](repeating: 0, count: Int(capacity)) }
    mutating func clear() { values = [UInt8](repeating: 0, count: values.count) }
    mutating func visit(_ ordinal: UInt16) -> RenderWorkspaceVisit {
        guard Int(ordinal) < values.count else { return .invalid }
        guard values[Int(ordinal)] == 0 else { return .repeated }
        values[Int(ordinal)] = 1
        return .first
    }
}

private struct DynamicVisitStorage: ProfileVisitStorage {
    private var values: [Bool]
    init(capacity: UInt16) { values = [Bool](repeating: false, count: Int(capacity)) }
    mutating func clear() { values = [Bool](repeating: false, count: values.count) }
    mutating func visit(_ ordinal: UInt16) -> RenderWorkspaceVisit {
        guard Int(ordinal) < values.count else { return .invalid }
        guard !values[Int(ordinal)] else { return .repeated }
        values[Int(ordinal)] = true
        return .first
    }
}

private struct StaticVisitStorage: ProfileVisitStorage {
    private let capacity: UInt16
    private var bits: UInt8 = 0
    init(capacity: UInt16) { self.capacity = capacity }
    mutating func clear() { bits = 0 }
    mutating func visit(_ ordinal: UInt16) -> RenderWorkspaceVisit {
        guard ordinal < capacity, ordinal < 8 else { return .invalid }
        let mask = UInt8(1) << UInt8(ordinal)
        guard bits & mask == 0 else { return .repeated }
        bits |= mask
        return .first
    }
}

private protocol ProfileForegroundStorage {
    init(capacity: UInt16)
    var count: UInt16 { get }
    var current: Color? { get }
    mutating func clear()
    mutating func push(_ color: Color) -> Bool
    mutating func pop() -> Bool
}

private struct RecordingForegroundStorage: ProfileForegroundStorage {
    private var values: [Color?]
    private(set) var count: UInt16 = 0
    init(capacity: UInt16) { values = [Color?](repeating: nil, count: Int(capacity)) }
    var current: Color? { count == 0 ? nil : values[Int(count - 1)] }
    mutating func clear() {
        for index in values.indices { values[index] = nil }
        count = 0
    }
    mutating func push(_ color: Color) -> Bool {
        guard Int(count) < values.count else { return false }
        values[Int(count)] = color
        count += 1
        return true
    }
    mutating func pop() -> Bool {
        guard count > 0 else { return false }
        count -= 1
        values[Int(count)] = nil
        return true
    }
}

private struct DynamicForegroundStorage: ProfileForegroundStorage {
    private let capacity: UInt16
    private var values: [Color] = []
    init(capacity: UInt16) { self.capacity = capacity }
    var count: UInt16 { UInt16(values.count) }
    var current: Color? { values.last }
    mutating func clear() { values.removeAll(keepingCapacity: true) }
    mutating func push(_ color: Color) -> Bool {
        guard values.count < Int(capacity) else { return false }
        values.append(color)
        return true
    }
    mutating func pop() -> Bool { values.popLast() != nil }
}

private struct StaticForegroundStorage: ProfileForegroundStorage {
    private let capacity: UInt16
    private var values = (
        Color.black, Color.black, Color.black, Color.black, Color.black, Color.black
    )
    private(set) var count: UInt16 = 0
    init(capacity: UInt16) { self.capacity = capacity }
    var current: Color? { count == 0 ? nil : value(at: count - 1) }
    mutating func clear() { count = 0 }
    mutating func push(_ color: Color) -> Bool {
        guard count < capacity, count < 6 else { return false }
        set(color, at: count)
        count += 1
        return true
    }
    mutating func pop() -> Bool {
        guard count > 0 else { return false }
        count -= 1
        return true
    }
    private func value(at index: UInt16) -> Color {
        switch index {
        case 0: values.0
        case 1: values.1
        case 2: values.2
        case 3: values.3
        case 4: values.4
        default: values.5
        }
    }
    private mutating func set(_ color: Color, at index: UInt16) {
        switch index {
        case 0: values.0 = color
        case 1: values.1 = color
        case 2: values.2 = color
        case 3: values.3 = color
        case 4: values.4 = color
        default: values.5 = color
        }
    }
}

private struct ProfileRenderWorkspace<Identity, Visits, Foregrounds>: RenderProductionWorkspace
where
    Identity: RenderProfileIdentity, Visits: ProfileVisitStorage,
    Foregrounds: ProfileForegroundStorage
{
    let capacity: RenderLimits
    let structuralCapacity: RenderWorkspaceCapacity
    private(set) var isActive = false
    private(set) var foregroundHighWater: UInt16 = 0
    private var semantic: Visits
    private var layout: Visits
    private var foregrounds: Foregrounds

    init(capacity: RenderLimits, structuralCapacity: RenderWorkspaceCapacity) {
        self.capacity = capacity
        self.structuralCapacity = structuralCapacity
        semantic = Visits(capacity: structuralCapacity.maximumSemanticScopes)
        layout = Visits(capacity: structuralCapacity.maximumLayoutScopes)
        foregrounds = Foregrounds(capacity: structuralCapacity.maximumTraversalDepth)
    }
    mutating func acquire() -> Bool {
        guard !isActive else { return false }
        semantic.clear()
        layout.clear()
        foregrounds.clear()
        foregroundHighWater = 0
        isActive = true
        return true
    }
    mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        isActive ? semantic.visit(ordinal) : .invalid
    }
    mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        isActive ? layout.visit(ordinal) : .invalid
    }
    var currentForeground: Color? { isActive ? foregrounds.current : nil }
    mutating func pushForeground(_ color: Color) -> Bool {
        guard isActive, foregrounds.push(color) else { return false }
        foregroundHighWater = max(foregroundHighWater, foregrounds.count)
        return true
    }
    mutating func popForeground() -> Bool { isActive && foregrounds.pop() }
    mutating func reset() {
        semantic.clear()
        layout.clear()
        foregrounds.clear()
        isActive = false
    }
}

private enum ProfileRenderEvent: Equatable {
    case begin(RenderPlanHeader)
    case fill(FillRectOperation)
    case beginGlyphs(PositionedGlyphOperationHeader)
    case glyph(PositionedGlyph)
    case endGlyphs
    case finish
}

private struct ProfileRenderSink: RenderOperationSink {
    let capacity: RenderSinkCapacity
    private(set) var events: [ProfileRenderEvent] = []
    init(limits: RenderLimits) {
        capacity = RenderSinkCapacity(
            maximumOperations: limits.maximumOperations,
            maximumPositionedGlyphs: limits.maximumPositionedGlyphs
        )
    }
    mutating func begin(_ header: RenderPlanHeader) -> Bool { record(.begin(header)) }
    mutating func fillRect(_ operation: FillRectOperation) -> Bool { record(.fill(operation)) }
    mutating func beginPositionedGlyphs(_ operation: PositionedGlyphOperationHeader) -> Bool {
        record(.beginGlyphs(operation))
    }
    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool { record(.glyph(glyph)) }
    mutating func endPositionedGlyphs() -> Bool { record(.endGlyphs) }
    mutating func finish() -> Bool { record(.finish) }
    mutating func discard() { events.removeAll(keepingCapacity: true) }
    private mutating func record(_ event: ProfileRenderEvent) -> Bool {
        events.append(event)
        return true
    }
}

private struct ProfileRenderObservation: Equatable {
    let result: RenderProductionResult
    let events: [ProfileRenderEvent]
    let failure: GiftUIFailureFact?
    let limits: RenderLimits
    let structuralCapacity: RenderWorkspaceCapacity
    let foregroundHighWater: UInt16
}

private func runRecordingProfile(_ fixture: ProfileRenderFixture) -> ProfileRenderObservation {
    produceProfile(
        fixture,
        workspace: ProfileRenderWorkspace<
            RecordingRenderIdentity, RecordingVisitStorage, RecordingForegroundStorage
        >(
            capacity: fixture.limits,
            structuralCapacity: fixture.structuralCapacity
        )
    )
}

private func runDynamicProfile(_ fixture: ProfileRenderFixture) -> ProfileRenderObservation {
    produceProfile(
        fixture,
        workspace: ProfileRenderWorkspace<
            DynamicRenderIdentity, DynamicVisitStorage, DynamicForegroundStorage
        >(
            capacity: fixture.limits,
            structuralCapacity: fixture.structuralCapacity
        )
    )
}

private func runStaticProfile(_ fixture: ProfileRenderFixture) -> ProfileRenderObservation {
    produceProfile(
        fixture,
        workspace: ProfileRenderWorkspace<
            StaticRenderIdentity, StaticVisitStorage, StaticForegroundStorage
        >(
            capacity: fixture.limits,
            structuralCapacity: fixture.structuralCapacity
        )
    )
}

private func produceProfile<Identity: RenderProfileIdentity, Visits, Foregrounds>(
    _ fixture: ProfileRenderFixture,
    workspace initialWorkspace: ProfileRenderWorkspace<Identity, Visits, Foregrounds>
) -> ProfileRenderObservation
where Visits: ProfileVisitStorage, Foregrounds: ProfileForegroundStorage {
    var workspace = initialWorkspace
    var sink = ProfileRenderSink(limits: fixture.limits)
    let result = RenderProducer.produce(
        semantic: ProfileSemanticRenderView<Identity>(fixture: fixture),
        layout: ProfileResolvedRenderLayoutView<Identity>(fixture: fixture),
        textMetrics: ProfileRenderMetrics(),
        surfaceBounds: fixture.surfaceBounds,
        damageMode: fixture.damageMode,
        rootForeground: fixture.rootForeground,
        limits: fixture.limits,
        workspace: &workspace,
        sink: &sink
    )
    return ProfileRenderObservation(
        result: result,
        events: sink.events,
        failure: GiftUIRenderFailureAdapterFixture.fact(for: result),
        limits: workspace.capacity,
        structuralCapacity: workspace.structuralCapacity,
        foregroundHighWater: workspace.foregroundHighWater
    )
}

private extension RenderProductionResult {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}
