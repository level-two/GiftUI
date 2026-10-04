---
id: FW-027
feature: signal-analyzer
title: Pi Performance Investigation Resumption
status: captured
authors:
  - codex
created: 2026-09-30
updated: 2026-10-04
source:
  - SPEC-001
related_future_work:
  - FW-024
  - FW-025
  - FW-026
  - FW-032
related_explorations: []
related_spikes:
  - SPIKE-013
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-027: Pi Performance Investigation Resumption

## Observation / Opportunity

The Pi cold-frame investigation retained bounded semantic/layout lookup reuse,
sort-once publication, exact raster scan and pixel access improvements, and
framebuffer row projection reuse. Historical complete-frame measurements still
exceed the 250 ms policy; the timer-free sort-once runs averaged approximately
1.56 seconds. This is a known conformance gap, not a completed performance gate.

## Why Deferred

On 2026-09-30 the maintainer stopped performance experiments to prioritize the
remaining MVP work. Preserve measured evidence and compatible improvements;
do not continue speculative optimization during this closeout.

## Potential Value

- Resume from recorded phase measurements instead of repeating investigation.
- Compare bounded alternatives against exact pixels, failure semantics, and
  complete-frame cost once the remaining MVP work is ready for review.

## Current Non-goals

- No waiver or weakening of SPEC-001 cadence, resource, or connected-input
  requirements. SPEC-001 closes with an explicitly approved exception;
  the measured timing gap remains preserved for future iterations.
- No architecture or Specification amendment, new buffer, endpoint bypass,
  partial frames or cross-frame reuse. Hardware operations require their own
  maintainer authorization, provided for the later bounded measurement campaign.

## Revisit Triggers

- The maintainer starts the next performance-improvement iteration.
- A maintainer explicitly reprioritizes Pi responsiveness after reviewing the
  current measured gap and resource/failure constraints.

## Disposition

Captured. Further investigation is postponed. Resume compatible internal work
under the existing approved contract; any changed contract or architecture
must first pass its normal review and human approval gates.

On 2026-10-03 the maintainer explicitly postponed the Pi timing fix to the next
iterations while requesting final-artifact validation and connected evidence.
The final artifact's bounded connected run measured approximately 0.72 frames
per second, with 1.294–1.522-second frame costs. Resume when the maintainer
starts the next Pi timing iteration, before attempting full MVP conformance.
The subsequent maintainer instruction closes SPEC-001 as implemented under
an approved exception and postpones all performance improvement. Cadence and
deadline-safe interaction remain unmet measurements, with their original
requirements retained. [Recorded approval](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md)
supersedes the earlier no-exception disposition.

## 2026-10-04 bounded measurement update

The maintainer authorized hardware measurements/experiments after cleanup
research. The unchanged Pi artifact reproduced 0.717fps and 1.272–1.513s idle
frame costs at sampled peak RSS 9,748KiB. The application completed bounded
teardown; no service changed. [Connected reconciliation](../iterations/iteration-002-review/24-connected-reconciliation.md)
records exact identities and limitations. Compatible optimization remains
unselected; this baseline does not close the four-fps/sustained-workload gap.

## References

- [Closeout and retained implementation](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/pi-performance-closeout-20260930.md)
- [SPEC-001 implementation plan](../implementation-plans/spec-001-implementation-plan.md)
- [FW-024 partial frames](fw-024-pi-partial-frame-presentation.md)
- [FW-025 cross-frame reuse](fw-025-pi-cross-frame-work-reuse.md)
- [FW-026 physical-surface presentation](fw-026-pi-complete-physical-surface-presentation.md)
- [Current iteration closeout](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md)

- [nRF performance](fw-032-nrf-performance-improvement.md)
