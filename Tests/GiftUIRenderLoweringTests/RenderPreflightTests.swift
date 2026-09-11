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
func everyDirectSemanticAndLayoutMismatchFailsBeforeBegin() {
    let validSemantic = DirectRenderFixtures.validSemantic
    let validLayout = DirectRenderFixtures.validLayout
    let semanticMismatches = [
        replacingSemanticRecord(in: validSemantic, identity: .text) { record in
            SemanticFixtureRecord(
                identity: record.identity, scope: nil, layoutIdentity: record.layoutIdentity,
                children: record.children)
        },
        DirectSemanticRenderView(
            rootIdentity: validSemantic.rootIdentity,
            semanticScopeCount: validSemantic.semanticScopeCount, renderSnapshotVersion: 1,
            records: validSemantic.records + [validSemantic.records.last!]),
        replacingSemanticChildren(of: .foreground, with: [], in: validSemantic),
        replacingSemanticChildren(of: .text, with: [.alternate], in: validSemantic),
        replacingSemanticRecord(in: validSemantic, identity: .transparent) { record in
            SemanticFixtureRecord(
                identity: record.identity, scope: record.scope, layoutIdentity: nil,
                children: record.children)
        },
        DirectSemanticRenderView(
            rootIdentity: validSemantic.rootIdentity, semanticScopeCount: 4,
            renderSnapshotVersion: 1, records: validSemantic.records),
        DirectSemanticRenderView(
            rootIdentity: validSemantic.rootIdentity, semanticScopeCount: 6,
            renderSnapshotVersion: 1, records: validSemantic.records),
    ]
    let validText = validLayout.records.first { $0.identity == .text }!
    let validLine = validText.lines[0]!
    let validGlyph = validText.glyphs[0]!
    let layoutMismatches = [
        DirectResolvedRenderLayoutView(
            rootIdentity: validLayout.rootIdentity, layoutScopeCount: 2, renderSnapshotVersion: 1,
            rootBounds: validLayout.rootBounds, records: validLayout.records + [validText]),
        replacingTextRecord(in: validLayout) {
            LayoutFixtureRecord(
                identity: $0.identity, bounds: nil, clip: $0.clip, lines: $0.lines,
                glyphs: $0.glyphs)
        },
        replacingTextRecord(in: validLayout) {
            LayoutFixtureRecord(
                identity: $0.identity, bounds: $0.bounds, clip: nil, lines: $0.lines,
                glyphs: $0.glyphs)
        },
        replacingTextRecord(in: validLayout) {
            LayoutFixtureRecord(
                identity: $0.identity, bounds: $0.bounds, clip: $0.clip, lines: [nil],
                glyphs: $0.glyphs)
        },
        replacingTextRecord(in: validLayout) {
            LayoutFixtureRecord(
                identity: $0.identity, bounds: $0.bounds, clip: $0.clip, lines: $0.lines,
                glyphs: [nil, $0.glyphs[1]])
        },
        replacingTextRecord(in: validLayout) {
            LayoutFixtureRecord(
                identity: $0.identity, bounds: $0.bounds, clip: $0.clip,
                lines: [
                    ResolvedRenderTextLine(
                        lineIndex: 1, bounds: validLine.bounds, baseline: validLine.baseline,
                        clip: validLine.clip, glyphCount: validLine.glyphCount)
                ], glyphs: $0.glyphs)
        },
        replacingTextRecord(in: validLayout) {
            LayoutFixtureRecord(
                identity: $0.identity, bounds: $0.bounds, clip: $0.clip, lines: $0.lines,
                glyphs: [
                    ResolvedRenderGlyph(
                        lineIndex: 1, glyphIndex: 0, instance: validGlyph.instance,
                        glyph: validGlyph.glyph, baseline: validGlyph.baseline,
                        clip: validGlyph.clip), $0.glyphs[1],
                ])
        },
        replacingTextRecord(in: validLayout) {
            LayoutFixtureRecord(
                identity: $0.identity, bounds: $0.bounds, clip: $0.clip, lines: $0.lines,
                glyphs: [
                    ResolvedRenderGlyph(
                        lineIndex: 0, glyphIndex: 1, instance: validGlyph.instance,
                        glyph: validGlyph.glyph, baseline: validGlyph.baseline,
                        clip: validGlyph.clip), $0.glyphs[1],
                ])
        },
        DirectResolvedRenderLayoutView(
            rootIdentity: validLayout.rootIdentity, layoutScopeCount: 1, renderSnapshotVersion: 1,
            rootBounds: validLayout.rootBounds, records: validLayout.records),
        DirectResolvedRenderLayoutView(
            rootIdentity: validLayout.rootIdentity, layoutScopeCount: 3, renderSnapshotVersion: 1,
            rootBounds: validLayout.rootBounds, records: validLayout.records),
    ]
    let structure = RenderWorkspaceCapacity(
        maximumSemanticScopes: 6, maximumLayoutScopes: 3, maximumTraversalDepth: 6,
        maximumTextLines: 2)!

    for semantic in semanticMismatches {
        var workspace = PreflightWorkspace<RenderFixtureIdentity>(structuralCapacity: structure)
        var sink = StreamingSink()
        let result = RenderProducer.produce(
            semantic: semantic, layout: validLayout, textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds, damageMode: .rootIntersection,
            rootForeground: .white, limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &workspace, sink: &sink)
        #expect(result == .failure(.invariantViolation))
        #expect(sink.operationCallCount == 0)
        #expect(sink.discardCount == 0)
        #expect(workspace.resetCount == 1)
    }
    for layout in layoutMismatches {
        var workspace = PreflightWorkspace<RenderFixtureIdentity>(structuralCapacity: structure)
        var sink = StreamingSink()
        let result = RenderProducer.produce(
            semantic: validSemantic, layout: layout, textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds, damageMode: .rootIntersection,
            rootForeground: .white, limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &workspace, sink: &sink)
        #expect(result == .failure(.invariantViolation))
        #expect(sink.operationCallCount == 0)
        #expect(sink.discardCount == 0)
        #expect(workspace.resetCount == 1)
    }
}

