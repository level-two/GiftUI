import GiftUI
import GiftUILayout
import GiftUIRenderCore
import GiftUISemanticCore
import GiftUITextResources
import Testing

@testable import GiftUIRenderLowering

@Test
func preflightValidatesTheCompleteViewsAndBuildsTheExactHeaderWithoutEmission() {
    var workspace = PreflightWorkspace<RenderFixtureIdentity>()
    let workspaceAcquired = workspace.acquire()
    #expect(workspaceAcquired)
    var sink = PreflightSink(
        capacity: RenderSinkCapacity(
            maximumOperations: 2,
            maximumPositionedGlyphs: 2
        )
    )

    let result = RenderProducer.preflight(
        semantic: DirectRenderFixtures.validSemantic,
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &workspace,
        sink: &sink
    )

    guard case .success(let summary) = result else {
        Issue.record("expected successful preflight")
        return
    }
    #expect(summary.header.surfaceBounds == DirectRenderFixtures.bounds)
    #expect(summary.header.damageBounds == DirectRenderFixtures.bounds)
    #expect(summary.header.operationCount == 2)
    #expect(summary.header.positionedGlyphCount == 2)
    #expect(summary.header.maximumObservedClipDepth == 2)
    #expect(summary.semanticSnapshotVersion == 1)
    #expect(summary.layoutSnapshotVersion == 1)
    #expect(workspace.semanticVisitCalls == 5)
    #expect(workspace.layoutVisitCalls == 5)
    #expect(workspace.firstSemanticVisits == 5)
    #expect(workspace.firstLayoutVisits == 2)
    #expect(sink.counter.capacityReads == 1)
    #expect(sink.counter.operationCalls == 0)
}

@Test
func preflightChecksDeclaredStructuralAndSinkCapacityAtExactBoundaries() {
    var semanticShortWorkspace = PreflightWorkspace<RenderFixtureIdentity>(
        structuralCapacity: RenderWorkspaceCapacity(
            maximumSemanticScopes: 4,
            maximumLayoutScopes: 2,
            maximumTraversalDepth: 5,
            maximumTextLines: 1
        )!
    )
    let semanticShortWorkspaceAcquired = semanticShortWorkspace.acquire()
    #expect(semanticShortWorkspaceAcquired)
    var untouchedSink = PreflightSink.unbounded
    expectFailure(
        RenderProducer.preflight(
            semantic: DirectRenderFixtures.validSemantic,
            layout: DirectRenderFixtures.validLayout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &semanticShortWorkspace,
            sink: &untouchedSink
        ),
        equals: .capacityExhausted
    )
    #expect(semanticShortWorkspace.semanticVisitCalls == 0)
    #expect(untouchedSink.counter.capacityReads == 0)

    var depthShortWorkspace = PreflightWorkspace<RenderFixtureIdentity>(
        structuralCapacity: RenderWorkspaceCapacity(
            maximumSemanticScopes: 5,
            maximumLayoutScopes: 2,
            maximumTraversalDepth: 4,
            maximumTextLines: 1
        )!
    )
    let depthShortWorkspaceAcquired = depthShortWorkspace.acquire()
    #expect(depthShortWorkspaceAcquired)
    var depthSink = PreflightSink.unbounded
    expectFailure(
        RenderProducer.preflight(
            semantic: DirectRenderFixtures.validSemantic,
            layout: DirectRenderFixtures.validLayout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &depthShortWorkspace,
            sink: &depthSink
        ),
        equals: .capacityExhausted
    )
    #expect(depthShortWorkspace.semanticVisitCalls == 4)
    #expect(depthSink.counter.capacityReads == 0)

    var renderLimitWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    let renderLimitWorkspaceAcquired = renderLimitWorkspace.acquire()
    #expect(renderLimitWorkspaceAcquired)
    var renderLimitSink = PreflightSink.unbounded
    expectFailure(
        RenderProducer.preflight(
            semantic: DirectRenderFixtures.validSemantic,
            layout: DirectRenderFixtures.validLayout,
            textMetrics: PreflightMetrics(resourceWord: 99),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            limits: RenderLimits(
                maximumOperations: 1,
                maximumPositionedGlyphs: 2,
                maximumClipDepth: 2
            )!,
            workspace: &renderLimitWorkspace,
            sink: &renderLimitSink
        ),
        equals: .capacityExhausted
    )
    #expect(renderLimitSink.counter.capacityReads == 0)

    var exactWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    let exactWorkspaceAcquired = exactWorkspace.acquire()
    #expect(exactWorkspaceAcquired)
    var shortSink = PreflightSink(
        capacity: RenderSinkCapacity(
            maximumOperations: 1,
            maximumPositionedGlyphs: 2
        )
    )
    expectFailure(
        RenderProducer.preflight(
            semantic: DirectRenderFixtures.validSemantic,
            layout: DirectRenderFixtures.validLayout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &exactWorkspace,
            sink: &shortSink
        ),
        equals: .capacityExhausted
    )
    #expect(shortSink.counter.capacityReads == 1)
    #expect(shortSink.counter.operationCalls == 0)
}

