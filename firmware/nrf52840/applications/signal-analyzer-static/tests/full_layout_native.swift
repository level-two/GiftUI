import GiftUI
import GiftUILayout
import GiftUISemanticCore

private struct StartupTextFixture: SemanticLayoutView {
    let scalars: [UInt32]
    let rootIdentity: UInt16 = 1
    let scopeCount: UInt16 = 1
    func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? { identity == 1 ? .text : nil }
    func childCount(of identity: UInt16) -> UInt16? { identity == 1 ? 0 : nil }
    func child(of identity: UInt16, at index: UInt16) -> UInt16? { nil }
    func modifierCount(of identity: UInt16) -> UInt16? { identity == 1 ? 0 : nil }
    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? { nil }
    func modifier(of identity: UInt16, at index: UInt16) -> SemanticLayoutModifier? { nil }
    func textScalarCount(of identity: UInt16) -> UInt16? { identity == 1 ? UInt16(scalars.count) : nil }
    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        identity == 1 && Int(index) < scalars.count ? scalars[Int(index)] : nil
    }
}

private func checkStartupTextCorpus() {
    let scopes = UnsafeMutableRawPointer.allocate(byteCount: 3_136, alignment: 8)
    let text = UnsafeMutableRawPointer.allocate(byteCount: 4_704, alignment: 8)
    defer { scopes.deallocate(); text.deallocate() }
    var workspace = StaticSignalAnalyzerNRFCommonLayoutWorkspace(
        packed: StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
            scopes: UnsafeMutableRawBufferPointer(start: scopes, count: 3_136),
            text: UnsafeMutableRawBufferPointer(start: text, count: 4_704))!)
    let cases: [(scalars: [UInt32], width: GeometryScalar, height: GeometryScalar, lines: UInt16, glyphs: UInt16, lineLimit: UInt16, glyphLimit: UInt16, succeeds: Bool)] = [
        ([], 320, 240, 1, 0, 128, 224, true),
        ([13, 10, 68, 10, 13, 68], 320, 240, 4, 2, 128, 224, true),
        ([68, 68], 1, 1, 2, 2, 128, 224, true),
        ([68, 68], 320, 240, 1, 2, 128, 2, true),
        ([68, 68], 320, 240, 1, 2, 128, 1, false),
        ([10], 320, 240, 2, 0, 2, 224, true),
        ([10], 320, 240, 2, 0, 1, 224, false),
        (Array(repeating: 10, count: 127), 320, 240, 128, 0, 128, 224, true),
        (Array(repeating: 10, count: 128), 320, 240, 129, 0, 128, 224, false),
        (Array(repeating: 68, count: 224), 320, 240, 9, 224, 128, 224, true),
        (Array(repeating: 68, count: 225), 320, 240, 9, 225, 128, 224, false),
    ]
    // The registered D glyph advances 12 points: 26 glyphs fit a 320-point line.
    for _ in 0 ..< 2 {
        for item in cases {
            let limits = LayoutLimits(maximumScopes: 98, maximumDepth: 19,
                maximumTextScalars: 224, maximumTextLines: item.lineLimit,
                maximumPositionedGlyphs: item.glyphLimit)!
            var engine = LayoutEngine(limits: limits, validatedCounters: LayoutCounters(limits: limits))
            let zero = Size(width: 0, height: 0)!
            precondition(workspace.acquireLayout())
            precondition(workspace.appendScope(identity: 1, measurement: LayoutMeasurement(idealSize: zero, resolvedSize: zero)))
            let semantic = StartupTextFixture(scalars: item.scalars)
            let measurement = engine.measure(semantic: semantic, metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
                proposal: ProposedSize(width: item.width, height: item.height)!, workspace: &workspace)
            precondition((measurement != nil) == item.succeeds, "startup shared text bound")
            if let measurement {
                precondition(workspace.textLineCount == item.lines)
                precondition(workspace.positionedGlyphCount == item.glyphs)
                precondition(workspace.textLine(at: workspace.textLineCount) == nil)
                precondition(workspace.positionedGlyph(at: workspace.positionedGlyphCount) == nil)
                let bounds = Rect(origin: Point(x: 7, y: 11), size: measurement.resolvedSize)!
                precondition(engine.place(semantic: semantic, metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
                    rootBounds: bounds, workspace: &workspace))
                precondition(workspace.packed.reserveTextScalars(engine.finalCounters.textScalarCount))
                let published = workspace.packed.publish(rootIdentity: 1, expectedScopeCount: 1)!
                precondition(published.isPublished)
                precondition(published.line(at: 0)?.identity == 1)
                workspace.resetLayout()
                precondition(!published.isPublished)
            } else {
                workspace.resetLayout()
            }
            precondition(!workspace.isLayoutActive && workspace.scopeCount == 0)
        }
    }
    let limits = LayoutLimits(maximumScopes: 98, maximumDepth: 19,
        maximumTextScalars: 224, maximumTextLines: 128, maximumPositionedGlyphs: 224)!
    var engine = LayoutEngine(limits: limits, validatedCounters: LayoutCounters(limits: limits))
    precondition(workspace.acquireLayout())
    let zero = Size(width: 0, height: 0)!
    precondition(workspace.appendScope(identity: 1, measurement: LayoutMeasurement(idealSize: zero, resolvedSize: zero)))
    let semantic = StartupTextFixture(scalars: [68, 68])
    let measurement = engine.measure(semantic: semantic, metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
        proposal: ProposedSize(width: 320, height: 240)!, workspace: &workspace)!
    let overflow = Rect(origin: Point(x: 32_767, y: 0), size: measurement.resolvedSize)!
    precondition(!engine.place(semantic: semantic, metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
        rootBounds: overflow, workspace: &workspace))
    workspace.resetLayout()
    precondition(!workspace.isLayoutActive)
}

