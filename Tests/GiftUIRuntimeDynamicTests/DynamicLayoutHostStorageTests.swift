import GiftUI
import GiftUILayout
import GiftUIRuntimeDynamic
import GiftUISemanticCore
import Testing

@Test func dynamicResolvedLayoutPublishesAtomicallyAndPreservesLastResult() {
    let limits = LayoutLimits(
        maximumScopes: 2,
        maximumDepth: 2,
        maximumTextScalars: 2,
        maximumTextLines: 1,
        maximumPositionedGlyphs: 2
    )!
    let root = DynamicSemanticIdentity(
        components: [.root],
        declarationRole: SemanticRecordingRole(rawValue: 0)
    )
    let child = DynamicSemanticIdentity(
        components: [.root, .fixedChild(0)],
        declarationRole: SemanticRecordingRole(rawValue: 0)
    )
    let bounds = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 10, height: 10)!
    )!
    let summary = LayoutSummary(
        scopeCount: 2,
        textScalarCount: 0,
        textLineCount: 0,
        positionedGlyphCount: 0,
        maximumObservedDepth: 2,
        rootBounds: bounds
    )
    var storage = DynamicResolvedLayoutStorage(limits: limits)

    let beganFirst = storage.begin(summary: summary)
    let stagedRoot = storage.stageScope(identity: root, bounds: bounds, clip: bounds)
    let stagedChild = storage.stageScope(identity: child, bounds: bounds, clip: bounds)
    let stagedDuplicate = storage.stageScope(
        identity: child,
        bounds: bounds,
        clip: bounds
    )
    let published = storage.publish()
    #expect(beganFirst)
    #expect(stagedRoot)
    #expect(stagedChild)
    #expect(!stagedDuplicate)
    #expect(published)
    #expect(storage.hasPublishedResult)
    #expect(storage.renderView.rootIdentity == root)
    #expect(storage.renderView.layoutScopeCount == 2)
    #expect(storage.renderView.renderSnapshotVersion == 1)

    let beganSecond = storage.begin(summary: summary)
    let stagedReplacementRoot = storage.stageScope(
        identity: root,
        bounds: bounds,
        clip: bounds
    )
    #expect(beganSecond)
    #expect(stagedReplacementRoot)
    storage.discard()
    #expect(!storage.isLayoutActive)
    #expect(storage.renderView.rootIdentity == root)
    #expect(storage.renderView.renderSnapshotVersion == 1)
}
