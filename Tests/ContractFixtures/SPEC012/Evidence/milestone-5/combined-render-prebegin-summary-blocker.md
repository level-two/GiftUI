# SPEC-012 T5.2 Pre-Begin Summary Blocker

## Required ordering

SPEC-012 requires `CanvasRenderProducer.produce` to construct its paired
extensions, delegate to the extended `RenderProducer.produce`, and establish
all of the following before the one `sink.begin` call:

1. complete ordinary-plus-stroke header equality with `expectedHeader`;
2. actual sink-capacity sufficiency; and
3. complete equality between the visited Canvas/stroke/point/subpath/normalized
   totals and `drawingPlan.summary`.

It also prohibits `CanvasRenderProducer` from independently recursing through
semantic or layout scopes.

## Missing seam

`RenderPreflightExtension.visit` is called once per scope in preorder and can
accumulate the required plan totals. The amended
`RenderProducer.produce` signature accepts that visitor by `inout`, but the
producer performs preflight, calls `begin`, streams, and finishes before it
returns. The visitor protocol has no post-traversal completion method, and the
producer has no pre-`begin` validation callback or value carrying extension
totals.

Consequently `CanvasRenderProducer` cannot inspect the completed visitor until
after output has begun. A per-scope visitor cannot fail reliably on the last
scope because the API supplies neither traversal position nor a postorder/end
event. Header equality cannot substitute: `RenderPlanHeader` carries operation
and glyph totals, not Canvas, point, or subpath totals. In particular, a plan
summary that declares one missing zero-stroke Canvas or a wrong point/subpath
count can preserve the expected render header.

## Rejected workarounds

- A separate Canvas recursion violates the sole shared traversal requirement.
- Calling public preflight before extended produce adds an extra authoritative
  traversal and still does not make the delegate validate Canvas summary at
  its own pre-`begin` boundary.
- Guessing a terminal identity from ordinal order is not guaranteed by the
  visitor contract and remains preorder for a terminal parent.
- Adding an unapproved completion protocol, callback, or downcast would widen
  the exact package SPI and conceal the contract defect.

T5.2-T5.5 must remain paused until the approved Specification supplies a
post-preflight/pre-`begin` completion result or another exact equivalent. This
is a source-contract blocker, not deferred work and not permission to weaken
the plan-summary invariant.

## Disposition

The maintainer explicitly approved the focused SPEC-012 amendment on
2026-09-12. It adds an exact completion result to both render-extension
protocols and requires preflight completion after the sole traversal and before
`sink.begin`, plus paired streaming completion before `sink.finish`. This
evidence continues to record the resolved defect; T5.2-T5.5 may resume through
the amended contract.
