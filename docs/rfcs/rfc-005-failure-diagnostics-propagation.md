---
id: RFC-005
feature: giftui-mvp-architecture
title: Failure and Diagnostics Propagation Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-17
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-003
  - RFC-004
  - RFC-006
  - RFC-007
related_adrs: []
related_specs: []
related_future_work:
  - FW-009
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-005: Failure and Diagnostics Propagation Architecture

## Summary

This RFC is the independently reviewable cross-layer failure decision cluster
under PROPOSAL-003. It proposes that fallible GiftUI boundaries return
structured outcomes, that lower layers report facts rather than choose product
policy, and that diagnostics remain best-effort observations with no
control-flow authority.

```text
layer detects a condition
    -> explicit bounded outcome propagates toward its coordinator
    -> runtime/frame boundary supplies transaction context
    -> composition-owned policy selects an allowed disposition

optional diagnostic record
    -> bounded sink or counter
    -> no effect on correctness or disposition
```

This RFC defines meaning, direction, and policy ownership. It does not define a
universal binary record, global numeric registry, context-stack format,
secondary-failure array, privacy taxonomy, source-location scheme, diagnostic
transport, exact policy table, or concrete capacities. Those are
Specifications or separately justified tooling work.

The focused contracts fit RFC-002's import partial order as two narrow targets:
a dependency-free failure-fact leaf and an execution-correlation adapter above
that leaf. Neither target imports a runtime, backend, platform, driver, or
diagnostic implementation, and the execution contract does not import the
failure adapter. This placement resolves RFC-002 Question 2 for RFC-005 without
changing the shared boundary.

## Context

RFC-002 divides semantics, layout, render production, backends, display
targets, drivers, and transports. Each boundary can fail differently, while
Embedded Swift cannot rely on exceptions, rich strings, reflection, heap
allocation, or desktop logging. If every layer traps, retries, logs, or ignores
locally, product behavior becomes backend-specific and untestable.

RFC-004 owns cycle admission, semantic publication, frame lifetime, and
asynchronous completion re-entry. This RFC consumes those positions to explain
whether a failure affects unpublished work, a published semantic revision, or
only one presentation attempt. It does not duplicate RFC-004's phase machine.

The concern remains separate from RFC-002 because explicit results versus
exceptions, layer-local versus composition-owned policy, and diagnostics
versus control flow are independent architectural alternatives with common
dynamic/static consequences.

RFC-002 owns the physical dependency direction that constrains this RFC. In
particular, a low-level producer must be able to report a failure fact without
importing the runtime merely to name a cycle or frame. Correlation with
RFC-004's execution identities is therefore an adapter responsibility, not a
property of the foundational fact.

## Requirements

### R1 — Explicit fallible outcomes

Fallible cross-layer contracts MUST return a structured success, expected
operational condition, or failure outcome. Dynamic exceptions MAY be adapted
at an integration boundary but MUST NOT be the common GiftUI mechanism.

### R2 — Fact and policy separation

A layer MUST describe the condition it detected and the local work it could
not complete. It MUST NOT independently choose product-level retry, fallback,
capability disablement, runtime termination, or silent continuation unless its
contract explicitly grants that bounded local disposition.

### R3 — Composition-owned disposition

The target composition MUST supply total policy for outcomes requiring product
disposition. Policy may be specialized statically or injected dynamically, but
must respect invariants established by the detecting contract and RFC-004's
publication position.

### R4 — Diagnostics are non-authoritative

Diagnostic presence, filtering, formatting, delivery, loss, or sink failure
MUST NOT change semantic state, layout, render operations, capability results,
frame disposition, or failure policy.

### R5 — Preserve origin and context

Propagation MUST preserve stable origin and condition identity sufficient for
policy and tests. Boundary context MAY be added in a bounded form but MUST NOT
replace the original cause.

### R6 — Sequenced asynchronous outcomes

