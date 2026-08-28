---
id: SPEC-013
feature: giftui-mvp-architecture
title: Dynamic and Static Runtime Profile Contract
status: review
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
  - SPEC-004
  - SPEC-005
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
  - SPIKE-007
  - SPIKE-008
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

The contract makes every correctness-relevant store finite at its configured
limit in both profiles, validates concrete storage before the first cycle,
gives each attempt exclusive profile-owned workspaces, and defines one shared
recording conformance suite. It is reconciled with SPEC-012's generated Canvas
callable and inline-capture contract and with the coordinated SPEC-009 through
SPEC-011 review amendments. It does not select a backend, target host,
production capacity values, or retry policy.

## Scope

This Specification covers:

- dynamic and static runtime-profile identity and selection;
- profile-owned live, candidate, queue, workspace, and committed storage;
- coordination of SPEC-006 through SPEC-012 in the SPEC-009 run cycle;
- dynamic and static realization of SPEC-010 observable state and SPEC-011
  interaction records;
- dynamic Canvas closure storage, static generated callable-ID and inline-
  capture storage, transient Path storage, and cycle-local plan storage
  required by SPEC-012;
- startup validation of the profile's declared structural capacities;
- exclusive workspace lifetime, reset, and failure cleanup;
- preservation and correlation of every focused owner result through the
  SPEC-009 generic failure-carrier boundary;
- profile-neutral result transcripts and cross-profile conformance; and
- static-profile source-generation, allocation, language-runtime, ABI, and
  resource evidence.

It applies to dynamic macOS, static macOS, dynamic Raspberry Pi/Linux, and
static nRF52840 configurations. Connected-target assembly is downstream.

## Goals

- Preserve one portable Presentation source and one set of observable
  semantics across both profiles.
- Make every static correctness resource finite and inspectable before use.
- Prevent dynamic conveniences from becoming common semantic requirements.
- Compose approved focused contracts without duplicating their algorithms or
  vocabularies.
- Account separately for live, candidate, queued, attempt, routing, and
  generated-Canvas storage so no profile total hides overlapping lifetimes.
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
- Selecting application fact types, action domain, handler, root target,
  surface, endpoint, wake adapter, failure policy, or retry limit for a
  production host.
- Requiring retained frames, retained Canvas plans, replay, tasks, threads, or
  asynchronous semantic evaluation.
- Treating current proof-of-concept runtime types as authority.

## Dependencies

The governing Proposals are accepted, the related RFCs are approved, and all
listed ADRs are accepted. SPEC-002 through SPEC-008 and SPEC-012 are approved.
SPEC-009 through SPEC-011 contain coordinated contract clarifications and are
in `review`; this Specification cannot be approved until those amendments
receive renewed human approval. SPEC-014 remains a downstream draft and
supplies no authority here.

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

**Published storage**
: The semantic and observable-location state owned by the latest complete
  semantic revision. Layout, drawing-plan, and render work remain attempt-
  local; presentation-coupled geometry becomes committed routing only after
  acceptance.

**Committed routing storage**
: The hit regions, bound actions, generations, and presentation provenance
  made eligible only by an accepted frame.

**Storage audit**
: A deterministic startup report proving that every required store exists and
  meets the declared limits without exercising client code.

**Canvas callable storage**
: A bounded dynamic closure wrapper or static generated callable ID plus
  inline capture retained from semantic staging until that occurrence's
  post-layout invocation. Generated switch code is not part of this storage.

**Runtime owner failure**
: The exact finite sum of focused Semantic, Layout, Observable State,
  Interaction, and Drawing errors carried through SPEC-009 without generic
  translation.

## Public Contract

This Specification adds no public declaration to `GiftUI`.

Portable Presentation MUST compile with only `import GiftUI`, MUST use the
same source for dynamic and static profiles, and MUST NOT name, query, switch
over, or condition behavior on a runtime profile. Profile choice is made by
the target dependency graph and host composition before construction.

Static source generation is a build operation, not a second portable source
surface. Generated callable IDs, captures, observable slots, and action
specialization MUST remain absent from portable Presentation source and public
runtime selection.

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

