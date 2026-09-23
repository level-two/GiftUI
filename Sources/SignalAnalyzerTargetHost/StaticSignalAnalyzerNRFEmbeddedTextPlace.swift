/// Places a measured text scope and its retained line/glyph records in place.
/// The caller discards the active layout attempt if any field is unrepresentable.
package enum StaticSignalAnalyzerNRFEmbeddedTextPlace {
    package static func run(
        identity: UInt16,
        semantic: StaticSignalAnalyzerNRFEmbeddedSemanticView,
        originX: Int16, originY: Int16,
        inheritedClipX: Int16, inheritedClipY: Int16,
        inheritedClipWidth: Int16, inheritedClipHeight: Int16,
        workspace: inout StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace
    ) -> Bool {
        guard semantic.layoutPrimitive(at: identity) == .text,
            let ordinal = workspace.scopeOrdinal(of: identity),
            let measured = workspace.scope(at: ordinal),
            inheritedClipWidth >= 0, inheritedClipHeight >= 0,
            let scopeClip = intersection(
                x: originX, y: originY,
                width: measured.width, height: measured.height,
                otherX: inheritedClipX, otherY: inheritedClipY,
                otherWidth: inheritedClipWidth, otherHeight: inheritedClipHeight
            ),
            workspace.placeScope(
                identity: identity,
                originX: originX, originY: originY,
                width: measured.width, height: measured.height,
                clipX: scopeClip.x, clipY: scopeClip.y,
                clipWidth: scopeClip.width, clipHeight: scopeClip.height
            )
        else { return false }

        var lineFound = false
        var lineOrdinal: UInt16 = 0
        while lineOrdinal < workspace.textLineCount {
            guard let line = workspace.textLine(at: lineOrdinal) else {
                return false
            }
            if line.identity == identity {
                lineFound = true
                guard let x = Int16(exactly: Int32(line.x) + Int32(originX)),
                    let y = Int16(exactly: Int32(line.y) + Int32(originY)),
                    let baselineX = Int16(exactly: Int32(line.baselineX) + Int32(originX)),
                    let baselineY = Int16(exactly: Int32(line.baselineY) + Int32(originY)),
                    intersection(
                        x: x, y: y, width: line.width, height: line.height,
                        otherX: scopeClip.x, otherY: scopeClip.y,
                        otherWidth: scopeClip.width, otherHeight: scopeClip.height
                    ) != nil,
                    workspace.replaceTextLine(
                        StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line(
                            identity: identity, lineIndex: line.lineIndex,
                            x: x, y: y,
                            width: line.width, height: line.height,
                            baselineX: baselineX, baselineY: baselineY
                        ), at: lineOrdinal
                    )
                else { return false }
            }
            lineOrdinal += 1
        }
        guard lineFound else { return false }

        var glyphOrdinal: UInt16 = 0
        while glyphOrdinal < workspace.positionedGlyphCount {
            guard let glyph = workspace.glyph(at: glyphOrdinal) else {
                return false
            }
            if glyph.identity == identity {
                guard let baselineX = Int16(exactly: Int32(glyph.baselineX) + Int32(originX)),
                    let baselineY = Int16(exactly: Int32(glyph.baselineY) + Int32(originY)),
                    workspace.replaceGlyphBaseline(
                        StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph(
                            identity: identity, lineIndex: glyph.lineIndex,
                            glyphID: glyph.glyphID,
                            baselineX: baselineX, baselineY: baselineY
                        ), at: glyphOrdinal
                    )
                else { return false }
            }
            glyphOrdinal += 1
        }
        return true
    }

    private struct Intersection {
        let x: Int16
        let y: Int16
        let width: Int16
        let height: Int16
    }

    private static func intersection(
        x: Int16, y: Int16, width: Int16, height: Int16,
        otherX: Int16, otherY: Int16,
        otherWidth: Int16, otherHeight: Int16
    ) -> Intersection? {
        guard width >= 0, height >= 0, otherWidth >= 0, otherHeight >= 0
        else { return nil }
        let minimumX = max(Int32(x), Int32(otherX))
        let minimumY = max(Int32(y), Int32(otherY))
        let maximumX = min(Int32(x) + Int32(width), Int32(otherX) + Int32(otherWidth))
        let maximumY = min(Int32(y) + Int32(height), Int32(otherY) + Int32(otherHeight))
        let intersectionWidth = max(0, maximumX - minimumX)
        let intersectionHeight = max(0, maximumY - minimumY)
        guard let packedX = Int16(exactly: minimumX),
            let packedY = Int16(exactly: minimumY),
            let packedWidth = Int16(exactly: intersectionWidth),
            let packedHeight = Int16(exactly: intersectionHeight)
        else { return nil }
        return Intersection(
            x: packedX, y: packedY,
            width: packedWidth, height: packedHeight
        )
    }
}
