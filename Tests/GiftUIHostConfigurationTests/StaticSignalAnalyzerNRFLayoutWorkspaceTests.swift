import GiftUI
import GiftUILayout
import GiftUIReferenceTextResources
import GiftUITextResources
import Testing

@testable import SignalAnalyzerTargetHost

@Test func staticNRFLayoutWorkspaceRetainsGeometryAndDerivesTextFieldsInFixedRegions() {
    var scopeBytes = [UInt8](repeating: 0, count: 3_136)
    var textBytes = [UInt8](repeating: 0, count: 4_704)
    scopeBytes.withUnsafeMutableBytes { scopes in
        textBytes.withUnsafeMutableBytes { text in
            var workspace = StaticSignalAnalyzerNRFLayoutWorkspace(scopes: scopes, text: text)!
            let zero = Rect(origin: Point(x: 0, y: 0), size: Size(width: 0, height: 0)!)!
            let size = Size(width: 100, height: 40)!
            let measurement = LayoutMeasurement(idealSize: size, resolvedSize: size)
            let bounds = Rect(origin: Point(x: 10, y: 20), size: size)!
            let clip = Rect(
                origin: Point(x: 15, y: 25), size: Size(width: 40, height: 25)!
            )!
            let placement = LayoutPlacement(bounds: bounds, clip: clip)
            let lineBounds = Rect(
                origin: Point(x: 0, y: 0), size: Size(width: 70, height: 20)!
            )!
            let instance = GiftUIReferenceTextMetricsView().instance(at: 0)!.id
            let glyphID = GlyphID(rawValue: 7)

            #expect({ workspace.acquireLayout() }())
            #expect({ workspace.appendScope(identity: 17, measurement: measurement) }())
            #expect({ !workspace.appendScope(identity: 17, measurement: measurement) }())
            #expect({ workspace.pushScope(17) }())
            #expect(
                {
                    workspace.appendTextLine(
                        LayoutTextLine(
                            identity: 17, lineIndex: 0, bounds: lineBounds,
                            baseline: Point(x: 0, y: 16), clip: zero
                        ))
                }())
            #expect(
                {
                    workspace.appendPositionedGlyph(
                        LayoutPositionedGlyph(
                            identity: 17, lineIndex: 0, glyphIndex: 0, instance: instance,
                            glyph: glyphID, baseline: Point(x: 3, y: 16), clip: zero
                        ))
                }())
            #expect({ workspace.storePlacement(placement, for: 17) }())
            let placedLine = Rect(
                origin: Point(x: 10, y: 20), size: lineBounds.size
            )!
            let lineClip = LayoutGeometry.intersection(clip, placedLine)!
            #expect(
                {
                    workspace.storeTextLine(
                        LayoutTextLine(
                            identity: 17, lineIndex: 0, bounds: placedLine,
                            baseline: Point(x: 10, y: 36), clip: lineClip
                        ), at: 0)
                }())
            #expect(
                {
                    workspace.storePositionedGlyph(
                        LayoutPositionedGlyph(
                            identity: 17, lineIndex: 0, glyphIndex: 0, instance: instance,
                            glyph: glyphID, baseline: Point(x: 13, y: 36), clip: lineClip
                        ), at: 0)
                }())
            #expect(workspace.scopeIdentity(at: 0) == 17)
            #expect(workspace.measurement(for: 17) == measurement)
            #expect(workspace.placement(for: 17) == placement)
            #expect(workspace.textLine(at: 0)?.clip == lineClip)
            #expect(workspace.positionedGlyph(at: 0)?.baseline == Point(x: 13, y: 36))
            #expect(workspace.positionedGlyph(at: 0)?.clip == lineClip)
            #expect(text[StaticSignalAnalyzerNRFLayoutTextCodec.scratchOffset] == 17)
            workspace.popScope()
            #expect(text[StaticSignalAnalyzerNRFLayoutTextCodec.scratchOffset] == 0)
            workspace.resetLayout()
            #expect(!workspace.isLayoutActive)
            #expect(workspace.scopeIdentity(at: 0) == nil)
            #expect(scopes.allSatisfy { $0 == 0 })
            #expect(text.allSatisfy { $0 == 0 })
        }
    }
}

@Test func staticNRFLayoutWorkspaceRejectsWrongRegionsAndTextMetadata() {
    var shortScopes = [UInt8](repeating: 0, count: 3_135)
    var textBytes = [UInt8](repeating: 0, count: 4_704)
    shortScopes.withUnsafeMutableBytes { scopes in
        textBytes.withUnsafeMutableBytes { text in
            #expect(StaticSignalAnalyzerNRFLayoutWorkspace(scopes: scopes, text: text) == nil)
        }
    }

    var scopeBytes = [UInt8](repeating: 0, count: 3_136)
    scopeBytes.withUnsafeMutableBytes { scopes in
        textBytes.withUnsafeMutableBytes { text in
            var workspace = StaticSignalAnalyzerNRFLayoutWorkspace(scopes: scopes, text: text)!
            let size = Size(width: 1, height: 1)!
            let measurement = LayoutMeasurement(idealSize: size, resolvedSize: size)
            let zero = Rect(origin: Point(x: 0, y: 0), size: Size(width: 0, height: 0)!)!
            #expect({ !workspace.appendScope(identity: 1, measurement: measurement) }())
            #expect({ workspace.acquireLayout() }())
            #expect({ !workspace.acquireLayout() }())
            #expect({ workspace.appendScope(identity: 1, measurement: measurement) }())
            #expect({ !workspace.pushScope(2) }())
            #expect(
                {
                    !workspace.appendTextLine(
                        LayoutTextLine(
                            identity: 2, lineIndex: 0, bounds: zero,
                            baseline: Point(x: 0, y: 0), clip: zero
                        ))
                }())
            let instance = GiftUIReferenceTextMetricsView().instance(at: 0)!.id
            #expect(
                {
                    !workspace.appendPositionedGlyph(
                        LayoutPositionedGlyph(
                            identity: 1, lineIndex: 0, glyphIndex: 1, instance: instance,
                            glyph: GlyphID(rawValue: 1), baseline: Point(x: 0, y: 0), clip: zero
                        ))
                }())
            #expect(workspace.scopeCount == 1)
            #expect(workspace.textLineCount == 0)
            #expect(workspace.positionedGlyphCount == 0)
        }
    }
}
