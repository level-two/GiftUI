import GiftUI
import GiftUILayout
import GiftUIReferenceTextResources
import GiftUITextResources
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFEmbeddedLayoutWorkspaceMatchesHostScopeRecords() {
    var targetScopeBytes = [UInt8](repeating: 0, count: 3_136)
    var targetTextBytes = [UInt8](repeating: 0, count: 4_704)
    var hostScopeBytes = [UInt8](repeating: 0, count: 3_136)
    var hostTextBytes = [UInt8](repeating: 0, count: 4_704)
    targetScopeBytes.withUnsafeMutableBytes { targetScopes in
        targetTextBytes.withUnsafeMutableBytes { targetText in
            hostScopeBytes.withUnsafeMutableBytes { hostScopes in
                hostTextBytes.withUnsafeMutableBytes { hostText in
                    guard
                        var target = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
                            scopes: targetScopes, text: targetText
                        ),
                        var host = StaticSignalAnalyzerNRFLayoutWorkspace(
                            scopes: hostScopes, text: hostText
                        )
                    else {
                        Issue.record("Exact layout regions must construct")
                        return
                    }
                    let targetAcquired = target.acquire()
                    let hostAcquired = host.acquireLayout()
                    #expect(targetAcquired && hostAcquired)
                    let duplicateAcquire = target.acquire()
                    #expect(!duplicateAcquire)
                    let first = LayoutMeasurement(
                        idealSize: Size(width: 480, height: 320)!,
                        resolvedSize: Size(width: 480, height: 320)!
                    )
                    let targetAppended = target.appendScope(
                        identity: 0xA001,
                        idealWidth: 480, idealHeight: 320,
                        width: 480, height: 320
                    )
                    let hostAppended = host.appendScope(identity: 0xA001, measurement: first)
                    #expect(targetAppended && hostAppended)
                    #expect(target.scopeOrdinal(of: 0xA001) == 0)
                    let duplicateScope = target.appendScope(
                        identity: 0xA001,
                        idealWidth: 1, idealHeight: 1, width: 1, height: 1
                    )
                    #expect(!duplicateScope)
                    #expect([UInt8](targetScopes) == [UInt8](hostScopes))
                    let revised = LayoutMeasurement(
                        idealSize: Size(width: 470, height: 310)!,
                        resolvedSize: first.resolvedSize
                    )
                    let targetReplaced = target.replaceMeasurement(
                        identity: 0xA001,
                        idealWidth: 470, idealHeight: 310,
                        width: 480, height: 320
                    )
                    let hostReplaced = host.storeMeasurement(revised, for: 0xA001)
                    #expect(targetReplaced && hostReplaced)
                    #expect([UInt8](targetScopes) == [UInt8](hostScopes))
                    let zero = Rect(
                        origin: Point(x: 0, y: 0),
                        size: Size(width: 0, height: 0)!
                    )!
                    let instance = GiftUIReferenceTextMetricsView().instance(at: 0)!.id
                    let targetGlyph = StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph(
                        identity: 0xA001, lineIndex: 0, glyphID: 1,
                        baselineX: 0, baselineY: 16
                    )
                    let hostGlyph = LayoutPositionedGlyph(
                        identity: UInt16(0xA001), lineIndex: 0, glyphIndex: 0,
                        instance: instance, glyph: GlyphID(rawValue: 1),
                        baseline: Point(x: 0, y: 16), clip: zero
                    )
                    let targetGlyphAppended = target.appendGlyph(
                        targetGlyph, glyphIndex: 0
                    )
                    let hostGlyphAppended = host.appendPositionedGlyph(hostGlyph)
                    #expect(targetGlyphAppended && hostGlyphAppended)
                    #expect(target.glyph(at: 0) == targetGlyph)
                    #expect([UInt8](targetText) == [UInt8](hostText))
                    let lineBounds = Rect(
                        origin: Point(x: 0, y: 0),
                        size: Size(width: 100, height: 20)!
                    )!
                    let targetLine = StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line(
                        identity: 0xA001, lineIndex: 0,
                        x: 0, y: 0, width: 100, height: 20,
                        baselineX: 0, baselineY: 16
                    )
                    let hostLine = LayoutTextLine(
                        identity: UInt16(0xA001), lineIndex: 0,
                        bounds: lineBounds, baseline: Point(x: 0, y: 16), clip: zero
                    )
                    let targetLineAppended = target.appendTextLine(targetLine)
                    let hostLineAppended = host.appendTextLine(hostLine)
                    #expect(targetLineAppended && hostLineAppended)
                    let duplicateLine = target.appendTextLine(targetLine)
                    #expect(!duplicateLine)
                    #expect(target.textLine(at: 0) == targetLine)
                    #expect([UInt8](targetText) == [UInt8](hostText))
                    let placement = LayoutPlacement(
                        bounds: Rect(
                            origin: Point(x: 0, y: 0),
                            size: first.resolvedSize
                        )!,
                        clip: Rect(
                            origin: Point(x: 0, y: 0),
                            size: first.resolvedSize
                        )!
                    )
                    let targetPlaced = target.placeScope(
                        identity: 0xA001,
                        originX: 0, originY: 0, width: 480, height: 320,
                        clipX: 0, clipY: 0, clipWidth: 480, clipHeight: 320
                    )
                    let hostPlaced = host.storePlacement(placement, for: 0xA001)
                    #expect(targetPlaced && hostPlaced)
                    #expect([UInt8](targetScopes) == [UInt8](hostScopes))
                    let movedBounds = Rect(
                        origin: Point(x: 10, y: 10),
                        size: lineBounds.size
                    )!
                    let movedLine = StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Line(
                        identity: 0xA001, lineIndex: 0,
                        x: 10, y: 10, width: 100, height: 20,
                        baselineX: 10, baselineY: 26
                    )
                    let targetLineReplaced = target.replaceTextLine(movedLine, at: 0)
                    let hostLineReplaced = host.storeTextLine(
                        LayoutTextLine(
                            identity: UInt16(0xA001), lineIndex: 0,
                            bounds: movedBounds, baseline: Point(x: 10, y: 26),
                            clip: movedBounds
                        ), at: 0
                    )
                    #expect(targetLineReplaced && hostLineReplaced)
                    #expect([UInt8](targetText) == [UInt8](hostText))
                    let movedGlyph = StaticSignalAnalyzerNRFEmbeddedLayoutTextCodec.Glyph(
                        identity: 0xA001, lineIndex: 0, glyphID: 1,
                        baselineX: 10, baselineY: 26
                    )
                    let targetGlyphReplaced = target.replaceGlyphBaseline(
                        movedGlyph, at: 0
                    )
                    let hostGlyphReplaced = host.storePositionedGlyph(
                        LayoutPositionedGlyph(
                            identity: UInt16(0xA001), lineIndex: 0, glyphIndex: 0,
                            instance: instance, glyph: GlyphID(rawValue: 1),
                            baseline: Point(x: 10, y: 26), clip: movedBounds
                        ), at: 0
                    )
                    #expect(targetGlyphReplaced && hostGlyphReplaced)
                    #expect([UInt8](targetText) == [UInt8](hostText))
                    let targetPushed = target.pushScope(0xA001)
                    let hostPushed = host.pushScope(0xA001)
                    #expect(targetPushed && hostPushed)
                    #expect([UInt8](targetText) == [UInt8](hostText))
                    target.popScope()
                    host.popScope()
                    #expect([UInt8](targetText) == [UInt8](hostText))
                    target.reset()
                    host.resetLayout()
                    #expect([UInt8](targetScopes) == [UInt8](hostScopes))
                    #expect([UInt8](targetText) == [UInt8](hostText))
                    let reacquired = target.acquire()
                    #expect(reacquired)
                }
            }
        }
    }
}