// Execute the firmware's exact amalgamated Swift source on a native host.
// This checks the production diagnostic semantic-to-layout path without a board.
@main
struct FullLayoutNativeCheck {
    private static func dispatchAction(
        _ code: UInt16, revision: UInt32,
        profile: UnsafeMutableRawPointer,
        capture: UnsafeMutableRawPointer
    ) {
        let packed = giftUISignalAnalyzerActionPoint(code)
        precondition(packed != 0, "enabled action point missing")
        let x = UInt16(packed & 0xffff)
        let y = UInt16(packed >> 16)
        precondition(giftUISignalAnalyzerInputAdmit(0, x, y, revision, 1) == 0xff)
        precondition(giftUISignalAnalyzerInputAdmit(2, x, y, revision, 0) == 0xff)
        precondition(
            giftUISignalAnalyzerDrainInitialInput(
                profile, 39_696, capture, 19_392
            ) == 2,
            "admitted action did not dispatch"
        )
        precondition(giftUISignalAnalyzerInputPendingCount() == 0)
    }

    private static let accept: @convention(c) (
        UInt16, UInt16, UInt16, UInt16, UnsafePointer<UInt8>?, Int
    ) -> Int32 = { x, y, width, height, pixels, byteCount in
        x < 320 && y < 240 && width > 0 && height == 1
            && UInt32(x) + UInt32(width) <= 320
            && byteCount == Int(width) * 2 && pixels != nil ? 0 : -1
    }

    private static let refuse: @convention(c) (
        UInt16, UInt16, UInt16, UInt16, UnsafePointer<UInt8>?, Int
    ) -> Int32 = { _, _, _, _, _, _ in -1 }

