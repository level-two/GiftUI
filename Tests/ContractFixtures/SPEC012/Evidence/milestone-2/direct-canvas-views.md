# SPEC-012 Direct Canvas View Evidence

Plan task: `SPEC-012 T2.4`

Three focused host fixtures exercise Canvas through the existing generic
semantic, layout, and render seams:

- semantic expansion publishes one `Body == Never` Canvas primitive at one
  SPEC-006 identity, evaluates no body, invokes no drawing, has zero children,
  modifiers, actions, and text scalars, and projects the same identity into
  `.canvas` layout and render views;
- layout gives Canvas each present proposal axis and zero for each absent axis,
  applies the ordinary fixed-frame rules, preserves its exact resolved bounds
  and inherited clip, and stages no text line or glyph;
- ordinary render traversal locates Canvas between a background fill and a
  text glyph group in semantic painter order while adding no ordinary paint,
  clip, text, glyph, or child event of its own.

Reproduce from the repository root:

```text
swift test --filter canvasExpansionPublishes
swift test --filter canvasDirectView
swift test --filter directCanvasView
```

The fixtures deliberately do not stage or invoke a retained Canvas callable;
that production seam remains blocked by the separately recorded T2.1
Specification review.