Backend, display, driver, and transport outcomes arriving outside their
originating call MUST re-enter through RFC-004's bounded sequenced completion
admission. They MUST NOT mutate semantic state or invoke client handlers from
callbacks or interrupts.

### R7 — Publication-aware effects

A failure before complete semantic publication may invalidate that cycle's
unpublished work. A failure after publication MUST NOT roll back or replay the
published semantic revision and affects presentation or later operational
policy only.

### R8 — Bounded profile-neutral meaning

Static and dynamic profiles MUST agree on portable condition identity,
invariant severity, transaction position, and allowed disposition. The common
meaning MUST be representable without heap allocation, strings, exceptions,
reflection, or unrestricted dynamic dispatch.

### R9 — Deterministic testability

Every first-party boundary MUST permit deterministic fault injection or an
equivalent fixture so outcome propagation and policy can be tested without the
full hardware matrix.

## Constraints

- Backpressure, no-change results, cache misses, superseded frames, and similar
  expected states must remain distinguishable from violated contracts.
- Some invariant violations may require an immediate trap if continued
  propagation would itself be unsafe; this is not ordinary product policy.
- Diagnostics may be omitted from a static release without changing behavior.
- Platform-native details must be normalized before core policy consumes them.
- This RFC does not define application-domain errors or a general telemetry
  system.
- The foundational failure-fact target must not import `GiftUI`, execution,
  runtime, layout, render, backend, platform, driver, OS/RTOS, HAL, capability,
  or diagnostic implementations. Fixed-width primitive representations may be
  refined by a Specification without changing that placement.
- The execution-correlation target may import only the foundational failure
  facts and RFC-004's focused execution contract. RFC-004's execution contract
  must not import the correlation target.

## Proposed Design

### Outcome categories

The common architecture distinguishes three semantic roles:

- **success:** the operation fulfilled its contract;
- **operational:** an expected bounded condition requires an explicit local or
  coordinating disposition but does not indicate a broken invariant;
- **failure:** the operation could not fulfill its contract and reports whether
  continued normal processing is safe for the affected scope.

Exact enum cases, severities, and numeric representation belong in a
Specification. The architecture requires only enough stable meaning to prevent
unknown or richer dynamic details from changing policy unpredictably.

### Propagation

An operation may short-circuit when it cannot produce a valid result. It
returns the original outcome toward the owner of the affected cycle, frame, or
integration operation. A boundary may annotate its own operation and stable
correlation identity within configured bounds.

Synchronous outcomes are handled within their active RFC-004 boundary.
Asynchronous outcomes are copied into a bounded completion record and admitted
later. Neither path grants a diagnostic sink, backend callback, or driver
interrupt direct semantic authority.

### Policy

The composition root knows which facilities are required, which frames may be
dropped, and what fatal action a product supports. It therefore selects policy
for actions such as aborting unpublished work, dropping or retrying a frame,
marking an optional facility unavailable, quiescing the runtime, or invoking a
platform fatal hook.

Policy cannot manufacture missing semantic support, reinterpret a violated
invariant as success, or retry unboundedly. RFC-006 owns capability declaration
and operational-state classification.

### Diagnostics

A diagnostic is a bounded observation derived from an outcome or other event.
It may carry stable identifiers and limited details for tests or host tooling.
A consumer-specific sink may discard, buffer, stream, or symbolize it. No
shared `GiftUIServices` package or global diagnostic framework is required by
this RFC; FW-009 preserves that possible generalization.

### Placement in RFC-002's import partial order

The candidate maintained targets are:

- `GiftUIFailureCore`, which owns normalized origin, condition identity,
  outcome category, affected scope, and the invariant-safety seam; and
- `GiftUIFailureExecution`, which combines a `GiftUIFailureCore` fact with the
  applicable RFC-004 cycle, frame, attempt, phase, and publication position.

The names are candidates; the ownership and arrows are architectural. An
arrow means "depends on":

