# SPEC-008 T4.3 Render Streaming Evidence

The second `GiftUIRenderLowering.RenderProducer` traversal repeats the
canonical semantic/layout ordinal, identity, scope, child, mapping, geometry,
line, glyph, resource, out-of-range, and damage lookups. It does not receive a
workspace, call either ordinal visit set, read sink capacity, or retain a
display list or per-field preflight transcript.

With unchanged snapshot versions it calls `begin` once, streams the exact
background fill followed by one whole positioned-glyph group in painter order,
checks emitted totals and both snapshots after the last operation, and calls
`finish` once. A false `begin` returns `.sinkRefused` without discard. Any
later refusal, lookup/count disagreement, or snapshot change returns
`.invariantViolation` and calls `discard` exactly once.

Focused tests verify exact typed values for the header, unclipped fill bounds,
final clips, colors, font instance, glyph identities, baselines, group count,
and finish order. They also prove streaming leaves preflight visit counts
unchanged, introduces no second capacity read, and applies the distinct
begin/post-begin cleanup rules.

Reproduce with:

```text
swift test --filter 'streaming|RenderPreflightTests'
scripts/contracts/check-spec-008-render-streaming.rb
```

This is host execution and source evidence. It performs no simulator run,
deployment, connected-hardware execution, or flashing.
