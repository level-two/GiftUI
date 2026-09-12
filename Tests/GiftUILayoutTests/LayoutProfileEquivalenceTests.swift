import GiftUI
import GiftUIReferenceTextResources
import GiftUISemanticCore
import GiftUITextResources
import Testing

@testable import GiftUILayout

@Test
func recordingDynamicAndStaticViewsProduceIdenticalLayoutTranscripts() {
    let recording = runProfileLayout(ProfileSemantic<RecordingProfileIdentity>())
    let dynamic = runProfileLayout(ProfileSemantic<DynamicProfileIdentity>())
    let fixed = runProfileLayout(ProfileSemantic<StaticProfileIdentity>())

    #expect(recording == dynamic)
    #expect(dynamic == fixed)
    #expect(recording.summary.scopeCount == 8)
    #expect(recording.summary.textScalarCount == 2)
    #expect(recording.summary.textLineCount == 1)
    #expect(recording.summary.positionedGlyphCount == 2)
    #expect(recording.summary.maximumObservedDepth == 4)
}

@Test
func canvasDirectViewUsesProposalOrZeroAndFixedFrameExpansionWithoutExtraOutput() {
    let unframed = runCanvasLayout(
        CanvasSemantic<RecordingProfileIdentity>(hasFrame: false),
        proposal: ProposedSize(width: 17)!
    )
    let unframedBounds = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 17, height: 0)!
    )!
    #expect(unframed.summary.scopeCount == 1)
    #expect(unframed.summary.rootBounds == unframedBounds)
    #expect(
        unframed.scopes == [.init(token: .canvas, bounds: unframedBounds, clip: unframedBounds)])
    #expect(unframed.summary.textScalarCount == 0)
    #expect(unframed.summary.textLineCount == 0)
    #expect(unframed.summary.positionedGlyphCount == 0)

    let framed = runCanvasLayout(
        CanvasSemantic<RecordingProfileIdentity>(hasFrame: true),
        proposal: ProposedSize(width: 50, height: 40)!
    )
    let framedBounds = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 31, height: 19)!
    )!
    #expect(framed.summary.scopeCount == 2)
    #expect(framed.summary.rootBounds == framedBounds)
    #expect(framed.scopes.map(\.token) == [.canvasFrame, .canvas])
    #expect(framed.scopes.allSatisfy { $0.bounds == framedBounds && $0.clip == framedBounds })
}

private enum ProfileToken: UInt8, Equatable, Sendable {
    case root
    case text
    case horizontal
    case spacer
    case overlay
    case overlaySpacer
    case textPadding
    case overlayFrame
    case canvas
    case canvasFrame
}

private protocol ProfileIdentity: Equatable, Sendable {
    init(_ token: ProfileToken)
    var token: ProfileToken { get }
}

private struct RecordingProfileIdentity: ProfileIdentity {
    let path: (UInt8, UInt8, UInt8)
    let token: ProfileToken

    init(_ token: ProfileToken) {
        self.token = token
        path = (0x31, token.rawValue, 0xa7)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.path.0 == rhs.path.0 && lhs.path.1 == rhs.path.1
            && lhs.path.2 == rhs.path.2 && lhs.token == rhs.token
    }
}

private struct DynamicProfileIdentity: ProfileIdentity {
    let slot: UInt32
    let token: ProfileToken

    init(_ token: ProfileToken) {
        self.token = token
        slot = 0x4000 + UInt32(token.rawValue) * 17
    }
}

private enum StaticProfileIdentity: UInt16, ProfileIdentity {
    case root = 0x701
    case text = 0x119
    case horizontal = 0x5a0
    case spacer = 0x02d
    case overlay = 0x640
    case overlaySpacer = 0x203
    case textPadding = 0x7c1
    case overlayFrame = 0x355
    case canvas = 0x4a2
    case canvasFrame = 0x6b4

    init(_ token: ProfileToken) {
        switch token {
        case .root: self = .root
        case .text: self = .text
        case .horizontal: self = .horizontal
        case .spacer: self = .spacer
        case .overlay: self = .overlay
        case .overlaySpacer: self = .overlaySpacer
        case .textPadding: self = .textPadding
        case .overlayFrame: self = .overlayFrame
        case .canvas: self = .canvas
        case .canvasFrame: self = .canvasFrame
        }
    }