```text
target host / composition policy
    |-> runtime profile -------> GiftUIFailureExecution
    |                                |-> RFC-004 execution contract
    |                                \-> GiftUIFailureCore
    |-> GiftUIBackend ---------> GiftUIFailureExecution
    |-> integration adapter ---> GiftUIFailureCore
    \-> optional diagnostics --> GiftUIFailureCore

driver / transport / HAL -----> GiftUIFailureCore
```

The target that first knows both an execution identity and a lower-layer fact
creates the correlated envelope. A driver or transport therefore reports a
core fact to its owning integration adapter; it does not import execution,
runtime, or backend modules. Runtime profiles and `GiftUIBackend` already sit
above the RFC-004 execution contract in RFC-002, so importing the correlation
adapter adds no upward edge. The execution contract remains usable without the
failure modules and no cycle is created.

Composition-owned policy is an implementation supplied by the target host. A
narrow policy protocol may live with `GiftUIFailureExecution`, because its
inputs are correlated outcomes, but that target neither selects nor imports a
product policy. Optional diagnostic adapters are consumers of core or
correlated facts. Failure correctness never imports or depends on those
adapters.

This placement preserves RFC-002 B15 and B16: foundational facts can originate
at any operational layer, while publication-aware disposition is performed
only after correlation at the runtime/frame boundary. It also preserves B2:
the host assembles policy and optional diagnostics without exporting new
portable semantics.

## Module Responsibilities

| Owner | Responsibility | Must not own |
| --- | --- | --- |
| `GiftUIFailureCore` candidate leaf | Portable outcome meaning, origin, affected scope, and stable condition identity | Execution identity, product policy, or rich diagnostic formatting |
| `GiftUIFailureExecution` candidate adapter | Correlate a core fact with RFC-004 execution and publication context; expose the narrow policy input seam | Runtime/backend implementation or selected product policy |
| Detecting layer | Validate its contract and report a structured fact | Cross-product retry, fallback, or fatal choice |
| Runtime/frame coordinator | Attach publication/frame context and route synchronous or admitted asynchronous outcomes | Platform-specific error interpretation |
| Target composition | Select total bounded product policy and optional diagnostic adapter | Rewrite lower-layer invariants or capability support |
| Diagnostic adapter/tooling | Consume or symbolize bounded observations | Correctness, semantic mutation, or disposition authority |

## Public API Impact

Portable views should not normally handle framework-internal failures.
Host-facing and integration APIs may expose structured cycle, frame, startup,
or component outcomes when the caller can act meaningfully. Exact result
types, access control, error identifiers, and dynamic conveniences belong in
Specifications.

## Capabilities Impact

RFC-006 owns capability support and the distinction between immutable
declaration and mutable health. Failure policy may react to operational loss,
but cannot mutate the meaning of an effective capability or silently degrade
required semantics. Missing required capability remains a configuration
validation problem rather than a diagnostic choice.

## Backend Impact

Backends normalize command, resource, acceptance, and completion outcomes and
associate them with the relevant frame or attempt. They report facts upward
and do not retry, degrade, invoke actions, or roll back semantic state outside
their explicit bounded contract.

## Static / Embedded Impact

Static implementations may use tagged values, out-parameters, fixed slots, or
specialized generic policy. Diagnostic records may be omitted or stored in a
small ring. The common contract requires deterministic exhaustion and no
mandatory allocation, strings, exceptions, reflection, or dynamic registry.
Splitting facts from execution correlation also prevents low-level firmware
modules from linking execution metadata or diagnostics that they do not use.

## Performance

Failure-free paths should pay only bounded outcome checks and correlation
cost. Diagnostic formatting is not part of the correctness-critical path.
Specifications must measure outcome propagation, saturation, policy dispatch,
and asynchronous completion admission for each selected profile.

## Memory / Binary Size

Specifications must budget the chosen outcome representation, correlation
records, completion queue, any bounded context, optional diagnostic storage,
and policy code. Rich host descriptions and symbolization may live outside
firmware. This RFC does not require a global registry or universal sidecar.

