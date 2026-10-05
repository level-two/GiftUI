---
id: ADR-034
feature: signal-analyzer
title: Five-Second Transition Capture
status: accepted
authors:
  - codex
created: 2026-10-05
updated: 2026-10-05
proposal:
  - PROPOSAL-002
related_rfcs:
  - RFC-001
  - RFC-012
related_adrs:
  - ADR-003
related_specs:
  - SPEC-001
  - SPEC-013
  - SPEC-015
related_future_work: []
related_explorations: []
related_spikes: []
supersedes:
  - ADR-003
superseded_by: []
target_milestone: ITERATION-002
---

# ADR-034: Five-Second Transition Capture

## Status

Accepted by [explicit maintainer approval](../iterations/iteration-002-cleanup/retention-approval.md)
on 2026-10-05. This faithfully extracts approved RFC-012; no additional
architecture is selected. ADR-003 is preserved as superseded history.

## Context

The shared reference application exposes 1/2/5s windows without historical
navigation. Three nRF capture slots currently spend 115,392 bytes on 30s history.
Approved RFC-012 chooses the observable history tradeoff while preserving
repository ownership, transition representation, ordering and baseline semantics.

## Decision

The repository MUST own chronological digital `SignalTransition` values,
monotonic elapsed duration, ordering, retention and current-value publication.
The default retained horizon MUST be five seconds. Time trimming MUST retain
transitions exactly at `max(0, duration - 5s)` and evict only earlier ones.
Static storage MUST provide at least 404 transition entries and four separately
stored scalar channel baselines. The capacity covers four channels × 10 cycles/s
× two edges/cycle × 5s = 400 plus four simultaneous inclusive-boundary events.
The 10 Hz/channel density is the validation envelope; existing distinct
production deterministic patterns and seeded schedule MUST remain unchanged.

Time trimming and capacity pressure MUST evict oldest-first and update baselines.
Equal-time arrival order, out-of-horizon rejection, Clear epoch rebasing,
immutable snapshots, publication/borrow/slot lifetime and revision exhaustion
MUST retain their existing semantics. Dynamic and Static captures MUST preserve
equivalent retained levels and paths for all 1/2/5s views. Live, model and
admission nRF slots MUST resize together: `3 × 404 × 16 = 19,392` bytes.
No fourth buffer or heap fallback is introduced.

The sustained validation workload MUST remain 30s at 80 delivered events/s,
2,404 accepted facts including four initial levels. Retained count and delivered
count MUST use separate oracles. Its synchronized final retained window is
25–30s inclusive, 404 events; its delivery revision is 2,404. Timing obligations
and their existing exception provenance remain unchanged.

## Rationale

Five seconds covers the largest exposed window and removes 96,000 capture-storage
bytes. Separate baseline levels preserve correct left-edge reconstruction after
time/capacity eviction. Boundary headroom supports the accepted density without
changing signal patterns or shortening validation to hide delivery obligations.

## Consequences

### Positive

- All exposed windows remain reconstructable; fixed capture RAM falls by 96,000 bytes.
- Existing application layering, record ABI and allocation policy remain stable.

### Negative

- Complete-capture consumers lose older history and must migrate expectations.
- Three slot constants, C guards, fixtures and resource reports require coordinated updates.
- Smaller history does not establish physical timing or exhaustive stack bounds.

### Follow-up

- Amend SPEC-001/015 and affected SPEC-013 resource assumptions; derive exact tasks.
- Validate inclusive/equal-time/404/405/replay/Clear/reuse, independent full-history
  left edges, presentation/raster parity and unchanged 30s delivery.
- Report matched total linked RAM/flash, ABI/heaps/configured stack and connected limits.

## Deferred and Follow-up Work

Performance remains FW-027/FW-032 and full connected conformance FW-031/FW-033,
as linked by RFC-012. Neither conceals a prerequisite for this retention decision.

## Rejected Alternatives

### Retain 30s/2,404

Preserves older complete history but spends RAM beyond the current UI's navigation.

### Smaller ring with older history elsewhere

Adds ownership/storage policy and relocates the cost without a current requirement.

### Reduce source density, workload duration or capacity below 404

Weakens the accepted workload or inclusive-boundary envelope and is not approved.

## References

- [Approved RFC-012](../rfcs/rfc-012-five-second-capture-retention-amendment.md)
- [Accepted PROPOSAL-002](../proposals/proposal-002-signal-analyzer-reference-application.md)
- [Superseded ADR-003](adr-003-transition-based-bounded-capture.md)
- [Iteration scope](../iterations/iteration-002-cleanup.md)