@Test
func everyIndependentRenderAndStructuralCapacityFailsOneOverBeforeBegin() {
    let defaultLimits = PreflightWorkspace<RenderFixtureIdentity>.limits
    let defaultStructure = PreflightWorkspace<RenderFixtureIdentity>.structure
    let defaultSink = RenderSinkCapacity(maximumOperations: 2, maximumPositionedGlyphs: 2)
    let original = DirectRenderFixtures.validLayout
    let twoLineLayout = replacingTextRecord(in: original) { record in
        let first = record.glyphs[0]!
        let second = record.glyphs[1]!
        return LayoutFixtureRecord(
            identity: record.identity,
            bounds: record.bounds,
            clip: record.clip,
            lines: [
                ResolvedRenderTextLine(
                    lineIndex: 0, bounds: record.bounds!, baseline: first.baseline,
                    clip: record.clip!, glyphCount: 1),
                ResolvedRenderTextLine(
                    lineIndex: 1, bounds: record.bounds!, baseline: second.baseline,
                    clip: record.clip!, glyphCount: 1),
            ],
            glyphs: [
                ResolvedRenderGlyph(
                    lineIndex: 0, glyphIndex: 0, instance: first.instance, glyph: first.glyph,
                    baseline: first.baseline, clip: first.clip),
                ResolvedRenderGlyph(
                    lineIndex: 1, glyphIndex: 1, instance: second.instance, glyph: second.glyph,
                    baseline: second.baseline, clip: second.clip),
            ]
        )
    }
    let cases:
        [(
            RenderLimits, RenderLimits, RenderWorkspaceCapacity, RenderSinkCapacity,
            DirectResolvedRenderLayoutView
        )] = [
            (
                RenderLimits(
                    maximumOperations: 1, maximumPositionedGlyphs: 2, maximumClipDepth: 2)!,
                defaultLimits, defaultStructure, defaultSink, original
            ),
            (
                RenderLimits(
                    maximumOperations: 2, maximumPositionedGlyphs: 1, maximumClipDepth: 2)!,
                defaultLimits, defaultStructure, defaultSink, original
            ),
            (
                RenderLimits(
                    maximumOperations: 2, maximumPositionedGlyphs: 2, maximumClipDepth: 1)!,
                defaultLimits, defaultStructure, defaultSink, original
            ),
            (
                defaultLimits,
                RenderLimits(
                    maximumOperations: 1, maximumPositionedGlyphs: 2, maximumClipDepth: 2)!,
                defaultStructure, defaultSink, original
            ),
            (
                defaultLimits, defaultLimits,
                RenderWorkspaceCapacity(
                    maximumSemanticScopes: 5, maximumLayoutScopes: 1, maximumTraversalDepth: 5,
                    maximumTextLines: 1)!, defaultSink, original
            ),
            (
                defaultLimits, defaultLimits,
                RenderWorkspaceCapacity(
                    maximumSemanticScopes: 5, maximumLayoutScopes: 2, maximumTraversalDepth: 5,
                    maximumTextLines: 1)!, defaultSink, twoLineLayout
            ),
            (
                defaultLimits, defaultLimits, defaultStructure,
                RenderSinkCapacity(maximumOperations: 2, maximumPositionedGlyphs: 1), original
            ),
        ]

    for (limits, capacity, structure, sinkCapacity, layout) in cases {
        var workspace = PreflightWorkspace<RenderFixtureIdentity>(
            capacity: capacity, structuralCapacity: structure)
        var sink = StreamingSink(capacity: sinkCapacity)
        let result = RenderProducer.produce(
            semantic: DirectRenderFixtures.validSemantic,
            layout: layout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            rootForeground: .white,
            limits: limits,
            workspace: &workspace,
            sink: &sink
        )
        #expect(result == .failure(.capacityExhausted))
        #expect(sink.operationCallCount == 0)
        #expect(sink.discardCount == 0)
        #expect(workspace.resetCount == 1)
    }
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
        workspace: &workspace,
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
func foregroundStackUsesInnermostColorRestoresSiblingsAndOrdersNestedBackgrounds() {
    let bounds = DirectRenderFixtures.bounds
    let instance = DirectRenderFixtures.instance
    let semantic = DirectSemanticRenderView(
        rootIdentity: .root,
        semanticScopeCount: 7,
        renderSnapshotVersion: 1,
        records: [
            SemanticFixtureRecord(
                identity: .root,
                scope: .structural,
                layoutIdentity: .root,
                children: [.outerForeground, .secondText]
            ),
            SemanticFixtureRecord(
                identity: .outerForeground,
                scope: .foregroundStyle(.green),
                layoutIdentity: .outerForeground,
                children: [.outerBackground]
            ),
            SemanticFixtureRecord(
                identity: .outerBackground,
                scope: .background(.blue),
                layoutIdentity: .outerBackground,
                children: [.innerForeground]
            ),
            SemanticFixtureRecord(
                identity: .innerForeground,
                scope: .foregroundStyle(.red),
                layoutIdentity: .innerForeground,
                children: [.innerBackground]
            ),
            SemanticFixtureRecord(
                identity: .innerBackground,
                scope: .background(.gray),
                layoutIdentity: .innerBackground,
                children: [.firstText]
            ),
            SemanticFixtureRecord(
                identity: .firstText,
                scope: .text,
                layoutIdentity: .firstText,
                children: []
            ),
            SemanticFixtureRecord(
                identity: .secondText,
                scope: .text,
                layoutIdentity: .secondText,
                children: []
            ),
        ]
    )
    let emptyRecord: (RenderFixtureIdentity) -> LayoutFixtureRecord = { identity in
        LayoutFixtureRecord(
            identity: identity,
            bounds: bounds,
            clip: bounds,
            lines: [],
            glyphs: []
        )
    }
    let textRecord: (RenderFixtureIdentity, GlyphID, Point) -> LayoutFixtureRecord = {
        identity, glyph, baseline in
        LayoutFixtureRecord(
            identity: identity,
            bounds: bounds,
            clip: bounds,
            lines: [
                ResolvedRenderTextLine(
                    lineIndex: 0,
                    bounds: bounds,
                    baseline: baseline,
                    clip: bounds,
                    glyphCount: 1
                )
            ],
            glyphs: [
                ResolvedRenderGlyph(
                    lineIndex: 0,
                    glyphIndex: 0,
                    instance: instance,
                    glyph: glyph,
                    baseline: baseline,
                    clip: bounds
                )
            ]
        )
    }
    let firstBaseline = Point(x: 2, y: 8)
    let secondBaseline = Point(x: 20, y: 8)
    let layout = DirectResolvedRenderLayoutView(
        rootIdentity: .root,
        layoutScopeCount: 7,
        renderSnapshotVersion: 1,
        rootBounds: bounds,
        records: [
            emptyRecord(.root),
            emptyRecord(.outerForeground),
            emptyRecord(.outerBackground),
            emptyRecord(.innerForeground),
            emptyRecord(.innerBackground),
            textRecord(.firstText, GlyphID(rawValue: 1), firstBaseline),
            textRecord(.secondText, GlyphID(rawValue: 2), secondBaseline),
        ]
    )
    let limits = RenderLimits(
        maximumOperations: 4,
        maximumPositionedGlyphs: 2,
        maximumClipDepth: 2
    )!
    let structure = RenderWorkspaceCapacity(
        maximumSemanticScopes: 7,
        maximumLayoutScopes: 7,
        maximumTraversalDepth: 6,
        maximumTextLines: 2
    )!
    var workspace = PreflightWorkspace<RenderFixtureIdentity>(
        capacity: limits,
        structuralCapacity: structure
    )
    var sink = StreamingSink()

    let result = RenderProducer.produce(
        semantic: semantic,
        layout: layout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: limits,
        workspace: &workspace,
        sink: &sink
    )
    guard case .success(let header) = result else {
        Issue.record("expected nested style lowering to succeed")
        return
    }

    #expect(workspace.foregroundHighWater == 3)
    #expect(workspace.currentForeground == nil)
    #expect(
        sink.events == [
            .begin(header),
            .fill(FillRectOperation(bounds: bounds, clip: bounds, color: .blue)),
            .fill(FillRectOperation(bounds: bounds, clip: bounds, color: .gray)),
            .beginGlyphs(
                PositionedGlyphOperationHeader(
                    instance: instance,
                    clip: bounds,
                    color: .red,
                    glyphCount: 1
                )
            ),
            .glyph(PositionedGlyph(glyph: GlyphID(rawValue: 1), baseline: firstBaseline)),
            .endGlyphs,
            .beginGlyphs(
                PositionedGlyphOperationHeader(
                    instance: instance,
                    clip: bounds,
                    color: .white,
                    glyphCount: 1
                )
            ),
            .glyph(PositionedGlyph(glyph: GlyphID(rawValue: 2), baseline: secondBaseline)),
            .endGlyphs,
            .finish,
        ]
    )
}