## Alternatives

### Exceptions throughout the core

Exceptions provide familiar dynamic ergonomics and unwinding but do not form a
common Embedded Swift or asynchronous completion contract.

### Layer-local product policy

Local handling can be simple in a closed stack, but reusable layers do not
know whether a display is mandatory, whether retry storage exists, or which
fatal behavior a product supports.

### Global error callback

A callback centralizes reporting but leaves ordering, lifetime, reentrancy,
thread context, and transaction position ambiguous.

### Diagnostics as control flow

Using logging success or severity to decide correctness makes behavior depend
on observability configuration and is invalid for optional diagnostics.

### One rich universal error object

This maximizes desktop context but imposes allocation, strings, schema, and
storage costs that are not justified as the common static representation.

## Rejected Approaches

No approach is formally rejected while this RFC remains `draft`. Review must
choose explicit outcomes, policy ownership, and diagnostic independence before
ADR extraction.

## Compatibility

Existing throwing or callback-based APIs may be adapted at dynamic boundaries.
Existing static status enums may map to the approved portable meaning. The MVP
does not establish a serialized error ABI, numeric registry compatibility, or
telemetry schema.

## Testing Strategy

- Fault-inject every first-party boundary and preserve origin, transaction
  position, and correlation through propagation.
- Verify diagnostics enabled, disabled, saturated, or failing produce the same
  semantic and presentation outcomes.
- Compare static and dynamic policy inputs and dispositions for equivalent
  faults.
- Test asynchronous completion re-entry, late and duplicate facts, and
  interrupt-safe bounded handoff.
- Saturate every selected outcome/context/diagnostic store and verify its
  deterministic behavior.
- Add target-graph and import tests proving `GiftUIFailureCore` is a leaf,
  `GiftUIFailureExecution` imports only the core and execution contracts, the
  execution contract does not import failure, and drivers do not import the
  correlation adapter.
- Keep host, cross-build, simulator, and connected-hardware evidence distinct.

## Risks

- A minimal outcome may be too weak for useful policy; require concrete fault
  fixtures before freezing the Specification.
- A rich common record may impose unnecessary static cost; keep descriptions
  and symbolization out of the portable hot path.
- Product policy may become semantic divergence; restrict it to dispositions
  allowed by the detecting contract and publication position.
- RFC-004 and RFC-006 may change shared terminology; reconcile the coordinated
  drafts before approval.
- A monolithic failure target could pull execution context into drivers or
  diagnostics back into correctness paths; retain the two-target ownership
  split and enforce it with import tests.

## Open Questions

1. What minimum invariant classification must be common across profiles so an
   unknown or richer dynamic condition cannot be handled less safely?
2. Which dispositions must be architecture-wide, and which may remain local to
   a concrete operation without creating product-dependent layer behavior?
3. Does any MVP boundary require durable cross-build numeric compatibility, or
   can stable source-level identities and conformance fixtures suffice?

Record widths, packing, context depth, secondary-failure capacity, privacy
fields, source locations, formatting, sink representation, and target budgets
are Specification or tooling concerns after the architectural model is chosen.

## Deferred and Follow-up Work

No current blocker is hidden in deferred work. A generalized shared diagnostic
Service is preserved by
[FW-009](../future-work/fw-009-shared-delegated-service-foundation.md); current
MVP failure semantics require only an optional consumer-specific observation
seam. A future durable telemetry or cross-version record format requires its
own accepted need.

## Decision Summary

If approved, this RFC is expected to yield candidate ADRs for:

1. explicit bounded cross-layer outcomes with profile-neutral meaning;
2. composition-owned product disposition constrained by detecting-layer and
   publication invariants;
3. diagnostics as optional non-authoritative observations and asynchronous
   outcomes as sequenced runtime input.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-006](rfc-006-capability-system-architecture.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
