---
id: SPEC-013
feature: giftui-mvp-architecture
title: Dynamic and Static Runtime Profile Contract
status: draft
authors:
  - codex
created: 2026-08-27
updated: 2026-08-28
proposal:
  - PROPOSAL-003
  - PROPOSAL-005
  - PROPOSAL-006
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-005
  - RFC-008
  - RFC-009
  - RFC-010
  - RFC-011
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-008
  - ADR-009
  - ADR-010
  - ADR-011
  - ADR-012
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-024
  - ADR-025
  - ADR-026
  - ADR-028
  - ADR-029
  - ADR-031
  - ADR-032
  - ADR-033
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPEC-006
  - SPEC-007
  - SPEC-008
  - SPEC-009
  - SPEC-010
  - SPEC-011
  - SPEC-012
  - SPEC-014
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-003
  - SPIKE-004
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-013: Dynamic and Static Runtime Profile Contract

## Summary

This Specification defines the two MVP runtime profiles beneath GiftUI's one
portable declarative model. `GiftUIRuntimeDynamic` and
`GiftUIRuntimeStatic` may use different storage, dispatch, and specialization
mechanisms, but they must coordinate the same semantic expansion, layout,
drawing-plan derivation, rendering, execution, observable-state, and
interaction contracts with identical observable results.

The contract makes all correctness-relevant storage finite, validates it
before the first cycle, gives each attempt exclusive caller-owned workspaces,
and defines a shared recording conformance suite. It does not select a
backend, target host, production capacities, or retry policy.

## Scope

This Specification covers:

- dynamic and static runtime-profile identity and selection;
- profile-owned live, candidate, queue, workspace, and committed storage;
- coordination of SPEC-006 through SPEC-012 in the SPEC-009 run cycle;
- dynamic and static realization of SPEC-010 observable state and SPEC-011
  interaction records;
- Canvas callable and cycle-local plan storage required by SPEC-012;
- startup validation of the profile's declared structural capacities;
- exclusive workspace lifetime, reset, and failure cleanup;
- profile-neutral result transcripts and cross-profile conformance; and
- static-profile allocation, language-runtime, and resource evidence.

It applies to dynamic macOS, static macOS, dynamic Raspberry Pi/Linux, and
static nRF52840 configurations. Connected-target assembly is downstream.

## Goals

- Preserve one portable Presentation source and one set of observable
  semantics across both profiles.
- Make every static correctness resource finite and inspectable before use.
- Prevent dynamic conveniences from becoming common semantic requirements.
- Compose approved focused contracts without duplicating their algorithms or
  vocabularies.
- Permit complete hardware-free conformance through recording endpoints and
  deterministic fixtures.

## Non-goals

- Selecting concrete backend, raster, surface, display, input, or transport
  implementations.
- Defining Wave 7 host presets, production capacity values, pacing limits, or
  fatal product policy.
- Adding public client APIs or runtime selection branches to portable views.
- Defining another semantic tree, layout algorithm, rendering vocabulary,
  failure taxonomy, capability family, or diagnostic control path.
- Requiring retained frames, retained Canvas plans, replay, tasks, threads, or
  asynchronous semantic evaluation.
- Treating current proof-of-concept runtime types as authority.

## Dependencies

The governing Proposals are accepted, the related RFCs are approved, and all
listed ADRs are accepted. SPEC-002, SPEC-003, and SPEC-006 through SPEC-012 are
approved. This Specification was drafted against SPEC-012 before its approval
and MUST be reconciled to the approved drawing contract before this draft
advances.

The runtime receives a validated exact text-resource package from SPEC-005, a
resolved capability snapshot from SPEC-004, and a synchronous frame endpoint
from SPEC-009. It does not own those contracts.

## Related ADRs

- ADR-005 and ADR-006 require one semantic, layout, operation-order, failure,
  state-lifetime, action-order, and publication meaning across storage
  profiles.
- ADR-008 fixes the acyclic package topology and prevents `GiftUI` from
  importing either runtime.
