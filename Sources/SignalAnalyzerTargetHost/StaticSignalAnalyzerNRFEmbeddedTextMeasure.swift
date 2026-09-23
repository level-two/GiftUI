/// The canonical text measure rule over the target's packed line/glyph region.
/// On failure the caller discards the entire active layout attempt.
package enum StaticSignalAnalyzerNRFEmbeddedTextMeasure {
    package static func run(
        identity: UInt16,
        semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
        proposalWidth: Int16?, proposalHeight: Int16?,
        workspace: inout StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace
    ) -> Bool {
        guard semantic.layoutPrimitive(at: identity) == .text,
            workspace.scopeOrdinal(of: identity) != nil,
            let scalarCount = semantic.textScalarCount(of: identity),
            workspace.reserveTextScalars(scalarCount),
            proposalWidth.map({ $0 >= 0 }) ?? true,
            proposalHeight.map({ $0 >= 0 }) ?? true
        else { return false }

        let ascent = Int32(StaticSignalAnalyzerNRFReferenceMetrics.ascent)
        let lineHeight = ascent + Int32(StaticSignalAnalyzerNRFReferenceMetrics.descent)
        let progression =
            lineHeight
            + Int32(StaticSignalAnalyzerNRFReferenceMetrics.lineGap)
        guard lineHeight >= 0, progression >= 0 else { return false }

        var lineIndex: UInt16 = 0
        var localGlyphIndex: UInt16 = 0
        var currentAdvance: Int32 = 0
        var currentHasGlyph = false
        var maximumLineWidth: Int32 = 0
        var previousWasCarriageReturn = false
        var scalarIndex: UInt16 = 0

        func finalizeLine() -> Bool {
            let baselineY = ascent + Int32(lineIndex) * progression
            let lineY = baselineY - ascent
            let width =
                proposalWidth.map { min(currentAdvance, Int32($0)) }
                ?? currentAdvance
            guard let packedWidth = Int16(exactly: width),
                let packedHeight = Int16(exactly: lineHeight),
                let packedY = Int16(exactly: lineY),
                let packedBaseline = Int16(exactly: baselineY)
            else { return false }
            maximumLineWidth = max(maximumLineWidth, width)
            return workspace.appendTextLine(
                StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line(
                    identity: identity, lineIndex: lineIndex,
                    x: 0, y: packedY,
                    width: packedWidth, height: packedHeight,
                    baselineX: 0, baselineY: packedBaseline
                )
            )
        }

        while scalarIndex < scalarCount {
            guard let scalar = semantic.textScalar(of: identity, at: scalarIndex)
            else { return false }
            if scalar == 0x0D {
                guard finalizeLine(), lineIndex < UInt16.max else { return false }
                lineIndex += 1
                currentAdvance = 0
                currentHasGlyph = false
                previousWasCarriageReturn = true
            } else if scalar == 0x0A {
                if !previousWasCarriageReturn {
                    guard finalizeLine(), lineIndex < UInt16.max else {
                        return false
                    }
                    lineIndex += 1
                    currentAdvance = 0
                    currentHasGlyph = false
                }
                previousWasCarriageReturn = false
            } else {
                previousWasCarriageReturn = false
                let glyphID =
                    StaticSignalAnalyzerNRFReferenceMetrics.glyph(
                        for: scalar
                    ) ?? StaticSignalAnalyzerNRFReferenceMetrics.replacementGlyph
                guard
                    let metric = StaticSignalAnalyzerNRFReferenceMetrics.metric(
                        for: glyphID
                    ), metric.advanceX >= 0
                else { return false }
                let prospective = currentAdvance + Int32(metric.advanceX)
                let wraps =
                    currentHasGlyph
                    && proposalWidth.map { $0 == 0 || prospective > Int32($0) } == true
                if wraps {
                    guard finalizeLine(), lineIndex < UInt16.max else {
                        return false
                    }
                    lineIndex += 1
                    currentAdvance = 0
                }
                let baselineY = ascent + Int32(lineIndex) * progression
                guard let packedX = Int16(exactly: currentAdvance),
                    let packedY = Int16(exactly: baselineY),
                    workspace.appendGlyph(
                        StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph(
                            identity: identity, lineIndex: lineIndex,
                            glyphID: glyphID,
                            baselineX: packedX, baselineY: packedY
                        ), glyphIndex: localGlyphIndex
                    ), localGlyphIndex < UInt16.max
                else { return false }
                localGlyphIndex += 1
                currentAdvance += Int32(metric.advanceX)
                currentHasGlyph = true
            }
            scalarIndex += 1
        }
        guard finalizeLine() else { return false }
        let idealHeight = lineHeight + Int32(lineIndex) * progression
        let resolvedHeight =
            proposalHeight.map { min(idealHeight, Int32($0)) }
            ?? idealHeight
        guard let idealWidth = Int16(exactly: maximumLineWidth),
            let packedIdealHeight = Int16(exactly: idealHeight),
            let packedResolvedHeight = Int16(exactly: resolvedHeight)
        else { return false }
        return workspace.replaceMeasurement(
            identity: identity,
            idealWidth: idealWidth, idealHeight: packedIdealHeight,
            width: idealWidth, height: packedResolvedHeight
        )
    }
}
