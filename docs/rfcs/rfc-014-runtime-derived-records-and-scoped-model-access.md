---
id: RFC-014
feature: external-application-integration
title: Runtime-Derived Records and Scoped Model Access
status: draft
authors:
  - codex
created: 2026-10-09
updated: 2026-10-10
proposal:
  - PROPOSAL-007
related_rfcs:
  - RFC-013
  - RFC-012
  - RFC-008
  - RFC-009
  - RFC-010
  - RFC-011
related_adrs:
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
related_specs:
  - SPEC-001
  - SPEC-006
  - SPEC-007
  - SPEC-010
  - SPEC-011
  - SPEC-012
  - SPEC-013
  - SPEC-015
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-069
  - SPIKE-070
  - SPIKE-071
  - SPIKE-072
  - SPIKE-073
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# RFC-014: Runtime-Derived Records and Scoped Model Access

**Draft recommendation; not ready for approval or production adoption.**
This is the design output of [I3-T02](../iterations/iteration-003-review/memory-efficiency-plan.md#i3-t02--runtime-derivation-design-package),
using maintained baseline `710fbd24`. It records a concrete proposed realization
and its unresolved proofs. It does not claim a new measured feasible candidate.
The earlier NO-GO and stopped experiment budgets remain intact.
[The design review and conditional adoption sequence](../iterations/iteration-003-review/i3-t02-design-review.md)
record corrections and the remaining approval blockers.
The subsequent [SPIKE-069 result](../../experiments/spike-069-scoped-model-access/evidence/result.md)
provides bounded compiler/lifetime evidence and exposes a concrete source/API
choice; it does not close B1 or establish application feasibility.
The subsequent [source-design comparison](../iterations/iteration-003-review/rfc-014-source-design-options.md)
and [application ownership audit](../iterations/iteration-003-review/rfc-014-ownership-audit.md)
make the earlier A/B choices and retention risks reviewable. The maintainer
subsequently proposed a Canvas protocol and versioned observable storage.
The [2026-10-10 working direction C](../iterations/iteration-003-review/rfc-014-decision-direction.md)
replaces the earlier recommendation to develop closure-based SnapshotCanvas first.
RFC approval, exact declarations and physical pool bounds remain open.
[SPIKE-070](../spikes/spike-070-protocol-canvas-versioned-access.md) is now terminal
**inconclusive**: the finite C fixture passes both native runs and ARMv6
compilation, but its Embedded positive fails after the two allowed repairs.
The escape matrix and nRF resource inspection are unrun. The
[result](../../experiments/spike-070-protocol-canvas-versioned-access/evidence/result.md)
identifies generated body/draw signature adaptations and keeps B1/B4 open.
The separately authorized [SPIKE-071](../spikes/spike-071-canvas-embedded-escape-continuation.md)
now completes that bounded matrix: four-profile positives, 21 native checks per
profile, 24 intended negative controls and no allocator relocations in the rooted
nRF fixture. Its [result](../../experiments/spike-071-canvas-embedded-escape-continuation/evidence/result.md)
supports the mechanism under experimental lifetime flags, not complete production
binding, source compatibility, whole-image feasibility or RFC approval.

The [contextual evaluation design](../iterations/iteration-003-review/rfc-014-contextual-evaluation.md)
now proposes the production connection: a contextual compiled View contract,
explicit traversal session, short body/draw read borrows under a frame lease,
and typed access-failure transport. It distinguishes familiar authoring syntax
from an unchanged Swift protocol or macro-only implementation. The draft SPI,
compiler policy remain unapproved. The subsequent
[SPIKE-072](../spikes/spike-072-contextual-traversal-integration.md) supports the
contextual connection through actual adapted SemanticCore/Drawing modules on
four configurations, with 111 passing native checks per profile. Explicit
generated Body aliases and leaf-only defaults avoid an observed incorrect Never
witness. The [application inventory](../../experiments/spike-072-contextual-traversal-integration/application-coverage.md)
shows that complete counter/analyzer source coverage, production binding/ownership
and full-image feasibility remain unproved. Mandatory transformation is selected
provisionally for evidence, not adopted as production architecture.

## Current access/ownership work — 2026-10-10

The maintainer requested resolution of the two remaining issues. The
[analyzer capacity choice](../iterations/iteration-003-review/rfc-014-capture-policy-choice.md)
records the maintainer's explicit selection: keep three banks with bounded
replacement refusal. Model metadata capacity is separate from capture capacity;
retained owners are never revoked. The linked ownership transaction and failure
matrix define the proposed realization. Accepted constants are unchanged.
The [typed access contract](../iterations/iteration-003-review/rfc-014-typed-access-contract.md)
selects schema-specific read domains fixed by each compiled View conformance,
scoped typed facades and separate checked mutation. Generated application schema
requirements keep GiftUI independent of analyzer/counter fields and portable
presentation independent of Runtime. Swift derives Body; generated code supplies
the domain type arguments and access binding. The source-route matrix covers the
actual counter/analyzer inventory at the contract level, not as an implemented
frontend. This contract supersedes earlier universal scalar-reader, copy-freeze
and manually generated Body recommendations where they conflict.

Both requested design issues now have explicit dispositions. The remaining
B0–B4 work is integration, lifetime, complete source coverage and resource proof;
no additional maintainer policy choice is currently pending. RFC status remains
draft, and the selected contract has not been compiled across real modules.

## Current design correction — 2026-10-10

[SPIKE-073](../spikes/spike-073-fixed-context-body-inference.md) completed the
single bounded SR-Q2 check: fixed-context Body inference compiles on all four
configurations, both native runs pass 15 checks, and eight negative controls
reject. [SR-Q1–4 dispositions](../iterations/iteration-003-review/rfc-014-stable-read-revision.md#activity-results--2026-10-10)
record the accompanying source/contract audit. The access/ownership contracts
above answer the follow-up design questions; their integration and resource
proofs remain open. No successor study is opened.

The maintainer authorized [stable reads without a mandatory snapshot copy](../iterations/iteration-003-review/rfc-014-stable-read-revision.md).
That revision supersedes conflicting C copy-freeze, five-bank-baseline and
mandatory frontend Body-derivation recommendations below. Retain protocol Canvas
and stable model ownership, preserve mutation exclusion, and first investigate
compiler-derived Body with a fixed read context. Previous studies remain evidence
for their exact candidates. Accepted ADR-011/025 already require serialized
mutation; this correction changes a draft realization, not those decisions.

## Summary

Evaluate the real portable declarations through Semantic Core's traversal and
emit bounded records at runtime. Retain complete structural identity separately
from each revision's record indices. Keep live models in address-stable typed
owner storage; exclude mutation through post-layout Canvas invocation.
Develop a Canvas protocol with explicit draw invocation and observable properties
backed by retained model storage. Graph and drawing read the same unchanged
version; a separate snapshot copy is not required by this baseline. Preserve serialized mutation
and existing transaction order. Per-Canvas snapshot keys remain an earlier
alternative, not a required mechanism when the frame owner covers every read.

The recommendation is to pursue this representation at the contract-design
boundary, subject to B0–B4 below. This is not a recommendation to approve an
unsafe or incomplete implementation. No production change or proof experiment
was part of the original RFC-authoring task. Separately authorized SPIKE-069
has now completed; its unused budget does not authorize continuation or adoption.

## Context

[PROPOSAL-007](../proposals/proposal-007-external-application-integration.md) is
accepted. Its [runtime scope amendment](../iterations/iteration-003-review/runtime-derivation-scope-amendment.md)
requires the analyzer and finite counter to derive their graph at runtime on
macOS Dynamic/Static, Pi 1 ARMv6 Dynamic and nRF52840 Embedded Static.
This is post-MVP work; the MVP analyzer supplies regression contracts, not a
new MVP commitment. External delivery remains in iteration 4.

[I3-T01](../iterations/iteration-003-review/i3-t01-result.md) corrected source
deadlines and raster/layout costs. It retained generated production topology.
Its 74 passing hardware-free checks are baseline controls, not evidence for
this proposed representation. The retained 4 MHz transfer path still fails the
250 ms necessary condition; hypothetical 32 MHz is neither configured nor proved.

## Scope and Decision Boundary

This RFC owns runtime record construction and identity, the live-model access
context, capture validity through Canvas, storage lifetimes, and publication/
retirement. These are coupled: a representation is incomplete if it copies a
state wrapper or capture beyond the storage it addresses.

[RFC-013](rfc-013-external-application-and-backend-integration.md) retains package
partition, supported external APIs, host assembly, setup and migration for
external authors. Those decisions can consume this runtime contract without
this RFC choosing a package partition. This is a focused extraction of its
runtime question, not supersession of RFC-013 or adoption of its rejected
candidate. Neither RFC requires the other draft to be approved to define its
own contract. External implementation will depend on the accepted runtime result.

Display strategy/rate, asynchronous rendering, a different source workload,
fine-grained invalidation and general application compilation are excluded.
The finite counter may use isolated repository composition under iteration 3;
external-package success is not required here and cannot be claimed from it.

## Requirements

| Requirement | Governing source / proposed evidence |
| --- | --- |
| Actual body/state-dependent traversal, no pre-expanded topology input | I3-04 / IT-AC-006; source inventory and declaration/branch perturbation oracles |
| Exact paths, state preservation, action generations, layout and pixels | SPEC-006/010/011; compare both profiles and independent expected transcripts |
| One serialized mutation/freeze/publication sequence | ADR-011/025 and SPEC-013; failure injection at every acquisition/publication edge |
| Bounded Static storage with no allocator or dynamic fallback | ADR-026 and SPEC-013; exact target layouts, ELF, complete feasible-path stack and capacity controls |
| Same analyzer/counter behavior on all four configurations | IT-AC-004/008; application-specific limits and matrix, not analyzer limits reused for counter |
| Existing sustained workload remains an independent iteration gate | IT-AC-009 / SPEC-001; connected 30 s at 80 events/s and four-FPS cadence |

## Constraints

`GiftUI` remains the portable framework import. No owner lookup singleton,
task-local state, reflection, existential registry or application model in a
backend is introduced. Fixed callable code and type-role tags may be generated;
parent/child links, expanded branches and per-application scope tables may not.
The Static Canvas syntax lowering required by SPEC-012 remains mandatory for
current production; direction C proposes replacing that source contract through
explicit ADR/Spec changes, while retaining bounded typed storage and dispatch.
Generating code for a syntactic callable is distinct from generating its runtime
occurrences and captures.

The current analyzer logical maxima, including 126 structural identities,
98 layout/render scopes and 404 transitions per capture, remain the starting
workload limits. Record allocation does not silently raise them. New physical
byte budgets below are proposals requiring SPEC-013/015 approval.

## Proposed Design

### Current direction — protocol Canvas and versioned observable storage

The [working decision record](../iterations/iteration-003-review/rfc-014-decision-direction.md)
defines C1–C6 and the approval process. The subsequent
[detailed C contract](../iterations/iteration-003-review/rfc-014-c-contract.md)
proposes exact access operations, copy-freeze semantics, public authoring shapes
and lifecycle/error rules. Its finite context-injection mechanism remains an
explicit compiler/tooling proof obligation, not an implemented wrapper. Canvas becomes a View-refining protocol
with Body == Never, framework-supplied leaf traversal and an explicit draw method.
Observable properties delegate to stable typed owner storage with current/frozen
logical versions. One coherent frame freeze covers graph, Layout and drawing;
external facts still enter admission rather than mutating a frozen model.

This is the working RFC direction, not accepted architecture. It does not adopt
the earlier ScopedState/WithModel/SnapshotCanvas surface or prove that implicit
property reads can be safely bound. Exact API/compiler/access design is B1/B4.
Graph association does not transfer all application ownership to transient nodes.
Physical buffer mapping, replacement and retained owners remain B0/B2.

The runtime identity and publication principles below remain proposed shared
requirements. The per-Canvas key realization, callback-only restriction and
four-slot arithmetic below describe the earlier branch and its evidence; they
are not automatically the realization or reservation for C. Recompute the
resource model from C's complete owner/version ledger before approval. The
[C storage ledger](../iterations/iteration-003-review/rfc-014-c-storage-ledger.md)
now proposes K=2 current model slots and F=1 frozen slot: five analyzer
capture-sized banks (32,320 transition bytes), with first-excess replacement
refusal while a former owner occupies the second current slot. This conflicts
with ADR-034 and remains a proposed resource branch, not an approved increase.
The [detailed C review](../iterations/iteration-003-review/i3-t02-design-review.md#detailed-c-contract-review--2026-10-10)
maps those changes to existing authority and names C-P1/C-P2 as the next
proposed bounded proof. No experiment is launched by the contract design.

### Runtime records and exact identity

1. Semantic Core traverses the actual root using the existing visitor and state
   binding decorator. Bind each state host before invoking its body. Evaluate
   each encountered body once; do not derive a second graph in Runtime or Layout.
2. Append one compact record per retained occurrence into the candidate bank.
   Store ordered parent/child/sibling links, kind, exact identity reference and
   typed payload reference. Text and modifier payloads use bounded side pools.
   A record ordinal is valid only in its bank/revision.
3. Intern structural path components in a separate bank-owned path table. Each
   entry identifies its parent, component kind, branch/child ordinal and finite
   concrete declaration-role tag. Type tags identify declaration types, not
   pre-expanded positions. Modifier-scope discriminators stay explicit.
4. Reconcile candidate and published identities by complete component/endpoint
   equality. Numeric table indices may differ between banks. A prefix or hash
   collision never constitutes equality. Use paired traversal of the candidate and published path tries, matching
   each child by its exact component key. The closed portable vocabulary must
   supply a fixed child-fanout bound; prove that bound and charge traversal
   scratch. Do not use an all-pairs path search inside semantic expansion.
5. After successful expansion, expose the existing Semantic Core borrowed views
   to Layout and Render. Consumers retain no declaration tree or alternate
   canonical graph. Link/layout order is the semantic order, never hash order.

Candidate and published banks stay disjoint. On failure, discard the candidate;
on publication, swap bank roles and retire old semantic records only after
all old-bank borrows end. Committed interaction identities cannot point into a
reused bank: copy their complete bounded identity key into Interaction-owned
storage, or retain a separately charged immutable identity owner. The proposed
first implementation uses copied keys; its exact capacity is a B2 obligation.

An explicit path/record traversal stack does **not** eliminate compiler body
return temporaries or the existing recursive generic visitor's stack. Keep both
in the stack account. Replacing that visitor with a continuation machine is not
silently included in this proposal.

### Model storage, binding and callback isolation

RuntimeStatic owns typed live and replacement model slots at stable addresses
provided before activation. The host supplies the backing lifetime; Observable
State owns the logical association and registration. Dynamic may retain classes
but follows the same lifetime states and transcript.

A model handle identifies its concrete owner context, slot and non-aliasing
activation/model generation. Model allocation generation is distinct from the
observable registration/target generation: detaching a registration must not
invalidate an otherwise application-owned model. It never addresses an
initializer's local copy.
The context is passed explicitly from the assembled owner; `(slot, generation)`
alone is insufficient. Before resolving any framework-owned handle, the caller
already holds the live owner lease. Generation validation never dereferences an
owner whose backing has been released.

The proposed Static binding uses a bounded context record and specialized read,
replacement and report routes. Read addresses the installed typed slot;
replacement records the exact result in the coordinator's existing mutation
result slot; report touches separate registration/dirty storage. No route owns a
model, starts a cycle or allocates a closure context. Whether the compiler can
realize these routes and model copies without allocation is B1, not inferred
from this prose or a `borrowing` annotation.

Do not hold a mutable borrow of an aggregate owner across callbacks that mutate
its fields. Split model, registration/dirty, coordinator-result and admission
storage into disjoint subregions with explicit phase access. Mutation handlers
hold only the model access needed for their invocation; the report route writes
its separate registration record. Derivation freezes model data. IRQ/input
callbacks may submit bounded facts into admission storage only; they cannot
resolve a model, call a getter, invoke Canvas or mutate the frozen snapshot.

Preserve the existing replacement protocol: reserve slot/generation and attach
candidate registration, validate its return, then commit and retire the former
registration. Attachment failure leaves the former association unchanged.
Replacement remains applied if subsequent derivation fails. Removal occurs
only at semantic publication; reinsertion materializes fresh state. Detaching
a runtime registration does not destroy a model still owned by the application
(ADR-024). Reclaim its slot only after both framework leases and application
ownership end. External live models consume a separately declared finite pool;
no two-slot bound may be assumed sufficient for arbitrary retained replacements.
That cardinality and exhaustion behavior are part of B1/B2. Generation
exhaustion refuses reuse. Application start/stop remains explicitly host-owned.

### Capture access through Canvas — earlier key-based branch

Keep owned `SignalCapture` values and their snapshot semantics for existing
Domain/publication APIs. Do not reinterpret that `Equatable, Sendable` value as
an alias to mutable storage.

Propose a separate internal presentation capture view: a small, read-only borrow
containing immutable metadata and snapshot revision, valid only under the live
owner's frozen access scope. Expose it during bound evaluation or a scoped
Canvas invocation, not as an escaping stored declaration value. SPIKE-069
demonstrates this distinction for one concrete nonescapable candidate.
The portable waveform helpers consume that view on all profiles; profile
storage changes remain below it. A typed application read contract exposes
metadata and indexed transition values without importing a Runtime module into
Domain or Presentation. Target composition supplies its storage adapter; the
16-byte packed record format stays in the target owner. Domain must not learn
firmware offsets or a runtime lease type. This changes the analyzer's maintained source
contract and requires SPEC-001 review. It is not an unexplained replacement of
`viewModel.state.capture` by a different lifetime under the same type.

The freeze lease spans body expansion, Layout and all Canvas invocations. The
snapshot cannot change until the last invocation/discard releases its pin.
Proposed Static Canvas payloads hold an owned typed snapshot key and scalar
parameters; they retain neither a borrowed view nor a full 404-record capture.
The key identifies the immutable snapshot selected at declaration, not whatever
capture happens to be current at invocation. The live owner resolves it and
supplies a fresh scoped read view for that invocation. Exact checked lowering
or a revised Canvas contract is still B1/B4; this is not an approved source-
compatible realization. Ordinary owned captures retain capture-at-declaration
semantics. Dynamic wrappers would remain bounded and release at the same logical
point. Drawing plans contain copied geometry, not a capture view, and survive
through synchronous rendering independently.

During replacement, old and staged models can require different captures.
**Proposed architecture change, blocked by ADR-034:** budget an additional
404 × 16-byte snapshot slot rather than assuming the old
and replacement values alias the live/admission slots. Four distinct analyzer
capture slots then cover source-live, admitted, installed-model and staged-model
storage. On successful replacement swap installed/staged roles; recycle the
retired slot only after all framework-owned leases and application ownership
end. The four-slot proposal covers the stated single staged replacement, not an
unbounded history of externally retained models. Source ownership and
observation attach/detach remain unchanged. [ADR-034](../adrs/adr-034-five-second-transition-capture.md)
currently requires exactly three capture slots and states that no fourth buffer
is introduced. The four-slot branch cannot be adopted through a Spec amendment
alone: it needs an explicitly reviewed successor/amendment to that decision,
preserving five-second retention and its other semantics (B0). Any later overlay optimization needs
its own lifetime evidence and cannot be used to make this initial sum fit.

The [SPIKE-069 ownership candidate](../spikes/spike-069-scoped-model-access.md#candidate-ownership-contract-proposed)
makes the retained-model term explicit: with R distinct detached snapshots
still application-owned, conservative non-sharing backing needs **4 + R** slots,
or **(4 + R) × 6,464 bytes**, plus metadata/control. Four slots require a proved
R=0 for the selected application lifecycle. The experiment models R=1 with five
slots; it does not select R for either application or approve that reservation.
Pool exhaustion must precede replacement commit and preserve the old association.
The subsequent [application ownership audit](../iterations/iteration-003-review/rfc-014-ownership-audit.md)
identifies retained host/failure/attempt model references and the counter
replacement requirement. Neither application yet proves R=0; transient retention
at replacement commit must be included, not just the state after cleanup.

The counter captures its scalar value by value. It needs no analyzer capture
pool and must not import analyzer owners.

### Non-escape boundary — earlier callback branch

A live lease is an ownership precondition, not a magic safety token. All
framework callbacks that receive bound state or capture access return only
status/scalar summaries; no unconstrained generic `Result` can carry the bound
wrapper out. Explicit owners of transient declarations and staged Canvas
payloads are registered in the phase ledger and destroyed before lease release.
Published semantics and interaction records contain no model/capture pointers.

This narrows the framework escape surface but does not make copyable Swift
values nonescaping. The existing `StaticObservableModelStorage.withBoundState`
uses `withUnsafeMutablePointer` captured by a read closure and permits generic
results. SPIKE-069 compiled return, outer-storage and delayed-closure escape
controls on all four configurations, including a Void callback and a fixed
typed pointer route. This refutes callback restriction alone as enforcement,
**not proof of an observed production use-after-free**. B1 requires an actual enforceable borrowing/lowering contract
and negative controls for every framework-owned route. Unsupported direct State
wrapper use remains SPEC-010 client misuse; no ordinary lifecycle failure is
converted into a getter trap. If safety needs a new portable restriction or
API, expose that change for review instead of assuming source compatibility.

### B1 evidence and remaining source decision

SPIKE-069's nonescapable borrow compiles on all four configurations with the
experimental `LifetimeDependence` flag; twenty negative controls reject return,
outer storage, escaping closure, overlapping mutation and ordinary declaration
storage. The compiler also warns that the selected `@lifetime` spelling is
unsupported and recommends the underscored spelling. Production compiler policy
and exact supported declarations therefore remain open.

Using all actual GiftUI declaration sources, an owned body made from scoped
scalar reads compiles; capturing the borrowed view in today's actual Canvas
is rejected on all four configurations. Sixteen lifetime-model cases pass in
each native profile, and Pi/nRF objects compile. These are not actual Semantic
Core/observable-owner executions or Dynamic class-owner equivalence evidence.
The section-GC nRF fixture has no retained allocator relocations, but no full
firmware, application stack or complete ownership proof was produced.

The [source-design comparison](../iterations/iteration-003-review/rfc-014-source-design-options.md)
now supplies analyzer/counter source sketches, required lowering, compatibility
costs and the earlier recommendation to develop explicit scoped APIs. The
[working direction C](../iterations/iteration-003-review/rfc-014-decision-direction.md)
now leads further design. The following two alternatives remain comparison
inputs, not a proof that any generic declarations compile:

| Candidate | Required design before adoption | Tradeoff / evidence boundary |
| --- | --- | --- |
| Preserve portable source through checked finite lowering | Define accepted model/capture uses; diagnose escapes; transform staged captures into pinned keys; prove every generated route and Dynamic equivalence | Preserves the source objective, adds compiler-tooling obligations; A does not refute this, but no such checker/lowerer was built |
| Expose scoped model reads and snapshot-aware Canvas invocation | Review exact portable State/body/Canvas declarations and compatibility; supply a fresh borrow at invocation from a declaration-selected key | B supports the internal mechanism, but the existing escaping Canvas signature cannot directly carry its borrowed view |

Scoped reads plus delayed owned keys remain the earlier internal candidate.
Direction C first tests whether a frame-owned frozen model covers all drawing
reads without separate Canvas snapshot ownership. No exact public contract is
approved. None of these candidates permits hidden pre-expanded graphs, an unbounded owner pool, arbitrary unsafe
backing aliases or unsafe getters after teardown. The next design decision is
the source-enforcement boundary alongside application ownership/cardinality;
additional full-image benchmarking cannot decide that API tradeoff.

### Publication and retirement

| Phase | Live objects / access | Exit obligation |
| --- | --- | --- |
| Validate/construct | Backing, immutable limits, typed slots; no active registration or user callback before validation | Account construction temporaries and partial failure |
| Admit/mutate | Live model, active/sealed facts, optional replacement model/capture; separate dirty/result routes | Apply each accepted fact/action once; consume first mutation failure |
| Freeze/derive | Installed model and snapshot read lease; candidate bank, path table, payload pools and compiler body temporaries | Preserve old published bank; release all transient declaration owners |
| Layout/Canvas | Candidate borrowed semantic view, layout, staged captures, Path and accumulating plan | Release each callable/capture after its one invocation, then end capture lease |
| Preflight/publish | Candidate products and interaction; prior committed routing still valid | Follow SPEC-013 ordering, publish semantics/observable set atomically |
| Offer/finalize | Immutable drawing plan/layout/render; committed and candidate routing until offer disposition | Synchronous one-shot offer; no semantic rollback; discard/commit routing as governed; clear borrows once |
| Quiesce/teardown | Stop admission and external producers, wait for active synchronous calls/IRQ handoff, retire registrations | Drop staged callables, invalidate generations, release backing last |

Backend refusal retains only existing pending presentation intent. Retry
rederives from current model state, never from retained declaration/capture
pointers and never by replaying admitted mutations.

## Module Responsibilities

| Owner | Responsibility | Dependency impact |
| --- | --- | --- |
| GiftUI / host compiler tooling | Existing declarations, traversal witnesses, bounded Static callable/model adaptation | No runtime owner import or global resolver in GiftUI |
| GiftUISemanticCore | Expansion, exact identity and borrowed semantic contracts | Runtime supplies storage; Layout still imports Semantic Core one way |
| GiftUIObservableState | Bind/reconcile/replace/remove and registration outcomes | No Interaction or application import |
| GiftUIRuntimeCore + profile modules | Sequence owners, own concrete banks/slots/leases and join action target generations | Preserve current acyclic owner graph |
| GiftUILayout / GiftUIDrawing / Render owners | Existing layout, synchronous Canvas and copied plan/operation meaning | Consume borrowed inputs; no model resolution in Render/backend |
| Signal Analyzer model/domain adapters | Owned capture versus scoped presentation reads and explicitly bounded snapshot storage | Requires explicit ADR-034 and application contract amendment; four slots alone assume R=0 |
| Host configuration / target composition | Exact application capacities, backing, validation, activation/quiescence | Counter composition stays separate; no package extraction here |

## Public API Impact

Retain ordinary `View.body`, typed Button actions and common portable semantics.
Direction C intentionally changes concrete closure-based Canvas into a protocol
with explicit context/bounds invocation. Its proposed observable property wrapper
uses stable versioned storage; spelling, initialization and read-context binding
remain open. It is not automatically Apple's `@Published` semantics or a Combine
dependency. Review compatibility against ADR-024/025/026/028 and SPEC-010/012.
Current source remains authoritative until the required decisions and contracts
are approved. Neither property storage nor Canvas replacement is a private
implementation-only change.

## Capabilities Impact

No capability, negotiation rule, default or fallback changes. Capacity and
lifetime rejection remain focused-owner failures; zero heap is a construction
constraint, not an optional capability.

## Backend Impact

Keep the existing one-shot operation stream, RGB565 raster/session/display
owners and target transport. No framebuffer, async queue, damage policy or SPI
rate change is proposed. The 4 MHz transfer lower bound remains an iteration
blocker independent of runtime representation.

## Static / Embedded Impact

Fixed typed stores and finite generated code replace retained nested declaration
aggregates. This still needs supported nRF hard-float compilation, zero forbidden
symbols, exact source ownership and actual ARMv6 composition. Static macOS
execution is a semantic control, not nRF stack evidence. Existing I3-T01 deadlines,
20-event catch-up bound and Layout-to-Render scratch transition remain intact.

## Performance

SPEC-006 requires linear expansion work. Record/path append and paired trie
reconciliation are proposed to cost O(N × K), with fixed supported child-fanout
bound K; emitted code and complete path-prefix counts must substantiate it.
An all-pairs O(N² × D) identity scan is excluded from this design. No performance
win is inferred solely from fewer copies. Body-return temporaries, repeated
identity decoding and specialization remain measurement obligations. Profile
phase accounting must include derivation, Layout, Canvas, preflight and physical
offer without double-counting nested timing intervals.

The analyzer must still satisfy 80 events/s for 30 seconds and four-FPS cadence.
Counter has its finite action/pixel workload, not that acquisition requirement.
Preserving operation-major 4 MHz transfer cannot meet the analyzer frame target;
no CPU optimization in this proposal removes that necessary-condition failure.

## Memory / Binary Size

The following is the **earlier key-based branch's proposed reservation model**;
direction C requires a fresh mapping of logical versions to physical backing.
It establishes neither approved limits nor measured consumption, a complete
codec, or a safe-stack finding. Extra pools are explicitly
charged; no implicit use of leftover platform RAM is permitted.

| Analyzer frame-store family | Proposed bytes | Basis / unresolved detail |
| --- | ---: | --- |
| Candidate + published occurrence records | 8,064 | 2 × 126 × 32; codec must cover all typed variants |
| Candidate + published exact path entries | 3,024 | 2 × 126 × 12; count of prefixes must be proven, not equated with endpoints |
| Candidate + published payload pools | 8,192 | 2 × 4,096, including owned text and modifier payloads; adequacy unproved |
| Layout + Render/text | 7,840 | Existing 3,136 + 4,704, including I3-T01 indexes during Layout only |
| Canvas / Path / drawing plan | 16,976 | Existing 160 + 3,280 + 13,536; snapshot-key/scalar payload and invocation bookkeeping fit remain B2 |
| Observable + Interaction | 768 | Existing 256 + 512; copied exact committed keys may require an explicit increase |
| Active/sealed admission | 7,680 | Existing 2 × 3,840, never aliased to snapshots |
| Pointer / coordinator / failure | 384 | Existing 96 + 192 + 96; expanded lease bookkeeping fit must be verified |
| Record/path construction scratch | 512 | Proposed; excludes Swift call-stack/body temporaries |
| **Frame-store subtotal** | **53,440** | Conditional on all fit obligations above |
| Four capture slots | 25,856 | 4 × 404 × 16; includes replacement snapshot |
| Typed model/control slots | 1,024 | Proposed live/replacement metadata and routes; externally retained retired models need an additional accounted bound |
| Raster/payload/coverage backing | 2,720 | Existing 2,560 + 160; aliases counted once |
| Main / IRQ stack | 29,696 | Existing 27,648 + 2,048; guards belong in remaining bytes |
| Remaining platform/globals/alignment | 8,192 | Proposed ceiling requiring exact ELF inventory |
| **Conditional total** | **120,928** | Under 196,608 application ceiling arithmetically; no safety proof |

Do not silently increase any conditional row if it fails. Revise the reservation
proposal and dependent contracts explicitly. The extra replacement snapshot is
a proposed change to ADR-034 as well as SPEC-001/013/015's exact three-slot
capture reservation; existing authority wins until explicitly changed.
The table assumes R=0. For a non-sharing analyzer pool with R retained detached
snapshots, add at least **6,464 × R** transition bytes plus additional model,
lease and control metadata; the existing 1,024-byte row is not automatically
sufficient. SPIKE-069's five-slot fixture is evidence about one ownership
sequence, not permission to add this term to the approved budget.
The table is incomplete if either application can retain more model/capture
backing than its stated live/staged allowance; B2 must establish the actual
finite bound and charge it before approval. The 95,104-byte I3-T01 linked RAM is
a generated-graph baseline, not a prediction.

For the counter, propose ceilings of 8,192 frame-store bytes, 1,024 model/control,
2,720 raster/coverage, 8,192 main stack, 2,048 IRQ and 8,192 platform/guards:
**30,368 bytes** total. Provisional logical bounds are 32 identities/scopes,
16 path levels, one root model plus replacement staging, two actions, one Canvas
and 32 text scalars. Every count must be derived from its complete portable
hierarchy and all ten states before approval; these are not borrowed analyzer
capacities or validated counter contracts.

Both nRF images retain the 1,048,576-byte flash ceiling and zero heap. Dynamic
allocation/peak-memory budgets need a matched runtime-derived application control;
source arithmetic cannot invent one. Full feasible-path stack analysis includes
construction, replacement, callback chains, recursive SCC bounds, indirect target
sets, finalization and IRQ overlap. I3-T01's 360-byte local raster frame is only
one term. Observed stack high-water supplements, never replaces, the bound.

## Alternatives

| Alternative | Benefit | Cost / disposition |
| --- | --- | --- |
| Runtime-emitted records with scoped model/capture access | Explicit ownership, avoids retaining full body tree and large capture copies | Recommended direction for contract work; safety/codec/stack proofs open |
| Retain expanded typed aggregate through Layout/Canvas | Strong ordinary Swift typing; fewer custom codecs | Archived large-copy/stack failures apply to exact past images; compiler behavior and complete lifetime proof still required; not assumed impossible |
| Keep exactly three capture slots, stage replacement without an extra snapshot | Preserves ADR-034 and saves 6,464 bytes | Must prove where old, admitted and candidate values live through attach failure and externally retained model lifetime; no safe overlay is established here |
| Keep owned snapshot values in each declaration | Simple independent lifetime and existing API semantics | Large Static copies/body temporaries; useful semantic oracle, not assumed to fit |

## Rejected Approaches

Generated pre-expanded topology as the delivered graph violates IT-AC-006.
A global resolver violates the existing module/state constraints. Merely
checking generation through a potentially freed pointer does not make access
safe. Reusing a revision's ordinal as persistent structural identity violates
SPEC-006. These exclusions follow existing requirements, not new approval.

## Compatibility

Do not remove the generated production path until runtime behavior, exact
resource limits and supported builds pass approved replacement gates. Generated
fonts, bounded model/callable source lowering and typed role tags may remain;
a production-input audit must distinguish them from forbidden graph outputs.
No ABI stability or external package surface is established here. Existing
accepted ADRs and implemented Specs remain unchanged until normal approvals.

## Testing Strategy

C's [contract controls and proposed proof recipe](../iterations/iteration-003-review/rfc-014-c-contract.md#7-contract-controls-for-the-next-proof)
add coherent multi-field freezing, unchanged-field preservation, new State
materialization, context-injection/failure transport, protocol-witness selection,
foreign/stale frame keys and retained-former first-excess cases. These are future
controls, not executed tests or authorization to run another Spike.

- Independent structural path and modifier-order corpus, branch/optional shape
  changes, declaration insertion that shifts record indices, and exact first-
  excess limits. Source perturbations must change runtime output without graph
  generation. Canonical fixtures may contain expected trees; production may not.
- State preservation, replacement attach failure, replacement then derivation
  failure, published removal/reinsertion, stale action target and generation
  exhaustion. Verify prior committed routing after offer refusal.
- Capture-at-declaration meaning, concurrent source admission while frozen,
  zero/multiple Canvas occurrences, and cleanup on every preflight/failure edge.
  Poison retired storage in host tests; audit/compiler-negative escape controls
  must cover the actual supported binder and every generated callable case.
- Separate module builds, target ABI/heap inspection, exact storage offsets and
  exclusive lifetimes; capacity tests cannot substitute for compiled stack proof.
- Both applications on four configurations, current independent semantic/action/
  pixel oracles and complete owner drivers. Connected sustained-workload and
  stack observations remain separately authorized operations.

## Risks

The compiler may allocate captured routes, copy a large model despite a handle
facade, or create oversized body temporaries. Exact identities may cost more
than the proposed path/interaction reservations. Replacement needs simultaneous
old/new storage. Pointer poisoning cannot prove absence of all escapes. None
of these risks is resolved by the conditional RAM sum.

## Open Questions

| ID | Blocking issue | Required resolution |
| --- | --- | --- |
| B0 | Three-bank capacity policy selected; ownership-transfer realization still needs proof | The maintainer selected bounded replacement refusal in the [capacity contract](../iterations/iteration-003-review/rfc-014-capture-policy-choice.md). Separate two metadata slots from one model-bank entitlement; preserve independently retained owners and reject unavailable backing before commit. Validate reservation/attach/rollback and bank reuse against actual owners. No fourth-bank amendment or sharing is selected; no complete-image fit claim. |
| B1 | Enforceable State/model/capture access and callback isolation | Current SR-Q1–3 support unchanged storage through drawing and finite fixed-context compiler-derived Body; the [typed access contract](../iterations/iteration-003-review/rfc-014-typed-access-contract.md) now selects fixed schema domains and scoped facades; real integration remains open; the following studies describe earlier candidates, not mandatory copy-freeze or frontend Body derivation. SPIKE-069 refutes callback restriction alone and supports a bounded borrow/key fixture. The earlier C contract proposed copy-freeze, contextual property access and typed protocol dispatch. Prove finite context lowering, typed failure transport, compiler support and every owner/access route (C-P1/C-P2); exact Swift realization remains open. SPIKE-070/071 support finite lowering and a four-profile borrow/escape fixture, with root evaluation/draw signature adaptations and experimental lifetime flags; the rooted nRF object has no allocator relocations. The contextual-evaluation draft specifies replacement compiled View witnesses, an explicitly threaded session and short read borrows under a frame lease. SPIKE-072 supports real nested SemanticCore/Drawing module integration using explicit generated Body aliases and leaf-only defaults; automatic opaque witness inference failed. Complete source-shape conformance, production owner routes and compiler-policy adoption remain open (CE-1–CE-6). Fixture results do not close full no-escape/exclusivity/zero-heap proof. |
| B2 | Complete record/payload/path/interaction and model storage | Apply the selected three-bank policy and separate metadata from capture entitlement (no mandatory F0); verify actual owners and every failure edge (C-P3), complete layouts/codecs/trie fanout and all source cases. The old K=2/F=1 fixture is not a new storage proof. Validate all byte rows before proposing SPEC-001/013/015 limits. |
| B3 | Complete supported-image stack and Dynamic cost | Bound recursive/indirect/callback/IRQ paths and construction/service/teardown; measure matched Dynamic memory. No unknown edge may be recorded as zero. |
| B4 | Concrete supported lowering and migration completeness | SR-Q3 now defines schema/domain placement, typed facade binding, composition and a real source-route matrix in the access contract; validate that contract rather than obsolete version selection or manual Body derivation; the earlier contextual-evaluation draft proposed mandatory finite lowering and a compiled View SPI change. SPIKE-072 inventories missing counter/analyzer routes and verifies conditional reads plus identity/work counts for a finite corpus. Define and validate the complete source/type/helper/current-write grammar, reject unchecked routes on every profile, and migrate actual graph producers/consumers. The inventory and small generator do not prove full application coverage (CE-1/4/5). |

B0's capacity choice is settled for the draft; its ownership proof and B1/B2 remain design/contract readiness blockers; B3/B4 include evidence required
before adoption. Which evidence can precede exact Spec approval must be explicitly
bounded and authorized as a separate experiment. SPIKE-069 completed under its
own authorization; this RFC opens no subsequent experimental allowance.
The preserved 4 MHz failure is an additional **iteration performance blocker**,
not evidence that record emission is intrinsically impossible. Resolving it
requires a separately selected transport/rendering or requirement decision.

## Deferred and Follow-up Work

Eugene's subsequent “Let's do it” authorizes
[SPIKE-072](../spikes/spike-072-contextual-traversal-integration.md): provisionally
pursue mandatory source transformation and test actual contextual traversal and
drawing integration. This is bounded evidence work, not RFC approval or adoption
of the compiler flags, changed View contract or proposed five-bank budget.
The experiment is now completed with supported finite integration and explicit
application coverage gaps; its terminal report retains the repair-limit deviation.

The authorized [contextual evaluation design](../iterations/iteration-003-review/rfc-014-contextual-evaluation.md)
is now delivered with [CE-1–CE-7 review findings](../iterations/iteration-003-review/i3-t02-design-review.md#contextual-evaluation-design-review--2026-10-10).
It proposes the production contract and explicit compatibility cost; it runs no
new experiment and approves no compiler flags, storage budget or architecture.
All integration/enforcement questions remain current B1/B4 blockers.

Eugene separately authorized [SPIKE-071](../spikes/spike-071-canvas-embedded-escape-continuation.md)
for the assertion correction and missing Embedded/escape/resource checks. It
completed with a supported recommendation for the bounded mechanism: 40/48
calls, 2/3 repairs, four-profile positives and 24 valid negative controls. The
rooted nRF fixture has no allocator relocations and retains five indirect drawing
sites. Earlier terminal evidence stays intact. Next specify production contextual
View evaluation/failure transport and binding coverage; the generic escape matrix
need not be repeated without a changed candidate. No further run is authorized.

Eugene separately authorized [SPIKE-070](../spikes/spike-070-protocol-canvas-versioned-access.md)
on 2026-10-10 for C-P1/C-P2. It completed **inconclusive**, using 11 of 48
invocations and both repair rounds before the 90-minute deadline. Both native
profiles pass 21 fixture checks and ARMv6 compiles; Embedded rejects two throwing
assertions and the escape/resource matrix is unrun. No production or connected
work occurred. A further proof needs separate bounded authorization; neither
this result nor unused invocation/time budget reopens a terminal Spike.

The later SPIKE-071 supplies the previously missing Embedded checks without
changing that historical result. Next contract work remains the contextual View
evaluation/failure seam, complete finite read/helper/current-write coverage and
experimental compiler policy. No current blocker is deferred.

No correctness or feasibility question above is deferred. RFC-013 and approved
iteration 4 already own external API/package/setup decisions; revisit after
runtime contracts stabilize. Existing FW-035 owns future generated frontends;
it cannot serve as the runtime-derivation implementation. No stopped experiment
is resumed. The separately authorized
[SPIKE-069](../spikes/spike-069-scoped-model-access.md) completed B1 escape controls
and recorded a proposed finite model/snapshot ownership contract. Its compiler
counterexamples and bounded positive evidence inform the source decision above.
B1/B2 remain
blockers here; the Spike does not approve a buffer count, portable API change
or production migration, and its allowance does not renew earlier budgets.

## Decision Summary

If the blockers are resolved and this RFC is approved, proposed ADR extractions
are (1) runtime records with exact cross-revision identity and publication,
and (2) frame-scoped versioned model/property ownership. Direction C additionally
requires an explicit Canvas representation decision against ADR-028 and the
closure-specific SPEC-012 contract. Final ADR boundaries follow the reviewed
choices, not provisional API names. The earlier proposed
four-slot branch additionally needs an explicit ADR-034 successor/amendment
preserving five-second retention; it cannot be approved as a private storage
change. Preserve
ADR-006/024/025/026/032/033; identify any actual amendment rather than implicitly
superseding them. Exact API declarations, codecs, capacities and error mapping
belong in affected Specification amendments, then per-Spec implementation plans.

## References

- [Current activity plan](../iterations/iteration-003-review/memory-efficiency-plan.md)
  and [iteration-3 scope](../iterations/iteration-003-dev-ux-improvement.md).
- [Prior candidate and 32 MHz review](../iterations/iteration-003-review/candidate-go-no-go.md),
  retained as historical evidence rather than resumed work.
- [State implementation](../../Sources/GiftUI/ObservableState.swift),
  [Static binding](../../Sources/GiftUIRuntimeStatic/StaticObservableModelStorage.swift),
  [Semantic traversal](../../Sources/GiftUISemanticCore/GiftUISemanticCore.swift).
- [Analyzer view](../../Sources/SignalAnalyzerPresentation/SignalAnalyzerView.swift),
  [owned capture](../../Sources/SignalAnalyzerDomain/SignalValues.swift),
  [existing snapshot view](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCaptureSnapshotView.swift),
  [profile regions](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFProfileRegions.swift).
- [Counter workload](../explorations/exp-002/preparation-2026-10-05/consumer-study.md);
  external-study requirements remain distinct from iteration-3 composition.
