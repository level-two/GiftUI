---
id: SPEC-003
feature: giftui-mvp-architecture
title: Failure Outcomes and Containment
status: draft
authors:
  - codex
created: 2026-08-22
updated: 2026-08-22
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-005
related_adrs:
  - ADR-014
  - ADR-015
  - ADR-016
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-004
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

# SPEC-003: Failure Outcomes and Containment

## Summary

This Specification defines the shared, bounded meaning of GiftUI outcomes,
failure containment, affected scope, layered disposition, explicit operational
health projection, and optional diagnostics. It establishes pure fixtures for
mapping producer facts into portable outcomes and for proving that policy and
diagnostic configuration cannot weaken correctness.

This is the `FAILURE` contract in the MVP Specification Portfolio. It is an
initial coordinated scaffold: the ownership boundaries and independent test
seam are normative draft intent, while exact Swift declarations, integer
widths, packing, and target budgets remain approval blockers listed in Open
Issues.

## Scope

This Specification covers:

- profile-neutral outcome categories for success, expected operational
  conditions, and failure;
- source-stable condition identity within one build, stable origin, affected
  scope, and conservative containment;
- the ordered responsibilities of detecting contracts, owning coordinators,
  and target-composition policy;
- explicit operational-health facts and transitions as correctness-relevant
  state distinct from diagnostic history;
- bounded, optional diagnostic projection from outcomes and health
  transitions;
- pure outcome-mapping, total-policy, containment, health, and diagnostic-
  isolation fixtures shared by dynamic and static profiles; and
- the physical dependency boundary between foundational failure facts,
  execution correlation, target policy, and optional diagnostics.

The contract applies to macOS dynamic, macOS static, Raspberry Pi/Linux
dynamic, and nRF52840 static configurations. It does not define the execution
phase machine, backend handoff protocol, capability catalogue, or a particular
platform's product policy.

### Ownership boundary

`FAILURE` exclusively owns outcome, containment, affected-scope, layered-
disposition, operational-health-projection, and diagnostic vocabulary.

- `FOUNDATION` / SPEC-002 owns portable values and import boundaries. This
  Specification references that ownership wherever downstream envelopes use
  those values and MUST NOT define competing geometry, identity-storage, or
  portability primitives. In accordance with ADR-014, `GiftUIFailureCore`
  itself uses only language-level fixed-width primitives and MUST NOT import
  the `GiftUI` module that owns Foundation values.
- `CAPABILITY` / SPEC-004 owns capability contribution, resolution, and
  immutable effective-capability semantics. This Specification MUST NOT
  redefine them. The foundational `GiftUICapabilities` module MUST NOT import
  failure. A target-host adapter outside that module may map a capability-
  domain unavailable result into this Specification's outcome vocabulary.
- Downstream execution Specifications own cycle, revision, frame, publication,
  and handoff state machines. `GiftUIFailureExecution` only correlates those
  externally owned identities with failure facts.
- Backend and host Specifications own concrete normalization tables and total
  product-policy choices for their boundaries. They MUST use, rather than
  reinterpret, this Specification's vocabulary.

## Goals

- Provide one finite, allocation-free portable meaning for equivalent
  outcomes in static and dynamic profiles.
- Make conservative containment and affected scope explicit and testable.
- Ensure every remaining product-policy choice is total, bounded, and no less
  safe than the detecting and coordinating contracts require.
- Keep operational health queryable independently of optional or lossy
  diagnostics.
- Make diagnostic enablement, filtering, saturation, omission, and sink
  failure observationally irrelevant to correctness.
- Supply a hardware-free acceptance seam usable before renderer, runtime,
  backend, or target implementations exist.

## Non-goals

- Defining portable Foundation values or changing module import boundaries
  owned by SPEC-002.
- Defining capability contribution, host resolution, effective capabilities,
  or capability absence/failure semantics owned by SPEC-004.
- Defining execution phases, publication, frame commit, refusal recovery,
  post-handoff presentation mechanics, or input gating.
- Defining one product policy, retry schedule, fatal hook, or target-specific
  policy table for all supported configurations.