- ADR-009 requires checked integer geometry and deterministic exhaustion.
- ADR-010 through ADR-012 fix the serialized cycle, one-shot offer, and
  constant-space refusal-recovery behavior the coordinator realizes.
- ADR-014 through ADR-016 require bounded outcomes, layered disposition, and
  diagnostics that cannot affect correctness.
- ADR-024 through ADR-026 require structurally owned, bounded,
  profile-equivalent observable state.
- ADR-028, ADR-029, and ADR-031 require post-layout scoped Canvas invocation,
  transient Path/plan storage, and complete pre-offer validation.
- ADR-032 preserves the semantic-core-owned borrowed layout input; runtime
  profiles coordinate that edge but do not own or adapt it.
- ADR-033 fixes bounded action/model-target binding, generation replacement,
  final dispatch validation, and allocation-free static action storage.

## Terminology

**Profile**
: A compile-time-selected storage, composition, and dispatch realization.

**Profile storage**
: All runtime-owned live, staged, queued, workspace, committed, and recovery
  state needed by one assembled runtime.

**Attempt storage**
: Exclusive semantic, layout, drawing-plan, rendering, observable-candidate,
  and interaction-candidate storage used by one run cycle.

**Committed routing storage**
: The hit regions, bound actions, generations, and presentation provenance
  made eligible only by an accepted frame.

**Storage audit**
: A deterministic startup report proving that every required store exists and
  meets the declared limits without exercising client code.

## Public Contract

This Specification adds no public declaration to `GiftUI`.

Portable Presentation MUST compile with only `import GiftUI`, MUST use the
same source for dynamic and static profiles, and MUST NOT name, query, switch
over, or condition behavior on a runtime profile. Profile choice is made by
the target dependency graph and host composition before construction.

Client-observable identity, state lifetime, evaluation order, layout,
operation order, Canvas invocation count, action behavior, failure effects,
semantic publication, and frame commit behavior MUST be identical for
equivalent inputs and limits. Greater dynamic storage does not permit a
different success result for a fixture configured with the same limits.

## Module Contract

`GiftUIRuntimeCore` owns the package SPI in this Specification, the common
coordinator sequencing, structural validation, storage-audit transcript, and
shared conformance fixture driver. It imports `GiftUI`,
`GiftUISemanticCore`, `GiftUILayout`, `GiftUITextResources`,
`GiftUIRenderLowering`, `GiftUIRenderCore`, `GiftUIExecution`,
`GiftUIObservableState`, `GiftUIInteraction`, and `GiftUIDrawing`.
It MUST NOT import a concrete backend, rasterizer, surface, platform, driver,
OS/RTOS, HAL, hardware target, host preset, or capability implementation.

`GiftUIRuntimeDynamic` and `GiftUIRuntimeStatic` each import
`GiftUIRuntimeCore` and the focused owners needed by their concrete storage.
They MUST NOT duplicate semantic expansion, layout, combined rendering,
execution, observable-state, or interaction algorithms. Neither runtime may
import the other.

The dynamic runtime MAY use retained classes, bounded heap-backed buffers,
and typed dictionaries internally. Dynamic convenience APIs remain in the
separate `GiftUIDynamicConveniences` product and lower to the same portable
contracts.

The static runtime MUST use fixed, generated, inline, or caller-supplied typed
storage. It MUST NOT depend on heap allocation, reflection, `Any`, arbitrary
existentials, Objective-C runtime facilities, task locals, tasks, threads,
exceptions, string structural paths, or dynamically growing collections.

The first adapter above the focused owners and below host policy maps local
errors into SPEC-003 facts. `GiftUIRuntimeCore` MUST NOT import
`GiftUIFailureCore` or `GiftUIFailureExecution`; a sibling owner adapter that
imports both sides performs mapping and correlation.

## Types / APIs

