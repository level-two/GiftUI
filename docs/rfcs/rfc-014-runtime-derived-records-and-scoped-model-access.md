---
id: RFC-014
feature: external-application-integration
title: Runtime-Derived Records and Scoped Model Access
status: approved
authors:
  - codex
created: 2026-10-09
updated: 2026-10-24
proposal:
  - PROPOSAL-007
related_rfcs:
  - RFC-013
  - RFC-012
  - RFC-008
  - RFC-009
  - RFC-010
  - RFC-011
  - RFC-015
related_adrs:
  - ADR-041
  - ADR-038
  - ADR-006
  - ADR-008
  - ADR-011
  - ADR-024
  - ADR-025
  - ADR-026
  - ADR-028
  - ADR-032
  - ADR-033
  - ADR-034
  - ADR-035
  - ADR-036
  - ADR-037
related_specs:
  - SPEC-002
  - SPEC-001
  - SPEC-006
  - SPEC-007
  - SPEC-010
  - SPEC-011
  - SPEC-012
  - SPEC-013
  - SPEC-015
related_future_work:
  - FW-009
  - FW-035
  - FW-036
related_explorations: []
related_spikes:
  - SPIKE-069
  - SPIKE-070
  - SPIKE-071
  - SPIKE-072
  - SPIKE-073
  - SPIKE-074
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# RFC-014: Runtime-Derived Records and Scoped Model Access

**2026-10-24 Native Static construction amendment:** explicit human approval is
recorded by [ADR-041](../adrs/adr-041-native-static-typed-model-backing.md). Only
Native generic owning-model construction qualification changes to caller-supplied
typed backing through the checked factory; shared operations, Embedded/Dynamic
behavior, ownership/lifetimes and strict zero-heap/resource duties remain. Prior
reasoning and evidence below are preserved; no P08 exit or unit waiver follows.

**Approved — 2026-10-10.** Finalized under Eugene's explicit conditional
review-and-close instruction after correcting all review findings. This document
describes the selected design only.
The [final review](../iterations/iteration-003-review/rfc-014-final-review.md)
records findings, corrections, evidence limits and finalization provenance.
RFC approval enables ADR extraction; it does not change accepted ADRs, approve
Specifications or authorize production migration.

## Approved P08 construction graph amendment — 2026-10-12