- Exposing framework-internal failures as ordinary portable-view control flow.
- Promising stable numeric condition identifiers across builds or versions,
  a serialized error ABI, a global identity registry, or a telemetry schema.
- Adding finer containment classes, rollback, nested semantic execution, or
  condition-specific recovery beyond the accepted conservative MVP model.
- Creating a general `GiftUIServices` package or mandatory global diagnostic
  service.

## Dependencies

### Lifecycle authority

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
  is accepted.
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md) supplies the
  approved import partial order and foundational ownership constraints.
- [RFC-005](../rfcs/rfc-005-failure-diagnostics-propagation.md) is approved.
- [ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md),
  [ADR-015](../adrs/adr-015-layered-failure-disposition.md), and
  [ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md) are accepted.

### Specification and module dependencies

Wave 1 has no earlier Specification drafting prerequisite. Coordination with
SPEC-002 and SPEC-004 is nevertheless required before this draft can enter
review so the three Specifications use identical portable values and do not
claim the same contract.

The required physical dependency direction is:

```text
target host / composition policy
    |-> runtime or backend ----------> GiftUIFailureExecution
    |                                      |-> execution contract
    |                                      \-> GiftUIFailureCore
    |-> integration adapter ---------> GiftUIFailureCore
    \-> optional diagnostic adapter -> GiftUIFailureCore

driver / transport / HAL -----------> GiftUIFailureCore
```

`GiftUIFailureCore` has no dependency on `GiftUI`, execution, runtime, layout,
rendering, backend, platform, driver, OS/RTOS, HAL, capability, or diagnostic
implementations. `GiftUIFailureExecution` imports only `GiftUIFailureCore` and
the focused execution contract. The execution contract MUST NOT import
`GiftUIFailureExecution`.

## Related ADRs

- **ADR-014 — Bounded Cross-Layer Outcome Meaning** governs the three outcome
  categories, stable origin and source identity, affected scope, conservative
  containment, unknown-value mapping, and the split between
  `GiftUIFailureCore` and `GiftUIFailureExecution`.
- **ADR-015 — Layered Failure Disposition Ownership** governs the strict order
  of detecting-layer containment, coordinator-mandated effects, and only then
  total composition-owned selection among remaining safe choices.
- **ADR-016 — Non-Authoritative Diagnostic Projection** governs optional
  bounded diagnostics, explicit operational health independent of diagnostic
  history, and the prohibition on diagnostic or callback paths gaining
  semantic authority.

## Terminology

- **Outcome:** A bounded result of a fallible cross-layer operation. Its
  category is success, operational, or failure.
- **Success:** The operation fulfilled its contract.
- **Operational condition:** An expected bounded condition that requires an
  explicit local or coordinating disposition without asserting a broken
  invariant.
- **Failure:** The operation did not fulfill its contract and supplies a
  failure fact.
- **Failure fact:** The portable combination of source-stable condition
  identity, origin, affected scope, and containment.
- **Origin:** The stable producing contract or subsystem identity. Wrapping a
  fact MUST preserve its original origin.
- **Condition identity:** A source-level identity stable within the producing
  build and shared fixtures. Its numeric representation is not durable across
  builds or versions.
- **Affected scope:** The smallest scope for which the detecting contract can
  prove the reported condition applies: local operation, active cycle,
  candidate frame, owning component/integration, or assembled runtime.
- **Contained:** The detecting contract proved that partial work was rejected
  or invalidated and that normal processing remains safe outside the reported
  affected scope.
- **Safety not proven:** The detecting contract cannot prove contained
  continuation for the reported scope. Unknown or richer profile-specific
  containment maps to this value.
- **Mechanical containment:** Mandatory local rejection, invalidation,
  draining, or resource-release behavior owned by the detecting contract.
- **Coordinator disposition:** Mandatory operation, publication, or frame-
  transaction behavior owned by the coordinator after local containment.
- **Residual product choice:** A safe choice that remains after mechanical
  containment and coordinator disposition and may therefore be selected by
  target composition.