```swift
package enum RuntimeProfileKind: UInt8, Equatable, Sendable {
    case dynamic = 0
    case `static` = 1
}

package struct RuntimeProfileLimits: Equatable, Sendable {
    package let semantic: SemanticExpansionLimits
    package let layout: LayoutLimits
    package let render: RenderLimits
    package let renderSink: RenderSinkCapacity
    package let execution: ExecutionLimits
    package let observableState: ObservableStateLimits
    package let interaction: InteractionLimits
    package let drawing: DrawingLimits
    package let staticCanvas: StaticCanvasLimits?

    package init?(
        semantic: SemanticExpansionLimits,
        layout: LayoutLimits,
        render: RenderLimits,
        renderSink: RenderSinkCapacity,
        execution: ExecutionLimits,
        observableState: ObservableStateLimits,
        interaction: InteractionLimits,
        drawing: DrawingLimits,
        staticCanvas: StaticCanvasLimits?,
        profile: RuntimeProfileKind
    )
}

package struct RuntimeStorageAudit: Equatable, Sendable {
    package let profile: RuntimeProfileKind
    package let limits: RuntimeProfileLimits
    package let semanticBytes: UInt32
    package let layoutBytes: UInt32
    package let renderWorkspaceBytes: UInt32
    package let drawingWorkspaceBytes: UInt32
    package let observableStateBytes: UInt32
    package let interactionBytes: UInt32
    package let admissionBytes: UInt32
    package let committedRoutingBytes: UInt32
    package let totalProfileBytes: UInt32
}

package enum RuntimeProfileValidationError: UInt8, Equatable, Sendable {
    case invalidLimits = 0
    case incompatibleLimits = 1
    case missingStorage = 2
    case insufficientStorage = 3
    case arithmeticOverflow = 4
    case unsupportedStaticFacility = 5
    case callableCoverageIncomplete = 6
    case invariantViolation = 7
}

package enum RuntimeProfileValidationResult: Equatable, Sendable {
    case valid(RuntimeStorageAudit)
    case invalid(RuntimeProfileValidationError)
}

package protocol RuntimeProfileStorage: ~Copyable {
    associatedtype StructuralIdentity: Equatable & Sendable
    static var profile: RuntimeProfileKind { get }
    borrowing var limits: RuntimeProfileLimits { get }
    borrowing func audit() -> RuntimeProfileValidationResult
    mutating func resetAttemptStorage()
    mutating func resetAllStorage()
}

package protocol GiftUIRuntimeProfileCoordinator:
    ExecutionAdmissionSink, ExecutionOpportunityRunner
{
    associatedtype Storage: RuntimeProfileStorage
    borrowing var profile: RuntimeProfileKind { get }
    borrowing var storageAudit: RuntimeStorageAudit { get }
    borrowing var executionContext: ExecutionContext { get }
    mutating func quiesce()
}
```

`RuntimeProfileLimits.init` returns `nil` unless every contained value is
valid and these relations hold:

- layout scopes and render operations fit their respective semantic results;
- `interaction.maximumActions <= execution.maximumCommittedActions`;
- `interaction.maximumHitRegions <= interaction.maximumActions`;
- observable registrations and staged associations each cover observable
  locations as required by SPEC-010;
- drawing normalized strokes cover plan strokes;
- the checked sum of maximum ordinary render operations and maximum drawing
  strokes fits both render and sink operation limits; and
- `staticCanvas` is non-`nil` exactly for `.static`.

Validation compares concrete storage capacities to every contained limit and
performs checked byte summation. A missing or smaller store fails; validation
does not clamp limits or borrow unused capacity from an unrelated store.

`RuntimeStorageAudit` values are exact owned storage sizes for the selected
build. `totalProfileBytes` is their checked sum and excludes backend,
resource-package, stack, executable-image, and host-owned storage. Overflow
returns `.arithmeticOverflow`; fields never saturate.

`resetAttemptStorage` discards only incomplete cycle-local semantic, layout,
drawing, render, and candidate-routing state. It MUST NOT erase applied model
mutations, published semantic state, live observable locations, queued later
facts, committed routing state, operational health, or pending presentation
intent. `resetAllStorage` is legal only before first use or after quiescence
and teardown.