@Test
func preflightRejectsRootOrdinalSnapshotAndResourceDisagreementExactly() {
    let validSemantic = DirectRenderFixtures.validSemantic
    let duplicateOrdinalSemantic = DirectSemanticRenderView(
        rootIdentity: validSemantic.rootIdentity,
        semanticScopeCount: validSemantic.semanticScopeCount,
        renderSnapshotVersion: validSemantic.renderSnapshotVersion,
        records: validSemantic.records + [validSemantic.records.last!]
    )
    var ordinalWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    let ordinalWorkspaceAcquired = ordinalWorkspace.acquire()
    #expect(ordinalWorkspaceAcquired)
    var ordinalSink = PreflightSink.unbounded
    expectFailure(
        RenderProducer.preflight(
            semantic: duplicateOrdinalSemantic,
            layout: DirectRenderFixtures.validLayout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &ordinalWorkspace,
            sink: &ordinalSink
        ),
        equals: .invariantViolation
    )
    #expect(ordinalSink.counter.capacityReads == 0)

    var rootWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    let rootWorkspaceAcquired = rootWorkspace.acquire()
    #expect(rootWorkspaceAcquired)
    var rootSink = PreflightSink.unbounded
    let validLayout = DirectRenderFixtures.validLayout
    let mismatchedRoot = DirectResolvedRenderLayoutView(
        rootIdentity: .alternate,
        layoutScopeCount: validLayout.layoutScopeCount,
        renderSnapshotVersion: validLayout.renderSnapshotVersion,
        rootBounds: validLayout.rootBounds,
        records: validLayout.records
    )
    expectFailure(
        RenderProducer.preflight(
            semantic: validSemantic,
            layout: mismatchedRoot,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &rootWorkspace,
            sink: &rootSink
        ),
        equals: .invalidInput
    )

    var snapshotWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    let snapshotWorkspaceAcquired = snapshotWorkspace.acquire()
    #expect(snapshotWorkspaceAcquired)
    var snapshotSink = PreflightSink.unbounded
    expectFailure(
        RenderProducer.preflight(
            semantic: ChangingSnapshotSemanticView(base: validSemantic),
            layout: validLayout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &snapshotWorkspace,
            sink: &snapshotSink
        ),
        equals: .invariantViolation
    )
    #expect(snapshotSink.counter.capacityReads == 0)

    var resourceWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    let resourceWorkspaceAcquired = resourceWorkspace.acquire()
    #expect(resourceWorkspaceAcquired)
    var resourceSink = PreflightSink.unbounded
    expectFailure(
        RenderProducer.preflight(
            semantic: validSemantic,
            layout: validLayout,
            textMetrics: PreflightMetrics(resourceWord: 99),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &resourceWorkspace,
            sink: &resourceSink
        ),
        equals: .incompatibleTextResource
    )
}

