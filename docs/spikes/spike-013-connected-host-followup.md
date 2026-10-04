---
id: SPIKE-013
feature: signal-analyzer
title: Connected Host Phase and Failure Follow-up
status: active
authors:
  - codex
created: 2026-10-04
updated: 2026-10-04
source:
  - FW-027
  - FW-032
  - FW-033
related_future_work:
  - FW-027
  - FW-032
  - FW-033
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# SPIKE-013: Connected Host Phase and Failure Follow-up

## Target Questions

Where does the nRF's roughly 21s presentation time go across the actual common
owner stages and SPI writes? What does its real scheduling loop deliver over
wall time? Does a deliberately refused pixel transfer quiesce/retire the graph,
and does a fresh activation restore normal presentation? Which stages dominate
the Pi Dynamic owner, and what does its real source scheduling deliver?

## Bounds / Stop Conditions

Authorized connected research under the maintainer's request to proceed with
remaining tasks. Copied application only, supported board/J-Link/compiler/ABI,
nRF zero heaps and fixed trace storage; Pi preserves its Dynamic profile. No production optimization or contract change,
no fabricated physical contact/pixel signoff. Stop on missing calibration,
trace overflow, ABI/resource failure, CPU fault or uncontrolled device state.
At most six complete nRF frames per case, bounded fault/restart runs and a 45s
Pi observation. Restore
original production firmware afterward.

## Method

Instrument a copied StaticPreset's eleven common-owner stages with CYCCNT entry/exit
samples. Record SPI call counts/bytes/time separately within offer/production.
Preserve original stage bodies and the production scheduling loop. Use a
caller-owned fixed C trace; timing includes interrupts and instrumentation.
Existing startup probes remain linked but the experiment enters production
activation directly, avoiding their unrelated pre-application runtime.

A bounded software action script runs at service boundaries, uses current
revision/hit points and observes actual state/capture changes. Programmatic
Clear and a model diagnostic use the existing native rehearsal hooks compiled
into the copy. Neither creates a new UI control or proves repository failure.
Inject one pixel-write refusal at the selected update's real backend boundary;
observe the production teardown. Attempt a new activation only after verifying
quiescence, and record its outcome rather than assume recovery.

For Pi, copy the package and name a separate research product. Keep all original
Dynamic source bodies, time their eleven common stages with CLOCK_MONOTONIC,
and time the existing mmap projection separately. Preserve automatic acquisition
and the production loop; record actual source deliveries/capture counts in a
bounded 45s run. Do not replace the deployed production executable.

## Reproduction

Disposable preparation/build/collection commands and exact hashes will be
recorded with the results under `experiments/spike-013-connected-host-followup/`.
Connected flashing uses the repository environment and explicit J-Link runner.

## Results

nRF cases completed; Pi collection is blocked by lost SSH connectivity after a verified build. See
[Step 26](../iterations/iteration-002-review/26-connected-nrf-phases-and-failure.md)
for costs, Clear/diagnostic, injected refusal and fresh activation evidence.

## Limitations

Software actions/injected failures do not supply physical touch or a spontaneous
transport malfunction. Phase totals identify bounded workload costs, not every
lookup's independent cost or an optimization decision. A fresh activation is
not a full fault/recovery corpus. Painted extents are observations, not bounds.

## Disposition

Feed measured costs and remaining proof barriers back to FW-032/FW-033.

## References

- [FW-032](../future-work/fw-032-nrf-performance-improvement.md)
- [FW-033](../future-work/fw-033-connected-validation-follow-up.md)
- [Prior connected reconciliation](../iterations/iteration-002-review/24-connected-reconciliation.md)