## Behavior

### Construction and validation

The host constructs exactly one profile storage and coordinator. Before the
first admission or run opportunity, the runtime validates the profile limits,
obtains one successful audit, validates exact text resources, and receives
already-resolved capability and host-policy inputs. A failed audit rejects
construction. No client body, Canvas closure, model attachment, input
callback, or backend offer occurs during validation.

The coordinator retains the immutable limits and successful audit for its
entire lifetime. Storage capacity cannot shrink after validation. Dynamic
growth beyond a configured limit is prohibited even when memory is available.

### Run-cycle coordination

Each opportunity follows this exact order:

1. enter SPEC-009 admission, seal the bounded prefix, and allocate a cycle ID;
2. apply admitted pointer, state-change, completion, and semantic-action work
   at most once in `.mutating`;
3. freeze observable mutation and enter `.deriving`;
4. expand the root through SPEC-006 into profile-owned candidate storage;
5. reconcile SPEC-010 candidate observable locations;
6. run SPEC-007 layout into profile-owned resolved storage;
7. derive the SPEC-012 Canvas plan, invoking each Canvas at most once;
8. preflight the combined SPEC-008/SPEC-012 stream;
9. build and finish the SPEC-011 interaction candidate, reserving required
   action and observable-target generations;
10. publish the complete semantic revision and resolve observable associations;
11. allocate the candidate frame and presentation revision and call the
    SPEC-009 endpoint at most once;
12. commit or discard presentation-coupled routing according to the offer;
13. apply mandatory refusal/failure effects; and
14. finalize, release every borrow, and reset attempt storage.

An earlier failure skips every later fallible stage except mandatory
containment, disposition, finalization, and wake bookkeeping. Client actions,
admitted facts, and model mutations are never replayed. Failure before
publication discards all candidate products, preserves applied state as dirty,
and schedules paced rederivation. Failure or refusal after publication never
rolls the semantic revision back.

### Storage ownership and borrowing

At most one run cycle and one attempt may be active. Workspace acquisition is
exclusive and reentry returns the focused owner's reentrancy failure. Every
borrow from semantic, layout, resource, drawing-plan, operation, action, or
observable storage ends at the boundary fixed by its owning Specification.

No profile may retain a Canvas closure after its derivation, a Path outside
its `withPath`, a drawing plan after finalization, an operation or glyph after
the synchronous offer, or an aborted interaction candidate. Refusal recovery
retains only SPEC-009 `PresentationPendingIntent`.

Candidate and committed storage are distinct. An accepted offer atomically
publishes the reserved presentation revision and candidate routing records.
Every other offer result discards the candidate records without disturbing
the prior committed set.

### Profile equivalence

Given the same portable root, exact resources, limits, initial model values,
admitted fact sequence, pointer sequence, capability result, endpoint script,
and host policy, both profiles MUST produce identical:

- local success/failure and SPEC-003 mapped outcome sequence;
- semantic identities, state preservation/removal, and model generations;
- layout summaries, bounds, clips, lines, and positioned glyphs;
- Canvas invocation count, drawing plan summary, and normalized operations;
- painter-ordered recording transcript and frame provenance;
- action generations, hit resolution, dispatch, and cancellation;
- publication, commit/abort, pending-intent, wake, and quiescence transitions.

Storage addresses, allocation strategy, concrete type layout outside specified
bounds, and diagnostic volume are not compared.

## State / Lifecycle

```text
unvalidated -> validated -> idle <-> active cycle -> quiescent -> torn down
       \-> rejected

active cycle:
admitting -> mutating -> deriving -> publishing -> offering -> finalizing
```

Only `validated` may enter `idle`. Rejected construction exposes its bounded
validation error and owns no active model registration or backend borrow.
Quiescence refuses new work as unavailable, cancels pointer captures, detaches
observable registrations during teardown, and permits `resetAllStorage` only
after no borrow or callback can remain.