@Test
func sourceOrderChildrenPaintBackToFrontWithoutOpaqueEliminationAndLinesStayGrouped() {
    let bounds = DirectRenderFixtures.bounds
    let instance = DirectRenderFixtures.instance
    let semantic = DirectSemanticRenderView(
        rootIdentity: .root,
        semanticScopeCount: 6,
        renderSnapshotVersion: 1,
        records: [
            SemanticFixtureRecord(
                identity: .root,
                scope: .structural,
                layoutIdentity: .root,
                children: [.background, .text, .foreground]
            ),
            SemanticFixtureRecord(
                identity: .background,
                scope: .background(.green),
                layoutIdentity: .background,
                children: [.transparent]
            ),
            SemanticFixtureRecord(
                identity: .transparent,
                scope: .structural,
                layoutIdentity: .transparent,
                children: []
            ),
            SemanticFixtureRecord(
                identity: .text,
                scope: .text,
                layoutIdentity: .text,
                children: []
            ),
            SemanticFixtureRecord(
                identity: .foreground,
                scope: .background(.blue),
                layoutIdentity: .foreground,
                children: [.alternate]
            ),
            SemanticFixtureRecord(
                identity: .alternate,
                scope: .structural,
                layoutIdentity: .alternate,
                children: []
            ),
        ]
    )
    let emptyLineBounds = Rect(
        origin: Point(x: 0, y: 10),
        size: Size(width: 0, height: 0)!
    )!
    let layout = DirectResolvedRenderLayoutView(
        rootIdentity: .root,
        layoutScopeCount: 6,
        renderSnapshotVersion: 1,
        rootBounds: bounds,
        records: [
            LayoutFixtureRecord(
                identity: .root,
                bounds: bounds,
                clip: bounds,
                lines: [],
                glyphs: []
            ),
            LayoutFixtureRecord(
                identity: .background,
                bounds: bounds,
                clip: bounds,
                lines: [],
                glyphs: []
            ),
            LayoutFixtureRecord(
                identity: .transparent,
                bounds: bounds,
                clip: bounds,
                lines: [],
                glyphs: []
            ),
            LayoutFixtureRecord(
                identity: .text,
                bounds: bounds,
                clip: bounds,
                lines: [
                    ResolvedRenderTextLine(
                        lineIndex: 0,
                        bounds: bounds,
                        baseline: Point(x: 1, y: 8),
                        clip: bounds,
                        glyphCount: 2
                    ),
                    ResolvedRenderTextLine(
                        lineIndex: 1,
                        bounds: emptyLineBounds,
                        baseline: Point(x: 1, y: 12),
                        clip: bounds,
                        glyphCount: 0
                    ),
                    ResolvedRenderTextLine(
                        lineIndex: 2,
                        bounds: bounds,
                        baseline: Point(x: 1, y: 16),
                        clip: bounds,
                        glyphCount: 1
                    ),
                ],
                glyphs: [
                    ResolvedRenderGlyph(
                        lineIndex: 0,
                        glyphIndex: 0,
                        instance: instance,
                        glyph: GlyphID(rawValue: 0),
                        baseline: Point(x: 1, y: 8),
                        clip: bounds
                    ),
                    ResolvedRenderGlyph(
                        lineIndex: 0,
                        glyphIndex: 1,
                        instance: instance,
                        glyph: GlyphID(rawValue: 1),
                        baseline: Point(x: 5, y: 8),
                        clip: bounds
                    ),
                    ResolvedRenderGlyph(
                        lineIndex: 2,
                        glyphIndex: 2,
                        instance: instance,
                        glyph: GlyphID(rawValue: 2),
                        baseline: Point(x: 1, y: 16),
                        clip: bounds
                    ),
                ]
            ),
            LayoutFixtureRecord(
                identity: .foreground,
                bounds: bounds,
                clip: bounds,
                lines: [],
                glyphs: []
            ),
            LayoutFixtureRecord(
                identity: .alternate,
                bounds: bounds,
                clip: bounds,
                lines: [],
                glyphs: []
            ),
        ]
    )
    let limits = RenderLimits(
        maximumOperations: 4,
        maximumPositionedGlyphs: 3,
        maximumClipDepth: 2
    )!
    let structure = RenderWorkspaceCapacity(
        maximumSemanticScopes: 6,
        maximumLayoutScopes: 6,
        maximumTraversalDepth: 3,
        maximumTextLines: 3
    )!
    var workspace = PreflightWorkspace<RenderFixtureIdentity>(
        capacity: limits,
        structuralCapacity: structure
    )
    var sink = StreamingSink()

    let result = RenderProducer.produce(
        semantic: semantic,
        layout: layout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: limits,
        workspace: &workspace,
        sink: &sink
    )
    let header = RenderPlanHeader(
        surfaceBounds: bounds,
        damageBounds: bounds,
        operationCount: 4,
        positionedGlyphCount: 3,
        maximumObservedClipDepth: 2
    )

    #expect(result == .success(header))
    #expect(
        sink.events == [
            .begin(header),
            .fill(FillRectOperation(bounds: bounds, clip: bounds, color: .green)),
            .beginGlyphs(
                PositionedGlyphOperationHeader(
                    instance: instance,
                    clip: bounds,
                    color: .white,
                    glyphCount: 2
                )
            ),
            .glyph(PositionedGlyph(glyph: GlyphID(rawValue: 0), baseline: Point(x: 1, y: 8))),
            .glyph(PositionedGlyph(glyph: GlyphID(rawValue: 1), baseline: Point(x: 5, y: 8))),
            .endGlyphs,
            .beginGlyphs(
                PositionedGlyphOperationHeader(
                    instance: instance,
                    clip: bounds,
                    color: .white,
                    glyphCount: 1
                )
            ),
            .glyph(PositionedGlyph(glyph: GlyphID(rawValue: 2), baseline: Point(x: 1, y: 16))),
            .endGlyphs,
            .fill(FillRectOperation(bounds: bounds, clip: bounds, color: .blue)),
            .finish,
        ]
    )
}