@Test
func streamingRepeatsCanonicalLookupsAndEmitsTheExactOrderedValues() {
    var workspace = PreflightWorkspace<RenderFixtureIdentity>()
    let acquired = workspace.acquire()
    #expect(acquired)
    var sink = StreamingSink()
    let semantic = DirectRenderFixtures.validSemantic
    let layout = DirectRenderFixtures.validLayout
    let metrics = PreflightMetrics()
    let preflight = successfulPreflight(
        semantic: semantic,
        layout: layout,
        metrics: metrics,
        workspace: &workspace,
        sink: &sink
    )
    guard let preflight else { return }
    let semanticVisits = workspace.semanticVisitCalls
    let layoutVisits = workspace.layoutVisitCalls

    let result = RenderProducer.stream(
        preflight: preflight,
        semantic: semantic,
        layout: layout,
        textMetrics: metrics,
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        sink: &sink
    )

    #expect(result == .success(preflight.header))
    #expect(workspace.semanticVisitCalls == semanticVisits)
    #expect(workspace.layoutVisitCalls == layoutVisits)
    #expect(sink.capacityReads == 1)
    #expect(sink.discardCount == 0)
    #expect(
        sink.events == [
            .begin(preflight.header),
            .fill(
                FillRectOperation(
                    bounds: DirectRenderFixtures.bounds,
                    clip: DirectRenderFixtures.bounds,
                    color: .blue
                )
            ),
            .beginGlyphs(
                PositionedGlyphOperationHeader(
                    instance: DirectRenderFixtures.instance,
                    clip: DirectRenderFixtures.bounds,
                    color: .red,
                    glyphCount: 2
                )
            ),
            .glyph(
                PositionedGlyph(
                    glyph: GlyphID(rawValue: 1),
                    baseline: Point(x: 1, y: 12)
                )
            ),
            .glyph(
                PositionedGlyph(
                    glyph: GlyphID(rawValue: 2),
                    baseline: Point(x: 5, y: 12)
                )
            ),
            .endGlyphs,
            .finish,
        ]
    )
}

@Test
func streamingDistinguishesBeginRefusalFromPostBeginInvariantFailure() {
    let semantic = DirectRenderFixtures.validSemantic
    let layout = DirectRenderFixtures.validLayout
    let metrics = PreflightMetrics()

    var beginWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    let beginAcquired = beginWorkspace.acquire()
    #expect(beginAcquired)
    var beginSink = StreamingSink(refuseAtOperationCall: 1)
    let beginPreflight = successfulPreflight(
        semantic: semantic,
        layout: layout,
        metrics: metrics,
        workspace: &beginWorkspace,
        sink: &beginSink
    )
    guard let beginPreflight else { return }
    let beginResult = RenderProducer.stream(
        preflight: beginPreflight,
        semantic: semantic,
        layout: layout,
        textMetrics: metrics,
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        sink: &beginSink
    )
    #expect(beginResult == .failure(.sinkRefused))
    #expect(beginSink.operationCallCount == 1)
    #expect(beginSink.discardCount == 0)

    var glyphWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    let glyphAcquired = glyphWorkspace.acquire()
    #expect(glyphAcquired)
    var glyphSink = StreamingSink(refuseAtOperationCall: 4)
    let glyphPreflight = successfulPreflight(
        semantic: semantic,
        layout: layout,
        metrics: metrics,
        workspace: &glyphWorkspace,
        sink: &glyphSink
    )
    guard let glyphPreflight else { return }
    let glyphResult = RenderProducer.stream(
        preflight: glyphPreflight,
        semantic: semantic,
        layout: layout,
        textMetrics: metrics,
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        sink: &glyphSink
    )
    #expect(glyphResult == .failure(.invariantViolation))
    #expect(glyphSink.operationCallCount == 4)
    #expect(glyphSink.discardCount == 1)
    #expect(!glyphSink.events.contains(.finish))
}