For Canvas, the dynamic runtime MAY retain a bounded closure wrapper until
SPEC-012 invocation. The static runtime MUST stage only a nonzero generated
`UInt16` callable ID and fixed-layout inline capture, dispatch through one
complete `StaticCanvasCallableTable`, destroy each capture immediately after
invocation, and reject unsupported or over-limit capture source at build time.
It MUST NOT retain the source closure or use a heap-backed fallback box.

The first adapter above the focused owners and below host policy maps local
errors into SPEC-003 facts. `GiftUIRuntimeCore` MUST NOT import
`GiftUIFailureCore` or `GiftUIFailureExecution`; a sibling owner adapter that
imports both sides performs mapping and correlation.

The adapter MUST preserve `RuntimeOwnerFailure` until mapping and make the
correlated failure available to total host policy independently of diagnostic
selection or delivery. Runtime profile code MUST NOT replace a focused error
with a generic profile error after construction.

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
    package let maximumOrdinaryRenderOperations: UInt16
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
        maximumOrdinaryRenderOperations: UInt16,
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
    package let semanticCandidateBytes: UInt32
    package let semanticPublishedBytes: UInt32
    package let layoutCandidateBytes: UInt32
    package let renderWorkspaceBytes: UInt32
    package let canvasCallableBytes: UInt32
    package let pathWorkspaceBytes: UInt32
    package let drawingPlanBytes: UInt32
    package let observableLiveBytes: UInt32
    package let observableCandidateBytes: UInt32
    package let interactionCandidateBytes: UInt32
    package let interactionCommittedBytes: UInt32
    package let admissionQueueBytes: UInt32
    package let sealedBatchBytes: UInt32
    package let pointerStateBytes: UInt32
    package let coordinatorStateBytes: UInt32
    package let failureStateBytes: UInt32
    package let totalProfileBytes: UInt32
}

package enum RuntimeProfileValidationError: UInt8, Equatable, Sendable {
    case invalidLimits = 0
    case incompatibleLimits = 1
    case missingStorage = 2
    case insufficientStorage = 3
    case arithmeticOverflow = 4
    case staticCanvasTableInvalid = 5
    case invariantViolation = 6
}

package enum RuntimeProfileValidationResult: Equatable, Sendable {
    case valid(RuntimeStorageAudit)
    case invalid(RuntimeProfileValidationError)
}

