/// One bounded, attempt-local owner of the packed layout and text regions.
/// The region borrow must end before the enclosing profile opportunity ends.
package struct StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace {
    private let scopes: UnsafeMutableRawBufferPointer
    private let text: UnsafeMutableRawBufferPointer
    package private(set) var isActive = false
    package private(set) var scopeCount: UInt16 = 0
    package private(set) var textScalarCount: UInt16 = 0
    package private(set) var textLineCount: UInt16 = 0
    package private(set) var positionedGlyphCount: UInt16 = 0
    private var depth: UInt16 = 0

    package init?(
        scopes: UnsafeMutableRawBufferPointer,
        text: UnsafeMutableRawBufferPointer
    ) {
        guard scopes.count == StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.regionByteCount,
            text.count == StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.regionByteCount,
            let scopeAddress = scopes.baseAddress,
            let textAddress = text.baseAddress
        else { return nil }
        let scopeStart = UInt(bitPattern: scopeAddress)
        let textStart = UInt(bitPattern: textAddress)
        let scopeEnd = scopeStart.addingReportingOverflow(UInt(scopes.count))
        let textEnd = textStart.addingReportingOverflow(UInt(text.count))
        guard !scopeEnd.overflow, !textEnd.overflow,
            scopeEnd.partialValue <= textStart || textEnd.partialValue <= scopeStart
        else { return nil }
        self.scopes = scopes
        self.text = text
    }

    package mutating func acquire() -> Bool {
        guard !isActive, scopeCount == 0, textScalarCount == 0,
            textLineCount == 0,
            positionedGlyphCount == 0, depth == 0
        else { return false }
        scopes.initializeMemory(as: UInt8.self, repeating: 0)
        text.initializeMemory(as: UInt8.self, repeating: 0)
        isActive = true
        return true
    }

    package mutating func appendScope(
        identity: UInt16,
        idealWidth: Int16, idealHeight: Int16,
        width: Int16, height: Int16
    ) -> Bool {
        guard isActive, scopeCount < 98, scopeOrdinal(of: identity) == nil,
            StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.stage(
                identity: identity,
                idealWidth: idealWidth, idealHeight: idealHeight,
                width: width, height: height,
                at: scopeCount, in: scopes
            )
        else { return false }
        scopeCount += 1
        return true
    }

    package func scope(at ordinal: UInt16) -> StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec
        .Record?
    {
        guard isActive, ordinal < scopeCount else { return nil }
        return StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.read(
            at: ordinal, in: scopes
        )
    }

    package func scopeOrdinal(of identity: UInt16) -> UInt16? {
        guard isActive, identity != 0 else { return nil }
        var ordinal: UInt16 = 0
        while ordinal < scopeCount {
            if scope(at: ordinal)?.identity == identity { return ordinal }
            ordinal += 1
        }
        return nil
    }

    package mutating func replaceMeasurement(
        identity: UInt16,
        idealWidth: Int16, idealHeight: Int16,
        width: Int16, height: Int16
    ) -> Bool {
        guard let ordinal = scopeOrdinal(of: identity) else { return false }
        return StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.replaceMeasurement(
            identity: identity,
            idealWidth: idealWidth, idealHeight: idealHeight,
            width: width, height: height,
            at: ordinal, in: scopes
        )
    }

    package mutating func placeScope(
        identity: UInt16,
        originX: Int16, originY: Int16,
        width: Int16, height: Int16,
        clipX: Int16, clipY: Int16,
        clipWidth: Int16, clipHeight: Int16
    ) -> Bool {
        guard let ordinal = scopeOrdinal(of: identity) else { return false }
        return StaticSignalAnalyzerNRFEmbeddedLayoutScopeCodec.place(
            identity: identity,
            originX: originX, originY: originY,
            width: width, height: height,
            clipX: clipX, clipY: clipY,
            clipWidth: clipWidth, clipHeight: clipHeight,
            at: ordinal, in: scopes
        )
    }

    package mutating func pushScope(_ identity: UInt16) -> Bool {
        guard isActive, depth < 13,
            scopeOrdinal(of: identity) != nil
        else { return false }
        let offset =
            StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.scratchOffset
            + Int(depth) * 2
        text[offset] = UInt8(truncatingIfNeeded: identity)
        text[offset + 1] = UInt8(truncatingIfNeeded: identity >> 8)
        depth += 1
        return true
    }

    package mutating func appendTextLine(
        _ line: StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line
    ) -> Bool {
        guard isActive,
            textLineCount < StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.maximumLines,
            scopeOrdinal(of: line.identity) != nil,
            line.lineIndex == lineCount(of: line.identity),
            StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.stageLine(
                line, at: textLineCount, in: text
            )
        else { return false }
        textLineCount += 1
        return true
    }

    package mutating func reserveTextScalars(_ count: UInt16) -> Bool {
        let next = textScalarCount.addingReportingOverflow(count)
        guard isActive, !next.overflow, next.partialValue <= 224 else {
            return false
        }
        textScalarCount = next.partialValue
        return true
    }

    package func textLine(
        at ordinal: UInt16
    ) -> StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line? {
        guard isActive, ordinal < textLineCount else { return nil }
        return StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.line(
            at: ordinal, in: text
        )
    }

    package mutating func replaceTextLine(
        _ line: StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line,
        at ordinal: UInt16
    ) -> Bool {
        guard isActive, ordinal < textLineCount else { return false }
        return StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.replaceLine(
            line, at: ordinal, in: text
        )
    }

    package mutating func appendGlyph(
        _ glyph: StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph,
        glyphIndex: UInt16
    ) -> Bool {
        guard isActive,
            positionedGlyphCount < StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.maximumGlyphs,
            glyph.glyphID < StaticSignalAnalyzerNRFReferenceMetrics.glyphCount,
            scopeOrdinal(of: glyph.identity) != nil,
            glyphIndex == glyphCount(of: glyph.identity),
            StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.stageGlyph(
                glyph, at: positionedGlyphCount, in: text
            )
        else { return false }
        positionedGlyphCount += 1
        return true
    }

    package func glyph(
        at ordinal: UInt16
    ) -> StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph? {
        guard isActive, ordinal < positionedGlyphCount else { return nil }
        return StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.glyph(
            at: ordinal, in: text
        )
    }

    package mutating func replaceGlyphBaseline(
        _ glyph: StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph,
        at ordinal: UInt16
    ) -> Bool {
        guard isActive, ordinal < positionedGlyphCount,
            hasLine(identity: glyph.identity, index: glyph.lineIndex)
        else { return false }
        return StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.replaceGlyphBaseline(
            glyph, at: ordinal, in: text
        )
    }

    private func lineCount(of identity: UInt16) -> UInt16 {
        var ordinal: UInt16 = 0
        var count: UInt16 = 0
        while ordinal < textLineCount {
            if textLine(at: ordinal)?.identity == identity { count += 1 }
            ordinal += 1
        }
        return count
    }

    private func hasLine(identity: UInt16, index: UInt16) -> Bool {
        var ordinal: UInt16 = 0
        while ordinal < textLineCount {
            if let line = textLine(at: ordinal),
                line.identity == identity, line.lineIndex == index
            {
                return true
            }
            ordinal += 1
        }
        return false
    }

    private func glyphCount(of identity: UInt16) -> UInt16 {
        var ordinal: UInt16 = 0
        var count: UInt16 = 0
        while ordinal < positionedGlyphCount {
            if glyph(at: ordinal)?.identity == identity { count += 1 }
            ordinal += 1
        }
        return count
    }

    package mutating func popScope() {
        guard isActive, depth > 0 else { return }
        depth -= 1
        let offset =
            StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.scratchOffset
            + Int(depth) * 2
        text[offset] = 0
        text[offset + 1] = 0
    }

    package mutating func publish(
        rootIdentity: UInt16, expectedScopeCount: UInt16
    ) -> StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView? {
        guard isActive, depth == 0,
            scopeCount == expectedScopeCount,
            scopeCount > 0,
            text[StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.scratchOffset + 26] == 0,
            scopeOrdinal(of: rootIdentity) != nil
        else { return nil }
        var scopeCursor: UInt16 = 0
        while scopeCursor < scopeCount {
            guard let scope = scope(at: scopeCursor),
                scope.originX != nil, scope.originY != nil,
                scope.clipX != nil, scope.clipY != nil,
                scope.clipWidth != nil, scope.clipHeight != nil
            else { return nil }
            scopeCursor += 1
        }
        var lineOrdinal: UInt16 = 0
        while lineOrdinal < textLineCount {
            guard let line = textLine(at: lineOrdinal),
                scopeOrdinal(of: line.identity) != nil,
                line.lineIndex
                    == precedingLineCount(
                        of: line.identity, before: lineOrdinal
                    )
            else { return nil }
            lineOrdinal += 1
        }
        var glyphOrdinal: UInt16 = 0
        while glyphOrdinal < positionedGlyphCount {
            guard let glyph = glyph(at: glyphOrdinal),
                glyph.glyphID < StaticSignalAnalyzerNRFReferenceMetrics.glyphCount,
                scopeOrdinal(of: glyph.identity) != nil,
                hasLine(identity: glyph.identity, index: glyph.lineIndex)
            else { return nil }
            glyphOrdinal += 1
        }
        text[StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.scratchOffset + 26] = 1
        isActive = false
        return StaticSignalAnalyzerNRFEmbeddedResolvedLayoutView(
            scopes: scopes, text: text,
            scopeCount: scopeCount,
            lineCount: textLineCount,
            glyphCount: positionedGlyphCount,
            rootIdentity: rootIdentity
        )
    }

    private func precedingLineCount(of identity: UInt16, before ordinal: UInt16) -> UInt16 {
        var current: UInt16 = 0
        var count: UInt16 = 0
        while current < ordinal {
            if textLine(at: current)?.identity == identity { count += 1 }
            current += 1
        }
        return count
    }

    package mutating func reset() {
        scopes.initializeMemory(as: UInt8.self, repeating: 0)
        text.initializeMemory(as: UInt8.self, repeating: 0)
        scopeCount = 0
        textScalarCount = 0
        textLineCount = 0
        positionedGlyphCount = 0
        depth = 0
        isActive = false
    }
}
