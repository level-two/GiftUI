/// A synchronous borrow of in-place published layout records.
/// It becomes invalid when the owning profile attempt resets either region.
package struct StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView {
    private let scopes: UnsafeMutableRawBufferPointer
    private let text: UnsafeMutableRawBufferPointer
    package let scopeCount: UInt16
    package let lineCount: UInt16
    package let glyphCount: UInt16
    package let rootIdentity: UInt16

    package init(
        scopes: UnsafeMutableRawBufferPointer,
        text: UnsafeMutableRawBufferPointer,
        scopeCount: UInt16, lineCount: UInt16,
        glyphCount: UInt16, rootIdentity: UInt16
    ) {
        self.scopes = scopes
        self.text = text
        self.scopeCount = scopeCount
        self.lineCount = lineCount
        self.glyphCount = glyphCount
        self.rootIdentity = rootIdentity
    }

    package var isPublished: Bool {
        text.count == StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.regionByteCount
            && text[StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.scratchOffset + 26] == 1
    }

    package func scope(
        at ordinal: UInt16
    ) -> StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.Record? {
        guard isPublished, ordinal < scopeCount else { return nil }
        return StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.read(
            at: ordinal, in: scopes
        )
    }

    package func scopeOrdinal(of identity: UInt16) -> UInt16? {
        guard isPublished else { return nil }
        var ordinal: UInt16 = 0
        while ordinal < scopeCount {
            if scope(at: ordinal)?.identity == identity { return ordinal }
            ordinal += 1
        }
        return nil
    }

    package func line(
        at ordinal: UInt16
    ) -> StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line? {
        guard isPublished, ordinal < lineCount else { return nil }
        return StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.line(
            at: ordinal, in: text
        )
    }

    package func glyph(
        at ordinal: UInt16
    ) -> StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph? {
        guard isPublished, ordinal < glyphCount else { return nil }
        return StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.glyph(
            at: ordinal, in: text
        )
    }
}
