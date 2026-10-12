---
id: ADR-038
feature: giftui-mvp-architecture
title: Construction Graph and Operational Contracts
status: accepted
authors:
  - codex
created: 2026-10-12
updated: 2026-10-12
proposal:
  - PROPOSAL-003
  - PROPOSAL-007
related_rfcs:
  - RFC-014
related_adrs:
  - ADR-007
  - ADR-008
  - ADR-011
  - ADR-036
related_specs:
  - SPEC-009
  - SPEC-015
related_future_work:
  - FW-035
  - FW-009
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# ADR-038: Construction Graph and Operational Contracts

## Status

Accepted on 2026-10-12 under Eugene's explicit instruction to select Option B
and treat its required documents as approved. The
[approval record](../iterations/iteration-003-review/rfc-014-spec-approval.md#option-b-construction-graph-amendment--2026-10-12)
preserves both exact instructions, including the subsequent documentation-only
limit. No dependent implementation or conformance is claimed.

## Context

RFC-014 P08's fixed host-role graph was interpreted to include typed runtime
operations as well as construction. Under that interpretation, admission's
canonical wake notification created an upward role edge. The
[decision packet](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7g-graph-stop/graph-boundary-decision.md)
presented host forwarding (A) and a construction graph with separate operational
validation (B). Eugene selected B. ITERATION-003's existing analyzer/counter and
four-configuration validation remains the delivery boundary; this is post-MVP
work preserving the reference application's execution and pacing semantics.

## Decision

The fixed eighteen-record `HostComponentGraphView` MUST describe exact **direct
factory/construction dependencies** of the selected component roles. Mandatory
borrowed or retained inputs, backing and origins of derived configuration MUST
be traced and included where they are construction dependencies. Shared storage,
a pointer, an adapter or a callback MUST NOT conceal such an edge. Existing
ordering, cardinality, self/unknown-bit, cycle and lower-edge constraints remain
in force for actual construction edges. An actual required upward construction
edge MUST stop affected work for upstream resolution; it MUST NOT be omitted or
masked to pass validation.

Constructor/factory inputs, activation wiring and runtime operations MUST be
distinguished explicitly. Typed arguments supplied only to an operation do not
by themselves create construction edges. Shared value vocabulary does not by
itself identify a live target owner. Operational paths and all supplied backing
remain subject to complete identity, lifetime, behavior and teardown evidence.
A retained/bound callback required to construct an owner remains a construction
input; operational classification is not a blanket callback exception.

Module imports MUST continue to follow lower consumer-owned contracts under
ADR-007/008. This ADR does not relax their decisions. Runtime-owned admission
notification MAY call the existing typed consumer-owned wake contract; the host
binds that contract to platform scheduling once. The SPEC-009 canonical reason
set and outstanding bit, exact transition/coalescing behavior, fact deadlines,
non-reentry and quiescence remain required and MUST be validated separately from
construction graph shape. No new public protocol or shared service mechanism is
selected.

## Rationale

Construction establishes what must exist and remain available for an owner to
be valid. Runtime operation contracts express allowed collaboration after that
boundary. Auditing both explicitly preserves composition and backing obligations
without treating every method argument or value type as a construction order.
Runtime-owned notification avoids requiring each producer to repeat canonical
wake forwarding while retaining one host/platform binding.

## Consequences

### Positive

- Construction order and runtime notifications have distinct, reviewable proofs.
- Admission may retain automatic canonical wake behavior through the existing
  consumer-owned seam, with one platform binding at host composition.
- Lower-contract imports and complete ownership/lifetime accounting remain.

### Negative

- A passing graph mask no longer proves all operational collaboration; explicit
  operational and lifetime inventories and independent checks are mandatory.
- Existing P08 masks and projections need a fresh actual-owner audit. Neither
  existing code nor this decision proves that construction edges satisfy it.

### Follow-up

- Amend SPEC-015's graph contract, tests and HC-003; reciprocally clarify SPEC-009.
- Resume P08 only in a separate activity through construction/operation/lifetime
  inventory, the bounded projection slice, its one native attempt and review,
  then the existing four-route/linked-image and package exit gates.
- Preserve every historical stop and attempt ledger; approval resets no budget.

## Deferred and Follow-up Work

- [FW-035](../future-work/fw-035-generated-view-graph-for-interchangeable-frontends.md)
  preserves possible future frontend integration benefits; this separation does
  not select a frontend-neutral IR, generation path or interchangeable frontend.
- [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md)
  preserves possible repeated environmental contracts. One runtime wake binding
  does not establish a need for a shared service framework or promote the item.

## Rejected Alternatives

### Option A: per-producer host notification forwarding

Not selected by Eugene. It would preserve the former operation-inclusive graph
interpretation by moving notification to each enumerated host boundary, adding
caller-coverage obligations where B retains runtime-owned canonical notification.

### All runtime calls or type vocabulary are construction edges

Rejected because operational arguments and shared values do not necessarily
establish a factory dependency or live owner identity. Their separate contracts
still require complete validation.

### Retained fields only, or unrestricted callback exceptions

Rejected because borrowed inputs, backing, derived configuration and required
construction callbacks can establish real dependencies without a stored owner
field. Indirection cannot justify omitting an actual construction edge.

## References

- [RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
- [ADR-007](adr-007-integration-ownership-and-host-composition.md) and
  [ADR-008](adr-008-module-dependency-graph-and-package-topology.md).
- [Accepted PROPOSAL-007](../proposals/proposal-007-external-application-integration.md)
  and [ITERATION-003](../iterations/iteration-003-dev-ux-improvement.md).
