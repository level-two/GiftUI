---
id: ADR-041
feature: external-application-integration
title: Native Static Caller-Supplied Typed Model Backing
status: accepted
authors:
  - codex
created: 2026-10-24
updated: 2026-10-24
proposal:
  - PROPOSAL-007
related_rfcs:
  - RFC-014
  - RFC-015
related_adrs:
  - ADR-036
  - ADR-039
related_specs:
  - SPEC-013
  - SPEC-015
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# ADR-041: Native Static Caller-Supplied Typed Model Backing

## Status

Accepted by Eugene on 2026-10-24: **“APPROVE TYPED-BACKING DESIGN DIRECTION”**.
The [dated approval](../iterations/iteration-003-review/p08-native-typed-backing-approval.md)
records the exact question, implementation authorization and exclusions. This
explicit authority amends only Native Static construction realization and coverage;
it does not supersede ADR-036's shared semantics or ADR-039's physical ownership.

## Context

P08 must qualify complete Static construction and every later required operation
without heap allocation. Model53's complete serialization candidate did not remove
Self and Optional<Model> metadata from generic owning construction/lifetime. Its
retained evidence supports conditional first-use dependencies, not observed or
unconditional allocation. Earlier attempts and failures remain historical.
The Native counter already owns concrete typed backing and lends it with separate
ownership bookkeeping to the existing checked factory. That supplies an established
realization without changing shared model operations or introducing another runtime.

## Decision

Native Static model construction MUST require caller-supplied typed backing rather
than require the generic owning-model convenience construction to qualify. The
caller MUST establish initialization, alignment, bounds, disjointness and backing
stability before the checked factory, and retain backing until every scope,
registration, callback, ticket and model destruction required by its lifetime ends.
Ownership accounting remains separate and bounded. Shared generic scoped model
operations, keys, schema checks, phases, refusals, replacement and cleanup remain.

Construction conformance MUST migrate to this contract with equivalent behavioral
coverage, rather than deleting failing observations or shifting backing setup,
refusal or destruction outside the charged lifetime. Dynamic controls and Embedded's
existing owning path remain unchanged. No public API removal/unavailability, new
factory signature or shared slot representation is selected by this decision.
Strict zero-heap, stack/RAM/flash, workload and complete-call-path proof duties remain.

## Rationale

This follows ADR-036's stable typed storage supplied before activation and the
existing Native product's checked borrowing pattern. It avoids depending on an
unproved generic owning-construction specialization, without duplicating observable
algorithms or weakening ownership and resource requirements.

## Consequences

### Positive

- Native construction has a concrete supported backing boundary and retains the
  common checked scoped operations and behavioral controls.

### Negative

- Native callers own typed backing and bookkeeping lifetimes explicitly; their
  initialization, audit bytes and destruction remain fully charged.
- Existing owning-construction evidence does not automatically qualify the migrated
  paths. Optional, error, first-use/provider and live-state duties remain open.

### Follow-up

- Apply SPEC-013/SPEC-015 and P08 construction coverage consistently, including
  matching component prerequisites, populated-slot destruction and escape negatives.
- Qualify actual current construction-through-cleanup callers/callees, non-relocation,
  output equivalence, text cost and necessary supported-profile regressions.

## Deferred and Follow-up Work

No optional extension is introduced. P09 application migration and all existing
P08/provider/resource acceptance obligations retain their established dispositions.

## Rejected Alternatives

### Retain generic owning construction as the Native qualification requirement

No supported source-only correction was demonstrated after the complete Model53
candidate. This decision replaces that requirement; it does not prove every future
compiler realization impossible.

### Replace shared optional slots with uninitialized storage

This would change shared lifecycle/representation and arbitrary-model backing
size/alignment requirements beyond the selected construction boundary.

### Silently replace controls or prewarm caches outside the charged lifetime

Either would hide the required behavior/cost instead of qualifying it. Backing
setup, refusal, cleanup and all prescribed observations remain in scope.

## References

- [Approval](../iterations/iteration-003-review/p08-native-typed-backing-approval.md).
- [RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
- [RFC-015](../rfcs/rfc-015-p08-scoped-storage-ownership.md).
- [ADR-036](adr-036-scoped-model-access-and-bounded-ownership.md).
- [ADR-039](adr-039-scoped-storage-ownership.md).
- Historical Model53 retained failure: complete serialization did not meet its compiled removal gate; no earlier failure is retroqualified.
