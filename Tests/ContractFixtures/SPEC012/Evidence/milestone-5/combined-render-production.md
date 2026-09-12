# SPEC-012 T5.2 Combined Render Production Evidence

`RenderProducer` now implements the approved additive production overload with
one acquired caller-owned workspace and the same ordinary preflight and
streaming traversals used by SPEC-008. The overload validates the exact
expected header and actual sink capacity after preflight, calls preflight
extension completion before `begin`, and calls streaming extension completion
after the complete stream and before `finish`. Ordinary rendering supplies
empty extensions whose completion succeeds without changing its public entry
point or transcript.

`CanvasRenderProducer.produce` supplies plan-backed preflight and streaming
extensions. Each validates exact Canvas identity, origin, inherited clip,
stroke, point, subpath, and summary meaning. Streaming exposes each immutable
snapshot as one synchronously borrowed `straightLineStroke` operation at its
Canvas painter position and retains no operation list or payload borrow.

Focused tests prove:

- one background fill and one stroke use one combined begin/finish transaction;
- the stroke carries the exact header, translated points, and explicit subpath;
- the workspace is acquired and reset exactly once;
- actual sink capacity is read once before `begin`; and
- a final plan-summary disagreement fails before `begin` with no discard.

Reproduce the focused evidence with:

```sh
swift test --filter GiftUIDrawingTests
swift test --filter GiftUIRenderLoweringTests
```

These are host tests. Canonical multi-operation transcripts, the complete
fault matrix, cross-profile evidence, and module/source audits remain assigned
to T5.3-T5.5 and later profile tasks.
