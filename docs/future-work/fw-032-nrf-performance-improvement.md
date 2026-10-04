---
id: FW-032
feature: signal-analyzer
title: nRF Performance Improvement
status: captured
authors:
  - codex
created: 2026-10-03
updated: 2026-10-04
source:
  - SPEC-001
  - SPEC-015
related_future_work:
  - FW-027
  - FW-033
related_explorations: []
related_spikes:
  - SPIKE-012
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-032: nRF Performance Improvement

## Observation / Opportunity

The final nRF52840 firmware presents approximately every 21 seconds in the
connected software-Start observation, failing SPEC-001 cadence. Zero sampled
CPU/driver faults and a matching nine-record deterministic capture prefix do
not establish compliant sustained admission, mutation, publication or frame
costs. Startup/idle stack use is measured at 19,480 / 27,648 bytes; worst-case
loaded use remains unproved.

The 2026-10-04 cleanup audit identified repeated linear identity lookups in
the packed semantic/render and layout adapters. [CBR-005](../iterations/iteration-002-review/findings.md#cbr-005--repeated-packed-identity-lookups-need-phase-measurements)
preserves this profiling hypothesis. Their aggregate cost and contribution to
the observed cadence have not been measured; no optimization is selected.

## Why Deferred

On 2026-10-03 the maintainer explicitly postponed performance improvement to
future iterations and directed the remaining Specifications to be treated as
done. SPEC-001 and SPEC-015 are implemented under the recorded closeout
exception. Preserve the gap and measurements for the next performance iteration.

## Potential Value

- Restore required responsiveness while preserving exact pixels, bounded
  storage, zero heap, failure semantics and approved host ownership.
- Measure phase costs and sustained 80-Hz admission on the identified target
  before selecting internal improvements.

## Current Non-goals

- No numerical requirement amendment or inference that current timing passes.
- No architecture change, new buffering policy or selected production
  optimization. Later authorized disposable measurements are evidence only.

## Revisit Triggers

- The maintainer starts the next performance-improvement iteration.
- A target responsiveness issue makes nRF timing a priority for a release.

On resumption, measure phase costs and lookup call counts on the identified
firmware before choosing an index or changing packed storage. Preserve bounds,
identity validation, pixels, heap policy, and failure behavior.

## Disposition

Captured for future iterations under the explicit maintainer instruction.
Resume compatible internal work against the existing approved contracts;
contract or architecture changes require their normal review and approval.

## 2026-10-04 bounded measurement update

The maintainer authorized hardware measurements/experiments after cleanup
research. Fresh production observations reproduce a 21.2s median publication
gap and a 19,480-byte startup/idle sentinel extent. [SPIKE-012](../spikes/spike-012-connected-hierarchy-costs.md)
measures approximately 55.6ms packed staging and 54.3ms named-role staging,
plus a different-work counting prerequisite. This does not isolate lookup call
counts, explain the whole frame gap or prove sustained admission.
[Connected reconciliation](../iterations/iteration-002-review/24-connected-reconciliation.md)
records restored production firmware and remaining coverage. Performance
remediation remains captured/unselected; original requirements/exception stand.

## References

- [Cleanup review CBR-005](../iterations/iteration-002-review/findings.md#cbr-005--repeated-packed-identity-lookups-need-phase-measurements)
- [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
- [SPEC-015](../specs/spec-015-host-configuration.md)
- [Pi performance](fw-027-pi-performance-investigation-resumption.md)
- [Connected evidence](fw-033-connected-validation-follow-up.md)
- [Measured closeout](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md)
- [Maintainer approval](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md)
