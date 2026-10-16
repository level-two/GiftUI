---
id: ADR-040
feature: external-application-integration
title: Finite Counter Physical SRAM Budget
status: accepted
authors:
  - codex
created: 2026-10-16
updated: 2026-10-16
proposal:
  - PROPOSAL-007
related_rfcs:
  - RFC-014
  - RFC-015
related_adrs:
  - ADR-039
related_specs:
  - SPEC-004
  - SPEC-015
related_future_work:
  - FW-039
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# ADR-040: Finite Counter Physical SRAM Budget

## Status

Accepted by Eugene on 2026-10-16 through the explicit larger-stack and physical
SRAM budget exception and delegated numerical selection recorded in the
[acceptance provenance](../iterations/iteration-003-review/p08-counter-resource-acceptance.md).
This narrow amendment has explicit human authority; it is not extracted as though
RFC-015 originally selected larger limits. ADR-039 remains accepted for ownership.

## Context

PROPOSAL-007 and ITERATION-003 I3-04/I3-05 require the finite runtime-derived
counter and actual target resource proof. The unchanged source cannot fit the
historical 192 KiB budget: a required live fixed-stack subset alone needs 56,888
plus 142,972 other linked bytes. The subsequent independently corrected complete
proof bounds main/ISR at 95,469 / 6,672 and projects physical fit with sufficient
reservations. Further source optimization is not the maintainer's selected path.

## Decision

The existing finite P08 counter's nRF52840 Embedded Static image MAY use up to
**262,144 bytes total SRAM**, the physical device capacity. This is a per-application
exception to the 196,608-byte aggregate ceiling and counter stack exclusion in
RFC-015 / ADR-039. Normal analyzer and other application defaults MUST retain
existing budgets. It does not relax capability-specific, capture, raster/payload,
heap, flash, workload, identity or corpus limits.

Counter main and ISR reservations MUST each cover complete conservative feasible
software paths, callbacks/recursion, startup stack behavior and exception/FPU
preservation, with guards/alignment and all other linked RAM included exactly
once. A lower bound, isolated prologue, receipt or observed high-water alone MUST
NOT justify fit. The selected 106,496 / 8,192 reservations are implementation
configuration backed by the reviewed frozen proof; every new linked image MUST
be requalified before a fit claim. A total exceeding physical SRAM is forbidden.

## Rationale

The maintainer accepts reduced spare SRAM for this isolated finite validation
application, preserving the full required workload and ownership proof. Existing
resource evidence makes a counter-only sufficient configuration concrete without
another source candidate or a broad analyzer-policy relaxation.

## Consequences

### Positive

- Complete original loans, capacities and independent observations stay intact.
- The selected reservation projection leaves 6,532 linked-charge bytes, with
  separately accounted guard/alignment and address extent.

### Negative

- The counter consumes substantially more physical RAM than the analyzer policy.
- Its small remaining physical margin requires exact new-image evidence; the
  frozen bound and projected charge cannot certify a changed ELF automatically.

### Follow-up

- Apply the approved SPEC-004/SPEC-015 exception and counter-only configuration.
- Preserve normal complete-receipt, layout, ABI, flash and zero-heap checks;
  independently requalify the final linked image and complete P08 matrix/exit gates.
- No source repair allowance is renewed and no P08/lifecycle gate is declared met.

## Deferred and Follow-up Work

[FW-039](../future-work/fw-039-counter-prepared-lending.md) preserves the unexecuted
prepared-lending optimization. It is optional after fit is proved, not a deferred
substitute for required resource or safety evidence.

## Rejected Alternatives

### Keep 192 KiB and continue source optimization now

The required current path already exceeds that ceiling. The maintainer selected
physical-SRAM budgeting instead of the prepared-lending candidate; this does not
claim all smaller realizations impossible.

### Raise every application's limits or choose a stack from one lower bound

No broader relaxation was requested. A numerical increment over the prior
rejection does not bound complete stack/IRQ or physical SRAM use.

## References

- [Approved RFC-015](../rfcs/rfc-015-p08-scoped-storage-ownership.md), historical
  no-larger-limits rationale, amended only as stated here.
- [ADR-039](adr-039-scoped-storage-ownership.md).
- [SPEC-004](../specs/spec-004-capability-contribution-and-resolution.md) and
  [SPEC-015](../specs/spec-015-host-configuration.md).
- [Complete-bound review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-complete-bound-independent-review.md).