- **Total policy:** A bounded policy that maps every possible input in its
  declared domain to one explicitly allowed residual product choice.
- **Operational health:** Explicit bounded current integration or component
  state, including any required counters, that correctness may query without
  reconstructing it from diagnostics.
- **Diagnostic projection:** An optional bounded observation derived from an
  outcome or health transition. It has no control-flow or health authority.

## Public Contract

Portable views MUST NOT be required to catch or interpret framework-internal
failure facts. A host- or integration-facing API MAY expose bounded startup,
component, operation, cycle, or frame outcomes only when the caller owns a
meaningful disposition.

For the same normalized input and configured policy, static and dynamic
profiles MUST expose equivalent outcome category, condition identity, origin,
affected scope, containment, mandatory disposition, residual policy input,
and operational-health result. Diagnostic configuration MUST NOT change any
of those observations.

No public API may represent a numeric condition identity as persistent,
cross-process, cross-device, or cross-version data under this Specification.

## Module Contract

`GiftUIFailureCore` MUST own only the foundational portable vocabulary. It
MUST permit low-level producers to construct a failure fact without importing
execution, runtime, backend, capability, policy, or diagnostic code.

`GiftUIFailureExecution` MUST own only correlation between a core fact and
identities or positions supplied by the focused execution contract. The first
owner that knows both facts constructs the correlation. Low-level producers
MUST NOT manufacture execution context.

A detecting module MUST perform its contract-mandated mechanical containment
and return the original outcome. A coordinator MUST then apply every mandatory
effect belonging to its operation or transaction. Only a remaining residual
choice may be presented to target-composition policy.

Operational-health storage MUST be owned by the component or integration
whose current health it represents. Diagnostic adapters MAY observe a bounded
projection of its transitions but MUST NOT own, reconstruct, or mutate that
health.

Diagnostic adapters MUST be downstream consumers. No correctness-bearing
module may import an optional diagnostic implementation.

## Types / APIs

The final declaration names, visibility, fixed-width storage, and packing are
not frozen by this scaffold. The implementation contract MUST nevertheless
provide the following finite semantic surfaces:

| Surface | Required information | Invariants |
| --- | --- | --- |
| Portable outcome | category and either success payload, bounded operational condition, or failure fact | Exactly one category; no exception or diagnostic dependency |
| Failure fact | condition identity, origin, affected scope, containment | Original identity and origin survive propagation; scope is never narrowed without proof |
| Containment map | producer value to `contained` or `safety not proven` | Total; unknown and richer values map to `safety not proven` |
| Execution correlation | core fact plus externally owned execution identity/position | Adds context without replacing the core fact; absent below the execution boundary |
| Residual policy input | correlated outcome plus only choices left safe by prior mandatory disposition | Cannot include a choice that weakens containment or mandatory coordinator behavior |
| Operational-health projection | bounded current state and required counters owned by one component/integration | Queryable without diagnostic history; update precedes optional projection |
| Diagnostic projection | selected bounded category, origin, context, and observation data derived from an outcome or health transition | Optional, lossy, and non-authoritative |

All common portable surfaces MUST be representable without heap allocation,
strings, exceptions, reflection, unrestricted dynamic dispatch, or a dynamic
registry. Dynamic conveniences MAY adapt these surfaces at integration
boundaries but MUST preserve their portable meaning.

Every bounded context, record store, diagnostic buffer, counter, and policy
table MUST declare a finite capacity or finite case set. The final draft MUST
name each capacity and its deterministic exhaustion behavior before review.

## Behavior

### Normal outcome propagation

1. The producer classifies the result as success, operational, or failure.
2. For a failure, the producer reports its original identity, origin, the
   smallest affected scope it can prove, and containment.
3. The detecting contract completes mandatory local containment before
   returning the outcome.
4. Each wrapper preserves the original fact and may add bounded context. It
   MUST NOT replace the original cause, narrow affected scope without proof,
   or upgrade containment.
5. The owning coordinator applies every mandatory operation or transaction
   effect.