## Capability Requirements

The runtime consumes one immutable SPEC-004 snapshot. It does not contribute
or resolve capabilities and does not cache concrete component identities in
portable storage. Missing `rasterPresentation` rejects startup. Runtime health
does not mutate the snapshot.

SPEC-012 drawing structural capacity and SPEC-004 semantic presentation are
independent conjunctive startup facts. This runtime validates only its owned
structural half; Wave 7 host configuration joins both.

## Backend Requirements

The coordinator is generic over one SPEC-009 `SynchronousFrameEndpoint`. It
may observe only endpoint capacity and `FrameOfferResult`. It MUST NOT inspect
concrete raster, surface, encoding, display, driver, platform, or hardware
identity and MUST NOT retain or replay the operation payload.

## Error Handling

Profile validation errors occur before a cycle and map through the owner
adapter as follows:

| Local error | condition | origin | scope | containment |
| --- | --- | --- | --- | --- |
| `invalidLimits`, `incompatibleLimits` | `.invalidValue` | `.hostComposition` | `.runtime` | `.contained` |
| `missingStorage`, `insufficientStorage` | `.capacityExhausted` | `.hostComposition` | `.runtime` | `.contained` |
| `arithmeticOverflow` | `.arithmeticOverflow` | `.foundation` | `.runtime` | `.contained` |
| `unsupportedStaticFacility`, `callableCoverageIncomplete` | `.invariantViolation` | `.hostComposition` | `.runtime` | `.safetyNotProven` |
| `invariantViolation` | `.invariantViolation` | `.hostComposition` | `.runtime` | `.safetyNotProven` |

During execution, the coordinator preserves the exact focused local error and
applies the mapping defined by its owning Specification. It does not replace a
layout, rendering, drawing, observable, interaction, execution, or backend
condition with a generic profile error.

Detection order is: limit construction, storage audit, text-resource
validation, structural workload validation, capability input, then host
policy completeness. Within a cycle it is the ordered stage sequence above.
Diagnostics remain optional projections and cannot alter any result.

## Performance Requirements

All per-attempt operations are bounded by the supplied limits. Static runtime
operations use zero heap allocations after construction and at construction.
The static build contains no forbidden runtime facility listed in Module
Contract. Dynamic conformance fixtures enforce the same logical limits and
must not use unbounded history or retry storage.

For each supported toolchain, evidence MUST report separately:

- each `RuntimeStorageAudit` field and checked total;
- maximum stack depth and bytes for construction, admission, derivation,
  Canvas invocation, rendering, offer, and finalization;
- heap allocations and peak heap bytes, with both zero for static;
- text/resource, backend, and host bytes excluded from the profile total;
- linked text, read-only data, writable data, BSS, and total image deltas; and
- cycle time for the shared small fixture and approved Signal Analyzer fixture.

The static host fixture and nRF build MUST prove no allocation entry point or
forbidden runtime symbol is linked from the runtime-profile path.

## Compatibility

This draft creates package SPI, not public ABI or serialized data. Raw profile
values are stable only within this contract. Dynamic and static profiles must
compile from the same portable application source; profile-specific imports
in Presentation are nonconforming.

Adding a third profile, asynchronous semantics, replayable frames, or a new
public selection mechanism requires normal lifecycle review. Internal storage
may change without contract change when all behavior, limits, audits, and
conformance evidence remain equivalent.

## Testing Requirements

The checked-in shared suite MUST instantiate the same fixture scripts against
both profiles with identical artificial limits. It requires:

- exact-limit and first-excess tests for every contained limit;
- startup audit missing/small/overflow/incompatible-table tests;
- semantic identity, branch replacement, state preservation/removal, and
  failed-derivation fixtures;
- layout and render golden transcripts;
- Canvas closure count, Path snapshot, plan discard, and recovery fixtures;
- action generation, hit order, model replacement, stale input, and disabled
  behavior fixtures;