@Test
func textLoweringPreservesResolvedGlyphMeaningAndOnlyIntersectsItsClip() {
    let semantic = DirectRenderFixtures.validSemantic
    let original = DirectRenderFixtures.validLayout
    let partialClip = Rect(
        origin: Point(x: 8, y: 3),
        size: Size(width: 20, height: 10)!
    )!
    let firstBaseline = Point(x: 9, y: 7)
    let secondBaseline = Point(x: 17, y: 11)
    let layout = replacingTextRecord(in: original) { record in
        LayoutFixtureRecord(
            identity: record.identity,
            bounds: record.bounds,
            clip: partialClip,
            lines: [
                ResolvedRenderTextLine(
                    lineIndex: 0,
                    bounds: record.bounds!,
                    baseline: firstBaseline,
                    clip: partialClip,
                    glyphCount: 2
                )
            ],
            glyphs: [
                ResolvedRenderGlyph(
                    lineIndex: 0,
                    glyphIndex: 0,
                    instance: DirectRenderFixtures.instance,
                    glyph: GlyphID(rawValue: 1),
                    baseline: firstBaseline,
                    clip: partialClip
                ),
                ResolvedRenderGlyph(
                    lineIndex: 0,
                    glyphIndex: 1,
                    instance: DirectRenderFixtures.instance,
                    glyph: GlyphID(rawValue: 2),
                    baseline: secondBaseline,
                    clip: partialClip
                ),
            ]
        )
    }
    var workspace = PreflightWorkspace<RenderFixtureIdentity>()
    var sink = StreamingSink()

    let result = RenderProducer.produce(
        semantic: semantic,
        layout: layout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &workspace,
        sink: &sink
    )

    guard case .success(let header) = result else {
        Issue.record("expected exact text lowering to succeed")
        return
    }
    #expect(
        sink.events == [
            .begin(header),
            .fill(
                FillRectOperation(
                    bounds: DirectRenderFixtures.bounds,
                    clip: partialClip,
                    color: .blue
                )
            ),
            .beginGlyphs(
                PositionedGlyphOperationHeader(
                    instance: DirectRenderFixtures.instance,
                    clip: partialClip,
                    color: .red,
                    glyphCount: 2
                )
            ),
            .glyph(PositionedGlyph(glyph: GlyphID(rawValue: 1), baseline: firstBaseline)),
            .glyph(PositionedGlyph(glyph: GlyphID(rawValue: 2), baseline: secondBaseline)),
            .endGlyphs,
            .finish,
        ]
    )
}

@Test
func textResourceInstanceAndGlyphDisagreementsAllFailBeforeBegin() {
    let original = DirectRenderFixtures.validLayout
    let validGlyphs = original.records.first { $0.identity == .text }!.glyphs
    let incompatibleInstance = FontInstanceID(
        resource: DirectRenderFixtures.instance.resource,
        instanceIndex: 1
    )
    let incompatibleLayouts = [
        replacingTextRecord(in: original) { record in
            LayoutFixtureRecord(
                identity: record.identity,
                bounds: record.bounds,
                clip: record.clip,
                lines: record.lines,
                glyphs: validGlyphs.map { glyph in
                    glyph.map {
                        ResolvedRenderGlyph(
                            lineIndex: $0.lineIndex,
                            glyphIndex: $0.glyphIndex,
                            instance: incompatibleInstance,
                            glyph: $0.glyph,
                            baseline: $0.baseline,
                            clip: $0.clip
                        )
                    }
                }
            )
        },
        replacingTextRecord(in: original) { record in
            var glyphs = validGlyphs
            let first = glyphs[0]!
            glyphs[0] = ResolvedRenderGlyph(
                lineIndex: first.lineIndex,
                glyphIndex: first.glyphIndex,
                instance: first.instance,
                glyph: GlyphID(rawValue: 3),
                baseline: first.baseline,
                clip: first.clip
            )
            return LayoutFixtureRecord(
                identity: record.identity,
                bounds: record.bounds,
                clip: record.clip,
                lines: record.lines,
                glyphs: glyphs
            )
        },
    ]

    for layout in incompatibleLayouts {
        var workspace = PreflightWorkspace<RenderFixtureIdentity>()
        var sink = StreamingSink()
        let result = RenderProducer.produce(
            semantic: DirectRenderFixtures.validSemantic,
            layout: layout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            rootForeground: .white,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &workspace,
            sink: &sink
        )
        #expect(result == .failure(.incompatibleTextResource))
        #expect(sink.operationCallCount == 0)
        #expect(sink.capacityReads == 0)
    }

    var resourceWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    var resourceSink = StreamingSink()
    let resourceResult = RenderProducer.produce(
        semantic: DirectRenderFixtures.validSemantic,
        layout: original,
        textMetrics: PreflightMetrics(resourceWord: 99),
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &resourceWorkspace,
        sink: &resourceSink
    )
    #expect(resourceResult == .failure(.incompatibleTextResource))
    #expect(resourceSink.operationCallCount == 0)
    #expect(resourceSink.capacityReads == 0)
}