@Test
func streamingDiscardsWhenSnapshotChangesAfterTheLastOperation() {
    let semantic = LateChangingSnapshotSemanticView(
        base: DirectRenderFixtures.validSemantic
    )
    let layout = DirectRenderFixtures.validLayout
    let metrics = PreflightMetrics()
    var workspace = PreflightWorkspace<RenderFixtureIdentity>()
    let acquired = workspace.acquire()
    #expect(acquired)
    var sink = StreamingSink()
    let preflight = successfulPreflight(
        semantic: semantic,
        layout: layout,
        metrics: metrics,
        workspace: &workspace,
        sink: &sink
    )
    guard let preflight else { return }

    let result = RenderProducer.stream(
        preflight: preflight,
        semantic: semantic,
        layout: layout,
        textMetrics: metrics,
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        sink: &sink
    )

    #expect(result == .failure(.invariantViolation))
    #expect(sink.discardCount == 1)
    #expect(!sink.events.contains(.finish))
}

private func successfulPreflight<Semantic, Layout>(
    semantic: borrowing Semantic,
    layout: borrowing Layout,
    metrics: borrowing PreflightMetrics,
    workspace: inout PreflightWorkspace<RenderFixtureIdentity>,
    sink: inout StreamingSink
) -> RenderPreflightSummary?
where
    Semantic: SemanticRenderView,
    Layout: ResolvedRenderLayoutView,
    Semantic.Identity == RenderFixtureIdentity,
    Layout.Identity == RenderFixtureIdentity
{
    let result = RenderProducer.preflight(
        semantic: semantic,
        layout: layout,
        textMetrics: metrics,
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &workspace,
        sink: &sink
    )
    guard case .success(let summary) = result else {
        Issue.record("expected successful preflight")
        return nil
    }
    return summary
}

private func expectFailure(
    _ result: RenderPreflightResult,
    equals expected: RenderProductionError
) {
    guard case .failure(let error) = result else {
        Issue.record("expected preflight failure")
        return
    }
    #expect(error == expected)
}

private struct PreflightWorkspace<Identity>: RenderProductionWorkspace
where Identity: Equatable & Sendable {
    static var limits: RenderLimits {
        RenderLimits(
            maximumOperations: 2,
            maximumPositionedGlyphs: 2,
            maximumClipDepth: 2
        )!
    }

    static var structure: RenderWorkspaceCapacity {
        RenderWorkspaceCapacity(
            maximumSemanticScopes: 5,
            maximumLayoutScopes: 2,
            maximumTraversalDepth: 5,
            maximumTextLines: 1
        )!
    }

    let capacity: RenderLimits
    let structuralCapacity: RenderWorkspaceCapacity
    private(set) var isActive = false
    private(set) var semanticVisitCalls: UInt16 = 0
    private(set) var layoutVisitCalls: UInt16 = 0
    private(set) var firstSemanticVisits: UInt16 = 0
    private(set) var firstLayoutVisits: UInt16 = 0
    private var semanticVisits: [Bool]
    private var layoutVisits: [Bool]

    init(
        capacity: RenderLimits = Self.limits,
        structuralCapacity: RenderWorkspaceCapacity = Self.structure
    ) {
        self.capacity = capacity
        self.structuralCapacity = structuralCapacity
        semanticVisits = [Bool](
            repeating: false,
            count: Int(structuralCapacity.maximumSemanticScopes)
        )
        layoutVisits = [Bool](
            repeating: false,
            count: Int(structuralCapacity.maximumLayoutScopes)
        )
    }

    mutating func acquire() -> Bool {
        guard !isActive else { return false }
        isActive = true
        semanticVisits = [Bool](repeating: false, count: semanticVisits.count)
        layoutVisits = [Bool](repeating: false, count: layoutVisits.count)
        return true
    }

    mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        semanticVisitCalls += 1
        let result = visit(ordinal, visits: &semanticVisits)
        if result == .first { firstSemanticVisits += 1 }
        return result
    }

    mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        layoutVisitCalls += 1
        let result = visit(ordinal, visits: &layoutVisits)
        if result == .first { firstLayoutVisits += 1 }
        return result
    }

    mutating func reset() {
        semanticVisits = [Bool](repeating: false, count: semanticVisits.count)
        layoutVisits = [Bool](repeating: false, count: layoutVisits.count)
        isActive = false
    }

    private func visit(
        _ ordinal: UInt16,
        visits: inout [Bool]
    ) -> RenderWorkspaceVisit {
        guard isActive, Int(ordinal) < visits.count else { return .invalid }
        let index = Int(ordinal)
        if visits[index] { return .repeated }
        visits[index] = true
        return .first
    }
}

