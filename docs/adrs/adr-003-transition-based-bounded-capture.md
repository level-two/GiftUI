---
id: ADR-003
feature: signal-analyzer
title: Transition-Based Bounded Capture
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-14
updated: 2026-08-14
proposal:
  - PROPOSAL-002
related_rfcs:
  - RFC-001
related_adrs:
  - ADR-001
  - ADR-002
  - ADR-004
related_specs:
  - SPEC-001
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-003: Transition-Based Bounded Capture

## Status

Accepted.

## Context

The Signal Analyzer displays four digital channels with input frequencies
through 10 Hz and retains 30 seconds of history. Periodic sample storage would
spend memory on unchanged values, while a time-only retention rule would not
bound memory without an accepted event-rate limit. Removing old transitions
also risks losing the level that applies at the retained window's lower bound.

[RFC-001](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
approved transition-based storage, repository ownership, the maximum input
rate, a minimum embedded capacity, oldest-first eviction, and baseline
preservation.

## Decision

The analyzer MUST represent digital input as chronological
`SignalTransition` values containing a channel identifier, monotonic elapsed
`Duration`, and resulting low or high level. The repository MUST own storage,
ordering, capture duration, retention, and publication of current capture
values.

Each of four channels supports 10 cycles per second and two transitions per
cycle, for at most 80 transition events per second. The default retained
history is 30 seconds. Static storage MUST provide capacity for at least 2,404
transition entries: four initial channel levels plus 2,400 transitions during
the retained interval. It MUST additionally retain the baseline level of every
channel at the current lower bound.

Time-window trimming and capacity overflow MUST evict the oldest transitions
first. Eviction MUST update the per-channel baselines so rendering the retained
window never invents a level merely because its establishing transition was
removed. Dynamic storage MAY use a different representation but MUST preserve
the same ordering, retention, baseline, and overflow behavior.

## Rationale

Digital transition storage scales with changes rather than sampling frequency
and is sufficient to reconstruct straight-line waveforms. The accepted input
rate turns the 30-second history into a concrete static capacity. Oldest-first
eviction preserves the most recent window, while baseline retention preserves
correct rendering at its lower bound.

## Consequences

### Positive

- Unchanged digital levels consume no repeated sample entries.
- Embedded capture memory has a deterministic capacity requirement.
- Dynamic and static repositories expose equivalent observable captures.
- The newest 30 seconds remain renderable after trimming or overflow.

### Negative

- The repository must maintain per-channel baseline state in addition to the
  transition buffer.
- Out-of-order delivery requires deterministic ordering work.
- A 2,404-entry buffer may still consume a material fraction of nRF52840 RAM.
- Future analog or high-frequency acquisition will need a different storage
  decision.

### Follow-up

- The Specification must define exact ordering for equal timestamps,
  out-of-horizon events, overflow publication, clear behavior, and capture
  duration.
- Resource validation must report the concrete transition representation and
  total RAM usage on nRF52840.
- Tests must cover boundary-level reconstruction after both time trimming and
  capacity overflow.

## Rejected Alternatives

### Periodic sample buffers

Periodic samples were rejected because they consume memory for unchanged
levels and introduce an unnecessary sampling frequency into the MVP.

### Unbounded dynamic history

Unbounded storage was rejected because it is incompatible with a continuously
running embedded reference application.

### Time-only retention without baseline state

Dropping every transition older than the lower bound without retaining channel
levels was rejected because it can render the start of the retained window at
the wrong level.

## References

- [RFC-001: Signal Analyzer Application Architecture](../rfcs/rfc-001-signal-analyzer-application-architecture.md)
- [PROPOSAL-002: Signal Analyzer Reference Application](../proposals/proposal-002-signal-analyzer-reference-application.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
