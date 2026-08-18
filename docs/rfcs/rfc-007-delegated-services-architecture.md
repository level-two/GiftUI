---
id: RFC-007
feature: giftui-mvp-architecture
title: GiftUI Delegated Services Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-18
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-001
  - RFC-002
  - RFC-004
  - RFC-005
  - RFC-006
related_adrs:
  - ADR-001
related_specs: []
related_future_work:
  - FW-009
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: null
---

# RFC-007: GiftUI Delegated Services Architecture

## Summary

This RFC is a **paused draft**. It preserves the candidate idea that repeated
environmental operations could share explicit injected Service contracts and
a small foundational package. It is not an active MVP architecture decision,
does not require a `GiftUIServices` package, and does not authorize a Clock,
Scheduler, Diagnostic Sink, Service bundle, or adapter implementation.

Review found that most current invariants already have narrower owners:

- RFC-002 owns explicit host composition, dependency direction, and rejection
  of ambient platform lookup;
- RFC-004 owns runtime wake, synchronous frame handoff, and callback isolation;
- RFC-005 owns diagnostic independence and failure propagation;
- RFC-006 owns the distinction between semantic Capabilities, implementation
  facts, policy, and operational state.

The remaining shared-Service generalization lacks enough independent approved
consumers to justify an MVP package and catalogue. FW-009 records when this RFC
should be reconsidered.

## Context

The original draft proposed common Clock, wake Scheduler, and Diagnostic Sink
contracts injected by the target host. That proposal had credible long-term
value but did not establish that GiftUI itself needs all three for the MVP:

- the target host may drive the runtime externally without a framework
  Scheduler;
- Signal Analyzer acquisition time belongs to application Data/host contracts
  unless a GiftUI feature consumes it;
- diagnostic observation can remain a narrow RFC-005 integration seam; and
- no current approved feature requires a general Service lookup or bundle.

Creating the foundation now would freeze package ownership, common primitives,
dispatch shape, lifetime, and catalogue before concrete consumers establish
their contracts. That is architectural speculation rather than a necessary
MVP boundary.

## Requirements

This paused draft adds no current MVP requirement. If FW-009 triggers
re-evaluation, a revised RFC must demonstrate all of the following:

1. at least two approved GiftUI consumers require environmental operations
   with materially shared semantics;
2. consumer-owned contracts would create duplication, dependency cycles, or
   inconsistent static/dynamic behavior;
3. a shared package remains smaller and clearer than explicit host wiring;
4. the common catalogue is limited to evidenced operations; and
5. the static representation has explicit bounded cost and no ambient lookup.

## Constraints

- Portable views must not import concrete clocks, schedulers, loggers,
  platforms, OS/RTOS APIs, or a general Service locator.
- Environmental adapters must not invoke semantic actions or mutate state from
  callbacks or interrupts.
- A diagnostic adapter must not acquire control-flow authority.
- The target host remains the composition root under ADR-001 and RFC-002.
- Deferral must not block consumer-specific contracts needed by RFC-004,
  RFC-005, or another approved feature.

## Proposed Design

No active design is proposed for MVP. The preserved candidate, if revisited,
is:

```text
approved consumer contracts
        -> minimal shared environmental-operation foundation
        <- target-specific adapters selected by the host
```

The earlier candidate separated Services from semantic Capabilities and
prohibited ambient discovery. Those ideas remain non-authoritative until this
RFC is revised after a trigger.

Consumer-specific work proceeds without this foundation:

- a runtime wake operation may be specified with RFC-004 if required;
- a diagnostic observation seam may be specified with RFC-005;
- an application Clock remains in the application or host boundary unless a
  GiftUI feature establishes a framework need.

## Module Responsibilities

| Current owner | Current responsibility |
| --- | --- |
| RFC-002 / target host | Explicit composition and downward dependencies |
| RFC-004 | Wake, synchronous frame handoff, and post-handoff ownership |
| RFC-005 | Failure and optional diagnostic observation semantics |
| Consumer Specification | Exact environmental operation it requires |
| FW-009 / paused RFC-007 | Preserve possible later shared foundation |