Eugene explicitly selected Option B and approved its required documents; the
[approval record](../iterations/iteration-003-review/rfc-014-spec-approval.md#option-b-construction-graph-amendment--2026-10-12)
also records the later instruction that implementation is a separate activity.
[ADR-038](../adrs/adr-038-construction-graph-and-operational-contracts.md) records
this additive decision under ADR-007/008.

The fixed eighteen-role host graph describes exact direct factory/construction
dependencies, including mandatory borrowed/retained inputs, backing and derived
configuration origins. Activation wiring and runtime operations are audited
separately; operation-only typed arguments and shared value vocabulary do not
automatically create construction edges. Real construction edges cannot be
hidden by callbacks, pointer indirection or physical storage placement. Fixed
ordering, cycles and lower-edge constraints still apply; a required upward
construction edge stops work for upstream resolution.

Module imports remain toward lower contracts. Runtime-owned admission may notify
through the existing typed consumer-owned wake contract, bound once by the host
to platform scheduling. SPEC-009's single canonical reason set/outstanding bit,
identity, coalescing, deadlines, non-reentry and teardown/backing duties require
separate operational proof. Option A per-producer forwarding is not selected.
No shared services, public protocol redesign, new frontend/IR, allocator,
capacity, compiler or hardware change is approved. Existing P08 feasibility and
conformance remain unproved; documentation approval is not implementation.

Possible future benefits remain only in
[FW-035](../future-work/fw-035-generated-view-graph-for-interchangeable-frontends.md)
and [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md), with
no promotion or scope expansion.

## Summary

Traverse actual portable View declarations at runtime and emit bounded semantic
records. Preserve structural identity independently of record ordinals. Keep
model storage alive and exclude mutation through graph derivation, Layout and
post-layout Canvas drawing. A separate frozen copy is not required.

Canvas becomes a `View`-refining protocol with `Body == Never` and synchronous
scoped drawing. Generated access code supplies a fixed typed read domain to each
compiled View conformance; Swift infers custom Body types. Authored body and
property syntax remain the source contract, not an unchanged compiled ABI.

Preserve three analyzer capture banks: source, admission and model. Model metadata
capacity is separate from capture capacity. Replacement refuses before commit
when resources cannot accommodate it; independently retained owners remain valid.

The final bounded investigation supports this design's representative mechanisms.
Production integration, complete source coverage and final resource/conformance
proof belong to implementation acceptance. No further investigation is queued.

## Context

[Accepted PROPOSAL-007](../proposals/proposal-007-external-application-integration.md)
and its [runtime scope amendment](../iterations/iteration-003-review/runtime-derivation-scope-amendment.md)
cover iteration-3 runtime derivation for the analyzer and finite counter on
macOS Dynamic/Static, Pi 1 ARMv6 Dynamic and nRF52840 Embedded Static. External
application delivery remains in iteration 4. This is post-MVP work; the
[MVP analyzer](../iterations/iteration-001-mvp.md) supplies regression semantics
and stack requirements, not a new MVP commitment.

The [I3-T01 baseline](../iterations/iteration-003-review/i3-t01-result.md) retains
generated production topology. Its passing checks and linked memory figures
are baseline controls, not evidence for the new representation. The known
operation-major 4 MHz display path cannot meet the 250 ms frame requirement;
this RFC changes neither transport nor the requirement.

## Scope and Decision Boundary

This RFC owns runtime record construction and exact identity, compiled View/model
access, Canvas representation, model/capture ownership, storage lifetimes and
publication/retirement. These form one decision cluster: runtime declarations
must not outlive the state or capture data they reference.

[RFC-013](rfc-013-external-application-and-backend-integration.md) independently
owns external package partition, supported external APIs, host assembly and setup.
This RFC specifies semantic dependencies, not a distributable package topology.
The finite counter may use repository composition; that is not external-consumer
compatibility evidence.

Display transport/rate, asynchronous rendering, fine-grained invalidation,
general Swift compilation and arbitrary cross-domain view composition are outside
this decision. Accepted owner responsibilities and workload limits remain intact.

## Requirements

| ID | Required outcome | Trace / acceptance |
| --- | --- | --- |
| RD-1 | Evaluate actual body/state-dependent declarations; no pre-expanded topology input. | I3-04 / IT-AC-006; source inventory and declaration/branch perturbation. |
| RD-2 | Preserve exact identity, state, action generations, layout, painter order and pixels across profiles. | SPEC-006/010/011; independent semantic/action/pixel oracles. |
| RD-3 | Preserve serialized mutation, complete semantic publication and no replay of admitted mutations. | ADR-011/024/025 and SPEC-013; failure-edge coverage. |
| RD-4 | Model/capture reads cannot escape or survive their backing; ordinary failures are typed. | Compiler controls, actual owner/teardown tests and SPEC-010/012 failure routing. |
| RD-5 | Static has finite declared storage and no heap/dynamic fallback. | ADR-026; linked image, complete stack/IRQ and capacity evidence. |
| RD-6 | Keep the three-bank capture policy, five-second horizon and required admission/workload semantics. | ADR-034 / SPEC-001; 404/405 boundary, baselines, replay/Clear and 30s workload. |
| RD-7 | Both applications use the same portable semantics on four configurations. | IT-AC-004/008; per-application limits and full source coverage. |

## Constraints

- Authored portable framework usage imports `GiftUI`; existing application Domain
  imports remain allowed. Runtime/backend/platform selection stays at the host.
- No global resolver, task-local binding, reflection, `Any` registry or application
  schema in the generic GiftUI core. Backends never resolve models or run Canvas.
- Generated schema witnesses, type-role tags, access adapters and finite source
  lowering are allowed. Expanded runtime occurrences, parent/child links or
  per-application graph tables are not production inputs.
- Existing analyzer maxima, including 126 structural identities, 98 layout/render
  scopes and 404 transitions, are not silently raised by record allocation.
- Accepted ADRs and implemented Specs remain production authority until required
  ADR decisions and Spec amendments pass their own gates. Experimental source is
  evidence, not production code to copy without review.

## Proposed Design

### Runtime records and exact identity

Semantic Core traverses the actual root using its visitor and state-binding
orchestration. Bind each stateful custom declaration before invoking its body;
evaluate each encountered body once. Runtime and Layout do not derive another
graph or retain the expanded declaration tree.

Append compact candidate occurrence records containing ordered links, kind,
exact identity reference and typed payload reference. Text, modifier and other
owned payloads use bounded side pools. A record ordinal identifies only its
own bank/revision; it is never persistent state or interaction identity.

Each bank has an exact path table. Entries encode parent, component kind,
branch/child ordinal, concrete declaration-role tag and modifier discriminator.
Tags describe finite declaration types, not generated topology. Reconcile
candidate/published path tries by complete component and endpoint equality,
using paired traversal and exact bounded child matching. Neither a hash match
nor equal table indices establishes identity. Prove the supported child-fanout
and path-prefix bounds in the implementation; an all-pairs identity scan inside
expansion is excluded.

Candidate and published banks remain disjoint. Failure discards the candidate;
complete semantic publication swaps bank roles. Reuse waits for all old-bank
borrows. Interaction copies its complete bounded committed identity keys into
its own accounted storage, so later bank reuse cannot invalidate action routing.
Layout/Render consume Semantic Core's borrowed views in semantic order, without
an alternate canonical graph or application-owned layout representation.

An explicit record/path work stack does not eliminate Swift body-return
temporaries or recursive generic visitor frames. Both remain in stack accounting.

### Typed access and inferred Body

Each compiled View conformance has one fixed read-domain type. The nonescapable
read context is a concrete generic type parameterized by that domain; no
nonescapable associated type or method-generic body context is required. The
[typed access contract](../iterations/iteration-003-review/rfc-014-typed-access-contract.md)
provides the schematic interface and real application source-route matrix.

The generic GiftUI core owns View/builder/key/read-scope and failure contracts.
An application-generated schema surface owns field types, schema-specific read
requirements, facades and pure computed getters. A host/profile bridge implements
those requirements against its storage. The generated presentation imports that
schema surface; authored presentation does not import Runtime or write target
storage offsets. Package visibility/external delivery remain RFC-013's concern.

Generated custom views and core containers carry the same domain as a type
argument, not a stored context. Their opaque body witnesses constrain the result
to that domain and let Swift infer the concrete Body. Stateless primitive values
are lifted as leaves; stateless custom components retain custom traversal. Never
remains the leaf Body, so universal `Body.Domain == Domain` is not imposed on all
Views. A broad Never default must never mask a custom body witness.

Before exposing a facade, validate owner identity, schema, occupied slot,
allocation generation and read phase. Owned scalar getters then need no repeated
owner lookup; indexed capture reads still check bounds. Nested aggregates expose
further scoped facades. A read facade returns no mutable reference, storage
descriptor, service object or owning ticket.

Borrowing a descriptor containing a pointer is not proof of its pointee lifetime.
The trusted bridge must establish backing ownership, initialization, alignment,
bounds, disjoint writes and lifetime before constructing a read view. Application
lowering must reject unchecked aliases and unsupported escaping uses; there is
no runtime fallback that bypasses this boundary.

### Mutation, State discovery and ownership

Static models use stable typed storage supplied before activation; Dynamic may
use retained objects internally but enforces equivalent configured limits and
outcomes. Keep model schema, owner-instance identity, model allocation generation
and structural registration/target generation distinct. Detaching a registration
does not invalidate an independently owned model.

A copied model key is nonowning. A live owner must already retain its backing
before validating the key; checking a generation through freed storage is invalid.
Owning tickets, frame pins and registration references have explicit bounded
lifetimes and release paths. Reclaim storage only after every relevant owner and
reader has ended. Host caches cannot hide independent ownership behind a
current-root alias or assume observer detachment destroyed a model.

Observable writes use an exclusive checked mutation route. Validate phase,
identity, capacity and fallible operation preconditions before modifying data.
Keep model data separate from registration/dirty and coordinator result storage,
so synchronous reporting does not overlap a mutable model borrow. Preserve coarse
model-owned reports, proven no-op omission and existing mutation order. Do not
add property-read dependency tracking, Combine or Apple Observation.

A fallible compound capture update needs preflight followed by non-failing commit;
a complete capture rollback copy is not an unaccounted stack solution. Service
side effects or admitted mutations are not replayed because later derivation
fails. Unsupported arbitrary `inout` callbacks or unmanaged reference writes are
rejected by the supported source/build contract.

Read scopes end between parent body evaluation and child State discovery. The
frame's ownership/mutation exclusion persists. Discovery may reserve metadata,
materialize a new inert model and stage a registration under its dedicated
authority; it may not mutate an existing frame-visible model. Newly encountered
State is bound before its body; preserved State ignores repeated initializer
seeds. This is distinct from ordinary replacement, which remains mutation-phase
only. Candidate associations publish/discard under SPEC-010's existing rules.

### Protocol Canvas and capture values

Canvas refines View with `Body == Never`; concrete authors provide a synchronous
drawing method receiving checked local bounds and a scoped GraphicsContext,
without authoring body or traversal. The compiled draw witness additionally
receives the same domain's scoped read context. Invocation occurs after Layout,
at most once per occurrence per attempt, in resolved painter order. Local bounds
have nonnegative checked dimensions; framework translation and clipping retain
their existing ownership.

Owned Canvas values stage model identity and bounded scalar/selection payloads.
They never retain a read facade or copy a full 404-record capture. Each invocation
binds a fresh scoped read to the exact selected owner/model/generation, not the
host's current-root route. Model mutation is excluded for the entire attempt's
model-reading interval; a separate historical snapshot bank is unnecessary.

Existing owned Domain `SignalCapture` values retain their independent immutable
snapshot meaning. A distinct presentation selection/read type is an explicit
migration, not a silent conversion of that value into an alias. Export of an
owned full capture needs an explicitly accounted destination and is outside
body/draw evaluation. Counter scalar values need no analyzer bank.

Drawing produces a complete bounded immutable geometry plan before frame offer.
Backend consumption does not call client drawing code. Synchronous path-building
closures may remain; the retained escaping Canvas closure is replaced by the
protocol value. State writes, suspension, action dispatch and reentrant cycles
remain forbidden during drawing. Contexts/workspace borrows do not escape.

Release every staged value on success or discard, including caller cleanup when
a producer rejects before acquiring its workspace/payloads. End model-data reads
after their last body/Canvas use; keep any still-needed registration/model ownership
until its own retirement point. Owned geometry may survive those reads through
the synchronous offer; it is not a retained replay display list.

### Three-bank replacement policy

Keep ADR-034's source/admission/model backing at **3 × 404 × 16 = 19,392 bytes**.
The selected analyzer configuration has two bounded model metadata records and
one model-capture entitlement. An installed analyzer reserves that entitlement
even while empty. Scalar counter metadata has independent small storage.

The [capacity contract](../iterations/iteration-003-review/rfc-014-capture-policy-choice.md)
defines the transaction and failure matrix. For populated installed A and inert
empty candidate B, successful replacement requires explicit transfer of A's last
owning ticket, no surviving independent A owner/reader, and all metadata,
registration and generation reservations. Candidate attachment sees B's actual
empty seed. Guard reservation through commit/discard against reentrant writes,
frame reads and ownership changes that would invalidate it.

On precommit failure, keep A's data, identity, attachment and dirty state; release
candidate-only reservations exactly once. On success, activate B, retire A's
association and release the explicitly transferred final ownership, then make
the model-bank entitlement available to B. Old bytes need not be cleared: B's
count/baselines define its empty state and generations reject stale A keys.
Later derivation/drawing failure keeps the committed B. Required detach hooks
follow existing invariant-failure rules; there is no invented postcommit rollback.

If an independently retained A prevents transfer, replacement refuses before
commit. A second populated candidate needs unavailable backing and refuses; an
empty candidate cannot bypass this check merely to fail its first normal capture
update. Metadata capacity never implies additional transition capacity. Initial
materialization may use a candidate that already owns the sole bank when no
installed analyzer requires it. Source/admission banks are never stolen, and
there is no implicit sharing, COW, fourth bank or heap fallback.

### Publication and retirement

| Phase | Access / live storage | Exit obligation |
| --- | --- | --- |
| Validate/construct | Caller backing, immutable limits, typed slots | Validate before callbacks; account partial construction and shutdown. |
| Admit/mutate | Installed model, accepted facts/actions, optional bounded replacement | Apply each admitted mutation once; synchronous reports; retain first failure. |
| Derive | Model mutation excluded; short body reads; candidate records/path/payloads; new-State binding authority | Preserve published bank/live set; end parent reads before child discovery. |
| Layout/Canvas | Borrowed candidate semantics, layout, staged Canvas and owned plan under construction | One invocation per occurrence; release payloads on success/discard. |
| Preflight/publish | Complete candidate products and interaction; prior committed routing | Preserve SPEC-013 atomic publication/order and failure classifications. |
| Offer/finalize | Owned plan/layout/render and governed routing state | Synchronous one-shot offer; no semantic rollback; drop attempt-local state. |
| Quiesce/teardown | Stop admission/producers and drain active synchronous/IRQ handoffs | Retire registrations, invalidate generations and release backing last. |

Backend refusal retains only pending presentation intent. Retry derives from
current model state; it does not retain model-reading declarations or replay
already admitted mutations. No lock is required by the selected serialized
baseline. External facts enter the existing admission owner, not frozen model data.

## Module Responsibilities

| Owner | Responsibility | Dependency impact |
| --- | --- | --- |
| GiftUI / source tooling | Portable declarations, compiled View/Canvas contracts, finite access lowering | No application schema or Runtime lookup in generic GiftUI. |
| Application schema / Presentation | Typed fields/read requirements, computed semantics, domain-parameterized compiled views | Authored framework import remains GiftUI; generated schema has no Runtime/backend dependency. |
| GiftUISemanticCore | Actual expansion, exact structural identity, borrowed semantic outputs | Runtime supplies storage; Layout consumes Semantic Core one way. |
| GiftUIObservableState | Logical State binding, registration, replacement/removal outcomes | No Interaction/application import; model data and registration remain separate. |
| RuntimeCore / profile bridge | Phase coordination, concrete slots/banks/tickets, checked access and action generations | Preserve the accepted acyclic owner graph and cross-profile outcomes. |
| Layout / Drawing / Render | Existing layout, post-layout drawing, owned geometry and operation meaning | No model resolution in Render/backend. |
| Analyzer Domain / target adapter | Independent owned capture values and separate scoped presentation access; packed decoding below portable code | No firmware offsets or runtime leases in Domain. |
| Host / target composition | Application capacities, backing lifetime, services, activation/quiescence | Counter does not acquire analyzer storage; no package extraction here. |

## Public API Impact

Keep authored `var body: some View`, model-property reads, `@State` identity and
typed actions. Replace closure-based Canvas with the protocol drawing surface.
Observable field annotations/schema generation may use @Published-like spelling;
exact names belong to the Spec and do not imply publishers or Combine semantics.
Ordinary computed properties use checked typed inputs; arbitrary mutable external
references are not made frame-stable merely by looking like a property read.

The supported build performs finite source transformation for both profiles.
The compiled contextual View witness differs from today's getter ABI. This is
not a macro-only promise, unchanged binary ABI, general Swift compiler, or claim
that the complete lowerer already exists. The current counter/analyzer
[source inventory](../../experiments/spike-072-contextual-traversal-integration/application-coverage.md)
is the required implementation corpus. New unsupported effects/escapes fail the
build deterministically rather than silently selecting an unsafe path.

## Capabilities Impact

No capability negotiation, absence behavior, default or fallback changes.
Capacity and access rejection remain focused-owner outcomes. Zero heap on the
Static target is a requirement, not an optional capability.

## Backend Impact

Preserve one-shot operation streaming, RGB565 raster/session/display owners and
transport. No asynchronous queue, framebuffer strategy, damage policy or SPI
rate change is selected. The known 4 MHz performance issue is independent
iteration work, not a reason to reopen this model-access investigation.

## Static / Embedded Impact

Static uses finite typed storage and specialized dispatch; Dynamic enforces the
same configured failure and publication behavior. Host phase checks are not a
substitute for safe backing lifetime, zero heap or target ABI verification.

The initial implementation baseline is the already tested project-local Swift
6.3.2 configuration with `LifetimeDependence` and `Lifetimes` and its internal
lifetime annotations. This dependency is explicit: generated/internal access
code may require those compiler features; authored application source does not
expose them. Implementation must pin/check the supported tools and fail clearly
when required features are unavailable. No global compiler change, newer Swift
associated-type feature or unchecked fallback is implied. Exact build integration
and all escape diagnostics are Spec/implementation acceptance work; a compiler
change that forces different public semantics returns for a decision.

**Approved configuration correction — 2026-10-12:** the initial compiler choice
above is preserved as history. The explicitly
[approved Swift 6.4 correction](../iterations/iteration-003-review/rfc-014-compiler-baseline-correction.md)
now governs migration implementation and fresh evidence, with the same public
semantics, feature settings and lifetime requirements. Its matching target tools
and validation obligations are recorded in that correction; no unchecked fallback
or new associated-type feature dependency is introduced.

## Performance

Preserve SPEC-006 linear expansion: paired path-trie traversal costs O(N × K)
with fixed bounded child fanout K, not an all-pairs O(N² × D) scan. Prove the
finite vocabulary/fanout and charge its scratch in implementation. No speedup is
inferred solely from avoiding copies. Account body temporaries, indirect calls,
specialization and identity processing as well as explicit record buffers.

Measure derivation, Layout, Canvas, preflight and offer without double-counting
nested intervals. Existing source deadlines, catch-up bounds and scratch
transitions remain. The analyzer's 30s/80-events-per-second/four-FPS requirements
and the counter's separate finite workload remain acceptance gates. This RFC
does not claim that CPU optimization solves a transport lower bound.

## Memory / Binary Size

The selected capture reservation is three banks; earlier four/five-bank totals
are rejected alternatives, not a new budget. Complete image limits continue to
come from approved SPEC-001/013/015. The old conditional 120,928-byte estimate is
not a measured image, approved limit or allocation plan and is not carried forward.

[SPIKE-074 layout evidence](../../experiments/spike-074-final-access-ownership/evidence/result.md#f3--concrete-incremental-storage)
measures the representative mechanism:

| Storage | Native arm64 bytes | ARMv6 / nRF bytes |
| --- | ---: | ---: |
| Three transition banks | 19,392 | 19,392 |
| Two analyzer descriptors | 272 | 248 |
| Owner control | 72 | 44 |
| Two model keys | 24 | 24 |
| One staged Canvas | 24 | 16 |
| Descriptor/control/key/Canvas subtotal | 392 | 332 |
| Independent counter scalar slot | 1 | 1 |

These are fixture layout observations, not production allocations. Registration,
host tickets, actual payload counts, text, paths, graph banks, read/body stack,
IRQ overlap, construction/service/teardown and alignment all still need accounting.
Do not charge a key or descriptor twice when it belongs to an existing pool;
do not count missing costs as zero. Separate application-owned retention and
metadata bounds must be explicit even though transition bytes stay fixed.

The earlier proposed 1,024-byte model/control allowance and provisional counter
limits require per-application Spec validation before implementation relies on
them. A changed physical limit needs the normal reviewed Spec amendment; exceeding
an accepted architectural bound returns for decision. Neither fixture arithmetic
nor a generated-graph baseline predicts complete-image feasibility.

Target objects contain allocator references. Final linking, rooted allocation
reachability, complete feasible-path stack bounds and matched Dynamic allocation
costs remain mandatory. Static keeps its zero-heap requirement and the applicable
RAM/flash limits. Stack high-water observations supplement, not replace, bounds.

## Alternatives

| Alternative | Benefit | Disposition / cost |
| --- | --- | --- |
| Selected runtime records, typed scoped reads and protocol Canvas | Keeps runtime topology, inferred Body, explicit lifetimes and three banks | Requires source lowering, owner integration and full implementation conformance. |
| Retain an expanded typed declaration tree through drawing | Ordinary Swift values, fewer codecs | Large aggregate/capture copies and stack costs in earlier images; not selected for this runtime representation. |
| Keep separate copied frozen model versions | Independent version lifetime | Unnecessary under serialized mutation exclusion; adds capture storage and ownership work. |
| Four banks for two populated analyzer models | Permits additional replacement/retention scenarios | Maintainer selected three-bank bounded refusal; extra capacity would need a new ADR-034 decision. |
| Explicit user-facing scoped-read APIs | Makes access arguments visible without hiding transformation | Changes the selected authoring surface; retained as earlier comparison, not this design. |
| Keep owned full captures in every declaration | Simple independent value semantics | Remains valid at explicit Domain export boundaries, but is not the scoped presentation representation. |

## Rejected Approaches

Pre-expanded production topology violates runtime derivation. Global/task-local
resolvers violate dependency/access constraints. A potentially freed pointer does
not become safe through generation checks. Callback restrictions alone do not
prevent copyable wrappers escaping. Arbitrary retained-owner revocation, hidden
bank overlays and capacity fallback violate the chosen ownership/resource policy.
Manual frontend reconstruction of every Body type is unnecessary for the tested
fixed-domain design. Making all custom views Never leaves to bypass inference is
incorrect dispatch and is excluded.

## Compatibility

Preserve ADR-006/008/011/024/025/026/032/033 ownership and behavior; this RFC does
not supersede them. Preserve ADR-034's three banks and capture semantics. Extract
an explicit Canvas representation decision against ADR-028's closure wording
while preserving its timing, local context, occurrence order and plan lifetime.

| Contract family | Required downstream work |
| --- | --- |
| SPEC-006 / SPEC-007 | Contextual View/traversal declarations and runtime-owned record/identity inputs while preserving semantic/layout ownership. |
| SPEC-010 / SPEC-011 | Checked schema binding, model ownership/generations, bounded replacement and failure routing; preserve state/action semantics. |
| SPEC-012 / ADR-028 | Replace retained Canvas closure realization with protocol values and scoped draw witnesses; preserve the existing drawing lifecycle. |
| SPEC-001 | Explicit analyzer presentation-capture type migration and complete source/action/capture behavior. |
| SPEC-013 / SPEC-015 | Exact profile storage, capacities, offsets, lifetimes, costs and configuration/conformance evidence. |

Retain the generated production path until replacement gates pass. Generated
fonts, type roles and finite access code may remain; graph output may not. No
external ABI stability or outside-package eligibility is established here.
Application-specific target files/offsets stay below portable declarations.

## Testing Strategy

The [terminal SPIKE-074 result](../../experiments/spike-074-final-access-ownership/evidence/result.md)
supports six separate compiled module boundaries on four configurations, 47 checks
in each native selection, eight intended escape/exclusivity rejections and target
layout/ABI observations. It used 48/48 invocations and one case-order repair.
The native selections use the same bounded bridge, not actual runtime-profile
integration; target objects were not linked/executed. Hand-written lowered forms
are not proof of the source transformer or complete application coverage.

Implementation acceptance must cover:

- Actual declaration/branch perturbations, exact identity and modifier order,
  first-excess capacities, state preservation and published-bank reuse.
- All supported counter/analyzer source routes, helper/short-circuit order,
  typed failure transport, computed/nested reads and compound write preflight.
- Actual owner tickets and pointer lifetimes, nested State discovery, initializer
  behavior, replacement success/refusal, attach/detach/report errors, generation
  exhaustion/reuse, removal/reinsertion and stale action routing on both profiles.
- Zero/multiple Canvas occurrences, exact model selection, postcommit failure,
  source/admission isolation, early draw rejection and every cleanup/teardown path.
- Complete linked resource/allocation/stack proof and independent semantic/action/
  pixel comparisons on the four configurations. Connected workload evidence
  requires its existing explicit hardware authorization.

## Risks

Source lowering is substantial engineering work and may expose unsupported source
forms. Compiler features and specialization may change code size or escape
behavior. Exact path/payload counts or indirect/recursive stack costs may exceed
provisional estimates. Real host callbacks may retain owners absent from the
fixture. Implementation must expose these as failed acceptance cases with exact
causes; it must not change the contract silently or automatically open new research.

## Open Questions

No architectural choice remains open after final review. Exact API spelling,
source-lowering mechanics, layouts and error-code mappings are Specification
work within the decisions above. Actual production feasibility remains unproved
and cannot be labeled implemented/conformant until acceptance passes.

| Former question | Resolution | Remaining owner |
| --- | --- | --- |
| B0, capture capacity | Three-bank bounded refusal selected; representative transaction validated. | IH-3 actual ownership integration, IH-6 complete costs. |
| B1, typed access / Body | Fixed schema domains and scoped facades; representative compiled inference/module boundary validated. | IH-1 exact contracts/compiler integration, IH-2/3 production enforcement. |
| B2, complete storage | Bounded separate pools and ownership model selected; representative layouts measured. | IH-3/4 exact realization, IH-6 total accounting. |
| B3, full image / Dynamic cost | Remains required implementation acceptance, not a further architecture experiment. | IH-6 linked/stack/allocation/performance evidence. |
| B4, full source / migration | Finite source transformation selected; representative forms validated and inventory fixed. | IH-2/4/5 full lowering, migration and conformance. |

The separate 4 MHz iteration performance issue remains unresolved outside this
RFC's scope; no display or requirement decision is made here.

## Deferred and Follow-up Work

[FW-036](../future-work/fw-036-swift-compiler-upgrade-assessment.md) records the
compiler compatibility assessment scheduled for ITERATION-004 I4-05. This
follow-up changes no current compiler contract or P07 acceptance obligation.

The [implementation handoff](../iterations/iteration-003-review/rfc-014-implementation-handoff.md)
contains IH-1–6 prerequisites and acceptance evidence. ADR-035/036/037 are extracted
and accepted; approve affected Specs and derive ready
implementation plans. Full source migration, production integration, conformance
and image measurements belong there. No new Future Work item hides a current
requirement.

SPIKE-069–074 are terminal evidence. Their budgets are closed; no successor is
queued. Earlier copy-freeze/current-version ledgers and expanded-Body experiments
remain historical records, not competing current requirements. RFC-013 and
iteration 4 retain external delivery work, triggered by stabilized runtime
contracts. General future frontends remain outside this finite application scope.

## Decision Summary

These decisions were extracted and explicitly accepted by Eugene on 2026-10-10;
see the [acceptance record](../iterations/iteration-003-review/rfc-014-adr-acceptance.md):

1. [ADR-035 (accepted)](../adrs/adr-035-runtime-derived-records-and-exact-identity.md):
   Runtime-emitted bounded semantic records, exact cross-revision identity and
   publication/retirement, preserving Semantic Core/Layout/Interaction ownership.
2. [ADR-036 (accepted)](../adrs/adr-036-scoped-model-access-and-bounded-ownership.md):
   Fixed-domain scoped model/property access, stable owned storage, finite source
   transformation and checked mutation, preserving State/invalidation semantics.
3. [ADR-037 (accepted)](../adrs/adr-037-protocol-canvas-and-scoped-post-layout-drawing.md):
   Protocol Canvas values with Body == Never and scoped post-layout invocation,
   replacing ADR-028's retained-closure realization while preserving its lifecycle.

4. [ADR-038 (accepted, 2026-10-12)](../adrs/adr-038-construction-graph-and-operational-contracts.md):
   Exact host construction graph and separately validated typed operational
   contracts, additive to ADR-007/008 under the Option B approval above.

The selected three-bank capacity/refusal policy is part of the ownership decision;
it does not require an ADR-034 storage amendment. Exact declarations and resource
limits follow in the affected Specifications. RFC finalization alone accepts no
new ADR, changes no production code and closes no implementation acceptance gate.

## References

- [Coordinated draft Specification amendments and review](../iterations/iteration-003-review/rfc-014-spec-amendment-review.md).

- [Final review and finalization record](../iterations/iteration-003-review/rfc-014-final-review.md).
- [Current iteration plan](../iterations/iteration-003-review/memory-efficiency-plan.md)
  and [approved iteration-3 scope](../iterations/iteration-003-dev-ux-improvement.md).
- [Typed access contract](../iterations/iteration-003-review/rfc-014-typed-access-contract.md),
  [three-bank ownership contract](../iterations/iteration-003-review/rfc-014-capture-policy-choice.md),
  [ownership audit](../iterations/iteration-003-review/rfc-014-ownership-audit.md).
- [SPIKE-074](../spikes/spike-074-final-access-ownership.md) and its
  [terminal result](../../experiments/spike-074-final-access-ownership/evidence/result.md).
- Historical [SPIKE-069](../spikes/spike-069-scoped-model-access.md),
  [SPIKE-070](../spikes/spike-070-protocol-canvas-versioned-access.md),
  [SPIKE-071](../spikes/spike-071-canvas-embedded-escape-continuation.md),
  [SPIKE-072](../spikes/spike-072-contextual-traversal-integration.md),
  [SPIKE-073](../spikes/spike-073-fixed-context-body-inference.md): evidence applies
  only to each exact candidate, not to the full final implementation.
- Historical [source comparison](../iterations/iteration-003-review/rfc-014-source-design-options.md),
  [working direction](../iterations/iteration-003-review/rfc-014-decision-direction.md),
  [copy-freeze contract](../iterations/iteration-003-review/rfc-014-c-contract.md),
  [storage ledger](../iterations/iteration-003-review/rfc-014-c-storage-ledger.md) and
  [contextual design](../iterations/iteration-003-review/rfc-014-contextual-evaluation.md).
  The prior accumulated RFC text is preserved in Git at `e2839fb3`; this final
  document supersedes conflicting recommendations in those supporting drafts.

The separately reviewable [draft RFC-015](rfc-015-p08-scoped-storage-ownership.md)
proposes a focused P08 geometry/Interaction storage ownership amendment. It is
non-authoritative and does not change this approved RFC, its accepted ADRs or
approved Specs. Current syntax, physical-slot and validation/adoption blockers
remain explicit there; no historical experiment budget is reopened.
