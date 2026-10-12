import GiftUI
import GiftUISemanticCore
import GiftUITextResources

package func publishLayout<Workspace, Sink>(
    summary: LayoutSummary,
    workspace: inout Workspace,
    sink: inout Sink
) -> LayoutResult
where
    Workspace: LayoutWorkspace,
    Sink: LayoutResultSink,
    Workspace.Identity == Sink.Identity
{
    defer { workspace.resetLayout() }

    guard workspace.scopeCount == summary.scopeCount,
        workspace.textLineCount == summary.textLineCount,
        workspace.positionedGlyphCount == summary.positionedGlyphCount,
        workspace.scopeIdentity(at: summary.scopeCount) == nil,
        workspace.textLine(at: summary.textLineCount) == nil,
        workspace.positionedGlyph(at: summary.positionedGlyphCount) == nil
    else {
        return .failure(.invariantViolation)
    }

    guard sink.begin(summary: summary) else {
        return .failure(.capacityExhausted)
    }

    var scopeIndex: UInt16 = 0
    var lineIndex: UInt16 = 0
    var glyphIndex: UInt16 = 0
    while scopeIndex < workspace.scopeCount {
        guard
            let identity = workspace.scopeIdentity(at: scopeIndex),
            let placement = workspace.placement(for: identity),
            sink.stageScope(
                identity: identity,
                bounds: placement.bounds,
                clip: placement.clip
            )
        else {
            sink.discard()
            return .failure(.invariantViolation)
        }

        var expectedLineIndex: UInt16 = 0
        var expectedGlyphIndex: UInt16 = 0
        while lineIndex < workspace.textLineCount {
            guard let line = workspace.textLine(at: lineIndex) else {
                sink.discard()
                return .failure(.invariantViolation)
            }
            guard line.identity == identity else { break }
            guard line.lineIndex == expectedLineIndex else {
                sink.discard()
                return .failure(.invariantViolation)
            }
            guard
                sink.stageTextLine(
                    identity: line.identity,
                    lineIndex: line.lineIndex,
                    bounds: line.bounds,
                    baseline: line.baseline,
                    clip: line.clip
                )
            else {
                sink.discard()
                return .failure(.invariantViolation)
            }
            while glyphIndex < workspace.positionedGlyphCount {
                guard let glyph = workspace.positionedGlyph(at: glyphIndex) else {
                    sink.discard()
                    return .failure(.invariantViolation)
                }
                guard glyph.identity == identity, glyph.lineIndex == line.lineIndex else {
                    break
                }
                guard glyph.glyphIndex == expectedGlyphIndex else {
                    sink.discard()
                    return .failure(.invariantViolation)
                }
                guard
                    sink.stageGlyph(
                        identity: glyph.identity,
                        lineIndex: glyph.lineIndex,
                        glyphIndex: glyph.glyphIndex,
                        instance: glyph.instance,
                        glyph: glyph.glyph,
                        baseline: glyph.baseline,
                        clip: glyph.clip
                    )
                else {
                    sink.discard()
                    return .failure(.invariantViolation)
                }
                glyphIndex += 1
                expectedGlyphIndex += 1
            }
            lineIndex += 1
            expectedLineIndex += 1
        }
        if lineIndex < workspace.textLineCount,
            workspace.textLine(at: lineIndex)?.identity == identity
        {
            sink.discard()
            return .failure(.invariantViolation)
        }
        if glyphIndex < workspace.positionedGlyphCount,
            workspace.positionedGlyph(at: glyphIndex)?.identity == identity
        {
            sink.discard()
            return .failure(.invariantViolation)
        }
        scopeIndex += 1
    }

    guard lineIndex == summary.textLineCount,
        glyphIndex == summary.positionedGlyphCount,
        sink.publish()
    else {
        sink.discard()
        return .failure(.invariantViolation)
    }
    return .success(summary)
}