No `GiftUIServices` module is required by this draft.

## Public API Impact

None for current MVP architecture. Portable views gain no Clock, Scheduler,
logger, Service bundle, locator, or environment dictionary. A later revised
RFC must separately justify host API, framework SPI, and any client projection.

## Capabilities Impact

RFC-006 owns Capability semantics. A concrete environmental operation and its
properties do not become Capability values merely because this paused design
could later call them Services.

## Backend Impact

Backends synchronously report handoff outcomes through RFC-002, RFC-004, and
RFC-005 boundaries. Post-handoff presentation health remains backend-local and
may feed optional diagnostics. Backends do not become owners of a common
Clock, Scheduler, diagnostic system, or semantic event loop.

## Static / Embedded Impact

Deferral avoids introducing a generic bundle, type erasure, callback storage,
token catalogue, or unused adapters into the static image. Consumer-specific
contracts must still be bounded and allocation-free where required. Any later
shared foundation must prove lower combined RAM, flash, stack, and complexity
than those concrete contracts.

## Performance

No current runtime cost is introduced. A revised RFC must measure common
dispatch, wake admission, and adapter overhead against direct consumer wiring.

## Memory / Binary Size

No shared bundle or catalogue is budgeted for MVP. A revised RFC must account
for contract values, pending operations, tokens, adapter state, diagnostics,
generic specialization, and linked unused code.

## Alternatives

### Consumer-owned explicit contracts

This is the current direction. It keeps requirements close to the approved
consumer and avoids a general foundation before duplication is demonstrated.

### Shared foundational Service package

This may reduce duplication and prevent cycles when several consumers share
semantics, but currently lacks sufficient evidenced demand.

### Ambient Service locator or global callbacks

This reduces constructor wiring but hides dependencies, complicates tests and
static bounds, and conflicts with RFC-002 dependency direction.

### Backend-owned environmental coordination

This can fit a desktop event-loop backend but gives a replaceable renderer
cross-cutting timing and semantic responsibilities.

## Rejected Approaches

No design is rejected by this paused draft. Ambient lookup and backend semantic
ownership remain inconsistent with RFC-002's candidate boundaries; the shared
foundation itself is postponed, not rejected.

## Compatibility

There is no approved Service API or package to preserve. Consumer-specific
contracts created while this RFC is paused should remain narrow enough that a
future shared foundation can adapt them rather than silently supersede their
semantics.

## Testing Strategy

No RFC-007 conformance suite is required while paused. Each consumer tests its
own deterministic adapter, static bounds, callback isolation, and target
integration. A revised RFC must demonstrate common cross-consumer fixtures
before proposing shared conformance.

## Risks

- Consumer contracts may drift; RFC-002's contract matrix and review should
  detect repeated semantics and trigger FW-009.
- A later shared package may require migration; keep consumer contracts
  explicit and narrowly adapted.
- Pausing could be mistaken for rejection; metadata, FW-009, and this summary
  preserve the design and its revisit conditions.

## Open Questions

No question blocks RFC-002 or current consumer Specifications solely because
RFC-007 is paused. The questions preserved for a future revision are:

1. Which approved consumers actually require common time, wake, diagnostic,
   or other environmental semantics?
2. What duplication or dependency problem cannot be solved through explicit
   consumer-owned contracts?
3. What is the smallest shared catalogue and physical package placement once
   those consumers exist?

## Deferred and Follow-up Work

[FW-009](../future-work/fw-009-shared-delegated-service-foundation.md) preserves
the shared package and catalogue opportunity, why it is outside current MVP
architecture, and concrete triggers for re-evaluation. The source and deferred
artifact are linked bidirectionally.

## Decision Summary

No ADR extraction is proposed while this RFC is paused. If FW-009 triggers and
the RFC is revised, reviewers may consider decisions about explicit Service
semantics, shared package ownership, host injection, and static/dynamic
representation at that time.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005](rfc-005-failure-diagnostics-propagation.md)
- [RFC-006](rfc-006-capability-system-architecture.md)
- [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md)
- [ADR-001](../adrs/adr-001-signal-analyzer-application-boundaries.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
