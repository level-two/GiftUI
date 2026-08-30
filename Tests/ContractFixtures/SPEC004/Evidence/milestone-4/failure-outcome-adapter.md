# SPEC-004 T4.2 Failure Outcome Adapter Evidence

The shared SPEC-003/004 downstream fixture proves the complete frozen mapping:

| Unavailable family | Condition raw value |
| --- | ---: |
| malformed requirement | 12 |
| duplicate contributor | 13 |
| missing contributor | 14 |
| malformed contribution | 15 |
| insufficient capacity | 16 |
| operation-set mismatch | 17 |
| operation-stream mismatch | 18 |
| logical extent overflow | 19 |
| unsupported logical extent | 20 |
| no common canonical pixel encoding | 21 |
| incompatible submission lifetime | 22 |
| incompatible submission handoff | 23 |
| policy has no conforming realization | 24 |
| byte-count overflow | 25 |

Every required-family result is exactly a failure fact with capability origin,
runtime scope, and contained containment. Field, role, capacity, and byte
payloads remain capability-domain detail and cannot alter the mapped
condition. Raw value 11 stays unnamed, and initialization failure never
collapses into the operational-loss condition `requiredFacilityUnavailable`.

The adapter is an unpublished fixture target, not a production host API. Its
only imports are the two owning leaves; neither leaf imports the adapter or the
other leaf. Diagnostics are absent. An available snapshot resolved before
injected refusal, disconnection, and post-handoff transport faults remains
unchanged for every injected fact.

Validated on 2026-08-30 with four focused adapter tests and all four SPEC-003
profile builds. SPEC-004's macOS dynamic graph/boundary harness also passed;
remaining SPEC-004 profiles are checked by the task's final validation matrix.