private final class PreflightSinkCounter {
    var capacityReads: UInt16 = 0
    var operationCalls: UInt16 = 0
}

private struct PreflightSink: RenderOperationSink {
    static var unbounded: Self {
        PreflightSink(
            capacity: RenderSinkCapacity(
                maximumOperations: .max,
                maximumPositionedGlyphs: .max
            )
        )
    }

    let reportedCapacity: RenderSinkCapacity
    let counter = PreflightSinkCounter()

    init(capacity: RenderSinkCapacity) {
        reportedCapacity = capacity
    }

    var capacity: RenderSinkCapacity {
        counter.capacityReads += 1
        return reportedCapacity
    }

    mutating func begin(_ header: RenderPlanHeader) -> Bool {
        counter.operationCalls += 1
        return true
    }

    mutating func fillRect(_ operation: FillRectOperation) -> Bool {
        counter.operationCalls += 1
        return true
    }

    mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool {
        counter.operationCalls += 1
        return true
    }

    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
        counter.operationCalls += 1
        return true
    }

    mutating func endPositionedGlyphs() -> Bool {
        counter.operationCalls += 1
        return true
    }

    mutating func finish() -> Bool {
        counter.operationCalls += 1
        return true
    }

    mutating func discard() {
        counter.operationCalls += 1
    }
}

private final class SnapshotReadCounter {
    var reads: UInt32 = 0
}

private struct LateChangingSnapshotSemanticView: SemanticRenderView {
    let base: DirectSemanticRenderView
    let counter = SnapshotReadCounter()

    var rootIdentity: RenderFixtureIdentity { base.rootIdentity }
    var semanticScopeCount: UInt16 { base.semanticScopeCount }
    var renderSnapshotVersion: UInt32 {
        counter.reads += 1
        return counter.reads <= 3 ? 1 : 2
    }

    func semanticIdentity(at ordinal: UInt16) -> RenderFixtureIdentity? {
        base.semanticIdentity(at: ordinal)
    }

    func semanticOrdinal(of identity: RenderFixtureIdentity) -> UInt16? {
        base.semanticOrdinal(of: identity)
    }

    func scope(at identity: RenderFixtureIdentity) -> SemanticRenderScope? {
        base.scope(at: identity)
    }

    func layoutIdentity(
        for identity: RenderFixtureIdentity
    ) -> RenderFixtureIdentity? {
        base.layoutIdentity(for: identity)
    }

    func childCount(of identity: RenderFixtureIdentity) -> UInt16? {
        base.childCount(of: identity)
    }

    func child(
        of identity: RenderFixtureIdentity,
        at index: UInt16
    ) -> RenderFixtureIdentity? {
        base.child(of: identity, at: index)
    }
}

private enum StreamingEvent: Equatable {
    case begin(RenderPlanHeader)
    case fill(FillRectOperation)
    case beginGlyphs(PositionedGlyphOperationHeader)
    case glyph(PositionedGlyph)
    case endGlyphs
    case finish
}

private final class StreamingSinkCounter {
    var capacityReads: UInt16 = 0
}

