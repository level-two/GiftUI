# SPEC-012 Drawing Fault and Work Evidence

Plan task: `SPEC-012 T3.6`

The cumulative Milestone 3 corpus faults the live Path and immutable plan at
every local state, arithmetic, capacity, validation, and final storage-commit
boundary. The focused T3.6 cases add all four caller-storage refusals after
successful prevalidation, live-count overflow, normalized-count disagreement,
plan-count overflow, independent point/subpath exhaustion, and final snapshot
append refusal. Earlier T3 tests supply inactive/reentrant scope, missing
current point, malformed range/data, style, stroke capacity, and lifecycle
faults. Each case compares complete former storage or commit counters and
exposes no partial snapshot or plan.

The precedence probe combines invalid width with counting Path storage and a
recording plan: `.invalidValue` occurs with zero point/subpath lookups and zero
append attempts. The work probe runs 1, 2, 4, and 8 admitted points and records
exactly `2 * pointCount` point lookups plus two subpath lookups for one
subpath—the validation pass and atomic-copy pass. It reports live high-water
`(points, 1 subpath)` separately from immutable-plan high-water
`(1 stroke, points, 1 subpath)`.

Reproduce from the repository root:

```text
swift test --filter DrawingFaultAndWorkTests
swift test --filter PathConstructionTests
swift test --filter StrokeSnapshotTests
swift test --filter DrawingPlanWorkspaceTests
```
