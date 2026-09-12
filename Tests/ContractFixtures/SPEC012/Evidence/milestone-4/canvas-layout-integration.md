# SPEC-012 Canvas Layout Integration Evidence

Plan task: `SPEC-012 T4.1`

Canvas travels through the existing SPEC-006 generic primitive identity into
the production SPEC-007 layout engine. Its additive branch uses each present
proposal axis and zero for an absent axis before applying the ordinary cap and
frame rules. The result preserves exact bounds and the inherited clip and
creates no child, text line, glyph, hit, clip-source, or ordinary paint output.

Identity is not translated or re-created: the semantic-result adapter stages
the concrete Canvas payload under the structural identity; the render view
selects that same identity as its layout identity; and the generic layout sink
receives it unchanged for both unframed and fixed-frame cases. Dynamic,
recording, and fixed identity representations normalize to the same Canvas
layout transcript.

Reproduce from the repository root:

```text
swift test --filter canvasExpansionPublishes
swift test --filter canvasDirectView
swift test --filter directCanvasView
swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter CanvasInvocationAdapterTests
```
