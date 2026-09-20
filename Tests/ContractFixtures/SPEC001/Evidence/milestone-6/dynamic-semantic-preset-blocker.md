# SPEC-001 T6.7 Dynamic Semantic Preset Blocker

## Review disposition

**resolved after reapproval** — this report records the former approved-preset
mismatch and the correction completed on 2026-09-20.

## Reproduction

`SignalAnalyzerDynamicSemanticJoinTests` connects the production Dynamic
observable root, observable/semantic bridge, semantic workspace, semantic
store, and the actual `SignalAnalyzerView`. With measurement-only enlarged
limits, the initial application state produces:

| Measurement | Actual | Former Pi preset |
| --- | ---: | ---: |
| semantic nodes | 47 | 62 |
| body evaluations | 14 | 20 |
| modifier applications | 5 | 32 |
| action occurrences | 6 | 6 |
| maximum semantic depth | 26 | 12 |
| structural identities retained by the production store | 80 | 62 semantic-storage slots |
| Canvas occurrences | 5 | 5 |

The companion test used the former Raspberry Pi Dynamic preset and
deterministically receives `capacityExhausted`; it proves the failed candidate
publishes neither semantic state nor an observable registration.

Run:

```text
swift test --filter SignalAnalyzerDynamicSemanticJoinTests
```

## Located findings

1. **Approval blocker — generated maximum depth is not implementable.**
   SPEC-015 requires generated preset counts to cover the fixed SPEC-001
   hierarchy, but the real traversal observes depth 26 while every generated
   preset fixes 12.
2. **Approval blocker — semantic storage accounting omits structural
   identities.** The real traversal retains 80 structural identities. The
   current generated Dynamic semantic byte projection is derived from 62
   semantic-node occurrences and does not establish capacity for those 80
   identities.

## Required correction

Do not enlarge production limits or reinterpret the accepted counting rules
inside T6.7. Correct the checked-in hierarchy/workload descriptor and generated
four-preset values, reconcile SPEC-013 storage bytes, rerun all SPEC-015
generator/negative/profile comparisons, and obtain deliberate human
reapproval of the changed Specification contract before resuming the
production host join.

The issue is not deferred work: connected Pi and nRF execution depends on the
same immutable workload and therefore cannot provide conformance evidence
until the contract is corrected.

## Resolution

The maintainer explicitly reapproved SPEC-013 and SPEC-015 on 2026-09-20.
Schema 3 now records the diagnostic-present maximum of 48 semantic nodes and
81 structural identities, with depth 26, 14 body evaluations, 5 modifiers,
6 actions, and 5 Canvas occurrences. Runtime Core validates candidate and
published structural capacities independently. The Dynamic store consumes the
81-occurrence value, rejects first excess atomically, and the exact generated
Raspberry Pi preset now expands the state-bound application successfully.

Dynamic semantic candidate/published projections are 2,592 bytes each; Static
projections are 1,944 bytes each. Four generated manifests, the 168-row limit
corpus, focused profile/host suites, and macOS Dynamic/Static SPEC-015 contract
runs pass. This former blocker no longer prevents T6.7; the remaining host
layout, Drawing, render, interaction, endpoint, and lifecycle join stays open.
