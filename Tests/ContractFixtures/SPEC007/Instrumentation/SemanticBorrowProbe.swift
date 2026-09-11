import GiftUI
import GiftUILayout
import GiftUISemanticCore
import GiftUITextResources

package struct StaticSemanticLayoutView: SemanticLayoutView {
    package let rootIdentity: UInt16 = 1
    package let scopeCount: UInt16 = 1

    package func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        identity == rootIdentity ? .spacer(minLength: 0) : nil
    }

    package func childCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    package func child(of identity: UInt16, at index: UInt16) -> UInt16? { nil }

    package func modifierCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    package func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        nil
    }

    package func modifier(
        of identity: UInt16,
        at index: UInt16
    ) -> SemanticLayoutModifier? { nil }

    package func textScalarCount(of identity: UInt16) -> UInt16? { nil }
    package func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? { nil }
}

@inline(never)
package func spec007BorrowedStaticExposure<View: SemanticLayoutView>(
    _ view: borrowing View
) -> UInt16 {
    var checksum = view.scopeCount
    let root = view.rootIdentity
    checksum &+= view.childCount(of: root) ?? 0
    checksum &+= view.modifierCount(of: root) ?? 0
    checksum &+= view.textScalarCount(of: root) ?? 0
    if view.primitive(at: root) != nil {
        checksum &+= 1
    }
    return checksum
}

@inline(never)
package func spec007StaticExposureEntry() -> UInt16 {
    spec007BorrowedStaticExposure(StaticSemanticLayoutView())
}

package struct StaticTextMetricsView: CanonicalTextMetricsView {
    package init() {}

    package var descriptor: TextResourceDescriptor {
        TextResourceDescriptor(
            schemaVersion: 1,
            resource: resource,
            instanceCount: 1,
            realizationCount: 1,
            canonicalManifestByteCount: 1
        )
    }

    package func instance(at index: UInt16) -> FontInstanceDescriptor? {
        guard index == 0 else { return nil }
        return FontInstanceDescriptor(
            id: FontInstanceID(resource: resource, instanceIndex: 0),
            lineMetrics: FontLineMetrics(ascent: 1, descent: 0, lineGap: 0),
            replacementGlyph: GlyphID(rawValue: 0),
            glyphCount: 1,
            mappingCount: 0
        )
    }

    package func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }

    package func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? { nil }

    private var resource: FontResourceID {
        FontResourceID(
            rawValue: TextResourceDigest(
                word0: 0,
                word1: 0,
                word2: 0,
                word3: 0,
                word4: 0,
                word5: 0,
                word6: 0,
                word7: 7
            )
        )
    }
}

package struct StaticLayoutWorkspace: LayoutWorkspace {
    package let maximumScopes: UInt16 = 512
    package let maximumDepth: UInt16 = 64
    package let maximumTextScalars: UInt16 = 4096
    package let maximumTextLines: UInt16 = 512
    package let maximumPositionedGlyphs: UInt16 = 4096
    package var isLayoutActive = false
    private var identity: UInt16?
    private var measurement: LayoutMeasurement?
    private var placement: LayoutPlacement?

    package init() {}

    package mutating func acquireLayout() -> Bool {
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        return true
    }

    package mutating func appendScope(
        identity: borrowing UInt16,
        measurement: LayoutMeasurement
    ) -> Bool {
        guard isLayoutActive, self.identity == nil else { return false }
        self.identity = copy identity
        self.measurement = measurement
        return true
    }

    package var scopeCount: UInt16 { identity == nil ? 0 : 1 }
    package func scopeIdentity(at index: UInt16) -> UInt16? {
        index == 0 ? identity : nil
    }
    package func measurement(for identity: borrowing UInt16) -> LayoutMeasurement? {
        let identityCopy = copy identity
        return self.identity == identityCopy ? measurement : nil
    }
    package mutating func storeMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: borrowing UInt16
    ) -> Bool {
        let identityCopy = copy identity
        guard self.identity == identityCopy else { return false }
        self.measurement = measurement
        return true
    }
    package mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing UInt16
    ) -> Bool {
        let identityCopy = copy identity
        guard self.identity == identityCopy else { return false }
        self.placement = placement
        return true
    }
    package func placement(for identity: borrowing UInt16) -> LayoutPlacement? {
        let identityCopy = copy identity
        return self.identity == identityCopy ? placement : nil
    }
    package var textLineCount: UInt16 { 0 }
    package mutating func appendTextLine(_ line: LayoutTextLine<UInt16>) -> Bool { false }
    package func textLine(at index: UInt16) -> LayoutTextLine<UInt16>? { nil }
    package mutating func storeTextLine(
        _ line: LayoutTextLine<UInt16>,
        at index: UInt16
    ) -> Bool { false }
    package var positionedGlyphCount: UInt16 { 0 }
    package mutating func appendPositionedGlyph(
        _ glyph: LayoutPositionedGlyph<UInt16>
    ) -> Bool { false }
    package func positionedGlyph(
        at index: UInt16
    ) -> LayoutPositionedGlyph<UInt16>? { nil }
    package mutating func storePositionedGlyph(
        _ glyph: LayoutPositionedGlyph<UInt16>,
        at index: UInt16
    ) -> Bool { false }
    package mutating func pushScope(_ identity: borrowing UInt16) -> Bool { true }
    package mutating func popScope() {}
    package mutating func resetLayout() {
        identity = nil
        measurement = nil
        placement = nil
        isLayoutActive = false
    }
}

@inline(never)
package func spec007StaticWorkspaceSize() -> UInt32 {
    UInt32(MemoryLayout<StaticLayoutWorkspace>.size)
}

@inline(never)
package func spec007StaticWorkspaceStride() -> UInt32 {
    UInt32(MemoryLayout<StaticLayoutWorkspace>.stride)
}

package struct StaticLayoutSink: LayoutResultSink, LayoutResultSinkState {
    package var isLayoutActive = false
    package init() {}
    package mutating func begin(summary: LayoutSummary) -> Bool {
        isLayoutActive = true
        return summary.scopeCount == 1
    }
    package mutating func stageScope(
        identity: UInt16,
        bounds: Rect,
        clip: Rect
    ) -> Bool { identity == 1 }
    package mutating func stageTextLine(
        identity: UInt16,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) -> Bool { false }
    package mutating func stageGlyph(
        identity: UInt16,
        lineIndex: UInt16,
        glyphIndex: UInt16,
        instance: FontInstanceID,
        glyph: GlyphID,
        baseline: Point,
        clip: Rect
    ) -> Bool { false }
    package mutating func publish() -> Bool {
        isLayoutActive = false
        return true
    }
    package mutating func discard() { isLayoutActive = false }
}

@inline(never)
package func spec007StaticLayoutEntry() -> UInt16 {
    var workspace = StaticLayoutWorkspace()
    var sink = StaticLayoutSink()
    let result = layout(
        semantic: StaticSemanticLayoutView(),
        metrics: StaticTextMetricsView(),
        proposal: ProposedSize(width: 320, height: 240)!,
        limits: LayoutLimits(
            maximumScopes: 512,
            maximumDepth: 64,
            maximumTextScalars: 4096,
            maximumTextLines: 512,
            maximumPositionedGlyphs: 4096
        )!,
        workspace: &workspace,
        sink: &sink
    )
    switch result {
    case .success(let summary):
        return summary.scopeCount
    case .failure(let error):
        return UInt16(error.rawValue) + 100
    }
}