    var token: ProfileToken {
        switch self {
        case .root: .root
        case .text: .text
        case .horizontal: .horizontal
        case .spacer: .spacer
        case .overlay: .overlay
        case .overlaySpacer: .overlaySpacer
        case .textPadding: .textPadding
        case .overlayFrame: .overlayFrame
        case .canvas: .canvas
        case .canvasFrame: .canvasFrame
        }
    }
}

private struct ProfileSemantic<Identity: ProfileIdentity>: SemanticLayoutView {
    let rootIdentity = Identity(.root)
    let scopeCount: UInt16 = 8

    func primitive(at identity: Identity) -> SemanticLayoutPrimitive? {
        switch identity.token {
        case .root: .vStack(alignment: .leading, spacing: 2)
        case .text: .text
        case .horizontal: .hStack(alignment: .center, spacing: 0)
        case .spacer, .overlaySpacer: .spacer(minLength: 0)
        case .overlay: .zStack(alignment: .leading)
        case .textPadding, .overlayFrame: nil
        case .canvas, .canvasFrame: nil
        }
    }

    func childCount(of identity: Identity) -> UInt16? {
        switch identity.token {
        case .root: 3
        case .horizontal, .overlay: 1
        default: 0
        }
    }

    func child(of identity: Identity, at index: UInt16) -> Identity? {
        switch (identity.token, index) {
        case (.root, 0): Identity(.text)
        case (.root, 1): Identity(.horizontal)
        case (.root, 2): Identity(.overlay)
        case (.horizontal, 0): Identity(.spacer)
        case (.overlay, 0): Identity(.overlaySpacer)
        default: nil
        }
    }

    func modifierCount(of identity: Identity) -> UInt16? {
        switch identity.token {
        case .text, .overlaySpacer: 1
        default: 0
        }
    }

    func modifierScope(of identity: Identity, at index: UInt16) -> Identity? {
        guard index == 0 else { return nil }
        return switch identity.token {
        case .text: Identity(.textPadding)
        case .overlaySpacer: Identity(.overlayFrame)
        default: nil
        }
    }

    func modifier(of identity: Identity, at index: UInt16) -> SemanticLayoutModifier? {
        guard index == 0 else { return nil }
        return switch identity.token {
        case .text: .padding(edges: .all, length: 1)
        case .overlaySpacer:
            .flexibleFrame(
                minWidth: 4,
                maxWidth: .infinity,
                minHeight: 3,
                maxHeight: .points(5),
                alignment: .center
            )
        default: nil
        }
    }

    func textScalarCount(of identity: Identity) -> UInt16? {
        identity.token == .text ? 2 : nil
    }

    func textScalar(of identity: Identity, at index: UInt16) -> UInt32? {
        guard identity.token == .text else { return nil }
        return switch index {
        case 0: 0x41
        case 1: 0x00b0
        default: nil
        }
    }
}

private struct CanvasSemantic<Identity: ProfileIdentity>: SemanticLayoutView {
    let rootIdentity = Identity(.canvas)
    let hasFrame: Bool
    var scopeCount: UInt16 { hasFrame ? 2 : 1 }

    func primitive(at identity: Identity) -> SemanticLayoutPrimitive? {
        identity.token == .canvas ? .canvas : nil
    }

    func childCount(of identity: Identity) -> UInt16? {
        identity.token == .canvas || identity.token == .canvasFrame ? 0 : nil
    }

    func child(of _: Identity, at _: UInt16) -> Identity? { nil }

    func modifierCount(of identity: Identity) -> UInt16? {
        identity.token == .canvas ? (hasFrame ? 1 : 0) : 0
    }

    func modifierScope(of identity: Identity, at index: UInt16) -> Identity? {
        identity.token == .canvas && hasFrame && index == 0 ? Identity(.canvasFrame) : nil
    }

    func modifier(of identity: Identity, at index: UInt16) -> SemanticLayoutModifier? {
        guard identity.token == .canvas, hasFrame, index == 0 else { return nil }
        return .fixedFrame(width: 31, height: 19, alignment: .center)
    }