- queue seal, late arrival, reentrancy, coalesced wake, refusal, backpressure,
  retry exhaustion, and quiescence fixtures;
- borrow-poisoning fixtures proving no escaped Canvas, Path, plan, operation,
  glyph, resource, action, model, or endpoint storage;
- differential transcript comparison with zero semantic tolerance; and
- dependency tests rejecting imports in both directions prohibited above.

Static-only tests MUST compile and link with Embedded Swift restrictions,
exercise generated observable and Canvas tables, prove exact callable
coverage, scan for forbidden symbols, and report zero allocation. Dynamic-only
tests MAY inspect release/deinitialization but cannot weaken common behavior.

Connected Raspberry Pi and nRF52840 evidence is not required to approve this
contract. It is required later for implemented/conformance transitions of the
assembled configurations.

## Acceptance Criteria

- [ ] Both runtime targets compile against the same portable root and focused
  contract owners without importing each other or a concrete backend.
- [ ] One successful storage audit accounts for every correctness-relevant
  profile store with checked exact totals.
- [ ] Invalid, missing, undersized, and overflowing configurations fail before
  client code or endpoint use.
- [ ] Both profiles execute the normative stage order and cleanup rules.
- [ ] The shared suite produces byte-for-byte equal semantic, layout, drawing,
  render, interaction, publication, and disposition transcripts.
- [ ] Exact-limit succeeds and first-excess fails deterministically for every
  storage family.
- [ ] Failed derivation never replays admitted effects and releases all
  candidate/attempt storage.
- [ ] Accepted handoff alone commits presentation-coupled routing; every other
  result preserves the previous committed set.
- [ ] Refusal recovery retains only constant-space presentation intent.
- [ ] Static construction and execution allocate zero heap bytes and link no
  forbidden runtime facility.
- [ ] Dynamic conveniences remain outside `GiftUI` and do not alter portable
  fixture results.
- [ ] Dependency and borrow-poisoning tests pass.
- [ ] Resource and timing evidence is reproducible under the pinned MVP
  toolchains.
- [ ] SPEC-012 is approved and this Specification has been reconciled to its
  final declarations before approval is requested.

## Implementation Notes

The existing dynamic and bounded-static proof-of-concept stores may inform
migration, but conformance should be implemented through focused owner
protocols rather than by preserving legacy graph types. A fixture driver that
records one compact tagged event stream is preferred over profile-specific
assertions.

## Open Issues

- SPEC-012 is approved; reconciliation of this draft to the approved drawing
  contract remains required before review.
- Production `RuntimeProfileLimits`, audit totals, and retry policy are owned
  by Wave 7 HOST-CONFIGURATION and are intentionally absent here.

Neither issue requires a new architectural choice in this draft.

## Deferred and Follow-up Work

No new deferred item was created. Retained rendering, fine-grained observable
tracking, replayable delivery, and additional runtime profiles remain in their
existing lifecycle or deferred tracks and are not required by this contract.

## References

- [GiftUI MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [PROPOSAL-005](../proposals/proposal-005-observable-reference-state.md)
- [PROPOSAL-006](../proposals/proposal-006-canvas-path-stroke-drawing.md)
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-008](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [RFC-009](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md)
- [RFC-010](../rfcs/rfc-010-layout-semantic-core-adapter-boundary.md)
- [RFC-011](../rfcs/rfc-011-bounded-application-actions.md)
- [ADR index](../adrs/README.md)
- [SPEC-002](spec-002-portable-foundation.md)
- [SPEC-003](spec-003-failure-outcomes-and-containment.md)
- [SPEC-006](spec-006-declarative-view-semantics.md)
- [SPEC-007](spec-007-layout.md)
- [SPEC-008](spec-008-rendering.md)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md)
- [SPEC-010](spec-010-observable-reference-state.md)
- [SPEC-011](spec-011-interaction.md)
- [SPEC-012](spec-012-canvas-path-stroke-drawing.md)