6. If safe choices remain, target composition receives a residual policy
   input and selects one bounded allowed response.
7. Outcome and health transitions MAY independently produce diagnostic
   observations after correctness-relevant state is established.

### Conservative mapping

Containment normalization MUST be a pure total function. `contained` maps to
`contained`. `safety not proven`, an unknown representation, and every richer
profile-specific value without an explicit portable proof map to `safety not
proven`. Diagnostics, platform detail, policy, and severity MUST NOT upgrade
that result.

An affected scope MUST NOT become narrower during propagation unless the
contract performing that mapping proves the narrower containment before any
effect. Merely adding diagnostic context is not such proof.

### Layered disposition

Composition policy MUST NOT:

- weaken containment or narrow affected scope;
- override mandatory coordinator behavior;
- reinterpret failure as success;
- manufacture missing semantic support;
- silently fall back;
- retry without a finite attempt and pacing bound; or
- use diagnostic presence, severity, delivery, or loss as policy input.

If safe propagation is impossible, the detecting boundary MAY trap when its
contract requires it. A trap is mechanical enforcement of that boundary, not
a target-composition product choice.

### Operational health and diagnostics

Correctness-relevant operational health MUST be updated and queryable even
when diagnostics are disabled, filtered, saturated, dropped, or failing.
Diagnostic selection MAY occur before record construction. A selected record
MAY then be filtered, discarded, counted, buffered, streamed, symbolized, or
omitted.

Changing diagnostic configuration MUST NOT change outcome propagation,
operational health, semantic state, capability results, frame disposition,
policy inputs, or policy results. A diagnostic sink, callback, interrupt,
backend, or driver MUST NOT mutate semantic state or invoke client actions.

## State / Lifecycle

A core failure fact is immutable after construction. Correlation creates a
new envelope and does not mutate or replace the core fact.

Operational health belongs to one component or integration. A transition MUST
update the authoritative bounded health state before any optional diagnostic
projection of that transition. Diagnostic loss does not create, erase, or
reorder health transitions.

Outcome handling follows one forward-only lifecycle:

```text
detect -> mechanically contain -> preserve outcome
       -> apply mandatory coordinator disposition
       -> select any residual product choice
       -> optionally project diagnostics
```

No diagnostic path may re-enter an earlier stage. An approved asynchronous
outcome that is allowed to affect Core MUST enter through its own bounded,
sequenced admission contract; diagnostics are never that admission contract.

Initialization and teardown of diagnostic adapters MUST NOT change failure or
health behavior. After an adapter is unavailable or torn down, outcomes and
health updates continue according to the same contract and observations may
be omitted.

## Capability Requirements

This Specification declares no capability contribution, resolution rule, or
default. Those are owned by SPEC-004.

Failure disposition MAY react to operational loss only through an explicitly
owned health or target-policy seam. It MUST NOT mutate immutable effective-
capability meaning, manufacture support, or treat a missing required
capability as a diagnostic choice. Whether an operational-health transition
changes facility availability is a capability/host contract, not a decision
made here.

## Backend Requirements

A backend or integration boundary MUST normalize native errors into this
portable vocabulary before a core coordinator or composition policy consumes
them. Platform-native strings, exception types, error codes, or richer
containment details MAY remain available to optional diagnostics but MUST NOT
weaken the normalized outcome.

Pre-handoff and post-handoff ownership is supplied by downstream execution and
backend contracts. This Specification requires only that pre-handoff facts use
the typed outcome path and that post-handoff operational conditions cannot be
reclassified as an earlier refusal or reopen committed Core work.

Low-level drivers and transports MUST depend only on `GiftUIFailureCore` when
reporting portable facts. They MUST NOT import execution correlation, runtime,
composition policy, capability resolution, or diagnostics.

## Error Handling

Exhaustion of any correctness-bearing bounded store or admission surface MUST
produce its own deterministic typed outcome. It MUST NOT overwrite admitted
work, silently drop a correctness-relevant fact, reorder facts, recurse into
immediate unbounded retry, or redirect the condition through diagnostics.

