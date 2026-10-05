---
id: RFC-012
feature: signal-analyzer
title: Five-Second Capture Retention Amendment
status: approved
authors:
  - codex
created: 2026-10-05
updated: 2026-10-05
proposal:
  - PROPOSAL-002
related_rfcs:
  - RFC-001
related_adrs:
  - ADR-003
  - ADR-034
related_specs:
  - SPEC-001
  - SPEC-013
  - SPEC-015
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-002
---

# RFC-012: Five-Second Capture Retention Amendment

## Summary

Propose reducing the Signal Analyzer's retained capture horizon from 30s to 5s
and minimum transition capacity from 2,404 to 404 records. Preserve its existing
1/2/5s visible windows, four-channel stress density, elapsed capture duration, publication
protocol, baseline reconstruction and 30s sustained validation workload. Resize
the nRF live, observable-model and admission stores together, saving exactly
96,000 bytes of packed capture storage.

This is the separately reviewed retention amendment to RFC-001 selected by
[ITERATION-002 I2-09](../iterations/iteration-002-cleanup.md). Eugene explicitly approved this direction on 2026-10-05;
[approval provenance](../iterations/iteration-002-cleanup/retention-approval.md)
authorizes faithful successor decision, coordinated contracts and derived plan
before production changes. ADR-034 records the accepted successor policy.

## Context

[Accepted PROPOSAL-002](../proposals/proposal-002-signal-analyzer-reference-application.md)
establishes the shared analyzer as the reference workload. Approved RFC-001 and
[accepted ADR-003](../adrs/adr-003-transition-based-bounded-capture.md) chose
transition storage, 30s retention, oldest-first eviction and per-channel
baselines. Existing SPEC-001/015 implementations allocate three nRF stores of
2,404 16-byte records: 115,392 bytes, materially constraining the board's RAM.

The presentation exposes 1s, 2s and 5s windows and no historical navigation.
[Step 14](../iterations/iteration-002-review/14-five-second-retention-impact.md)
measured an isolated 5s/404 candidate: 96,000 fewer RAM bytes, 2,410 replay/history
comparisons and 7,200 full-history left-edge level comparisons. Those experiments
support the proposal; they do not establish production conformance or approval.
The existing timing and connected-validation exceptions remain separate.

## Scope and Decision Boundary

This amendment owns one independently reviewable change to RFC-001's retention
policy and resulting capture capacity. A separate amendment record preserves
RFC-001's approved historical reasoning and permits acceptance/rejection without
reopening its unrelated application layering. It does not supersede RFC-001 as
a whole. A successor to ADR-003 will establish the accepted retention policy;
no successor ID or acceptance is assigned before approval.

Execution/admission, observable lifetime, interaction, layout, Canvas, backend
and hardware owners remain under their existing accepted decisions. Their
resource declarations and derived evidence are consumers of this change, not
new ownership or negotiation choices. No draft RFC dependency is introduced.

## Requirements

The proposed successor decision and contracts would require:

1. A default 5s retained horizon and at least 404 Static transition entries,
   with four scalar baseline levels stored separately.
2. Retain events exactly at the time cutoff; trim events strictly before it.
   Preserve deterministic chronological order and equal-time arrival order.
3. Oldest-first capacity eviction, baseline updates, out-of-horizon rejection,
   Clear epoch rebasing, immutable snapshot borrowing/copying and revision
   exhaustion semantics remain as specified today.
4. The 1/2/5s visible presentation reconstructs the same levels and paths from
   retained history as an independent full-history oracle at every left edge.
5. All three physical nRF stores change together; no hidden fourth store, heap
   fallback, endpoint bypass, cache or alternate buffering policy is added.
6. Keep the validation workload at 30s, 80 delivered events/s, 2,404 accepted
   facts including initial levels, and its existing paced-frame/timing
   obligations. Retained count and total delivery count use separate oracles.
7. Report matched capture-storage accounting and total linked size, ABI, heap,
   resource and supported-profile results. No physical timing success is inferred
   from a faster host or smaller linked image.

## Constraints

The four supported analyzer configurations and substantially shared portable
presentation remain fixed. Embedded support stays ARMv7E-M/VFP with disabled
heaps; Pi remains ARMv6 hard-float. Existing semantic/text/profile regions,
Canvas callable-capture limits, raster buffers and stack reservations are
unrelated to signal retention and are not resized by this amendment.