package enum RuntimeOwnerFailure: Equatable, Sendable {
    case semantic(SemanticExpansionError)
    case layout(LayoutError)
    case observableState(ObservableStateError)
    case interaction(InteractionError)
    case drawing(DrawingProductionError)
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
where OwnerFailure == RuntimeOwnerFailure
{
    associatedtype Storage: RuntimeProfileStorage
    associatedtype Endpoint: SynchronousFrameEndpoint
        where Endpoint.Sink: DrawingOperationSink
    associatedtype Handler: GiftUIActionHandler
    associatedtype TargetAccess: ActionModelTargetAccess
        where TargetAccess.Model == Handler.Model
    borrowing var profile: RuntimeProfileKind { get }
    borrowing var storageAudit: RuntimeStorageAudit { get }
    borrowing var executionContext: ExecutionContext { get }
    borrowing var isQuiescent: Bool { get }
    mutating func quiesce()
}
```

`RuntimeProfileLimits.init` returns `nil` unless every contained value is
valid and these relations hold:

- `semantic.maximumActionOccurrences <= interaction.maximumActions`;
- `interaction.maximumActions <= execution.maximumCommittedActions`;
- `interaction.maximumHitRegions <= interaction.maximumActions`;
- `execution.maximumSemanticActions <= execution.maximumInputEvents`;
- `layout.maximumPositionedGlyphs <= render.maximumPositionedGlyphs` and
  `layout.maximumPositionedGlyphs <= renderSink.maximumPositionedGlyphs`;
- `drawing.maximumCanvasOccurrences <= semantic.maximumSemanticNodes` and
  `drawing.maximumCanvasOccurrences <= layout.maximumScopes`;
- `maximumOrdinaryRenderOperations` fits both render and sink operation limits;
- the checked sum of `maximumOrdinaryRenderOperations` and
  `drawing.maximumNormalizedStrokeOperations` fits both render and sink
  operation limits;
- the contained Observable State and Drawing limits already enforce their
  registration/location, association/location, and stroke/plan relations; and
- `staticCanvas` is non-`nil` exactly for `.static`.

`maximumOrdinaryRenderOperations` is the configured upper bound for SPEC-008
fill and nonempty glyph-group operations and excludes SPEC-012 straight-line
strokes. Wave 7 derives production values from the approved workload; a zero
value is valid only for a drawing-only fixture.

Validation compares concrete storage capacities to every contained limit and
performs checked byte summation. A missing or smaller store fails; validation
does not clamp limits or borrow unused capacity from an unrelated store.

Every audit field is the exact exclusive byte extent owned by that family.
Fields MUST NOT overlap or count a byte twice. If non-simultaneous families
share an overlay, the complete extent is charged to its owning lifetime and
the other field is zero; evidence names that ownership. `canvasCallableBytes`
includes wrappers or IDs/captures but excludes generated code.
`coordinatorStateBytes` includes identities, wake state, mutation-result slot,
pending presentation intent, phase, and quiescence. `failureStateBytes`
includes exact focused and correlated correctness state, never diagnostics.

`totalProfileBytes` is the checked sum of every preceding byte field and
excludes backend, text resources, capabilities, host policy/adapters, stack,
executable image, and generated code. Dynamic allocator bookkeeping is
reported separately. Overflow returns `.arithmeticOverflow`; fields never
saturate.

For `.static`, `audit()` validates the Canvas table without client invocation:
case count is nonzero and within `StaticCanvasLimits`, IDs
`1...callableCaseCount` are covered exactly once, and each exact capture size
is present and within its limit. Startup mismatch is
`.staticCanvasTableInvalid`. During staging, zero/out-of-range IDs or a capture
size that disagrees with its generated case return
`.drawing(.invariantViolation)` through `RuntimeOwnerFailure` before body or
Canvas invocation. Unsupported capture source is a SPEC-012 build error and
has no runtime fallback.

`resetAttemptStorage` discards only incomplete cycle-local semantic, layout,
drawing, render, and candidate-routing state. It MUST NOT erase applied model
mutations, published semantic state, live observable locations, queued later
facts, committed routing state, operational health, or pending presentation
intent. `resetAllStorage` is legal only before first use or after quiescence
and teardown.

`quiesce()` is synchronous, non-suspending, and idempotent. Idle quiescence
refuses later admission, cancels pointer sources, detaches observable
registrations, releases queued and committed routing state, and sets
`isQuiescent`. During a cycle it first refuses new admission; the active cycle
performs only mandatory containment/finalization and then the same teardown.
It MUST NOT start another cycle, offer a frame, invoke a handler, or call a
diagnostic sink merely to quiesce.

## Behavior

### Construction and validation

The host constructs exactly one profile storage and coordinator. Before first
admission or opportunity, profile validation performs these checks in order
and stops at the first failure:

1. every focused limit value was constructed successfully;
2. every `RuntimeProfileLimits` cross-relation holds;
3. every required storage family exists and reports concrete capacity;
4. each capacity covers its configured limit;
5. every audit field and exact checked total are representable; and
6. for `.static`, generated Canvas table, ID, capture-size, and coverage
   metadata are complete.

The later host-configuration gate validates exact text resources, the complete
SPEC-012 B2 workload declaration, the resolved SPEC-004
`rasterPresentation`, immutable action/target assembly, endpoint
compatibility, total retry/pacing policy, and target-required facilities. A
profile audit neither repeats nor substitutes for those facts.

A failed check rejects construction. No client body, Canvas closure, model
attachment, input or wake callback, policy hook, or backend offer occurs
during profile validation. Unsupported static Canvas capture is rejected at
build time before this sequence.

The coordinator retains the immutable limits and successful audit for its
entire lifetime. Storage capacity cannot shrink after validation. Dynamic
growth beyond a configured limit is prohibited even when memory is available.

### Run-cycle coordination

Each opportunity follows this exact order:

1. enter SPEC-009 admission, seal the bounded prefix, and allocate a cycle ID;
2. apply admitted pointer, state-change, completion, and semantic-action work
   at most once in `.mutating`;
3. freeze observable mutation and enter `.deriving`;
4. call SPEC-010 `beginCandidate`, then expand through SPEC-006's state-aware
   traversal, performing each `encounter` before its owning body;
5. run SPEC-007 layout by borrowing the complete successful Semantic Core
   layout view into profile-owned resolved storage;
6. derive the SPEC-012 plan in painter order, releasing each dynamic closure or
   static inline capture exactly once immediately after invocation and before
   publication;
7. preflight the combined SPEC-008/SPEC-012 stream against the immutable plan,
   ordinary-operation bound, render limits, and sink-capacity lower bound;
8. build and finish the SPEC-011 Interaction candidate, obtaining the exact
   SPEC-010 `publishableTargetGeneration` after encounter, appending in
   semantic order, and reserving required SPEC-009 action generations;
9. for a changed complete candidate, atomically publish semantics and call
   SPEC-010 `finishCandidate(.publish)`; for unchanged presentation recovery,
   prove no observable association changed, discard the observable candidate,
   and reuse the latest semantic revision;
10. allocate the candidate frame and presentation revision and call the
    SPEC-009 endpoint at most once;
11. stream through `CanvasRenderProducer.produce` to the endpoint's
    `DrawingOperationSink`, then commit or discard routing according to offer;
12. apply mandatory refusal/failure effects; and
13. finalize, release every borrow, clear focused-failure storage, and reset
    attempt storage.

An earlier failure skips every later fallible stage except mandatory
containment, disposition, finalization, and wake bookkeeping. Client actions,
admitted facts, and model mutations are never replayed. Failure before
publication discards all candidate products, preserves applied state as dirty,
and schedules paced rederivation. A begun Observable State candidate finishes
with `.discard`; a begun Interaction candidate resolves `.discard`; every
Canvas callable/capture is released; and each acquired plan/layout/render
workspace resets once. Failure or refusal after publication never rolls the
semantic revision back.

### Storage ownership and borrowing

At most one run cycle and one attempt may be active. Workspace acquisition is
exclusive and reentry returns the focused owner's reentrancy failure. Every
borrow from semantic, layout, resource, drawing-plan, operation, action, or
observable storage ends at the boundary fixed by its owning Specification.

No profile may retain a dynamic Canvas closure or static inline capture after
that occurrence's invocation, a Path outside `withPath`, a drawing plan after
finalization, an operation/glyph after synchronous offer, or an aborted
Interaction candidate. Generated callable code/data may remain read-only but
retains no occurrence capture. Refusal recovery retains only SPEC-009
`PresentationPendingIntent`.

Candidate and committed storage are distinct. An accepted offer atomically
publishes the reserved presentation revision and candidate routing records.
Every other offer result discards the candidate records without disturbing
the prior committed set.

### Profile equivalence

Given the same portable root, exact resources, limits, initial model values,
admitted fact sequence, pointer sequence, capability result, endpoint script,
and host policy, both profiles MUST produce identical:

- exact `RuntimeOwnerFailure`, correlated SPEC-003 fact, mandatory
  disposition, residual-policy input, and returned cycle-result sequence;
- semantic identities, state preservation/removal, and model generations;
- layout summaries, bounds, clips, lines, and positioned glyphs;
- Canvas symbolic callable token, invocation/release count, plan summary, and
  normalized operations;
- painter-ordered recording transcript and frame provenance;
- action generations, hit resolution, dispatch, and cancellation;
- publication, commit/abort, pending-intent, wake, and quiescence transitions.

Storage addresses, allocation strategy, concrete type layout outside specified
bounds, profile-private capture bytes, generated-code addresses, and
diagnostic volume are not compared.

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

The coordinator is generic over one SPEC-009 `SynchronousFrameEndpoint` whose
sink conforms to SPEC-012 `DrawingOperationSink`. It may observe only sink
capacity during the body call and the returned `FrameOfferResult`. It MUST NOT
inspect concrete raster, surface, encoding, display, driver, platform, or
hardware identity and MUST NOT retain or replay the operation payload.

## Error Handling

Profile validation errors occur before a cycle and map through the owner
adapter as follows:

| Local error | condition | origin | scope | containment |
| --- | --- | --- | --- | --- |
| `invalidLimits`, `incompatibleLimits` | `.invalidValue` | `.hostComposition` | `.runtime` | `.contained` |
| `missingStorage`, `insufficientStorage` | `.capacityExhausted` | `.hostComposition` | `.runtime` | `.contained` |
| `arithmeticOverflow` | `.arithmeticOverflow` | `.foundation` | `.runtime` | `.contained` |
| `staticCanvasTableInvalid` | `.invariantViolation` | `.hostComposition` | `.runtime` | `.safetyNotProven` |
| `invariantViolation` | `.invariantViolation` | `.hostComposition` | `.runtime` | `.safetyNotProven` |

During execution, the coordinator wraps Semantic, Layout, Observable State,
Interaction, or Drawing errors in the exact `RuntimeOwnerFailure` case and
returns `.focusedOwner` through SPEC-009. Execution, rendering, and endpoint
failures retain their SPEC-009 cases. The owning adapter maps the exact value;
no profile-generic failure or diagnostic side channel is permitted.

Profile detection order is the six-step construction sequence. Host
composition then checks text resources, structural workload, capability,
action/target assembly, endpoint compatibility, and total policy. Within a
cycle, focused owners retain their internal precedence; between owners, the
first failure in stage order wins. Later cleanup failure is secondary and may
widen containment only when its owner requires it. Diagnostics remain optional
and cannot alter any result.

| Detecting stage | Required cleanup before finalization |
| --- | --- |
| observable binding or semantic expansion | discard Semantic candidate; `finishCandidate(.discard)`; release staged Canvas values without invocation |
| layout | reset Layout candidate and discard preceding Semantic/Observable candidates |
| Canvas invocation or plan | release active callable/capture; discard/reset plan, Layout, Semantic, and Observable candidates |
| combined render preflight | reset render workspace; discard/reset plan and preceding candidates |
| Interaction build/generation | `resolveCandidate(.discard)`; discard/reset preceding candidates/workspaces |
| offer production/endpoint failure | preserve published semantics; abort and discard Interaction candidate; reset plan/render/attempt storage |
| accepted offer | commit Interaction under the reserved presentation revision, then reset attempt storage |

No cleanup row authorizes a second body, handler call, Canvas invocation,
endpoint offer, or focused-error mapping.

## Performance Requirements

All per-attempt operations are bounded by the supplied limits. Static runtime
construction and every later operation use zero heap allocations.
The static build contains no forbidden runtime facility listed in Module
Contract. Dynamic conformance fixtures enforce the same logical limits and
must not use unbounded history or retry storage.

`RuntimeOwnerFailure` MUST occupy no more than 2 bytes on every supported
compiler and therefore satisfies SPEC-009's `OwnerFailure` ceiling. It contains
no reference, existential, closure, string, or diagnostic payload.

For each supported toolchain, evidence MUST report separately:

- each `RuntimeStorageAudit` field and checked total;
- maximum stack depth and bytes for construction, admission, derivation,
  Canvas invocation, rendering, offer, and finalization;
- heap allocations and peak heap bytes, with both zero for static;
- dynamic allocator bookkeeping separately from profile-owned bytes;
- text/resource, capability, backend, and host bytes excluded from the total;
- generated Canvas code size and greatest inline capture size separately from
  `canvasCallableBytes`;
- linked text, read-only data, writable data, BSS, and total image deltas; and
- cycle time for the shared small fixture and approved Signal Analyzer fixture.

The static host fixture and nRF build MUST prove no allocation entry point,
`any Error`, reflection, Objective-C, task, thread, exception runtime,
arbitrary existential registry, or closure-box symbol is linked from the
runtime-profile path. nRF evidence verifies Cortex-M4F hard-float attributes;
Raspberry Pi evidence verifies `armv6-unknown-linux-gnueabihf` rather than
ARMv7 or AArch64.

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
- Canvas dynamic-closure/static-ID staging, inline captures, invocation/release,
  typed-throws cleanup, Path snapshot, plan discard, and recovery fixtures;
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

The repository MUST provide `scripts/contracts/run-spec-013.sh` with these
exact evidence modes:

```text
scripts/contracts/run-spec-013.sh --profile macos-dynamic
scripts/contracts/run-spec-013.sh --profile macos-static
scripts/contracts/run-spec-013.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-013.sh --profile nrf52840-embedded
```

Each report records repository revision/dirty state, compiler/SDK/target,
complete command, limits, audit, high-water counts, stack, allocation, section
sizes, timing, transcript digest, and pass/fail per fixture. Cross-build and
ELF inspection are hardware-free and MUST NOT be described as connected-board
execution.

Connected Raspberry Pi and nRF52840 evidence is not required to approve this
contract. It is required later for implemented/conformance transitions of the
assembled configurations.

## Acceptance Criteria

- [ ] **RP-001:** Both runtime targets compile against the same portable root and focused
  contract owners without importing each other or a concrete backend.
- [ ] **RP-002:** One successful storage audit accounts for every correctness-relevant
  profile store with checked exact totals.
- [ ] **RP-003:** Invalid, missing, undersized, overflowing, incompatible
  configurations and invalid static callable tables fail before client code or
  endpoint use.
- [ ] **RP-004:** Both profiles execute the stage order, bind state before body,
  release Canvas callable/capture before publication, and perform the exact
  cleanup row for every injected failure.
- [ ] **RP-005:** Shared fixtures produce value-for-value equal semantic,
  layout, drawing, render, interaction, publication, focused-failure, and
  disposition transcripts without comparing pointers or private bytes.
- [ ] **RP-006:** Exact-limit succeeds and first-excess fails deterministically for every
  storage family.
- [ ] **RP-007:** Failed derivation never replays admitted effects and releases all
  candidate/attempt storage.
- [ ] **RP-008:** Accepted handoff alone commits presentation-coupled routing; every other
  result preserves the previous committed set.
- [ ] **RP-009:** Refusal recovery retains only constant-space presentation intent.
- [ ] **RP-010:** Static generation rejects unsupported captures, stages only
  complete nonzero IDs/inline records, invokes one complete table, destroys
  each record, allocates zero heap bytes, and links no forbidden facility.
- [ ] **RP-011:** Dynamic conveniences remain outside `GiftUI` and do not alter portable
  fixture results.
- [ ] **RP-012:** Dependency, typed-source negative, borrow-poisoning, and
  generated-table coverage tests pass.
- [ ] **RP-013:** Resource and timing evidence is reproducible under the pinned MVP
  toolchains.
- [ ] **RP-014:** Initial materialization and replacement bind Interaction to
  SPEC-010's exact publishable candidate generation before publication; discard
  retires candidate-only generations and preserves committed state.
- [ ] **RP-015:** Every focused owner error returns through SPEC-009's generic
  carrier with exact value/context, mapping, cleanup, and equal cross-profile
  transcript.

## Implementation Notes

The existing dynamic and bounded-static proof-of-concept stores may inform
migration, but conformance should be implemented through focused owner
protocols rather than by preserving legacy graph types. A fixture driver that
records one compact tagged event stream is preferred over profile-specific
assertions.

## Open Issues

No unresolved contract or architectural issue remains in this review draft.
Renewed human approval of the coordinated SPEC-009, SPEC-010, and SPEC-011
amendments is a lifecycle gate, not an omitted decision. Production limits,
audit totals, fact/action types, and retry policy remain intentionally owned by
Wave 7 HOST-CONFIGURATION.

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
- [SPEC-001](spec-001-signal-analyzer-reference-application.md)
- [SPEC-002](spec-002-portable-foundation.md)
- [SPEC-003](spec-003-failure-outcomes-and-containment.md)
- [SPEC-004](spec-004-capability-contribution-and-resolution.md)
- [SPEC-005](spec-005-text-resources.md)
- [SPEC-006](spec-006-declarative-view-semantics.md)
- [SPEC-007](spec-007-layout.md)
- [SPEC-008](spec-008-rendering.md)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md)
- [SPEC-010](spec-010-observable-reference-state.md)
- [SPEC-011](spec-011-interaction.md)
- [SPEC-012](spec-012-canvas-path-stroke-drawing.md)
- [SPEC-014](spec-014-backend-integration.md) — downstream review input only
- [SPIKE-003](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
- [SPIKE-004](../spikes/spike-004-canvas-path-plan-feasibility.md)
- [SPIKE-007](../spikes/spike-007-static-action-storage-feasibility.md)
- [SPIKE-008](../spikes/spike-008-spec-012-exact-canvas-declarations.md)
