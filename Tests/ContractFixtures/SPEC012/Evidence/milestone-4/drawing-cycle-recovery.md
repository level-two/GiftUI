# SPEC-012 Drawing Cycle Recovery Evidence

Plan task: `SPEC-012 T4.5`

A focused cross-owner fixture joins a failing `CanvasPlanProducer` attempt to
SPEC-009's prepublication derivation recovery. The drawing workspace releases
the callable, discards once, and resets once. Recovery preserves the prior
semantic revision and two already-admitted effects, publishes no candidate or
logical frame, marks semantics dirty, and coalesces exactly one later
`.semanticDirty` wake. It never replays the admitted effects.

A separate retryable-refusal fixture finalizes the first plan, records only
SPEC-009's bounded presentation intent `(semanticRevision, refusalCount)`, and
performs a later derivation with a fresh source and fresh construction
workspace under a new cycle ID. Both old and new callable sets are independently
released, and the unchanged semantic revision does not act as callable or plan
storage.

This is the focused owner-adapter integration permitted before SPEC-013's
production coordinator. T7.4 retains the production publication/candidate/
offer integration obligation.

Reproduce from the repository root:

```text
swift test --filter CanvasPlanProducer
```