private func replacingTextRecord(
    in layout: DirectResolvedRenderLayoutView,
    transform: (LayoutFixtureRecord) -> LayoutFixtureRecord
) -> DirectResolvedRenderLayoutView {
    DirectResolvedRenderLayoutView(
        rootIdentity: layout.rootIdentity,
        layoutScopeCount: layout.layoutScopeCount,
        renderSnapshotVersion: layout.renderSnapshotVersion,
        rootBounds: layout.rootBounds,
        records: layout.records.map { record in
            record.identity == .text ? transform(record) : record
        }
    )
}

private func replacingSemanticRecord(
    in semantic: DirectSemanticRenderView,
    identity: RenderFixtureIdentity,
    transform: (SemanticFixtureRecord) -> SemanticFixtureRecord
) -> DirectSemanticRenderView {
    DirectSemanticRenderView(
        rootIdentity: semantic.rootIdentity,
        semanticScopeCount: semantic.semanticScopeCount,
        renderSnapshotVersion: semantic.renderSnapshotVersion,
        records: semantic.records.map { $0.identity == identity ? transform($0) : $0 }
    )
}

private func replacingSemanticChildren(
    of identity: RenderFixtureIdentity,
    with children: [RenderFixtureIdentity],
    in semantic: DirectSemanticRenderView
) -> DirectSemanticRenderView {
    replacingSemanticRecord(in: semantic, identity: identity) { record in
        SemanticFixtureRecord(
            identity: record.identity,
            scope: record.scope,
            layoutIdentity: record.layoutIdentity,
            children: children
        )
    }
}

@Test
func backgroundKeepsUnclippedBoundsAndOmitsOnlyAnEmptyFinalClip() {
    let surface = DirectRenderFixtures.bounds
    let rootBounds = Rect(
        origin: Point(x: -10, y: -5),
        size: Size(width: 60, height: 30)!
    )!
    let partialClip = Rect(
        origin: Point(x: 30, y: 10),
        size: Size(width: 20, height: 20)!
    )!
    let finalClip = Rect(
        origin: Point(x: 30, y: 10),
        size: Size(width: 10, height: 10)!
    )!
    let semantic = backgroundSemanticFixture()
    let partialLayout = backgroundLayoutFixture(
        rootBounds: rootBounds,
        logicalClip: partialClip
    )
    var partialWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    var partialSink = StreamingSink()

    let partialResult = RenderProducer.produce(
        semantic: semantic,
        layout: partialLayout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: surface,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &partialWorkspace,
        sink: &partialSink
    )
    guard case .success(let partialHeader) = partialResult else {
        Issue.record("expected partial background clip to succeed")
        return
    }
    #expect(partialHeader.damageBounds == surface)
    #expect(partialHeader.operationCount == 1)
    #expect(
        partialSink.events == [
            .begin(partialHeader),
            .fill(FillRectOperation(bounds: rootBounds, clip: finalClip, color: .green)),
            .finish,
        ]
    )

    let offSurfaceClip = Rect(
        origin: Point(x: 50, y: 50),
        size: Size(width: 10, height: 10)!
    )!
    var emptyWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    var emptySink = StreamingSink()
    let emptyResult = RenderProducer.produce(
        semantic: semantic,
        layout: backgroundLayoutFixture(
            rootBounds: rootBounds,
            logicalClip: offSurfaceClip
        ),
        textMetrics: PreflightMetrics(),
        surfaceBounds: surface,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &emptyWorkspace,
        sink: &emptySink
    )
    guard case .success(let emptyHeader) = emptyResult else {
        Issue.record("expected empty final clip to succeed")
        return
    }
    #expect(emptyHeader.operationCount == 0)
    #expect(emptySink.events == [.begin(emptyHeader), .finish])
}

@Test
func offSurfaceAndZeroAreaBackgroundsAreBothOmitted() {
    let surface = DirectRenderFixtures.bounds
    let rootRecord = LayoutFixtureRecord(
        identity: .root,
        bounds: surface,
        clip: surface,
        lines: [],
        glyphs: []
    )
    let offSurfaceBounds = Rect(
        origin: Point(x: -10, y: -5),
        size: Size(width: 60, height: 30)!
    )!
    let offSurfaceClip = Rect(
        origin: Point(x: 50, y: 50),
        size: Size(width: 10, height: 10)!
    )!
    let zeroAreaBounds = Rect(
        origin: Point(x: 5, y: 5),
        size: Size(width: 0, height: 10)!
    )!
    let semantic = DirectSemanticRenderView(
        rootIdentity: .root,
        semanticScopeCount: 5,
        renderSnapshotVersion: 1,
        records: [
            SemanticFixtureRecord(
                identity: .root,
                scope: .structural,
                layoutIdentity: .root,
                children: [.background, .foreground]
            ),
            SemanticFixtureRecord(
                identity: .background,
                scope: .background(.green),
                layoutIdentity: .background,
                children: [.transparent]
            ),
            SemanticFixtureRecord(
                identity: .transparent,
                scope: .structural,
                layoutIdentity: .transparent,
                children: []
            ),
            SemanticFixtureRecord(
                identity: .foreground,
                scope: .background(.blue),
                layoutIdentity: .foreground,
                children: [.alternate]
            ),
            SemanticFixtureRecord(
                identity: .alternate,
                scope: .structural,
                layoutIdentity: .alternate,
                children: []
            ),
        ]
    )
    let layout = DirectResolvedRenderLayoutView(
        rootIdentity: .root,
        layoutScopeCount: 5,
        renderSnapshotVersion: 1,
        rootBounds: surface,
        records: [
            rootRecord,
            LayoutFixtureRecord(
                identity: .background,
                bounds: offSurfaceBounds,
                clip: offSurfaceClip,
                lines: [],
                glyphs: []
            ),
            LayoutFixtureRecord(
                identity: .transparent,
                bounds: offSurfaceBounds,
                clip: offSurfaceClip,
                lines: [],
                glyphs: []
            ),
            LayoutFixtureRecord(
                identity: .foreground,
                bounds: zeroAreaBounds,
                clip: surface,
                lines: [],
                glyphs: []
            ),
            LayoutFixtureRecord(
                identity: .alternate,
                bounds: zeroAreaBounds,
                clip: surface,
                lines: [],
                glyphs: []
            ),
        ]
    )
    let structure = RenderWorkspaceCapacity(
        maximumSemanticScopes: 5,
        maximumLayoutScopes: 5,
        maximumTraversalDepth: 3,
        maximumTextLines: 1
    )!
    var workspace = PreflightWorkspace<RenderFixtureIdentity>(
        structuralCapacity: structure
    )
    var sink = StreamingSink()

    let result = RenderProducer.produce(
        semantic: semantic,
        layout: layout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: surface,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &workspace,
        sink: &sink
    )
    let header = RenderPlanHeader(
        surfaceBounds: surface,
        damageBounds: surface,
        operationCount: 0,
        positionedGlyphCount: 0,
        maximumObservedClipDepth: 1
    )

    #expect(result == .success(header))
    #expect(sink.events == [.begin(header), .finish])
}

