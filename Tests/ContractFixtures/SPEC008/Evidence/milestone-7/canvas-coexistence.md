# T7.4 Canvas Coexistence Audit

The SPEC-008 criterion set, canonical event schema, base corpus, and Signal
Analyzer manifest remain free of Canvas and stroke cases. The ordinary semantic
render cases and ordered fill/glyph sink surface are unchanged, and the exact
ordinary streaming transcript still executes through `RenderProducer`.

The approved SPEC-012 contract can extend the existing generic primitive
payload/visitor seam, semantic render scope, and ordered operation sink. Its
ready plan retains ownership of the combined producer and the future
zero-Canvas comparison between producer entry points; this task does not add
Canvas declarations, drawing plans, normalized strokes, or drawing behavior.

Reproduce with:

```console
scripts/contracts/check-spec-008-canvas-coexistence.rb
swift test --filter streamingRepeatsCanonicalLookupsAndEmitsTheExactOrderedValues
```
