import GiftUI
import GiftUISemanticCore
import GiftUITextResources
import Testing

@testable import GiftUILayout

@Test
func layoutEntryRejectsWorkspaceReentryBeforeInspectingInputs() {
    let semantic = ProbeSemanticView()
    let metrics = ProbeMetricsView()
    var workspace = ProbeWorkspace(isLayoutActive: true)
    var sink = ProbeSink()

    let result = layout(
        semantic: semantic,
        metrics: metrics,
        proposal: ProposedSize()!,
        limits: limits(),
        workspace: &workspace,
        sink: &sink
    )

    #expect(result == LayoutResult.failure(.reentrancyViolation))
    #expect(semantic.accessCount == 0)
    #expect(metrics.accessCount == 0)
    #expect(workspace.acquireCount == 0)
    #expect(sink.beginCount == 0)
}

@Test
func layoutEntryRejectsSinkReentryBeforeInspectingInputs() {
    let semantic = ProbeSemanticView()
    let metrics = ProbeMetricsView()
    var workspace = ProbeWorkspace()
    var sink = ProbeSink(isLayoutActive: true)

    let result = layout(
        semantic: semantic,
        metrics: metrics,
        proposal: ProposedSize()!,
        limits: limits(),
        workspace: &workspace,
        sink: &sink
    )

    #expect(result == LayoutResult.failure(.reentrancyViolation))
    #expect(semantic.accessCount == 0)
    #expect(metrics.accessCount == 0)
    #expect(workspace.acquireCount == 0)
    #expect(sink.beginCount == 0)
}

@Test
func workspaceReportsEveryCapacityAndIndexesExactIdentities() {
    var workspace = ProbeWorkspace()
    let size = Size(width: 3, height: 5)!
    let bounds = Rect(origin: Point(x: 7, y: 11), size: size)!
    let measurement = LayoutMeasurement(idealSize: size, resolvedSize: size)
    let placement = LayoutPlacement(bounds: bounds, clip: bounds)

    #expect(workspace.maximumScopes == 5)
    #expect(workspace.maximumDepth == 5)
    #expect(workspace.maximumTextScalars == 5)
    #expect(workspace.maximumTextLines == 5)
    #expect(workspace.maximumPositionedGlyphs == 5)
    let acquired = workspace.acquireLayout()
    let appended = workspace.appendScope(identity: 17, measurement: measurement)
    #expect(acquired)
    #expect(appended)
    #expect(workspace.measurement(for: 17) == measurement)
    #expect(workspace.measurement(for: 18) == nil)
    let stored = workspace.storePlacement(placement, for: 17)
    #expect(stored)
    #expect(workspace.placement(for: 17) == placement)
    let pushed = workspace.pushScope(17)
    #expect(pushed)
    workspace.popScope()
    workspace.resetLayout()
    #expect(!workspace.isLayoutActive)
    #expect(workspace.measurement(for: 17) == nil)
    #expect(workspace.placement(for: 17) == nil)
}

private func limits() -> LayoutLimits {
    LayoutLimits(
        maximumScopes: 5,
        maximumDepth: 5,
        maximumTextScalars: 5,
        maximumTextLines: 5,
        maximumPositionedGlyphs: 5
    )!
}

private final class ProbeAccesses: @unchecked Sendable {
    var count = 0
}

private struct ProbeSemanticView: SemanticLayoutView {
    typealias Identity = UInt16

    private let accesses = ProbeAccesses()

    var accessCount: Int { accesses.count }
    var rootIdentity: UInt16 {
        accesses.count += 1
        return 1
    }
    var scopeCount: UInt16 {
        accesses.count += 1
        return 1
    }

    func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        accesses.count += 1
        return .proxy
    }

    func childCount(of identity: UInt16) -> UInt16? {
        accesses.count += 1
        return 0
    }

    func child(of identity: UInt16, at index: UInt16) -> UInt16? {
        accesses.count += 1
        return nil
    }

    func modifierCount(of identity: UInt16) -> UInt16? {
        accesses.count += 1
        return 0
    }

    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        accesses.count += 1
        return nil
    }

    func modifier(
        of identity: UInt16,
        at index: UInt16
    ) -> SemanticLayoutModifier? {
        accesses.count += 1
        return nil
    }

    func textScalarCount(of identity: UInt16) -> UInt16? {
        accesses.count += 1
        return nil
    }

    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        accesses.count += 1
        return nil
    }
}