Exhaustion or failure of optional diagnostic storage or delivery MUST follow
its configured bounded observation behavior and MUST NOT replace, suppress, or
modify the originating outcome or operational-health update.

Unknown containment fails closed as `safety not proven` for the reported
scope. A failure with safety not proven for runtime scope MUST prevent normal
runtime processing from continuing; target composition may quiesce or invoke
its configured fatal hook, but continuation is not allowed.

## Performance Requirements

- The static-profile construction, normalization, propagation, and pure
  policy path MUST require zero heap allocations.
- Failure-free execution MUST perform only bounded outcome checks and any
  correlation required at an owning boundary; diagnostic formatting MUST NOT
  be part of the correctness-critical path.
- Disabled diagnostic categories MUST NOT require construction of a complete
  diagnostic record.
- Every policy lookup, containment mapping, health query/update, diagnostic
  selection, and diagnostic saturation path MUST have an input-independent
  finite upper bound stated by the implementing target.
- Before this Specification enters review, the draft MUST add numeric RAM,
  stack, code-size, record-size, context-depth, and latency budgets for each
  selected profile or explicitly assign those budgets to a named dependent
  Specification with a conformance interface.

## Compatibility

Equivalent normalized facts MUST have the same source-level identity and
portable meaning in shared static and dynamic conformance fixtures.

Existing throwing, callback-based, or platform-native APIs MAY be adapted at
dynamic or integration boundaries. Such adapters MUST preserve origin,
identity, affected scope, containment, ordering, and disposition and MUST not
make exceptions or callbacks the common GiftUI contract.

Numeric condition representations are build-local. They MUST NOT be persisted,
transmitted, externally symbolized without the exact producing build's map, or
treated as stable across versions. This Specification defines no serialized
failure ABI or migration format.

## Testing Requirements

The independent acceptance harness MUST use pure producers, mappers,
coordinators, policy fixtures, health stores, and diagnostic sinks. It MUST
require no renderer, runtime implementation, concrete backend, platform
driver, simulator, or connected hardware.

Required tests are:

- exhaustive category and containment mapping, including every unknown or
  richer input representation;
- propagation fixtures proving identity and origin preservation, non-narrowing
  affected scope, and non-upgrading containment;
- table-driven policy-totality tests that enumerate every declared residual
  policy input and verify exactly one allowed bounded result;
- fixtures proving detecting-layer, coordinator, and composition stages cannot
  perform one another's responsibilities;
- an operational-health fixture proving current state and counters remain
  accurate when every diagnostic record is dropped;
- a diagnostic matrix covering disabled, source-filtered, sink-filtered,
  saturated, dropping, counting, and failing sinks and comparing all
  correctness-relevant outputs against diagnostics omitted;
- callback and interrupt fixtures proving diagnostic paths cannot mutate
  semantic state or invoke client actions;
- deterministic exhaustion tests for every selected correctness-bearing and
  diagnostic capacity;
- static/dynamic parity fixtures for equivalent facts and policy inputs;
- allocation instrumentation proving the static outcome and policy path makes
  zero heap allocations; and
- target-graph/import tests proving the module dependency rules in this
  Specification.

Downstream execution, backend, platform, and hardware Specifications MUST add
their own transaction-position, handoff, device-health, and connected-target
tests. Those are not prerequisites for this contract's pure test seam.

## Acceptance Criteria

- [ ] A compile fixture imports `GiftUIFailureCore` without importing GiftUI,
  execution, runtime, backend, platform, capability, or diagnostic modules.
- [ ] Import-graph checks prove `GiftUIFailureExecution` imports only the core
  failure and focused execution contracts, the execution contract does not
  import failure execution correlation, and a driver fixture cannot import
  the correlation adapter.
- [ ] One exhaustive containment fixture maps `contained` to `contained` and
  every safety-not-proven, unknown, and richer test value to `safety not
  proven` in both runtime profiles.
- [ ] Propagation fixtures prove the original condition identity and origin
  are unchanged, affected scope is never narrowed without fixture-backed
  proof, and containment is never upgraded.
