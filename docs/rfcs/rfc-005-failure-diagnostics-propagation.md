---
id: RFC-005
feature: giftui-mvp-architecture
title: Failure and Diagnostics Propagation Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-19
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
  - FW-012
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

post-handoff presentation condition
    -> bounded backend-local health, recovery, and input gating
    -> no change to committed logical frame

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

RFC-004 owns cycle admission, semantic publication, frame lifetime, and the
synchronous handoff commit boundary. This RFC consumes those positions to
explain whether a failure aborts unpublished work, refuses frame handoff, or is
only backend-local health after a logical frame has committed. It does not
duplicate RFC-004's phase machine.

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

### R6 — Callback and interrupt isolation

An outcome from an approved asynchronous contract that is allowed to affect
Core MUST re-enter through its owning bounded sequenced admission contract and
MUST NOT mutate semantic state or invoke client handlers from a callback or
interrupt. Device, transport, compositor, and physical-presentation outcomes
after RFC-004's accepted handoff remain backend/integration-local; they MAY
feed local health, recovery, input gating, or optional diagnostics but MUST NOT
reopen the frame transaction.

### R7 — Publication-aware effects

A failure before complete semantic publication may invalidate that cycle's
unpublished work. A failure after publication MUST NOT roll back or replay the
published semantic revision. A failure before accepted frame handoff may abort
the candidate frame; a failure after accepted handoff affects backend-local
health, recovery, presentation/input gating, or optional diagnostics only.

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

Synchronous outcomes through frame handoff are handled within their active
RFC-004 boundary. An approved asynchronous operation whose outcome can affect
Core uses its own bounded admission contract. Post-handoff presentation
outcomes remain in the target integration and may produce optional bounded
diagnostics. No path grants a diagnostic sink, backend callback, or driver
interrupt direct semantic authority.

### Policy

The composition root knows which facilities are required and what fatal action
a product supports. It therefore selects policy for actions such as aborting
unpublished work, refusing a pre-handoff frame, marking an optional facility
unavailable, quiescing the runtime, or invoking a platform fatal hook.
Post-handoff presentation recovery and physical-input gating belong to the
target integration rather than this Core disposition policy.

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
  applicable RFC-004 cycle, frame, phase, handoff, and publication position.

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

This placement preserves RFC-002 B15: foundational facts can originate at any
operational layer, while publication-aware disposition through handoff is
performed only after correlation at the runtime/frame boundary. After handoff,
B16 keeps presentation/input coherence inside the target integration and this
RFC supplies only optional diagnostic observation. It also preserves B2: the
host assembles policy and optional diagnostics without exporting new portable
semantics.

## Module Responsibilities

| Owner                                      | Responsibility                                                                                                                                         | Must not own                                                                 |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------- |
| `GiftUIFailureCore` candidate leaf         | Portable outcome meaning, origin, affected scope, and stable condition identity                                                                        | Execution identity, product policy, or rich diagnostic formatting            |
| `GiftUIFailureExecution` candidate adapter | Correlate a core fact with RFC-004 execution and publication context; expose the narrow policy input seam                                              | Runtime/backend implementation or selected product policy                    |
| Detecting layer                            | Validate its contract and report a structured fact                                                                                                     | Cross-product retry, fallback, or fatal choice                               |
| Runtime/frame coordinator                  | Attach publication/frame/handoff context and route synchronous pre-handoff outcomes plus outcomes from separately approved asynchronous Core contracts | Platform-specific error interpretation or post-handoff presentation recovery |
| Presentation/input integration             | Own post-handoff device health, recovery, and physical-input gating; optionally emit diagnostics                                                       | Reopen a committed frame, mutate semantics, or invoke client actions         |
| Target composition                         | Select total bounded product policy and optional diagnostic adapter                                                                                    | Rewrite lower-layer invariants or capability support                         |
| Diagnostic adapter/tooling                 | Consume or symbolize bounded observations                                                                                                              | Correctness, semantic mutation, or disposition authority                     |

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

Backends normalize command, resource, and handoff outcomes synchronously. A
pre-handoff failure propagates toward the frame coordinator. After accepted
handoff, the backend/integration owns bounded downstream health, recovery, and
presentation-coupled input gating; it may emit optional diagnostics but does
not report a Core frame outcome, invoke actions, or roll back semantic state.

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
approved asynchronous Core admission where present, and backend-local post-
handoff health/input gating for each selected profile.

## Memory / Binary Size

Specifications must budget the chosen outcome representation, correlation
records, any approved asynchronous admission queue, bounded context, backend-
local health/input-gating state, optional diagnostic storage, and policy code.
Rich host descriptions and symbolization may live outside firmware. This RFC
does not require a global registry or universal sidecar.

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
Existing static status enums may map to the approved portable meaning. The
proposed MVP contract preserves typed source-level failure identities and
their meaning through shared conformance fixtures, but it does not promise
that a numeric representation keeps the same meaning across different builds
or software versions. MVP code must not persist, transmit, or externally
symbolize such a number as though it were a durable identifier. A future
cross-build consumer would require an explicitly versioned compatibility
contract; [FW-012](../future-work/fw-012-durable-failure-identity-compatibility.md)
preserves that post-MVP question. The MVP does not establish a serialized error
ABI, numeric registry, or telemetry schema.

