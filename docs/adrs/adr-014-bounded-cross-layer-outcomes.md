---
id: ADR-014
feature: giftui-mvp-architecture
title: Bounded Cross-Layer Outcome Meaning
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-26
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-005
related_adrs:
  - ADR-008
  - ADR-010
  - ADR-012
  - ADR-015
  - ADR-016
  - ADR-017
related_specs:
  - SPEC-001
  - SPEC-003
  - SPEC-009
  - SPEC-010
related_future_work:
  - FW-012
  - FW-013
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-014: Bounded Cross-Layer Outcome Meaning

## Status

Accepted.

## Context

Fallible GiftUI boundaries span dynamic hosts and Embedded Swift targets that
cannot share exceptions, rich allocated errors, or platform-native details.
Policy still needs enough portable meaning to distinguish expected operating
conditions from failed contracts and to decide where normal processing is
safe.

## Decision Boundary

This record extracts RFC-005 Decision Summary item 1 together with its approved
acyclic physical ownership. It owns bounded outcome meaning, conservative
containment, affected scope, source-stable condition identity, and the
foundational/execution-correlation split. It does not own transaction-specific
frame handling (ADR-010 and ADR-012), product disposition (ADR-015), diagnostics
(ADR-016), or capability/health classification (ADR-017).

## Decision

Fallible cross-layer contracts MUST return explicit bounded outcomes that
distinguish success, expected operational conditions, and failure. A failure
MUST preserve source-stable condition identity, origin, and the smallest
affected scope its detecting contract can prove.

Portable containment MUST be either `contained`, when the contract proves
normal processing remains safe outside the affected scope after rejecting or
invalidating partial work, or `safety not proven`, when it cannot. Unknown or
richer profile-specific containment MUST map to `safety not proven` and MUST
NOT be upgraded by diagnostics, platform detail, or product policy.

MVP MUST NOT promise that a numeric representation of condition identity is
stable across builds or software versions.

`GiftUIFailureCore` MUST be the dependency-free physical owner of foundational
outcome category, origin, condition identity, affected scope, and containment
meaning. `GiftUIFailureExecution` MUST correlate those facts with ADR-011 and
ADR-010 execution identities while importing only the foundational failure
contract and the focused execution contract. Low-level drivers and transports
MUST NOT import execution correlation, and the execution contract MUST NOT
import the failure adapter.

## Rationale

The conservative model is small enough for static representation yet carries
the safety facts coordinators and tests require. Preserving source identity and
scope prevents wrappers from erasing origin or reporting a narrower failure
than they can prove.

## Consequences

### Positive

- Static and dynamic profiles share one portable failure meaning.
- Unknown conditions fail conservatively.
- Each boundary can be fault-injected without a universal rich error object.
- Foundational failure reporting remains available below runtime and backend
  layers without creating an import cycle.

### Negative

- Conservative containment may quiesce more scope than a future specialized
  implementation could prove necessary.
- Numeric IDs cannot be persisted, transmitted, or externally symbolized as a
  durable protocol in MVP.

### Follow-up

- Specifications must define cases, widths, packing, affected scopes,
  correlation adapters, exhaustion, and fault fixtures.
- Dependency tests must enforce the failure-core leaf and one-way execution-
  correlation imports.

## Deferred and Follow-up Work

- [FW-012](../future-work/fw-012-durable-failure-identity-compatibility.md)
  preserves durable cross-build identifiers for a future concrete consumer.
- [FW-013](../future-work/fw-013-fine-grained-failure-containment-recovery.md)
  preserves finer containment and recovery classes.

## Rejected Alternatives

### Exceptions throughout Core

Rejected because exceptions do not provide the common Embedded Swift or
asynchronous boundary.

### One rich universal error object

Rejected because strings, allocation, schema, and storage costs are not
justified for the common static path.

### Severity as containment

Rejected because severity does not prove whether continued processing is safe
for an affected scope.

### One monolithic failure and diagnostics target

Rejected because it would pull execution correlation into low-level producers
or optional diagnostic dependencies into correctness paths.

## References

- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [GiftUI Principles](../PRINCIPLES.md)
