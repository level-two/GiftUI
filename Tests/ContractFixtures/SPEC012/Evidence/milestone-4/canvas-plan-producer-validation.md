# SPEC-012 Canvas Plan Producer Validation Evidence

Plan task: `SPEC-012 T4.2`

`CanvasPlanProducer.derive` now consumes only the amended
`DrawingPlanConstructionWorkspace` seam. Before client invocation it validates
idle workspace state, deriving phase, active cycle, absent candidate frame,
attempt Canvas capacity, dense source access, unique identities, exact layout
lookup, and strictly increasing painter ordinals. Each admitted occurrence is
entered with its exact resolved origin, inherited clip, and size.

Focused fixtures cover both allowed semantic-revision forms, workspace reentry,
wrong phase, absent cycle, existing candidate, duplicate/missing/out-of-range
identity, missing layout, reversed
painter order, and first-excess occurrence capacity. Eight named detectable
client violations cover observed-state mutation, action dispatch, fact
submission, wake request, capability/backend query, cycle start, and cycle
reentry. The first seven map to `.invalidPhase`; reentry maps to
`.reentrancyViolation`; no later callable is invoked.

On every failure after acquisition the producer releases remaining staged
callables, discards once, resets once, and exposes no plan. The later T4.3-T4.5
tasks retain ownership of the complete callable-lifetime, translated-snapshot,
and execution-cycle integration corpora.

Reproduce from the repository root:

```text
swift test --filter CanvasPlanProducer
scripts/contracts/check-spec-012-module-contract.rb
swift package dump-package | scripts/contracts/check-target-dependencies.rb
```