## Testing Strategy

- Fault-inject every first-party boundary and preserve origin, transaction
  position, and correlation through propagation.
- Verify diagnostics enabled, disabled, saturated, or failing produce the same
  semantic and presentation outcomes.
- Compare static and dynamic policy inputs and dispositions for equivalent
  faults.
- Test every separately approved asynchronous Core contract for interrupt-safe
  bounded admission, late facts, and duplicate facts.
- Inject post-handoff display and transport failures and verify they affect
  only backend-local health/recovery, physical-input gating, and optional
  diagnostics rather than Core frame disposition.
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

These two questions remain approval blockers because they determine the
portable safety meaning and the boundary between local handling and product
policy. Cross-build numeric stability is no longer an MVP blocker: the
proposed compatibility contract above does not promise it.

### 1. What safety information must every build understand?

**In simple words:** When something goes wrong, what is the smallest shared
answer to: "Is it safe to continue, and if so, what work is still valid?"

**Context:** A dynamic build may attach more detail than a small static build
can afford. Both builds must nevertheless make equally safe decisions for the
same condition. A condition that one profile does not recognize must never be
treated as less serious merely because its richer classification is absent.

**Possible alternatives:**

- Use one common safety distinction: continued processing is either safe or
  unsafe for the reported affected scope. This is the smallest representation,
  but it may give composition policy too little information.
- Define a small closed set of portable safety classes, for example: only the
  current operation failed, the current cycle or frame is invalid, or the
  runtime cannot safely continue. This supports more precise policy at a
  higher representation and testing cost.
- Permit profile-specific classes but require each one to map to a smaller
  portable class, with unknown values taking the most conservative allowed
  meaning. This preserves richer host diagnostics but adds mapping and version
  rules.

**Evidence needed to close it:** Classify representative MVP faults from state,
layout, render production, backend handoff, and bounded-storage exhaustion.
Choose the smallest common classification that gives every target composition
enough information to select a safe disposition without inspecting
platform-specific detail.

### 2. Which responses are local, and which belong to the whole application?

**In simple words:** What may the code that detects a problem do by itself,
and what must be decided by the target application's composition policy?

**Context:** Some responses are part of a concrete operation's normal contract,
such as reporting backpressure or declining work before handoff. Other
responses affect the whole product, such as abandoning a frame, disabling an
optional facility, stopping the runtime, or invoking a fatal platform hook.
Putting every response in the detecting layer makes products behave
differently inside shared framework code. Sending every small operational
choice to the composition root can make simple boundaries unnecessarily
complex.

**Possible alternatives:**

- Route every non-success outcome to one composition-owned policy. This gives
  one visible decision point but centralizes operation-specific knowledge and
  increases plumbing.
- Use a split model: a detecting contract may perform only explicitly listed,
  bounded local responses; anything that changes cycle, frame, facility, or
  runtime state goes to composition-owned policy. This preserves local
  simplicity but requires a precise architecture-wide boundary.
- Give each subsystem its own policy interface. This offers flexibility, but
  risks inconsistent product behavior and makes whole-stack review harder.

**Evidence needed to close it:** Build a disposition table for representative
MVP outcomes. For each row, identify the detecting owner, publication or
handoff position, allowed local responses, required composition response, and
the invariant that prevents silent fallback or unbounded retry.

Record widths, packing, context depth, secondary-failure capacity, privacy
fields, source locations, formatting, sink representation, and target budgets
are Specification or tooling concerns after the architectural model is chosen.

## Deferred and Follow-up Work

No current blocker is hidden in deferred work. A generalized shared diagnostic
Service is preserved by
[FW-009](../future-work/fw-009-shared-delegated-service-foundation.md); current
MVP failure semantics require only an optional consumer-specific observation
seam.

[FW-012](../future-work/fw-012-durable-failure-identity-compatibility.md)
preserves the alternatives for stable numeric identifiers, versioned
catalogues, and durable registries. They remain outside MVP because no current
tool, persisted record, or device protocol requires a failure identifier to be
interpreted across builds. Revisit the item when an accepted post-MVP need
introduces such a consumer; the future design must then pass the normal
Proposal, RFC, ADR, and Specification gates as applicable.

## Decision Summary

If approved, this RFC is expected to yield candidate ADRs for:

1. explicit bounded cross-layer outcomes with profile-neutral, source-stable
   identity and no MVP promise of cross-build numeric stability;
2. composition-owned product disposition constrained by detecting-layer and
   publication invariants;
3. diagnostics as optional non-authoritative observations, approved
   asynchronous Core outcomes as sequenced input, and post-handoff
   presentation failures as backend-local operational state.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-006](rfc-006-capability-system-architecture.md)
- [FW-012](../future-work/fw-012-durable-failure-identity-compatibility.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