The 10 Hz/channel density is the accepted sustained-validation stress envelope.
The production deterministic source retains its existing distinct channel
patterns, frequencies and seeded schedule; this amendment does not turn those
patterns into four 10 Hz generators.

The proposed capacity assumes the accepted stress density: four channels × 10 cycles/s
× two edges/cycle × 5s = 400, plus four simultaneous events at the inclusive
boundary = 404. The extra four are boundary headroom, not additional permanently
retained initial records or a substitute for the scalar baselines. Unsupported
bursts still follow capacity eviction; a nominal rate does not authorize
unbounded bursts or lossless retention beyond physical capacity.

## Proposed Design

Keep repository-owned ordered transition capture and baseline state. After an
accepted event advances elapsed duration, use `max(0, duration - 5s)` as the time
cutoff, removing only earlier events. Capacity pressure continues evicting the
oldest records and advancing retained lower-bound state using the existing
contract; an equal-time overflow must remain deterministically replayable.
Capture duration remains elapsed time since the current Clear epoch, even when
its retained history contains only the newest 5s.

The observable model receives the same immutable snapshot/mutation/terminal
publication forms. The host's live, model and admission snapshots each hold up
to 404 records with the same 16-byte packed representation, alignment, ownership,
borrow lifetime and slot-reuse discipline. Clear, stopped captures, diagnostics
and reserved operational-failure admission preserve existing semantics.

For the unchanged synchronized 30s oracle, final delivery revision remains
2,404, time cutoff is 25s, retained count is 404 including four events at 25s,
and all window-left-edge levels must agree with full delivered history. Workload
fixtures must express these as separate expectations; historical 30s-contract
reports must remain immutable.

## Module Responsibilities

| Owner | Impact | Dependency impact |
| --- | --- | --- |
| SignalAnalyzerDomain | Capture bound and value/replay invariants | None |
| SignalAnalyzerData | Default time horizon/capacity and cutoff behavior | None |
| SignalAnalyzerPresentation | Existing range/baseline/path consumers validated | None |
| SignalAnalyzerTargetHost | Live/model/admission region sizes and borrow/ABI guards | None |
| Firmware C composition | Exact capture region and symbol accounting | None |
| Contract tooling | Separate delivery versus retention oracles and fresh reports | None |

## Public API Impact

Publication types, sink/use-case interfaces, actions and visible-window choices
stay the same. Retention policy and documented minimum capacity change, so
clients reading complete captures can observe fewer older transitions and an
earlier onset of a nonzero retained lower bound. Source shape compatibility
does not imply behavioral compatibility for those consumers. This change is
bounded to the reference application's capture policy; it is not a general
GiftUI history-service API.

## Capabilities Impact

None. Capture history is application-domain policy. Memory reduction does not
become a renderer capability, negotiated hardware feature or portable-view
platform branch.

## Backend Impact

No backend contract changes. Desktop/Pi and nRF histories must agree on the
same cutoff, order, baselines and visible presentation. The nRF composition
changes fixed capture region constants/ABI guards; framebuffer/TFT and input
integration remain independently owned.

## Static / Embedded Impact

Reduce each of three slots from 38,464 to 6,464 bytes. Preserve exact packed
record schema, disjointness, alignment, stack reservations and allocation
refusal. Review SPEC-013 resource assumptions even when totals derive from
SPEC-001/015; update only affected declarations after approval. No new dynamic
allocation or language/runtime requirement is introduced.

## Performance

Smaller histories can reduce traversal/copy work, but this proposal makes no
cadence or sustained performance claim. Pi/nRF measured publication gaps remain
under FW-027/FW-032. Keep 30s/80-event/s workload duration and timing obligations;
record whether collection is host execution, cross-build inspection or connected
execution. Reuse of historical performance exceptions requires their exact
existing provenance, not an expanded inferred exception.

## Memory / Binary Size

Current packed capture storage is `3 × 2,404 × 16 = 115,392` bytes. Proposed
storage is `3 × 404 × 16 = 19,392`, a 96,000-byte reduction. Four channel baselines
are separately retained under the existing representation. Step 14's isolated
candidate linked RAM fell by exactly 96,000 bytes, with a small flash change;
actual production-linked totals must be remeasured after coordinated changes.
Do not subtract the capture saving from unrelated buffers or stack budgets.

## Alternatives

- Retain 30s/2,404: fully compatible with current complete-capture consumers,
  but spends RAM on history the current UI cannot navigate. Prefer if preserving
  that history is the product requirement.