@Test
func damageModeIsExplicitAndRetainsNoFirstFrameHistory() {
    let surface = DirectRenderFixtures.bounds
    let rootBounds = Rect(
        origin: Point(x: 5, y: 4),
        size: Size(width: 10, height: 6)!
    )!
    let semantic = DirectSemanticRenderView(
        rootIdentity: .root,
        semanticScopeCount: 1,
        renderSnapshotVersion: 1,
        records: [
            SemanticFixtureRecord(
                identity: .root,
                scope: .structural,
                layoutIdentity: .root,
                children: []
            )
        ]
    )
    let layout = DirectResolvedRenderLayoutView(
        rootIdentity: .root,
        layoutScopeCount: 1,
        renderSnapshotVersion: 1,
        rootBounds: rootBounds,
        records: [
            LayoutFixtureRecord(
                identity: .root,
                bounds: rootBounds,
                clip: rootBounds,
                lines: [],
                glyphs: []
            )
        ]
    )

    let modes: [(RenderDamageMode, Rect)] = [
        (.initializeCompleteSurface, surface),
        (.rootIntersection, rootBounds),
        (.initializeCompleteSurface, surface),
    ]
    for (mode, expectedDamage) in modes {
        let structure = RenderWorkspaceCapacity(
            maximumSemanticScopes: 1,
            maximumLayoutScopes: 1,
            maximumTraversalDepth: 1,
            maximumTextLines: 1
        )!
        var workspace = PreflightWorkspace<RenderFixtureIdentity>(
            structuralCapacity: structure
        )
        var sink = StreamingSink()
        let result = RenderProducer.produce(
            semantic: semantic,
            layout: layout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: surface,
            damageMode: mode,
            rootForeground: .white,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &workspace,
            sink: &sink
        )
        guard case .success(let header) = result else {
            Issue.record("expected explicit damage mode to succeed")
            return
        }
        #expect(header.damageBounds == expectedDamage)
        #expect(header.operationCount == 0)
        #expect(sink.events == [.begin(header), .finish])
    }
}

private func backgroundSemanticFixture() -> DirectSemanticRenderView {
    DirectSemanticRenderView(
        rootIdentity: .root,
        semanticScopeCount: 2,
        renderSnapshotVersion: 1,
        records: [
            SemanticFixtureRecord(
                identity: .root,
                scope: .background(.green),
                layoutIdentity: .root,
                children: [.alternate]
            ),
            SemanticFixtureRecord(
                identity: .alternate,
                scope: .structural,
                layoutIdentity: .alternate,
                children: []
            ),
        ]
    )
}

