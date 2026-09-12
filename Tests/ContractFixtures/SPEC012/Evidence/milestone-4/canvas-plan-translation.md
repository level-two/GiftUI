# SPEC-012 Canvas Plan Translation Evidence

Plan task: `SPEC-012 T4.4`

The construction-workspace fixture now binds the existing scoped Path and
stroke-snapshot engines to each Canvas identity, resolved surface origin, and
inherited logical clip. Before committing a snapshot it checked-adds the
origin to every local point. The immutable plan stores translated points while
retaining the origin solely as coordinate-space metadata and carries the
inherited clip without intersecting it with Canvas bounds.

The focused success fixture records local points `(1,2)` and `(3,4)` at origin
`(10,20)` and observes exactly `(11,22)` and `(13,24)`, one unchanged origin,
one unchanged inherited clip, one stroke, two points, one subpath, and one
normalized operation. This distinguishes correct single translation from both
missing and double translation.

The overflow fixture combines `Int32.max` surface X with local X `1`. It
returns `.arithmeticOverflow`, releases the callable, discards and resets the
whole acquired plan, and exposes no stroke. Sealing independently verifies
that normalized-operation count equals stroke count before publishing the
summary.

Reproduce from the repository root:

```text
swift test --filter CanvasPlanProducer
```