    static func main() {
        checkStartupTextCorpus()
        let profile = UnsafeMutableRawPointer.allocate(byteCount: 39_696, alignment: 8)
        let capture = UnsafeMutableRawPointer.allocate(byteCount: 19_392, alignment: 8)
        let raster = UnsafeMutableRawPointer.allocate(byteCount: 2_560, alignment: 8)
        let coverage = UnsafeMutableRawPointer.allocate(byteCount: 160, alignment: 8)
        defer {
            profile.deallocate()
            capture.deallocate()
            raster.deallocate()
            coverage.deallocate()
        }
        profile.initializeMemory(as: UInt8.self, repeating: 0, count: 39_696)
        capture.initializeMemory(as: UInt8.self, repeating: 0, count: 19_392)
        raster.initializeMemory(as: UInt8.self, repeating: 0, count: 2_560)
        coverage.initializeMemory(as: UInt8.self, repeating: 0, count: 160)
        precondition(
            giftUISignalAnalyzerTopologyValid(profile, 39_696, capture, 19_392) == 1,
            "diagnostic semantic topology failed"
        )
        precondition(giftUISignalAnalyzerLayoutTextValid(profile, 39_696) == 1)
        precondition(giftUISignalAnalyzerLayoutTextValid(nil, 39_696) == 0)
        precondition(giftUISignalAnalyzerLayoutTextValid(profile, 39_695) == 0)
        precondition(giftUISignalAnalyzerLayoutTextValid(profile, 39_696) == 1)
        precondition(
            giftUISignalAnalyzerFullLayoutValid(profile, 39_696) == 1,
            "full diagnostic layout failed"
        )
        precondition(
            giftUISignalAnalyzerDrawingStorageValid(profile, 39_696) == 1,
            "fixed Drawing workspace failed"
        )
        precondition(
            giftUISignalAnalyzerCanvasPayloadValid(profile, 39_696) == 1,
            "bounded Canvas payload failed"
        )
        precondition(
            giftUISignalAnalyzerFullCanvasValid(
                profile, 39_696, capture, 19_392, raster, 2_560,
                coverage, 160
            ) == 1,
            "five Canvas derivation failed"
        )
        precondition(
            giftUISignalAnalyzerRepositoryProducerValid(
                profile, 39_696, capture, 19_392
            ) == 1,
            "embedded action dispatch did not apply repository facts"
        )
        precondition(
            giftUISignalAnalyzerPresentInitial(
                profile, 39_696, nil, 19_392, raster, 2_560,
                coverage, 160, accept
            ) == 0,
            "invalid bootstrap capture region was accepted"
        )
        precondition(giftUISignalAnalyzerInitialModelActive() == 0)
        precondition(giftUISignalAnalyzerInitialCommittedActions() == 0)
        precondition(giftUISignalAnalyzerInitialGestureReady() == 0)
        precondition(
            giftUISignalAnalyzerPresentInitial(
                profile, 39_696, capture, 19_392, raster, 2_560,
                coverage, 160, accept
            ) == 1,
            "initial Canvas offer failed"
        )
        precondition(giftUISignalAnalyzerInitialModelActive() == 1)
        precondition(giftUISignalAnalyzerInitialCommittedActions() == 3)
        precondition(giftUISignalAnalyzerInitialGestureReady() == 1)
        precondition(giftUISignalAnalyzerNeedsPresentation() == 0)
        precondition(giftUISignalAnalyzerCurrentRevision() == 1)
        precondition(giftUISignalAnalyzerNextDelayMicroseconds() == UInt64.max)
        let published = UnsafeMutableRawBufferPointer(
            start: profile.advanced(by: 3_024), count: 3_024
        )
        precondition(
            StaticSignalAnalyzerNRFEmbeddedSemanticView(published: published)?
                .scopeCount == 92,
            "initial offer retained the diagnostic semantic table"
        )
        // Standalone validator revisions do not consume the freshly activated
        // common runner's semantic allocator. Its first publication is 1.
        precondition(
            StaticSignalAnalyzerNRFEmbeddedSemanticView(published: published)?
                .revision == 1,
            "initial offer did not start the canonical semantic revision"
        )
        precondition(giftUISignalAnalyzerInputInitialize(1) == 0)
        precondition(
            giftUISignalAnalyzerInputAdmit(0, 20, 20, 0, 1) == 0x0101,
            "uncommitted presentation admitted input"
        )
        precondition(giftUISignalAnalyzerInputPendingCount() == 0)
        let startPoint = giftUISignalAnalyzerInitialStartPoint()
        let startX = UInt16(startPoint & 0xffff)
        let startY = UInt16(startPoint >> 16)
        precondition(startPoint != 0)
        precondition(giftUISignalAnalyzerInputInstallPresentation(1) == 0)
        precondition(
            giftUISignalAnalyzerInputAdmit(0, startX, startY, 1, 0) == 0xff
        )
        precondition(
            giftUISignalAnalyzerInputAdmit(2, startX, startY, 1, 0) == 0xff
        )
        precondition(giftUISignalAnalyzerInputPendingCount() == 2)
        precondition(
            giftUISignalAnalyzerDrainInitialInput(
                profile, 39_696, capture, 19_392
            ) == 2,
            "queued Start action did not dispatch through repository"
        )
        precondition(giftUISignalAnalyzerInputPendingCount() == 0)
        precondition(giftUISignalAnalyzerNeedsPresentation() == 1)
        precondition(giftUISignalAnalyzerNextDelayMicroseconds() == 80_000)
        let scheduledResult = giftUISignalAnalyzerPollScheduledDue(
            profile, 39_696, capture, 19_392
        )
        precondition(
            scheduledResult == 1,
            "scheduled repository fact was not applied"
        )
        precondition(giftUISignalAnalyzerNeedsPresentation() == 1)
        let nextOffer = giftUISignalAnalyzerPresentNext(
            profile, 39_696, capture, 19_392, raster, 2_560,
            coverage, 160, accept
        )
        precondition(
            nextOffer == 1,
            "second physical Canvas offer failed"
        )
        precondition(giftUISignalAnalyzerNeedsPresentation() == 0)
        precondition(giftUISignalAnalyzerCurrentRevision() == 2)
        precondition(
            StaticSignalAnalyzerNRFEmbeddedSemanticView(published: published)?
                .revision == 2,
            "second offer did not advance semantic revision"
        )
        precondition(giftUISignalAnalyzerInitialGestureReady() == 1)
        precondition(
            giftUISignalAnalyzerInputAdmit(0, startX, startY, 1, 1) != 0xff,
            "prior physical revision admitted a touch after replacement"
        )
        precondition(giftUISignalAnalyzerInputPendingCount() == 0)
        // The approved touch amendment exposes Stop, window increase from 2 s
        // to 5 s, decrease to 2 s, decrease to 1 s, and increase to 2 s in turn.
        for (step, code) in [UInt16(1), 5, 4, 3, 4].enumerated() {
            dispatchAction(
                code, revision: UInt32(step) + 2,
                profile: profile, capture: capture
            )
            if step < 4 {
                precondition(
                    giftUISignalAnalyzerPresentNext(
                        profile, 39_696, capture, 19_392,
                        raster, 2_560, coverage, 160, accept
                    ) == 1,
                    "action did not produce the next physical frame"
                )
            }
        }
        precondition(
            giftUISignalAnalyzerPresentInitial(
                profile, 39_696, capture, 19_392, raster, 2_560,
                coverage, 160, accept
            ) == 0,
            "active model admitted a second initial offer"
        )
        precondition(giftUISignalAnalyzerInitialGestureReady() == 1)
        giftUISignalAnalyzerRetireInitial()
        giftUISignalAnalyzerInputQuiesce()
        precondition(giftUISignalAnalyzerInitialModelActive() == 0)
        precondition(giftUISignalAnalyzerInitialCommittedActions() == 0)
        precondition(giftUISignalAnalyzerInitialGestureReady() == 0)
        precondition(
            giftUISignalAnalyzerPresentInitial(
                profile, 39_696, capture, 19_392, raster, 2_560,
                coverage, 160, refuse
            ) == 0,
            "initial Canvas offer hid display refusal"
        )
        precondition(giftUISignalAnalyzerInitialModelActive() == 0)
        precondition(giftUISignalAnalyzerInitialCommittedActions() == 0)
        precondition(giftUISignalAnalyzerInitialGestureReady() == 0)
        precondition(
            giftUISignalAnalyzerPresentInitial(
                profile, 39_696, capture, 19_392, raster, 2_560,
                coverage, 160, accept
            ) == 1,
            "retired model could not activate again"
        )
        precondition(giftUISignalAnalyzerInitialCommittedActions() == 3)
        precondition(giftUISignalAnalyzerInitialGestureReady() == 1)
        precondition(
            giftUISignalAnalyzerPresentNext(
                profile, 39_696, capture, 19_392, raster, 2_560,
                coverage, 160, refuse
            ) == 0,
            "replacement display refusal was accepted"
        )
        precondition(giftUISignalAnalyzerInitialCommittedActions() == 0)
        precondition(giftUISignalAnalyzerInitialGestureReady() == 0)
        precondition(
            giftUISignalAnalyzerTileValid(raster, 2_560, coverage, 160) == 1,
            "fixed RGB565 tile failed"
        )
        print("nRF layout and Drawing storage: passed")
    }
}