private func backgroundLayoutFixture(
    rootBounds: Rect,
    logicalClip: Rect
) -> DirectResolvedRenderLayoutView {
    DirectResolvedRenderLayoutView(
        rootIdentity: .root,
        layoutScopeCount: 2,
        renderSnapshotVersion: 1,
        rootBounds: rootBounds,
        records: [
            LayoutFixtureRecord(
                identity: .root,
                bounds: rootBounds,
                clip: logicalClip,
                lines: [],
                glyphs: []
            ),
            LayoutFixtureRecord(
                identity: .alternate,
                bounds: rootBounds,
                clip: logicalClip,
                lines: [],
                glyphs: []
            ),
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
        workspace: &beginWorkspace,
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
        workspace: &glyphWorkspace,
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
        workspace: &workspace,
        sink: &sink
    )

    #expect(result == .failure(.invariantViolation))
    #expect(sink.discardCount == 1)
    #expect(!sink.events.contains(.finish))
}

@Test
func producerAcquiresRunsBothPassesAndResetsExactlyOnceOnEveryAcquiredExit() {
    var successWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    var successSink = StreamingSink()
    let success = RenderProducer.produce(
        semantic: DirectRenderFixtures.validSemantic,
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &successWorkspace,
        sink: &successSink
    )
    #expect(success == .success(expectedPreflightHeader))
    #expect(successWorkspace.acquireCount == 1)
    #expect(successWorkspace.resetCount == 1)
    #expect(!successWorkspace.isActive)
    #expect(successSink.events.last == .finish)

    var failureWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    var failureSink = StreamingSink()
    let invalidSurface = Rect(
        origin: Point(x: 1, y: 0),
        size: DirectRenderFixtures.bounds.size
    )!
    let failure = RenderProducer.produce(
        semantic: DirectRenderFixtures.validSemantic,
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: invalidSurface,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &failureWorkspace,
        sink: &failureSink
    )
    #expect(failure == .failure(.invalidInput))
    #expect(failureWorkspace.acquireCount == 1)
    #expect(failureWorkspace.resetCount == 1)
    #expect(!failureWorkspace.isActive)
    #expect(failureSink.capacityReads == 0)
    #expect(failureSink.operationCallCount == 0)
}

@Test
func producerRejectsReentryBeforeInputOrSinkAccessAndPreservesActiveAttempt() {
    var workspace = PreflightWorkspace<RenderFixtureIdentity>()
    let acquired = workspace.acquire()
    #expect(acquired)
    let semantic = AccessCountingSemanticView(
        base: DirectRenderFixtures.validSemantic
    )
    var sink = StreamingSink()

    let result = RenderProducer.produce(
        semantic: semantic,
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &workspace,
        sink: &sink
    )

    #expect(result == .failure(.reentrancyViolation))
    #expect(workspace.acquireCount == 1)
    #expect(workspace.resetCount == 0)
    #expect(workspace.isActive)
    #expect(semantic.counter.accesses == 0)
    #expect(sink.capacityReads == 0)
    #expect(sink.operationCallCount == 0)
}

@Test
func producerMapsInactiveAcquireRefusalToInvariantWithoutResetOrInputAccess() {
    var workspace = PreflightWorkspace<RenderFixtureIdentity>(refuseAcquire: true)
    let semantic = AccessCountingSemanticView(
        base: DirectRenderFixtures.validSemantic
    )
    var sink = StreamingSink()

    let result = RenderProducer.produce(
        semantic: semantic,
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &workspace,
        sink: &sink
    )

    #expect(result == .failure(.invariantViolation))
    #expect(workspace.acquireCount == 1)
    #expect(workspace.resetCount == 0)
    #expect(!workspace.isActive)
    #expect(semantic.counter.accesses == 0)
    #expect(sink.capacityReads == 0)
    #expect(sink.operationCallCount == 0)
}

@Test
func constructibleFailurePrecedenceFollowsTheExactClosedOrder() {
    let semantic = {
        LateChangingSnapshotSemanticView(base: DirectRenderFixtures.validSemantic)
    }
    let invalidSurface = Rect(
        origin: Point(x: 1, y: 0),
        size: DirectRenderFixtures.bounds.size
    )!
    let shortLimits = RenderLimits(
        maximumOperations: 1,
        maximumPositionedGlyphs: 2,
        maximumClipDepth: 2
    )!

    var reentrantWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    let reentrantAcquired = reentrantWorkspace.acquire()
    #expect(reentrantAcquired)
    var reentrantSink = StreamingSink(refuseAtOperationCall: 1)
    let reentrant = RenderProducer.produce(
        semantic: semantic(),
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(resourceWord: 99),
        surfaceBounds: invalidSurface,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: shortLimits,
        workspace: &reentrantWorkspace,
        sink: &reentrantSink
    )
    #expect(reentrant == .failure(.reentrancyViolation))
    #expect(reentrantSink.operationCallCount == 0)
    #expect(reentrantSink.discardCount == 0)

    var invalidWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    var invalidSink = StreamingSink(refuseAtOperationCall: 1)
    let invalid = RenderProducer.produce(
        semantic: semantic(),
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(resourceWord: 99),
        surfaceBounds: invalidSurface,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: shortLimits,
        workspace: &invalidWorkspace,
        sink: &invalidSink
    )
    #expect(invalid == .failure(.invalidInput))
    #expect(invalidSink.operationCallCount == 0)
    #expect(invalidSink.discardCount == 0)

    var capacityWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    var capacitySink = StreamingSink(refuseAtOperationCall: 1)
    let capacity = RenderProducer.produce(
        semantic: semantic(),
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(resourceWord: 99),
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: shortLimits,
        workspace: &capacityWorkspace,
        sink: &capacitySink
    )
    #expect(capacity == .failure(.capacityExhausted))
    #expect(capacitySink.operationCallCount == 0)
    #expect(capacitySink.discardCount == 0)

    var resourceWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    var resourceSink = StreamingSink(refuseAtOperationCall: 1)
    let resource = RenderProducer.produce(
        semantic: semantic(),
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(resourceWord: 99),
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &resourceWorkspace,
        sink: &resourceSink
    )
    #expect(resource == .failure(.incompatibleTextResource))
    #expect(resourceSink.operationCallCount == 0)
    #expect(resourceSink.discardCount == 0)

    var beginWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    var beginSink = StreamingSink(refuseAtOperationCall: 1)
    let begin = RenderProducer.produce(
        semantic: semantic(),
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &beginWorkspace,
        sink: &beginSink
    )
    #expect(begin == .failure(.sinkRefused))
    #expect(beginSink.operationCallCount == 1)
    #expect(beginSink.discardCount == 0)

    var invariantWorkspace = PreflightWorkspace<RenderFixtureIdentity>()
    var invariantSink = StreamingSink()
    let invariant = RenderProducer.produce(
        semantic: semantic(),
        layout: DirectRenderFixtures.validLayout,
        textMetrics: PreflightMetrics(),
        surfaceBounds: DirectRenderFixtures.bounds,
        damageMode: .rootIntersection,
        rootForeground: .white,
        limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
        workspace: &invariantWorkspace,
        sink: &invariantSink
    )
    #expect(invariant == .failure(.invariantViolation))
    #expect(invariantSink.discardCount == 1)
}

@Test
func everyPostBeginSinkAndForegroundRefusalDiscardsOnceAndResets() {
    for refusedCall in UInt16(2) ... UInt16(7) {
        var workspace = PreflightWorkspace<RenderFixtureIdentity>()
        var sink = StreamingSink(refuseAtOperationCall: refusedCall)
        let result = RenderProducer.produce(
            semantic: DirectRenderFixtures.validSemantic,
            layout: DirectRenderFixtures.validLayout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            rootForeground: .white,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &workspace,
            sink: &sink
        )
        #expect(result == .failure(.invariantViolation))
        #expect(sink.discardCount == 1)
        #expect(workspace.resetCount == 1)
        #expect(workspace.currentForeground == nil)
    }

    for refusePushAt in [UInt16(1), UInt16(2)] {
        var workspace = PreflightWorkspace<RenderFixtureIdentity>(
            refuseForegroundPushAt: refusePushAt
        )
        var sink = StreamingSink()
        let result = RenderProducer.produce(
            semantic: DirectRenderFixtures.validSemantic,
            layout: DirectRenderFixtures.validLayout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            rootForeground: .white,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &workspace,
            sink: &sink
        )
        #expect(result == .failure(.invariantViolation))
        #expect(sink.discardCount == (refusePushAt == 1 ? 0 : 1))
        #expect(sink.operationCallCount == (refusePushAt == 1 ? 0 : 1))
        #expect(workspace.resetCount == 1)
        #expect(workspace.currentForeground == nil)
    }

    for refusePopAt in [UInt16(1), UInt16(2)] {
        var workspace = PreflightWorkspace<RenderFixtureIdentity>(
            refuseForegroundPopAt: refusePopAt
        )
        var sink = StreamingSink()
        let result = RenderProducer.produce(
            semantic: DirectRenderFixtures.validSemantic,
            layout: DirectRenderFixtures.validLayout,
            textMetrics: PreflightMetrics(),
            surfaceBounds: DirectRenderFixtures.bounds,
            damageMode: .rootIntersection,
            rootForeground: .white,
            limits: PreflightWorkspace<RenderFixtureIdentity>.limits,
            workspace: &workspace,
            sink: &sink
        )
        #expect(result == .failure(.invariantViolation))
        #expect(sink.discardCount == 1)
        #expect(workspace.resetCount == 1)
        #expect(workspace.currentForeground == nil)
    }
}

private var expectedPreflightHeader: RenderPlanHeader {
    RenderPlanHeader(
        surfaceBounds: DirectRenderFixtures.bounds,
        damageBounds: DirectRenderFixtures.bounds,
        operationCount: 2,
        positionedGlyphCount: 2,
        maximumObservedClipDepth: 2
    )
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
    private(set) var acquireCount: UInt16 = 0
    private(set) var resetCount: UInt16 = 0
    private(set) var semanticVisitCalls: UInt16 = 0
    private(set) var layoutVisitCalls: UInt16 = 0
    private(set) var firstSemanticVisits: UInt16 = 0
    private(set) var firstLayoutVisits: UInt16 = 0
    private(set) var foregroundHighWater: UInt16 = 0
    private(set) var foregroundPushCalls: UInt16 = 0
    private(set) var foregroundPopCalls: UInt16 = 0
    private var semanticVisits: [Bool]
    private var layoutVisits: [Bool]
    private var foregroundStack: [Color] = []
    private let refuseAcquire: Bool
    private let refuseForegroundPushAt: UInt16?
    private let refuseForegroundPopAt: UInt16?

    init(
        capacity: RenderLimits = Self.limits,
        structuralCapacity: RenderWorkspaceCapacity = Self.structure,
        refuseAcquire: Bool = false,
        refuseForegroundPushAt: UInt16? = nil,
        refuseForegroundPopAt: UInt16? = nil
    ) {
        self.capacity = capacity
        self.structuralCapacity = structuralCapacity
        self.refuseAcquire = refuseAcquire
        self.refuseForegroundPushAt = refuseForegroundPushAt
        self.refuseForegroundPopAt = refuseForegroundPopAt
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
        acquireCount += 1
        guard !isActive else { return false }
        guard !refuseAcquire else { return false }
        isActive = true
        semanticVisits = [Bool](repeating: false, count: semanticVisits.count)
        layoutVisits = [Bool](repeating: false, count: layoutVisits.count)
        foregroundStack.removeAll(keepingCapacity: true)
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

    var currentForeground: Color? {
        guard isActive else { return nil }
        return foregroundStack.last
    }

    mutating func pushForeground(_ color: Color) -> Bool {
        foregroundPushCalls += 1
        guard isActive,
            foregroundPushCalls != refuseForegroundPushAt,
            foregroundStack.count < Int(structuralCapacity.maximumTraversalDepth)
        else { return false }
        foregroundStack.append(color)
        foregroundHighWater = max(foregroundHighWater, UInt16(foregroundStack.count))
        return true
    }

    mutating func popForeground() -> Bool {
        foregroundPopCalls += 1
        guard isActive,
            foregroundPopCalls != refuseForegroundPopAt,
            !foregroundStack.isEmpty
        else { return false }
        foregroundStack.removeLast()
        return true
    }

    mutating func reset() {
        semanticVisits = [Bool](repeating: false, count: semanticVisits.count)
        layoutVisits = [Bool](repeating: false, count: layoutVisits.count)
        foregroundStack.removeAll(keepingCapacity: true)
        isActive = false
        resetCount += 1
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

private final class AccessCounter {
    var accesses: UInt16 = 0
}

private struct AccessCountingSemanticView: SemanticRenderView {
    let base: DirectSemanticRenderView
    let counter = AccessCounter()

    var rootIdentity: RenderFixtureIdentity {
        counter.accesses += 1
        return base.rootIdentity
    }

    var semanticScopeCount: UInt16 {
        counter.accesses += 1
        return base.semanticScopeCount
    }

    var renderSnapshotVersion: UInt32 {
        counter.accesses += 1
        return base.renderSnapshotVersion
    }

    func semanticIdentity(at ordinal: UInt16) -> RenderFixtureIdentity? {
        counter.accesses += 1
        return base.semanticIdentity(at: ordinal)
    }

    func semanticOrdinal(of identity: RenderFixtureIdentity) -> UInt16? {
        counter.accesses += 1
        return base.semanticOrdinal(of: identity)
    }

    func scope(at identity: RenderFixtureIdentity) -> SemanticRenderScope? {
        counter.accesses += 1
        return base.scope(at: identity)
    }

    func layoutIdentity(
        for identity: RenderFixtureIdentity
    ) -> RenderFixtureIdentity? {
        counter.accesses += 1
        return base.layoutIdentity(for: identity)
    }

    func childCount(of identity: RenderFixtureIdentity) -> UInt16? {
        counter.accesses += 1
        return base.childCount(of: identity)
    }

    func child(
        of identity: RenderFixtureIdentity,
        at index: UInt16
    ) -> RenderFixtureIdentity? {
        counter.accesses += 1
        return base.child(of: identity, at: index)
    }
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
    let reportedCapacity: RenderSinkCapacity
    let refuseAtOperationCall: UInt16?
    private let counter = StreamingSinkCounter()
    private(set) var operationCallCount: UInt16 = 0
    private(set) var discardCount: UInt16 = 0
    private(set) var events: [StreamingEvent] = []

    init(
        capacity: RenderSinkCapacity = RenderSinkCapacity(
            maximumOperations: .max,
            maximumPositionedGlyphs: .max
        ),
        refuseAtOperationCall: UInt16? = nil
    ) {
        reportedCapacity = capacity
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
