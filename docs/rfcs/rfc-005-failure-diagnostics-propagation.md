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
  - FW-013
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
structured outcomes, that detecting layers perform only contract-mandated
containment, that coordinators apply required transaction rules, and that
target composition chooses only the remaining safe product dispositions.
Diagnostics remain best-effort observations with no control-flow authority.

```text
layer detects a condition
    -> contract-mandated local containment
    -> explicit bounded outcome propagates toward its coordinator
    -> coordinator applies required publication/handoff disposition
    -> composition policy selects among any remaining safe product choices

post-handoff presentation condition
    -> bounded backend-local health, recovery, and input gating
    -> no change to committed logical frame

optional diagnostic record
    -> optional bounded projection and filtering
    -> sink, counter, buffer, stream, or omission
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

### R2 — Fact, containment, and policy separation

A detecting layer MUST describe the condition and local work it could not
complete, perform any mechanical containment required by its contract, and
return the resulting outcome. It MUST NOT independently choose product-level
retry, fallback, capability disablement, runtime termination, or silent
continuation. A local response is allowed only when the detecting contract
lists it explicitly, bounds it, and proves that it preserves the reported
containment and affected scope.

### R3 — Layered disposition ownership

The owning coordinator MUST apply disposition required by the active operation
and RFC-004's publication or handoff position. When more than one safe product
response remains, the target composition MUST supply total bounded policy for
that choice. Composition policy may be specialized statically or injected
dynamically, but MUST NOT override detecting-layer containment or mandatory
coordinator disposition.

### R4 — Diagnostics are non-authoritative

Diagnostic presence, filtering, formatting, delivery, loss, or sink failure
MUST NOT change semantic state, layout, render operations, capability results,
frame disposition, or failure policy.

### R5 — Preserve origin and context

Propagation MUST preserve stable origin, condition identity, and the smallest
affected scope the detecting contract can prove, sufficient for policy and
tests. Boundary context MAY be added in a bounded form but MUST NOT replace the
original cause or narrow its affected scope.

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
containment, affected scope, transaction position, and allowed disposition. A
profile-specific or unknown containment value MUST map to the conservative
portable meaning rather than permit less-safe continuation. The common meaning
MUST be representable without heap allocation, strings, exceptions,
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

### MVP containment and affected scope

The MVP uses one conservative portable containment distinction for failures:

- **contained:** the detecting contract proves that partial work is rejected
  or invalidated and that normal processing remains safe outside the reported
  affected scope; or
- **safety not proven:** the detecting contract cannot provide that guarantee,
  so normal processing MUST NOT continue for the reported affected scope.

An unknown or richer profile-specific value maps to **safety not proven**.
Diagnostics, platform detail, and product policy cannot upgrade it to
**contained**.

Affected scope remains a separate fact. The MVP needs only straightforward
architectural scopes: the local operation, the active cycle or candidate
frame, the owning component or integration, and the assembled runtime. A
Specification may choose compact names and representation, but it MUST NOT
report a scope narrower than the detecting contract can prove. The execution-
correlation adapter adds RFC-004 publication, frame, and handoff position; the
foundational fact does not import those identities.

The conservative MVP mapping covers these representative cases:

- a validated request, arithmetic, or bounded-capacity failure detected before
  publication is contained to its operation, cycle, or candidate frame when
  the contract discards all partial output;
- a synchronous handoff refusal is contained to the candidate frame only when
  the backend satisfies RFC-004's refusal and retention invariants;
- a post-handoff device or transport failure is contained from Core and affects
  the owning presentation/input integration's local health; and
- broken state identity or lifetime, internal reentrancy, forbidden-phase
  mutation, or any similar invariant violation is **safety not proven** for the
  runtime unless its contract already proves before-effect rejection or
  deferral. If safe propagation itself is impossible, the detecting boundary
  may trap immediately.

Approved asynchronous facts and reentrant external input that enter through a
bounded sequenced admission contract are operational work, not invariant
failures. Exhaustion or corruption of that admission mechanism is reported as
its own outcome.

The MVP does not add finer severity rankings, recoverable invariant-violation
subclasses, rollback, nested semantic execution, or condition-specific
continuation rules. [FW-013](../future-work/fw-013-fine-grained-failure-containment-recovery.md)
preserves that possible refinement without weakening this RFC's current
direction.

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

Disposition has three owners, in order:

1. The detecting layer performs only contract-mandated mechanical containment,
   such as rejecting partial output, retaining no borrowed resource, and
   preserving the original failure fact.
2. The owning coordinator applies mandatory operation and transaction rules,
   such as keeping state dirty after failed derivation, aborting a candidate
   frame, or retaining the previous committed frame and routing state.
3. The target composition selects only among safe product responses that
   remain, such as marking an optional facility unavailable, quiescing the
   runtime, or invoking a platform fatal hook.

The first two stages are contract behavior, not configurable product policy.
Composition may select nothing weaker than the reported containment, affected
scope, and transaction position allow. It cannot manufacture missing semantic
support, reinterpret a violated invariant as success, silently fall back, or
retry unboundedly. Post-handoff presentation recovery and physical-input
gating belong to the target integration; composition may configure that local
policy but cannot use it to reopen a committed Core frame. RFC-006 owns
capability declaration and operational-state classification.

The following representative MVP table fixes the ownership boundary without
specifying exact Swift cases or policy APIs:

| Outcome | Detecting owner and position | Mandatory local response | Mandatory coordinator response | Remaining composition choice | Safety invariant |
| --- | --- | --- | --- | --- | --- |
| Admission storage exhausted | Admission boundary, before cycle membership | Reject the new fact or input and report bounded backpressure; do not overwrite admitted work | Preserve ordering and existing membership | Select only an admission action explicitly allowed by the contract, such as paced resubmission or declared loss | No overwrite, reordering, hidden drop, or immediate unbounded retry |
| Derivation or layout failure after admitted mutation, before semantic publication | State, reconciliation, or layout producer in the active cycle | Discard partial derived output and preserve the failure fact | Keep affected state dirty and request a later host-paced cycle under RFC-004 | No override of dirty recovery; composition may quiesce only when safety is not proven or continued service is not acceptable | Do not roll back or replay admitted mutations, actions, or side effects |
| Render storage exhausted after semantic publication, before handoff | Render producer preparing the candidate frame | Discard partial frame-local output | Abort the candidate frame; retain the published semantic revision and previous committed logical frame | Mark an optional presentation facility unavailable, quiesce, or invoke the target fatal hook according to required-facility policy | No partial handoff, silent allocation fallback, or automatic frame retry |
| Backend refuses or fails synchronous handoff | Backend during `offer`, before acceptance | Retain no frame data or borrowed resource and return the normalized outcome | Abort the candidate frame and retain the previous committed frame and routing state | Apply required-facility policy; any future presentation attempt must be separately admitted and bounded | Refusal cannot commit, retain, replay, or synchronously retry the offered operation stream |
| Device or transport fails after accepted handoff | Presentation/input integration, after logical commit | Update bounded local health, preserve presentation/input coherence, and gate stale physical input | Do not reopen or change the committed Core frame | Configure bounded integration-local recovery or treat the required facility as unavailable | Post-handoff failure cannot roll back semantics, invoke client actions, or alter Core frame disposition |
| Failure reports **safety not proven** for runtime scope | Boundary detecting an invariant failure; any phase | Trap immediately if safe propagation is impossible; otherwise preserve and report the failure | Prevent normal processing from continuing for the affected runtime scope | Quiesce or invoke the target fatal hook; continuation is not an allowed choice | Diagnostics or policy cannot upgrade the failure to **contained** |

### Diagnostics

A diagnostic is a bounded observation derived from an outcome or other event.
It is separate from both the outcome path and current operational health:

- every correctness-relevant outcome follows its typed propagation path even
  when diagnostics are disabled or filtered;
- integration health is explicit bounded state or counters owned by that
  integration and is not inferred from a possibly lossy diagnostic history;
  and
- diagnostics are an optional projection for logging, debugging, tests, or
  host tooling and never determine correctness or health.

A dynamic or debug target may project every normalized outcome and selected
health transition. A static or production target may omit diagnostics or
select only configured categories before records are created. A sink may then
apply additional filtering by category, origin, transaction position, or
severity and may discard, buffer, stream, count, or symbolize the result.
Severity alone is not the portable disposition model: a low-severity
operational condition may be important for health analysis, while a serious
but contained frame failure may still permit safe runtime continuation.

Diagnostic selection, filtering, saturation, or sink failure MUST NOT suppress
an outcome, change integration health, or alter a disposition. This RFC does
not require either a critical-only stream or a universal all-event stream, and
it does not require a shared `GiftUIServices` package or global diagnostic
framework. FW-009 preserves that possible generalization.

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
| `GiftUIFailureExecution` candidate adapter | Correlate a core fact with RFC-004 execution and publication context; expose the narrow residual policy input seam                                     | Runtime/backend implementation or selected product policy                    |
| Detecting layer                            | Validate its contract, perform contract-mandated mechanical containment, and report a structured fact                                                 | Cross-product retry, fallback, capability, quiescence, or fatal choice       |
| Runtime/frame coordinator                  | Attach publication/frame/handoff context, apply mandatory transaction disposition, and route any remaining product choice                            | Platform-specific error interpretation or post-handoff presentation recovery |
| Presentation/input integration             | Own explicit bounded post-handoff device health, recovery, and physical-input gating; optionally project diagnostics                                 | Reopen a committed frame, mutate semantics, or invoke client actions         |
| Target composition                         | Select total bounded policy only for remaining safe product choices and assemble the optional diagnostic projection                                  | Override local containment, mandatory coordinator disposition, or capability support |
| Diagnostic adapter/tooling                 | Select, filter, consume, count, buffer, stream, or symbolize bounded observations                                                                      | Correctness, health authority, semantic mutation, or disposition authority   |

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
specialized generic policy. Diagnostic projection may be removed at build
time, restricted to configured categories before record creation, or stored in
a small bounded ring. The common contract requires deterministic exhaustion
and no mandatory allocation, strings, exceptions, reflection, dynamic
registry, or all-event stream. Splitting facts from execution correlation also
prevents low-level firmware modules from linking execution metadata or
diagnostics that they do not use.

## Performance

Failure-free paths should pay only bounded outcome checks and correlation
cost. Diagnostic selection and formatting are not part of the correctness-
critical path, and disabled categories should not require full record
construction. Specifications must measure outcome propagation, mandatory
coordinator disposition, residual policy dispatch, diagnostic projection and
saturation, approved asynchronous Core admission where present, and backend-
local post-handoff health/input gating for each selected profile.

## Memory / Binary Size

Specifications must budget the chosen outcome representation, correlation
records, any approved asynchronous admission queue, bounded context, backend-
local health/input-gating state and counters, optional diagnostic selection and
storage, and policy code. Rich host descriptions and symbolization may live
outside firmware. This RFC does not require a global registry, universal
sidecar, or storage sized for all events.

## Alternatives

### Exceptions throughout the core

Exceptions provide familiar dynamic ergonomics and unwinding but do not form a
common Embedded Swift or asynchronous completion contract.

### One fixed architecture-wide response per outcome

A fixed table is small and deterministic, and this RFC uses fixed responses
where containment or transaction invariants permit no choice. Extending that
table to product consequences is too rigid: a reusable layer does not know
whether a facility is required or which fatal action a target supports.

### Composition policy for every non-success outcome

Routing every outcome directly to one composition policy creates one visible
decision point. It also forces product policy to understand partial buffers,
borrowed resources, dirty state, and handoff mechanics that belong to the
detecting contract or transaction coordinator.

### Independent subsystem policies

Per-subsystem policy interfaces offer local flexibility but allow equivalent
conditions to receive inconsistent product dispositions. They also spread
whole-product policy across modules and complicate static/dynamic conformance.

### Global error callback

A callback centralizes reporting but leaves ordering, lifetime, reentrancy,
thread context, and transaction position ambiguous.

### Diagnostics as control flow

Using logging success or severity to decide correctness makes behavior depend
on observability configuration and is invalid for optional diagnostics.

### Critical-only diagnostics as the common contract

Emitting only critical records reduces production cost, but "critical" is a
consumer and product classification rather than the portable safety model. It
also removes contained operational evidence useful for debugging and health
analysis. A target may select such a projection, but it is not the universal
diagnostic contract.

### Emit every diagnostic record and filter only at the sink

This gives dynamic host tooling maximum visibility, but requires every target
to construct and transport records that may immediately be discarded. It is a
valid target configuration, not a portable requirement for constrained static
builds.

### One rich universal error object

This maximizes desktop context but imposes allocation, strings, schema, and
storage costs that are not justified as the common static representation.

## Rejected Approaches

No approach is formally rejected while this RFC remains `draft`. Review must
validate explicit outcomes, the layered disposition table, and diagnostic
independence before ADR extraction.

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
- For representative state, layout, render-production, bounded-capacity, and
  handoff faults, verify that a **contained** result discards partial work and
  leaves normal processing valid outside its reported scope.
- Inject an unknown or richer profile-specific containment value and verify
  every profile maps it to **safety not proven** for the same affected scope.
- Verify broken state identity or lifetime and uncontained internal
  reentrancy or forbidden-phase mutation cannot resume normal runtime
  processing; a boundary may claim containment only with a fixture proving
  before-effect rejection or deferral.
- Verify diagnostics enabled, disabled, saturated, or failing produce the same
  semantic and presentation outcomes.
- Exercise each representative disposition-table row and verify the detecting
  layer performs only its mandatory containment, the coordinator applies the
  required transaction effect, and composition sees only any remaining safe
  product choice.
- Compare critical-only, all-selected-outcome, and category-filtered diagnostic
  projections. Verify they produce identical outcome propagation, health
  state, coordinator disposition, and composition-policy inputs.
- Drop diagnostic health-transition records and verify an explicit health
  query or counter still reports the current backend/integration state.
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
- Diagnostic volume may exceed bounded storage or transport capacity; permit
  source selection and sink filtering while keeping loss independent from
  outcomes and explicit health.
- A severity-only filter may hide useful contained operational evidence; keep
  category, origin, and transaction position available to configured
  diagnostic projections.
- RFC-004 and RFC-006 may change shared terminology; reconcile the coordinated
  drafts before approval.
- A monolithic failure target could pull execution context into drivers or
  diagnostics back into correctness paths; retain the two-target ownership
  split and enforce it with import tests.
- Conservative containment may stop a component or runtime in a case that
  future evidence could prove recoverable. This is an accepted MVP simplicity
  cost; FW-013 preserves finer classification and recovery work.

## Open Questions

No question remains an approval blocker in the current proposed direction.
The portable safety meaning uses conservative containment plus affected scope;
the MVP makes no cross-build numeric-stability promise; and the representative
disposition table assigns mandatory containment to the detecting contract,
mandatory transaction effects to the owning coordinator, and only remaining
safe product choices to target composition.

Diagnostic projection is also separated from that disposition path. Targets
may select critical-only, all-selected-outcome, or category-filtered
observation without changing typed outcome propagation or explicit operational
health. These remain proposed architectural choices until this RFC receives
human approval.

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

[FW-013](../future-work/fw-013-fine-grained-failure-containment-recovery.md)
preserves possible relaxation of the conservative MVP safety rule, finer
affected scopes, recoverable invariant subclasses, before-effect reentrancy
handling, and specialized recovery. These are outside MVP because the simple
containment-plus-scope model handles the required faults safely and no current
Signal Analyzer or target-validation requirement needs more availability.
Revisit only when concrete evidence shows that the conservative rule prevents
an accepted behavior or availability requirement.

## Decision Summary

If approved, this RFC is expected to yield candidate ADRs for:

1. explicit bounded cross-layer outcomes with profile-neutral conservative
   containment, affected scope, source-stable identity, and no MVP promise of
   cross-build numeric stability;
2. layered disposition: contract-mandated detecting-layer containment,
   mandatory coordinator transaction effects, and composition-owned selection
   only among remaining safe product choices;
3. diagnostics as optional filtered non-authoritative projections distinct
   from explicit operational health, approved
   asynchronous Core outcomes as sequenced input, and post-handoff
   presentation failures as backend-local operational state.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-006](rfc-006-capability-system-architecture.md)
- [FW-012](../future-work/fw-012-durable-failure-identity-compatibility.md)
- [FW-013](../future-work/fw-013-fine-grained-failure-containment-recovery.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