private struct ProbeMetricsView: CanonicalTextMetricsView {
    private let accesses = ProbeAccesses()

    var accessCount: Int { accesses.count }

    var descriptor: TextResourceDescriptor {
        accesses.count += 1
        return TextResourceDescriptor(
            schemaVersion: 1,
            resource: resourceID,
            instanceCount: 1,
            realizationCount: 0,
            canonicalManifestByteCount: 0
        )
    }

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        accesses.count += 1
        return nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        accesses.count += 1
        return nil
    }

    func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        accesses.count += 1
        return nil
    }

    private var resourceID: FontResourceID {
        FontResourceID(
            rawValue: TextResourceDigest(
                word0: 0,
                word1: 0,
                word2: 0,
                word3: 0,
                word4: 0,
                word5: 0,
                word6: 0,
                word7: 0
            )
        )
    }
}

private struct ProbeWorkspace: LayoutWorkspace {
    let maximumScopes: UInt16 = 5
    let maximumDepth: UInt16 = 5
    let maximumTextScalars: UInt16 = 5
    let maximumTextLines: UInt16 = 5
    let maximumPositionedGlyphs: UInt16 = 5
    var isLayoutActive = false
    var acquireCount = 0
    private var scopes: [(UInt16, LayoutMeasurement, LayoutPlacement?)] = []
    private var depth: [UInt16] = []

    init(isLayoutActive: Bool = false) {
        self.isLayoutActive = isLayoutActive
    }

    mutating func acquireLayout() -> Bool {
        acquireCount += 1
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        return true
    }

    mutating func appendScope(
        identity: borrowing UInt16,
        measurement: LayoutMeasurement
    ) -> Bool {
        let identityCopy = copy identity
        guard isLayoutActive,
            scopes.count < Int(maximumScopes),
            !scopes.contains(where: { $0.0 == identityCopy })
        else { return false }
        scopes.append((identityCopy, measurement, nil))
        return true
    }

    func measurement(for identity: borrowing UInt16) -> LayoutMeasurement? {
        let identityCopy = copy identity
        return scopes.first(where: { $0.0 == identityCopy })?.1
    }

    mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing UInt16
    ) -> Bool {
        let identityCopy = copy identity
        guard let index = scopes.firstIndex(where: { $0.0 == identityCopy }),
            scopes[index].2 == nil
        else { return false }
        scopes[index].2 = placement
        return true
    }

    func placement(for identity: borrowing UInt16) -> LayoutPlacement? {
        let identityCopy = copy identity
        return scopes.first(where: { $0.0 == identityCopy })?.2
    }

    mutating func pushScope(_ identity: borrowing UInt16) -> Bool {
        guard depth.count < Int(maximumDepth) else { return false }
        depth.append(copy identity)
        return true
    }

    mutating func popScope() {
        _ = depth.popLast()
    }

    mutating func resetLayout() {
        scopes.removeAll(keepingCapacity: true)
        depth.removeAll(keepingCapacity: true)
        isLayoutActive = false
    }
}

private struct ProbeSink: LayoutResultSink, LayoutResultSinkState {
    typealias Identity = UInt16

    var isLayoutActive = false
    var beginCount = 0

    mutating func begin(summary: LayoutSummary) -> Bool {
        beginCount += 1
        isLayoutActive = true
        return true
    }

    mutating func stageScope(
        identity: UInt16,
        bounds: Rect,
        clip: Rect
    ) -> Bool { true }

    mutating func stageTextLine(
        identity: UInt16,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) -> Bool { true }

    mutating func stageGlyph(
        identity: UInt16,
        lineIndex: UInt16,
        glyphIndex: UInt16,
        instance: FontInstanceID,
        glyph: GlyphID,
        baseline: Point,
        clip: Rect
    ) -> Bool { true }

    mutating func publish() -> Bool {
        isLayoutActive = false
        return true
    }

    mutating func discard() {
        isLayoutActive = false
    }
}
