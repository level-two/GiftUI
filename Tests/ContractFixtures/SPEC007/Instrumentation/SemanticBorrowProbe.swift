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
    private var identities = InlineArray<512, UInt16?>(repeating: nil)
    private var measurements = InlineArray<512, LayoutMeasurement?>(repeating: nil)
    private var placements = InlineArray<512, LayoutPlacement?>(repeating: nil)
    private var storedScopeCount: UInt16 = 0
    private var lines = InlineArray<512, LayoutTextLine<UInt16>?>(repeating: nil)
    private var storedLineCount: UInt16 = 0
    private var glyphs = InlineArray<4096, LayoutPositionedGlyph<UInt16>?>(repeating: nil)
    private var storedGlyphCount: UInt16 = 0
    private var depth = InlineArray<64, UInt16?>(repeating: nil)
    private var storedDepth: UInt16 = 0

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
        let value = copy identity
        guard isLayoutActive, storedScopeCount < maximumScopes,
            findScope(value) == nil
        else { return false }
        let index = Int(storedScopeCount)
        identities[index] = value
        measurements[index] = measurement
        placements[index] = nil
        storedScopeCount += 1
        return true
    }

    package var scopeCount: UInt16 { storedScopeCount }
    package func scopeIdentity(at index: UInt16) -> UInt16? {
        guard index < storedScopeCount else { return nil }
        return identities[Int(index)]
    }
    package func measurement(for identity: borrowing UInt16) -> LayoutMeasurement? {
        findScope(copy identity).flatMap { measurements[$0] }
    }
    package mutating func storeMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: borrowing UInt16
    ) -> Bool {
        guard let index = findScope(copy identity) else { return false }
        measurements[index] = measurement
        return true
    }
    package mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing UInt16
    ) -> Bool {
        guard let index = findScope(copy identity), placements[index] == nil else {
            return false
        }
        placements[index] = placement
        return true
    }
    package func placement(for identity: borrowing UInt16) -> LayoutPlacement? {
        findScope(copy identity).flatMap { placements[$0] }
    }
    package var textLineCount: UInt16 { storedLineCount }
    package mutating func appendTextLine(_ line: LayoutTextLine<UInt16>) -> Bool {
        guard storedLineCount < maximumTextLines else { return false }
        lines[Int(storedLineCount)] = line
        storedLineCount += 1
        return true
    }
    package func textLine(at index: UInt16) -> LayoutTextLine<UInt16>? {
        guard index < storedLineCount else { return nil }
        return lines[Int(index)]
    }
    package mutating func storeTextLine(
        _ line: LayoutTextLine<UInt16>,
        at index: UInt16
    ) -> Bool {
        guard index < storedLineCount else { return false }
        lines[Int(index)] = line
        return true
    }
    package var positionedGlyphCount: UInt16 { storedGlyphCount }
    package mutating func appendPositionedGlyph(
        _ glyph: LayoutPositionedGlyph<UInt16>
    ) -> Bool {
        guard storedGlyphCount < maximumPositionedGlyphs else { return false }
        glyphs[Int(storedGlyphCount)] = glyph
        storedGlyphCount += 1
        return true
    }
    package func positionedGlyph(
        at index: UInt16
    ) -> LayoutPositionedGlyph<UInt16>? {
        guard index < storedGlyphCount else { return nil }
        return glyphs[Int(index)]
    }
    package mutating func storePositionedGlyph(
        _ glyph: LayoutPositionedGlyph<UInt16>,
        at index: UInt16
    ) -> Bool {
        guard index < storedGlyphCount else { return false }
        glyphs[Int(index)] = glyph
        return true
    }
    package mutating func pushScope(_ identity: borrowing UInt16) -> Bool {
        guard storedDepth < maximumDepth else { return false }
        depth[Int(storedDepth)] = copy identity
        storedDepth += 1
        return true
    }
    package mutating func popScope() {
        guard storedDepth > 0 else { return }
        storedDepth -= 1
        depth[Int(storedDepth)] = nil
    }
    package mutating func resetLayout() {
        var scopeIndex: UInt16 = 0
        while scopeIndex < storedScopeCount {
            identities[Int(scopeIndex)] = nil
            measurements[Int(scopeIndex)] = nil
            placements[Int(scopeIndex)] = nil
            scopeIndex += 1
        }
        var lineIndex: UInt16 = 0
        while lineIndex < storedLineCount {
            lines[Int(lineIndex)] = nil
            lineIndex += 1
        }
        var glyphIndex: UInt16 = 0
        while glyphIndex < storedGlyphCount {
            glyphs[Int(glyphIndex)] = nil
            glyphIndex += 1
        }
        while storedDepth > 0 { popScope() }
        storedScopeCount = 0
        storedLineCount = 0
        storedGlyphCount = 0
        isLayoutActive = false
    }

    private func findScope(_ identity: UInt16) -> Int? {
        var index: UInt16 = 0
        while index < storedScopeCount {
            if identities[Int(index)] == identity { return Int(index) }
            index += 1
        }
        return nil
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

@inline(never)
package func spec007PrimitiveSize() -> UInt32 {
    UInt32(MemoryLayout<SemanticLayoutPrimitive>.size)
}

@inline(never)
package func spec007ModifierSize() -> UInt32 {
    UInt32(MemoryLayout<SemanticLayoutModifier>.size)
}

@inline(never)
package func spec007LimitsSize() -> UInt32 {
    UInt32(MemoryLayout<LayoutLimits>.size)
}

@inline(never)
package func spec007SummarySize() -> UInt32 {
    UInt32(MemoryLayout<LayoutSummary>.size)
}

@inline(never)
package func spec007ErrorSize() -> UInt32 {
    UInt32(MemoryLayout<LayoutError>.size)
}

@inline(never)
package func spec007ResultSize() -> UInt32 {
    UInt32(MemoryLayout<LayoutResult>.size)
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