- Retain 5s/404 (recommended): meets every exposed window and has quantified
  storage benefit; accepts the observable capture-history change.
- Keep a smaller ring plus reconstruct old history elsewhere: adds storage,
  ownership or retrieval policy and merely relocates the cost. Consider only
  under a separately justified history-navigation requirement.
- Reduce channel frequency, shorten the workload or retain fewer than 404:
  undermines current accepted density/window validation or inclusive-boundary
  headroom. Not supported by this iteration.

## Rejected Approaches

Do not use unreviewed global replacement of `30`/`2404`, lower the delivered
workload count to 404, change only one store, infer that linked saving proves
physical timing, or treat a Spike as an accepted decision.

## Compatibility

Source interfaces and packed record schema remain stable. Fixed-region capacities
and complete-capture behavior change; downstream consumers relying on older
history require migration. No persisted capture format is introduced. Historical
reports retain their original 30s contract; new reports must identify the revised
contract and separately count delivered and retained events.

## Testing Strategy

After the authority gates, derive coordinated implementation tasks covering:

- 5s cutoff just before/at/after, nonzero baselines, equal-time ordering,
  retained out-of-order input, exact 404/405 capacity and overflow/replay;
- Clear, snapshot immutability, revision exhaustion, admission slot lifetime,
  disposal and repeated reuse at the smaller physical bound;
- unchanged 30s delivered-event count with separately revised retention
  expectations and independent full-history 1/2/5s left-edge levels;
- path/presentation/raster parity at cutoff, partial capture, Stop/Clear and
  diagnostics across supported realizations;
- matched three-store accounting, 96,000 fewer storage bytes, total linked
  RAM/flash, ARMv6 and ARMv7E-M/VFP, heap/symbol/resource/stack-reservation gates;
- fresh four-profile reports and the approved bounded connected changed-path
  checks, retaining explicit timing and physical evidence limits.

Step 14's probe omits fresh production raster and physical sustained-acquisition
proof. Its passing replay/level results are supporting evidence only.

## Risks

Older-history consumers lose transitions beyond 5s. Audit all production callers
and fixtures before implementation. A single resized slot would violate cross-owner
copy/ABI assumptions; coordinated region and boundary validation is required.

## Open Questions

Human approval of the observable retention tradeoff is the current gate. The
boundary/capacity rationale is supported by existing density and experiments;
there is no unresolved architecture choice hidden in a deferred artifact.
Exact affected Spec wording, index bounds and fixture relations require
coordinated authoring/review after the accepted successor decision. Missing
production/connected evidence remains an implementation criterion, not an RFC
approval claim. Old complete-history expectations must be audited by meaning,
not by literal replacement.

## Decision Summary

A proposed successor to ADR-003: 5s inclusive transition retention, at least 404
records plus four scalar baselines, unchanged density and oldest-first capacity
semantics. Extract it after explicit RFC approval; accept it only through its
normal human gate. Preserve ADR-003's history and reciprocal supersession links.

## Deferred and Follow-up Work

Performance under [FW-027](../future-work/fw-027-pi-performance-investigation-resumption.md)
and [FW-032](../future-work/fw-032-nrf-performance-improvement.md), broad physical
conformance under [FW-031](../future-work/fw-031-macos-connected-pointer-validation-resumption.md)
and [FW-033](../future-work/fw-033-connected-validation-follow-up.md), and
historical navigation or alternate buffering remain outside this decision.
No new deferred artifact or implied commitment is introduced; these are the
iteration's existing exclusions, not postponed prerequisites for this RFC.

## References

- [RFC-001](rfc-001-signal-analyzer-application-architecture.md)
- [ADR-003](../adrs/adr-003-transition-based-bounded-capture.md)
- [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
- [SPEC-013](../specs/spec-013-runtime-profiles.md)
- [SPEC-015](../specs/spec-015-host-configuration.md)
- [Retention owner impact and experimental limitations](../iterations/iteration-002-review/14-five-second-retention-impact.md)
- [Iteration delivery and remaining gates](../iterations/iteration-002-cleanup/implementation-plan.md)

## Approval provenance — 2026-10-05

[Explicit maintainer approval](../iterations/iteration-002-cleanup/retention-approval.md) approves the concrete RFC policy and its faithful implementation chain. Earlier proposed/pending language describes the reviewed proposal, not a remaining RFC approval gate.