private struct StreamingSink: RenderOperationSink {
    let reportedCapacity = RenderSinkCapacity(
        maximumOperations: .max,
        maximumPositionedGlyphs: .max
    )
    let refuseAtOperationCall: UInt16?
    private let counter = StreamingSinkCounter()
    private(set) var operationCallCount: UInt16 = 0
    private(set) var discardCount: UInt16 = 0
    private(set) var events: [StreamingEvent] = []

    init(refuseAtOperationCall: UInt16? = nil) {
        self.refuseAtOperationCall = refuseAtOperationCall
    }

    var capacityReads: UInt16 { counter.capacityReads }

    var capacity: RenderSinkCapacity {
        counter.capacityReads += 1
        return reportedCapacity
    }

    mutating func begin(_ header: RenderPlanHeader) -> Bool {
        record(.begin(header))
    }

    mutating func fillRect(_ operation: FillRectOperation) -> Bool {
        record(.fill(operation))
    }

    mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool {
        record(.beginGlyphs(operation))
    }

    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
        record(.glyph(glyph))
    }

    mutating func endPositionedGlyphs() -> Bool {
        record(.endGlyphs)
    }

    mutating func finish() -> Bool {
        record(.finish)
    }

    mutating func discard() {
        discardCount += 1
        events.removeAll(keepingCapacity: true)
    }

    private mutating func record(_ event: StreamingEvent) -> Bool {
        operationCallCount += 1
        guard operationCallCount != refuseAtOperationCall else { return false }
        events.append(event)
        return true
    }
}

private struct ChangingSnapshotSemanticView: SemanticRenderView {
    let base: DirectSemanticRenderView
    let counter = SnapshotReadCounter()

    var rootIdentity: RenderFixtureIdentity { base.rootIdentity }
    var semanticScopeCount: UInt16 { base.semanticScopeCount }
    var renderSnapshotVersion: UInt32 {
        counter.reads += 1
        return counter.reads
    }

    func semanticIdentity(at ordinal: UInt16) -> RenderFixtureIdentity? {
        base.semanticIdentity(at: ordinal)
    }

    func semanticOrdinal(of identity: RenderFixtureIdentity) -> UInt16? {
        base.semanticOrdinal(of: identity)
    }

    func scope(at identity: RenderFixtureIdentity) -> SemanticRenderScope? {
        base.scope(at: identity)
    }

    func layoutIdentity(
        for identity: RenderFixtureIdentity
    ) -> RenderFixtureIdentity? {
        base.layoutIdentity(for: identity)
    }

    func childCount(of identity: RenderFixtureIdentity) -> UInt16? {
        base.childCount(of: identity)
    }

    func child(
        of identity: RenderFixtureIdentity,
        at index: UInt16
    ) -> RenderFixtureIdentity? {
        base.child(of: identity, at: index)
    }
}

private struct PreflightMetrics: CanonicalTextMetricsView {
    let descriptor: TextResourceDescriptor
    private let fontInstance: FontInstanceDescriptor

    init(resourceWord: UInt32 = 1) {
        let resource = FontResourceID(
            rawValue: TextResourceDigest(
                word0: resourceWord,
                word1: 2,
                word2: 3,
                word3: 4,
                word4: 5,
                word5: 6,
                word6: 7,
                word7: 8
            )
        )
        descriptor = TextResourceDescriptor(
            schemaVersion: 1,
            resource: resource,
            instanceCount: 1,
            realizationCount: 0,
            canonicalManifestByteCount: 0
        )
        fontInstance = FontInstanceDescriptor(
            id: FontInstanceID(resource: resource, instanceIndex: 0),
            lineMetrics: FontLineMetrics(ascent: 8, descent: 2, lineGap: 0),
            replacementGlyph: GlyphID(rawValue: 0),
            glyphCount: 3,
            mappingCount: 0
        )
    }

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        index == 0 ? fontInstance : nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }

    func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        guard instance == fontInstance.id,
            glyph.rawValue < fontInstance.glyphCount
        else {
            return nil
        }
        return GlyphMetrics(
            advanceX: 4,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 1, height: 1)!
        )
    }
}
