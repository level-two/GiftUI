# SPEC-007 T3.4 Atomic Publication Evidence

`LayoutWorkspace` exposes bounded, identity-preserving sequential scope,
text-line, and positioned-glyph records. `publishLayout` validates complete
summary/count and terminal-index agreement before beginning the sink, then
uses one cursor per store to publish canonical depth-first scope order with a
text scope's lines and glyphs immediately following that scope.

The focused lifecycle corpus proves:

- a complete workspace begins once, stages `scope, scope, line, glyph`,
  publishes once, never discards, and resets once;
- `begin == false` returns capacity exhaustion, preserves prior current
  output, resets the workspace, and does not discard;
- independent scope, line, glyph, and publish refusals return invariant
  failure, discard exactly once, preserve prior current output, and reset;
- malformed complete-workspace metadata fails before begin without discard;
  and
- independently active workspace, active sink, and both-active entry attempts
  reject reentry before input access and do not reset or discard the active
  outer collaborators.

The generic layout entry remains fail-closed until T4/T5 populate real
placements and text records. Those algorithms feed this publication
coordinator; they do not define another publication lifecycle.

Reproduce with:

```text
swift test --filter GiftUILayoutTests
```