    func textScalarCount(of identity: Identity) -> UInt16? {
        _ = identity
        return nil
    }

    func textScalar(of _: Identity, at _: UInt16) -> UInt32? { nil }
}

private struct NormalizedProfileResult: Equatable {
    let summary: LayoutSummary
    let events: [String]
}

private struct CanvasScopeObservation: Equatable {
    let token: ProfileToken
    let bounds: Rect
    let clip: Rect
}

private struct CanvasLayoutObservation {
    let summary: LayoutSummary
    let scopes: [CanvasScopeObservation]
}

private func runCanvasLayout<Identity: ProfileIdentity>(
    _ semantic: CanvasSemantic<Identity>,
    proposal: ProposedSize
) -> CanvasLayoutObservation {
    var workspace = ProfileWorkspace<Identity>()
    var sink = ProfileSink<Identity>()
    let result = layout(
        semantic: semantic,
        metrics: GiftUIReferenceTextResources.targetPackage.metrics,
        proposal: proposal,
        limits: LayoutLimits(
            maximumScopes: 2,
            maximumDepth: 2,
            maximumTextScalars: 1,
            maximumTextLines: 1,
            maximumPositionedGlyphs: 1
        )!,
        workspace: &workspace,
        sink: &sink
    )
    guard case .success(let summary) = result, sink.summary == summary else {
        Issue.record("Canvas layout failed: \(result)")
        return CanvasLayoutObservation(
            summary: LayoutSummary(
                scopeCount: 0,
                textScalarCount: 0,
                textLineCount: 0,
                positionedGlyphCount: 0,
                maximumObservedDepth: 0,
                rootBounds: Rect(
                    origin: Point(x: 0, y: 0),
                    size: Size(width: 0, height: 0)!
                )!
            ),
            scopes: []
        )
    }
    return CanvasLayoutObservation(summary: summary, scopes: sink.scopes)
}

private func runProfileLayout<Identity: ProfileIdentity>(
    _ semantic: ProfileSemantic<Identity>
) -> NormalizedProfileResult {
    var workspace = ProfileWorkspace<Identity>()
    var sink = ProfileSink<Identity>()
    let limits = LayoutLimits(
        maximumScopes: 16,
        maximumDepth: 8,
        maximumTextScalars: 16,
        maximumTextLines: 8,
        maximumPositionedGlyphs: 16
    )!
    let result = layout(
        semantic: semantic,
        metrics: GiftUIReferenceTextResources.targetPackage.metrics,
        proposal: ProposedSize(width: 80, height: 60)!,
        limits: limits,
        workspace: &workspace,
        sink: &sink
    )

    #expect(result == .success(sink.summary!))
    #expect(!workspace.isLayoutActive)
    #expect(!sink.isLayoutActive)
    return NormalizedProfileResult(summary: sink.summary!, events: sink.events)
}

private struct ProfileWorkspace<Identity: ProfileIdentity>: LayoutWorkspace {
    let maximumScopes: UInt16 = 16
    let maximumDepth: UInt16 = 8
    let maximumTextScalars: UInt16 = 16
    let maximumTextLines: UInt16 = 8
    let maximumPositionedGlyphs: UInt16 = 16
    var isLayoutActive = false
    private var scopes: [(Identity, LayoutMeasurement, LayoutPlacement?)] = []
    private var lines: [LayoutTextLine<Identity>] = []
    private var glyphs: [LayoutPositionedGlyph<Identity>] = []
    private var depth: [Identity] = []

    mutating func acquireLayout() -> Bool {
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        return true
    }

    mutating func appendScope(
        identity: borrowing Identity,
        measurement: LayoutMeasurement
    ) -> Bool {
        let value = copy identity
        guard scopes.count < Int(maximumScopes),
            !scopes.contains(where: { $0.0 == value })
        else { return false }
        scopes.append((value, measurement, nil))
        return true
    }

    var scopeCount: UInt16 { UInt16(scopes.count) }

    func scopeIdentity(at index: UInt16) -> Identity? {
        guard Int(index) < scopes.count else { return nil }
        return scopes[Int(index)].0
    }

    func measurement(for identity: borrowing Identity) -> LayoutMeasurement? {
        let value = copy identity
        return scopes.first(where: { $0.0 == value })?.1
    }

