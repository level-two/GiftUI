# SPEC-012 Combined Render Extension Seam Blocker

Resolution: corrected by the approved 2026-09-12 SPEC-012 amendment through
the paired `RenderPreflightExtension` / `RenderStreamingExtension` visitors and
extended `RenderProducer` overloads. The diagnostic below remains historical
implementation evidence.

Plan task: `SPEC-012 T5.1`

Status: blocked in Specification review.

SPEC-012 requires `CanvasRenderProducer` to reuse SPEC-008's complete ordinary
render traversal and inject one borrowed stroke operation at each `.canvas`
painter position. It must preflight without observing a sink and later stream
one combined sequence under exactly one sink `begin`/`finish` pair.

The current `GiftUIRenderLowering` package surface exposes only
`RenderProducer.produce`. Its reusable mechanisms are not package seams:

- `RenderPreflightSummary` and `RenderPreflightResult` are internal;
- `RenderProducer.preflight` and `RenderProducer.stream` are internal;
- `RenderPreflightState` and `RenderStreamingState` are private;
- both recursive per-scope traversal methods are private;
- `.canvas` is currently treated only as a zero-child no-op leaf.

`GiftUIDrawing` therefore cannot add stroke counts during preflight or emit a
stroke at the same traversal position. Calling `RenderProducer.produce` first
or second would produce separate streams and sink lifecycles, and it cannot
provide the sink-free expected header required before publication. Copying the
ordinary traversal into `GiftUIDrawing` is explicitly forbidden by SPEC-012
and plan task T5.5.

An approved correction needs a narrow package extension hook owned by
`GiftUIRenderLowering` that preserves its single traversal, validation order,
foreground/clip semantics, snapshot checks, and sink lifecycle while allowing
the reviewed Canvas contributor to count and synchronously emit its operation.
It must not make backends import `GiftUIDrawing` or expose an operation list.

Reproduce the surface audit from the repository root:

```text
rg -n "package static func|struct RenderPreflight|enum RenderPreflight|private struct Render" Sources/GiftUIRenderLowering
```