- [ ] Every value in every declared residual-policy input domain is exercised
  exactly once by a table-driven test and produces one allowed finite result;
  no test exposes a mandatory local or coordinator action as a policy choice.
- [ ] The diagnostic configuration matrix produces byte-for-byte equivalent
  normalized outcomes, health snapshots, coordinator inputs, residual policy
  inputs, and policy results for diagnostics omitted, enabled, filtered,
  saturated, dropping, and failing.
- [ ] Dropping every projected health-transition record leaves the explicit
  health query and counters equal to the diagnostics-enabled baseline.
- [ ] Diagnostic callback and interrupt fixtures record zero semantic
  mutations and zero client-action invocations.
- [ ] Every declared store, context, counter, and policy capacity has one
  deterministic exhaustion test, and no such test overwrites, silently drops,
  reorders, or immediately retries correctness-relevant work.
- [ ] Allocation instrumentation records zero heap allocations for static
  construction, normalization, propagation, health update/query, and residual
  policy dispatch with diagnostics disabled.
- [ ] Static and dynamic fixtures produce identical portable facts and
  dispositions for the complete shared fault corpus.
- [ ] Exact declarations, visibility, widths, packing, capacities, and
  per-profile budgets are resolved in this document before its status changes
  from `draft` to `review`.

## Implementation Notes

This section is non-authoritative. A practical drafting sequence is to freeze
the core semantic cases and fixture corpus first, then agree the Foundation
primitive representations with SPEC-002, and finally add execution correlation
and optional diagnostic adapters. Existing throwing and platform-specific
errors are migration evidence, not contract authority.

The same pure fixtures should be reusable by later execution, runtime-profile,
backend-integration, and host-configuration Specifications.

## Open Issues

These are contract-detail blockers for review, not unresolved architecture:

- Choose exact Swift declaration names, generic or non-generic outcome shape,
  access levels, and construction APIs without changing the three approved
  outcome meanings.
- Select fixed integer widths and packing for condition identity, origin,
  affected scope, correlation, health counters, and diagnostic records.
- Define the complete bounded operational-condition catalogue required by the
  MVP producer contracts.
- Define exact bounded context depth and behavior when additional context
  cannot be recorded.
- Define exact operational-health state/counter surfaces shared with SPEC-004
  without redefining capability contribution or resolution.
- Define diagnostic categories, record fields, source-selection mechanism,
  sink interface, buffering capacities, and saturation counters.
- Assign concrete RAM, stack, binary-size, and latency budgets for all four
  MVP configurations.
- Reconcile final names and imports reciprocally with SPEC-002 and SPEC-004,
  then update all three relationship links and the feature manifest in the
  coordinated Wave 1 change.

Any resolution that changes ownership, adds a new containment or recovery
class, makes diagnostics authoritative, or changes the accepted dependency
direction MUST return to RFC/ADR review instead of being resolved here.

## Deferred and Follow-up Work

- [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md)
  preserves a possible shared delegated-service foundation. This
  Specification requires only a narrow consumer-specific diagnostic seam.
- [FW-012](../future-work/fw-012-durable-failure-identity-compatibility.md)
  preserves durable cross-build identities and versioned catalogues.
- [FW-013](../future-work/fw-013-fine-grained-failure-containment-recovery.md)
  preserves finer containment and recovery classifications.

None of these items is required for correctness or approval of the bounded MVP
contract.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [ADR-014: Bounded Cross-Layer Outcome Meaning](../adrs/adr-014-bounded-cross-layer-outcomes.md)
- [ADR-015: Layered Failure Disposition Ownership](../adrs/adr-015-layered-failure-disposition.md)
- [ADR-016: Non-Authoritative Diagnostic Projection](../adrs/adr-016-non-authoritative-diagnostics.md)
- [SPEC-001: Signal Analyzer Reference Application Contract](spec-001-signal-analyzer-reference-application.md)
- [SPEC-002: Portable Foundation](spec-002-portable-foundation.md)
- [SPEC-004: Capability Contribution and Resolution](spec-004-capability-contribution-and-resolution.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