    mutating func storeMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: borrowing Identity
    ) -> Bool {
        let value = copy identity
        guard let index = scopes.firstIndex(where: { $0.0 == value }) else {
            return false
        }
        scopes[index].1 = measurement
        return true
    }

    mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing Identity
    ) -> Bool {
        let value = copy identity
        guard let index = scopes.firstIndex(where: { $0.0 == value }),
            scopes[index].2 == nil
        else { return false }
        scopes[index].2 = placement
        return true
    }

    func placement(for identity: borrowing Identity) -> LayoutPlacement? {
        let value = copy identity
        return scopes.first(where: { $0.0 == value })?.2
    }

    var textLineCount: UInt16 { UInt16(lines.count) }

    mutating func appendTextLine(_ line: LayoutTextLine<Identity>) -> Bool {
        guard lines.count < Int(maximumTextLines) else { return false }
        lines.append(line)
        return true
    }

    func textLine(at index: UInt16) -> LayoutTextLine<Identity>? {
        guard Int(index) < lines.count else { return nil }
        return lines[Int(index)]
    }

    mutating func storeTextLine(
        _ line: LayoutTextLine<Identity>,
        at index: UInt16
    ) -> Bool {
        guard Int(index) < lines.count else { return false }
        lines[Int(index)] = line
        return true
    }

    var positionedGlyphCount: UInt16 { UInt16(glyphs.count) }

    mutating func appendPositionedGlyph(
        _ glyph: LayoutPositionedGlyph<Identity>
    ) -> Bool {
        guard glyphs.count < Int(maximumPositionedGlyphs) else { return false }
        glyphs.append(glyph)
        return true
    }

    func positionedGlyph(at index: UInt16) -> LayoutPositionedGlyph<Identity>? {
        guard Int(index) < glyphs.count else { return nil }
        return glyphs[Int(index)]
    }

    mutating func storePositionedGlyph(
        _ glyph: LayoutPositionedGlyph<Identity>,
        at index: UInt16
    ) -> Bool {
        guard Int(index) < glyphs.count else { return false }
        glyphs[Int(index)] = glyph
        return true
    }

    mutating func pushScope(_ identity: borrowing Identity) -> Bool {
        guard depth.count < Int(maximumDepth) else { return false }
        depth.append(copy identity)
        return true
    }

    mutating func popScope() {
        _ = depth.popLast()
    }

    mutating func resetLayout() {
        scopes.removeAll(keepingCapacity: true)
        lines.removeAll(keepingCapacity: true)
        glyphs.removeAll(keepingCapacity: true)
        depth.removeAll(keepingCapacity: true)
        isLayoutActive = false
    }
}

private struct ProfileSink<Identity: ProfileIdentity>:
    LayoutResultSink, LayoutResultSinkState
{
    var isLayoutActive = false
    var summary: LayoutSummary?
    var events: [String] = []
    var scopes: [CanvasScopeObservation] = []

    mutating func begin(summary: LayoutSummary) -> Bool {
        self.summary = summary
        isLayoutActive = true
        events.append("begin:\(summary)")
        return true
    }

    mutating func stageScope(identity: Identity, bounds: Rect, clip: Rect) -> Bool {
        scopes.append(.init(token: identity.token, bounds: bounds, clip: clip))
        events.append("scope:\(identity.token):\(bounds):\(clip)")
        return true
    }

    mutating func stageTextLine(
        identity: Identity,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) -> Bool {
        events.append(
            "line:\(identity.token):\(lineIndex):\(bounds):\(baseline):\(clip)"
        )
        return true
    }

    mutating func stageGlyph(
        identity: Identity,
        lineIndex: UInt16,
        glyphIndex: UInt16,
        instance: FontInstanceID,
        glyph: GlyphID,
        baseline: Point,
        clip: Rect
    ) -> Bool {
        events.append(
            "glyph:\(identity.token):\(lineIndex):\(glyphIndex):\(instance):\(glyph):\(baseline):\(clip)"
        )
        return true
    }

    mutating func publish() -> Bool {
        events.append("publish")
        isLayoutActive = false
        return true
    }

    mutating func discard() {
        events.append("discard")
        isLayoutActive = false
    }
}
