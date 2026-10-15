---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — P08 Scoped Storage Ownership
status: draft
authors:
  - codex
created: 2026-10-13
updated: 2026-10-14
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work:
  - FW-038
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — P08 Scoped Storage Ownership

Current remaining P08 boundary — **FIT FAIL; independent Strong exit review pending, 2026-10-15**.
The [activity record](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-remaining-completion-activity.md) consumed both corrective cycles (2/2). Four full profile collections and
both registered early image builds pass. The [resource reconciliation](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-remaining-images-resource-result.md)
pins a reachable nRF frame needing at least 30,096 bytes against the unchanged
27,648-byte main-stack ceiling. Complete IRQ/allocator/Dynamic cost proof remains
open. P08/R07/T8.1/HC-RD-003 stay open; I4-07/analyzer, P09–P12, hardware and
timing boundaries remain. No further automatic source repair, new variant or
resource waiver is authorized. Earlier boundary records below remain historical.

Current P08 collected-suite repair batch — **COMPLETE; independent package review PASS, 2026-10-15**.
The [batch result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-suite-collection-result.md) records the full registered baseline collection,
grouped routine corrections and focused validation. Current native runtimes pass
1,736,158 Static / 1,736,082 Dynamic assertions with zero failures; reuse and
exclusivity controls pass. ARMv6's 22 selected compiler checks pass; Embedded's
full 226-check collection passes. Focused receipts remain partial, not a full
corrected-source matrix pass. Both grouped correction cycles are consumed;
historical budgets, contracts and resource limits are unchanged. P08/fit, images
and acceptance coverage remain open. The following boundary records are historical.

Historical grouped lifetime continuation boundary — **STOP, 2026-10-14**.
Candidate `cab1c415`, source review `2989ca7f`: the complete counter module now
compiles, clearing the prior L01–L03 diagnostic sites. The one registered native
counter invocation exited 1 after **191 accepted scoped compiler checks**; check
192 rejected the intended closure escape, but its diagnostic did not contain the
harness's required `escaping` substring. It reports lifetime-dependent input
`escapes its scope`; the positive twin compiled. This is a diagnostic-classifier
mismatch, not an accepted full matrix or runtime result.
[Independent result and immutable evidence](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-compiler-compatibility2-result.md).
The [frozen allowance](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-compiler-compatibility2-source-freeze.md)
is consumed: candidate 1/1, invocation 1/1, automatic repairs 0. Historical
integrated cycles 2/2 and compatibility 1 remain closed. No classifier edit or
rerun occurred. Remaining compiler controls, native exclusivity, counter runtime,
ten initial profile cells, both images, all nine SO criteria and P08/fit remain
open. Three earlier component passes retain their exact applicability limits.
FW-038 captures validation cost separately; its documentation-only commit did
not change any of the nine frozen source hashes or this running matrix.
Earlier pending/current wording below is historical.

Historical compatibility 1 boundary — **STOP, 2026-10-14**.
Candidate `bbb54fc1`, source review `7002a953`, exact native counter run failed
with ten explicit lifetime/ownership diagnostics in three cause groups. The
earlier graph SILGenCleanup assertion is no longer emitted; compiler acceptance
is still absent. [Result and independent diagnosis](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-compiler-compatibility1-result.md).
New allowance consumed: candidate1/1, invocation1/1, automatic repairs0; historical
cycles2/2 remain closed. Three component passes retain their bounded evidence;
actual counter runtime, remaining profiles/images and fit/P08 remain open.
Earlier pending/current wording below is historical.


Current P08 package boundary — **STOP, 2026-10-14**. Source `8ef34f59`
passed independent source review `72bd3a11`, but the final macOS Dynamic counter
compile failed in Swift 6.4 SILGenCleanup ownership verification for the
`p08CounterGraph` closure. [Package evidence and disposition](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-integrated-package-stop.md).
Three component cells passed (459/5,904/187 assertions); actual counter initial
attempt and both corrective reruns failed before runtime. Both corrective cycles
are consumed (2/2), with ten remaining initial cells and two images unrun.
No automatic source repair, rerun, probe or toolchain change remains authorized.
All nine SO criteria, fit and P08 remain open. The earlier dated checkpoints below
are historical; this boundary supersedes their pending/current action wording.


Current integrated independent SOURCE review — 2026-10-14: [Strong review of `e2d9db9c`](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-integrated-independent-source-review.md) finds **B01 blocking**: current retained-action delivery bypasses the admitted/sealed SPEC-009 mutation path. Original producer guards and full same-inventory/same-address host reconstruction are present; O01 requests targeted application-counter fingerprint coverage. Source readiness fails until correction; no compiler/runtime/fit/conformance result. Broader activity permits a bundled autonomous local correction and independent assessment, with cycles **0/2 consumed**, matrix/images **0 consumed** at review. Historical allowances and the two-unproductive guard persist; no renewed file permission gate.


> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification. The original SO-02 design remains below. The
> repeated-host addendum selects a private direction for independent Strong
> design review; it is not implemented code, source authorization, compiler
> acceptance or target-fit evidence.

## Current integrated corrective source candidate — 2026-10-14

The [broader authorized activity](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-integrated-activity.md)
governs necessary existing-contract completion and predefined validation. The
[cycle 1 source freeze](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-integrated-cycle1-source-freeze.md)
bundles diagnosed compiler fixes and B01/O01. Guarded prepare admits a real down;
after its actual zero-action cycle, guarded delivery puts the original retained
capture into existing pointer capture and admits a real up. Existing gesture/seal/
mutating dispatch consumes that original once; owned observations correlate the
sealed action, actual dispatch phase/cycle and effect. There is no idle dispatch,
new pending transaction owner, scoped getter or duplicate dirty authority.
Fresh control reconstruction resets observation fields; actual family24/stack/
layout accounting remains required. Cycle1/2 consumed, source candidate unreviewed/
unexecuted. Historical initial freeze/design/receipts remain evidence; their dated
file/source-only stops do not reinstate obsolete current permission gates.

## Repeated Full Hosts — Derived Addendum, 2026-10-14

Input is frozen source `369906abf54f6341b0f0287e09d3dfeec28ab005`, independently
reviewed in `5ba87bd0`. The
[corrective review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-06-corrective-independent-review.md)
confirms findings 1–4 corrected as source and leaves finding 5 open. This
addendum replaces no frozen evidence and authorizes no source pass. Its exact
[bounded handoff](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-06-repeated-host-design-handoff.md)
defines the proposed whitelist. Independent Strong
[design review PASS](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so04-06-repeated-host-independent-design-review.md)
validates the bounded realization and actual ingress dispositions; the next step
is a concrete human source-allowance decision, with source allowance still zero.

### Contract classification and guarantee

[SPEC-013 S13.1](../specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract)
allows the initialized physical inventory to return to idle after complete
logical cleanup and all old scoped accesses end. A fresh session restores empty
banks and original roles; generations still obey the stale-action contract.
[SPEC-015 operational teardown](../specs/spec-015-host-configuration.md#operational-state-and-teardown)
makes failed/quiescent instances terminal and requires a fresh complete host.
Neither clause requires reopening a retired model/root/runtime/input owner.

[SPEC-009 identity declarations](../specs/spec-009-execution-cycle-and-frame-handoff.md#execution-identities-and-phases)
scope cycle, semantic, candidate, presentation and action generations to one
assembled runtime and allocate raw zero first; its
[input contract](../specs/spec-009-execution-cycle-and-frame-handoff.md#presentation-coupled-pointer-admission)
likewise starts each source's submitted sequence at zero and requires reassembly
on exhaustion. SPEC-010's registration declaration allocates raw zero first
and guarantees uniqueness for the assembled runtime lifetime. Its existing
`ObservableModelOwnerNamespace` instead survives reassembly and issues a fresh
model owner identity. Preserve these distinct namespace lifetimes.

Select **fresh complete logical owners plus private producer provenance** over
one initialized G/C/R/H inventory. Existing physical-owner identity and checked
session serial identify the selected session internally. They are not new
Execution identities, semantic path components, public epochs or a cross-module
namespace contract. They select which actual finite producer may deliver to the
current runtime; all focused raw declarations and allocator rules stay exact.

The guarantee is rejection of an old producer/capture delivery through its
original host ingress, and no surviving old callback or scoped dispatch
capability. It is not content-only rejection of arbitrary raw values relabeled
as current work. `SemanticCompleteIdentity` is a semantic path.
`RuntimeRecordInteractionBridge.dispatch` checks that path, action generation,
enabled state and current target generation; it has no model-owner field.
`NormalizedPointerEvent` contains source, presentation, sequence and ordinal,
with no runtime-owner field. A naked old value and a legitimate new value can
have identical bits after genuine runtime reassembly. The approved runtime-local
contract does not make a naked raw value a cross-runtime capability. If review
requires rejection of that stronger replay scenario at the focused raw API,
stop and route an explicit namespace/API clarification upstream; this note
cannot add it or claim to satisfy it with an envelope.

### Surviving storage and fresh logical reconstruction

Keep the enclosing native typed reservation borrows or Embedded raw reservation,
the original initialized G/C/R/H inventory, physical owner identity/serial and
the control reservation at their original addresses until final release. Do not
reinitialize geometry/banks between hosts. Each session initializes a fresh
logical `CounterControl` in its separately reserved control slot only after the
previous host, bindings, application and callback scopes have ended and the old
control value has been destroyed. Native performs typed replacement within the
pinned slot; Embedded deinitializes that slot before initializing the same T.
No replacement happens while an old live owner's exclusive borrow exists.

Move model/root, semantic and Canvas outer construction from the once-per-
physical-allocation path to a closed once-per-host helper in
`CounterScopedStorage.swift`. The old outer values are destroyed in reverse
after their existing `withLifetime` scopes end. The next helper constructs new
adapters/storage in the now-vacant same typed slots (Static), or new bounded
outer values around the same control reservation (Dynamic). Persist the two
existing owner namespaces outside both host helpers and issue distinct model
and semantic owners before reconstruction. Keep the old root/model shutdown
behavior and all existing report/registration teardown. No root restart API,
reset-retired flag, new observable initializer or altered allocator is selected.

The fresh helper validates/audits the exact new outer owner and unchanged
physical inventory, acquires model/root → semantic → Canvas scopes, consumes
one `withP08Storage` session into the actual supplied → pipeline → coordinator
→ preset host chain and installs the current cleanup holder before activation.
The session carries owned immutable origin facts derived from its existing
common token to the trusted construction body. Install those facts in the new
control before coordinator admission construction. Original typed pointer
borrows and the complete carrier lifetime unions remain unchanged; the facts
neither lend storage nor replace the compiler lifetime proof.

### Actual ingress inventory and guards

Use a small fixture-internal owned origin value `(physical owner identity,
checked session serial)` and an active-origin field in `CounterControl`.
The physical serial at `P08TypedBackingOwner.withStorage` already advances with
checked overflow. It is never reset while this reservation is alive. The guard
is valid only inside the enclosing reservation; retaining/dereferencing an old
raw pointer after final reservation release remains forbidden. No global registry,
heap lease, stamp allocator or extra transaction machine is introduced.

| Actual frozen path | Selected internal realization and review obligation |
| --- | --- |
| `CounterAdmission.swift:127–160`, coordinator construction and `init(borrowing:)` consumers | Each adapter snapshots current origin when legitimately created. Every submit checks active origin equality before controller access, synchronization, cancellation, queue writes or wake notification. A mismatched old adapter returns existing `.unavailable` with zero effects on the new runtime. It must not synchronize an old controller by reading the current pointee first. Ordinary owned probes retain their existing route; selected origins cannot silently fall back to that route. |
| `CounterApplication.swift`, source → repository → nonescaping delivery callback | Application owner snapshots the origin at construction. `startSource`/delivery checks it before control access and before minting a borrowing admission adapter. Teardown disables delivery, stops source, detaches observations and quiesces its gate before old scope destruction. A deliberately retained old application/producer test value cannot mint fresh ingress from the reused address. |
| Host-local normalized gate → `CounterAdmission.submit(pointer:)` → seal → gesture | An old gate/event is delivered with the original producer adapter; guard its origin before the new gate/controller is touched. Then current-origin delivery follows the unchanged source/revision/sequence/ordinal and cancellation algorithm. A test must retain the actual old event and adapter, not fabricate an event with only an obviously unequal revision. |
| `CounterPipelineOwner.swift:226–252,285–300`, gesture capture → sealed action → checked bridge | Captures are created and consumed inside the current pipeline; no host callback exports a dispatch capability. Old scoped pipeline/root/target/carrier values end before the next host. An owned capture retained by the fixture for the adversarial corpus travels with its original immutable origin observation to a closed test delivery seam; reject old origin before dispatch. A current-origin twin invokes the actual existing bridge and validates all four focused checks. The seam cannot construct a new current origin for an arbitrary capture. |
| Existing `CounterHostControl`, typed wake binding and scheduler | Their old callbacks are stopped/drained under the existing eight teardown steps before the control slot is replaced. No old wake binding or host controller is reused. The reuse corpus checks absent wake/scheduler/input eligibility before reconstruction and a fresh binding after activation; complete-union/escape negatives still enforce old scoped host rejection. |

Only trusted selected construction obtains an origin. Fixtures retain immutable
observations for tests, not a new client-callable capability factory. Keep the
control field and origin constructor private to their declaring type and expose
only narrow internal setup/check operations across the named fixture files.
No public/package API or focused module changes. The test seam takes original
producer provenance; direct raw bridge calls remain governed by the caller's
one-runtime scope. Source review must inventory every creation/submit/callback
site and reject a path that recreates current origin from an old pointer alone.

### Required adversarial corpus and accounting

Execute two actual complete Static hosts and two actual complete Dynamic hosts
over one initialized physical owner per pair, preserving original G/C/R/H
addresses, inventory, capacities and extents. Preserve all earlier transaction,
failure, graph, semantic, action and pixel controls. First session publishes,
captures an actual action/event/adapter and stops cleanly. Destroy old scoped
owners; reconstruct fresh outer/control owners; second session publishes the
same finite UI. Explicitly observe equal semantic paths and repeated raw action/
target/presentation/first-sequence values where the contracts allocate them.
Do not use a changed model owner ID or an unrelated unequal raw generation as
the rejection oracle.

Replay original-origin action, normalized input, source callback and copyable
`CounterAdmission` against the live second host at the **same control address**.
Require refusal before queue/cancel/wake/model/dispatch effects; fingerprint
the new queues, pointer/capture state, wake deadlines/counts, context and model
before/after. A current-origin twin for each path must be admitted/dispatched by
the actual runtime and produce the existing independent semantic/pixel result.
Retired old host activation/opportunity rejects before old scope end; scoped
old carrier escape is separately rejected by the existing compiler corpus.
No old host is invoked after consumption or scoped destruction.

Charge the origin field in control, each admission/application snapshot, the
session facts, retained adversarial observation, reconstruction temporaries and
all enclosing/helper frames in the existing physical ledger. Dynamic outer
destruction/reconstruction costs and peaks remain measured obligations. No fit
claim follows from private scalar provenance or sequential host lifetimes.
Failure/overflow/cleanup violation stops; no new trap-recovery or silent serial
reset is selected. Finding 5 remains open pending independent design/source and
later authorized execution evidence; no requirement is deferred.

## Purpose and Boundary

Replace the finite counter's by-value geometry/five-bank transfers with final
physical objects and one exclusive scoped session. SO-01's source is `59d98712`;
SO-02 inspects clean `d8a3d5ff`, which changes only documentation. All source
paths below are current maintained inputs, not frozen Evidence snapshots.

The feature is implementing; SPEC-011/013/015 and their plans stay implementing/
active, P08/R07/T8.1 stay open. This is ITERATION-003 I3-04/I3-05 runtime-derived
counter and four-stack validation, preserving the closed ITERATION-001 analyzer
controls. Full RFC-015 conformance remains ITERATION-004 I4-07. The
[SO-01 necessity allocation](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so01-inventory.md)
is unchanged: every adopted-path safety/fit obligation remains in P08; full
review/integration/conformance residuals remain open. No new deferred idea,
exploration, compiler experiment or production allowance is created.

## Governing Contract

- [ADR-039](../adrs/adr-039-scoped-storage-ownership.md), accepted; ADR-007/008,
  ADR-035/036/038 remain governing, with no supersession.
- [SPEC-011 S11.1–S11.4](../specs/spec-011-interaction.md#s111-scoped-storage-and-state-declarations):
  exact six headers, five-input union, conditional owned state, capacity and
  descriptor exchange, restricted factories, owned compatibility; IN-SO-001–003.
- [SPEC-013 S13.1–S13.2](../specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract):
  final physical owner, initialization prefix, common actual-owner token,
  exclusive session, logical cleanup and accounting; RP-SO-001–003.
- [SPEC-015 S15.1–S15.2](../specs/spec-015-host-configuration.md#s151-construction-transfers-and-retirement):
  complete carriers, consuming retirement, owned-only return and one old-slot
  migration; HC-SO-001–003 and unchanged HC-RD-001–004/HC-001–018.
- Owner tasks [SPEC-011 T12.1](../implementation-plans/spec-011-implementation-plan.md),
  [SPEC-013 T11.1](../implementation-plans/spec-013-implementation-plan.md),
  [SPEC-015 T8.1](../implementation-plans/spec-015-implementation-plan.md),
  [shared P08 SO-02](../iterations/iteration-003-review/rfc-014-implementation-plan.md),
  [handoff checklist](../iterations/iteration-003-review/rfc-015-p08-handoff.md#pre-code-physical-design-note-checklist)
  and [delivery allocation](../iterations/iteration-003-review/rfc-015-delivery-allocation.md).

Existing common coordinator/pipeline cleanup, storage audit and model/capture
lifetime notes remain applicable. This note selects only fixture-private
representation, projection and destruction; it changes no ownership boundary,
protocol associated type, action rule, workload or resource limit.

## Current-Code Context

`RD/` below means `Tests/ContractFixtures/SPEC015/RuntimeDerived/`. Each row
identifies the complete migration, including owned paths intentionally retained.

| Current actual site | Selected replacement / retained obligation |
| --- | --- |
| `RD/StaticCounterEmbeddedBacking.swift`: `counterEmbeddedSlotBytes/Count`, `counterEmbeddedField`, `counterSelectedProfileBacking`, `counterMakeSelectedProfile`, `CounterEmbeddedProfileStorage.init/deinit` | Replace old 30,176-byte layout as a single revision; checked new field layout and original initialization inventory; keep four disjoint caller slots and exact caller byte-count validation. No stride equality with the old inline profile. |
| Same: `workspaceStorage` at 21,812, initialized `interactionStorage: CounterStaticKeys?` at 24,024, control at 26,440, used at 30,168 | Remove old workspace aggregate and old Keys Optional binding, initialization, accessors, take and destructor together. Reserve byte-codec regions, final geometry objects and five bank objects separately. Control gets its own checked aligned extent; never overlays old Keys. |
| Same: `audit(report:)`, `resetAttemptStorage`, `resetAllStorage` | Audit physical owner/owned facts; no `guard let interaction` copy. Session reset uses consumed scoped state; idle reset checks every physical bank empty. Physical owner never resolves Interaction phase. |
| `RD/CounterProfileStorage.swift`: `CounterStaticWorkspaceBacking.withGeometry/measurement`, Static/Dynamic profile init/audit/reset/run | Keep the ordinary owned profiles and `run()` coordinator probes as compatibility controls; introduce separate selected scoped-host profile types alongside them, without retaining duplicate owned Keys/geometry in a selected host. Owned-probe and scoped-host types have separate fields and constructors, not a large enum retaining both layouts. Remove selected host use of `withGeometry` and `interaction.take`; keep owned probe behavior and return path. |
| `RD/CounterGeometry.swift`: `StaticCounterGeometry` and `DynamicCounterGeometry`, every method and initializer | Keep owned adapters for owned probes. New private geometry access delegates the same algorithms using separately initialized typed fields below; do not construct an owned aggregate in the selected host body. |
| `RD/CounterStaticGeometry.swift`: `LocalSemantic`, `QualifiedLayout`, `QualifiedRender` | Retain semantic translation/render behavior. Final Static render object is `QualifiedRender`; final references are separate. QualifiedLayout is an operation-local read descriptor with its current references copy accounted as a temporary. |
| `RD/CounterHostProbe.swift`: `runCounterHost`, `counterCheckRejectedBindings`, `counterRunHostLifecycle`, `p08CounterHost` | Selected host obtains one session, installs cleanup, consumes into supplied, retains six foreign-join negatives and lifecycle corpus. Generic helpers retain complete unions; no `keys` aggregate local or workspace callback. Four selected slots keep graph/host phases sequential. |
| `RD/CounterDynamicHostProbe.swift`: `runCounterDynamicHost`, `p08CounterDynamicHost` | Remove both geometry.take and interaction.take from selected host; use the identical session/retirement/cleanup protocol. Keep complete/partial/nonRetryable plus failure steps 2–7 and owned scheduler controls. |
| `RD/CounterHostOwner.swift`: `CounterHostControl`, supplied init, scoped pipeline init, state init/activate/attachRoot/admit/runOpportunity/quiesce/releasePlatformOwners/resetProfileStorage, owner init and seven activation/eight teardown methods | Generalize supplied/state/owner over exact S15 G/C/R/H set; geometry/Interaction private; add both storage dependencies. Keep current control borrow and activation span. Replace field extraction with consuming inert/active retirement. Control wrapper's existing pointer provenance remains separately bounded by its actual control scope. |
| `RD/CounterDynamicHostOwner.swift`: equivalent supplied/state/owner paths | Same generalization, unions and consuming retirement using actual Dynamic coordinator/scope types. No pointer-erased coordinator or copied fields from dying opportunity. |
| `RD/CounterPipelineOwner.swift`: declaration, both init routes, returnWorkspaces, input dispatch, candidate flags, cleanup/terminatePresentation | Exact suppressed constraints/unions/private fields; operation-only record dispatch. Scoped retirement consumes once after quiescence. Move returnWorkspaces to owned-only extension. Preserve existing per-attempt flags and once-only cleanup; add no parallel transaction state. |
| `RD/CounterStorageMeasurement.swift`: backing protocols/conformances, counterMeasureInteraction, CounterReturnedWorkspaces | Admit suppressed Self on exactly the three fixture backing protocols; replace callback extraction with owned bounded facts. Return carrier and its initializer explicitly require Copyable & Escapable G/C/R/H. |
| `RD/CounterStorageRegions.swift`: geometry visitors, counterVisitInteraction; `CounterProfileStorage.counterValidateBacking` | Replace selected owner size subtraction with explicit physical ledger, separately charge scoped descriptors/state/padding and all retained extents. Preserve owned visitor facts and normative 26 families. |
| `Sources/GiftUIInteraction/InteractionState.swift`, `InteractionOwnedKeyState.swift`: two withBacking definitions; `SPEC013/RuntimeDerived/CycleStorageMeasurement.swift`, `CycleStorageRegions.swift` plus the two RD callers | Remove both APIs with all four maintained callback repairs in SO-03/04, preserving owned Cycle/analyzer/probe returns. Same single state algorithm and conditional owned conformances. |
| `Sources/GiftUIRuntimeStatic/StaticRuntimeExecutionCoordinator.swift`, Dynamic equivalent: init, admission/opportunity getters, takeQuiescedOpportunity | Preserve existing explicit suppressions, consuming three-input union, private setters and lifetime-dependent Optional; scoped retirement must consume that Optional. |
| `RD/CounterRouteEntry.swift`, `CounterGraphProbe.swift`; counter/image checkers; firmware `src/counter_main.c` | Keep actual four routes, graph-first controls, target C roots and workloads; update only selected raw reservation constant/recipe/input registration where necessary. No graph provenance, first-error, action/semantic/pixel oracle weakened. |

The full finite consumer set and transitive/hash inventory are linked in SO-01;
no seventh Interaction protocol or retained scoped dispatcher is introduced.

## Proposed Internal Organization

Add one fixture file `RD/CounterScopedStorage.swift`. All concrete
P08TypedBackingOwner, session/token, access types, descriptor constructors and
concrete assembly body live there. Access types are fileprivate with private
stored fields and constructors; trusted creation is a private nested factory
on the owning type, not a new callable arbitrary-conformer API. Other files
hold only generic supplied/pipeline/host/retired declarations and helpers, under
S15's complete constraints. Concrete selected profile types/aliases, p08CounterGraph/Host/DynamicHost
assembly bodies and host-body specialization move into the new file so
fileprivate access types never need wider visibility. Existing files retain
generic or owned helpers only. The graph uses the selected physical owner for
its unchanged audit/zero-effect controls; it never activates a session. Owned
run() probes retain their separate ordinary profile constructors.

Select these physical forms:

1. **Static Embedded:** the existing caller's four raw BSS slots, freshly laid
   out; typed fields are bound and initialized separately. No live old Optional
   exists. Byte codec payloads remain UInt8, not rebound records.
2. **Static native:** a lexical noncopyable native reservation containing one
   *individual typed Optional slot per physical object*, initially nil; byte
   codec arrays use separate individual Optional<InlineArray> slots. Pin each reservation slot in
   the closed reservation callback before initialization, initialize its T
   payload once, and keep that slot borrow until final destruction. This is
   typed Swift storage, not raw rebinding of a live byte array. No aggregate
   `CounterStaticKeys?` exists. Optional tag/padding and inline byte storage
   remain charged even when nil. No heap reservation or temporary-allocation
   fallback is selected for Static.
3. **Dynamic:** the same lexical typed Optional slots for final Dynamic field
   objects and five existing Dynamic bank objects; existing workspace/bank
   constructors allocate their own bounded payloads. Those exact objects
   remain unique; no copy/COW snapshot is made. Charge actual retained capacity
   including allocator/header/control costs and allocation peaks.

The closed outer reservation callback returns owned Result only. Its mutable
slot borrows keep native addresses stable throughout initialization, all
sessions and final release. Inside that callback a noncopyable physical owner
owns the right to initialize/destroy those slots and no caller can access the
reservation. Embedded's outer caller contract keeps BSS stable through the
same interval. The owner is a small typed descriptor over that reservation;
it cannot be returned from this closed route. Thus native field address
stability does not rely on the optimizer leaving an ordinary returned aggregate
in one location. Before initialization succeeds, a slot can be nil; after
success it is never assigned/replaced until reverse destruction. Idle sessions
mutate the existing payload in place. The owner holds no transaction phase,
revision, candidate-error/key counters, gesture state or host control instance.

Its fixed `InlineArray<14, InitializedEntry>` records only acquired geometry,
byte-region and bank physical identities/types, retained extents, initialization
counts and original addresses/slot selectors. Static needs 14 entries: four
byte regions, five geometry objects and five banks. Dynamic needs nine: four
geometry objects and five banks. Unused entries are explicit sentinels. No
closure, Any or heap list is used. `InitializedEntry` is an owned tagged record
whose switch names each typed destructor. A separate lifecycle enum and owned
session serial exclude invalid transitions; the serial has checked overflow
and is never reused while any session can live. Separately supplied outer
control keeps its current wake/admission/backend state and lifetime.

## Data and Control Flow

The enclosing profile reserves root/semantic/Canvas/control storage and this
physical owner, validates all configured capacities/identity/schema/extents,
initializes, obtains an immutable owned audit, and runs HostAssembly.validate
before activation. The same graph/input provenance and first-error order stay.
No service is activated by physical initialization or audit.

Root→semantic→Canvas scopes remain acquired through existing throwing APIs;
the nonthrowing withP08Storage body is entered only after those acquisitions
succeed. Their catches release the prefix of outer scopes before returning an
owned failure (the existing invariant-failure policy remains for impossible
validated failures). These throws are not a throwing storage-session callback.
At the deepest level control is separately borrowed, activationBacking lives,
and `withP08Storage(backing: &owner)` consumes the session into a trusted body.
The body immediately wraps its current stage in a private noncopyable cleanup
holder and installs `defer { holder.finish() }` before any owned-failure return
or activation. The holder owns exactly one of session/supplied/live-host/retired;
consuming transitions replace that one value. Its stage is cleanup bookkeeping,
not another Interaction machine. It exposes operations/owned reports only.
No escaping cleanup closure or capability-returning getter is introduced.

### Actual typed borrowing and common token

The private factory follows this exact borrow order, subject to compiler proof:

1. Require initialized/idle, validate original inventory and all pair capacities,
   assign checked fresh serial, set active. Copy only immutable typed descriptor
   facts to locals; nothing mutable or borrowed escapes. An active call or
   final-release/reinitialize request is rejected as invariant failure.
2. Hold the function's `inout P08TypedBackingOwner` exclusive access for the
   complete synchronous callback. For every inventory object, nest a typed
   `withUnsafeMutablePointer(to: &typedObject)` scope in initialization order
   (native uses the already pinned individual Optional's non-nil payload;
   Embedded uses the bound T pointee). The four Static UInt8 regions likewise
   have disjoint typed byte borrows. Nested helper bodies return owned Result.
   These are borrows of the real final typed objects, not pointer-variable
   borrows or temporary copies of bank values.
3. At the innermost scope construct one private token with the proposed
   `@_lifetime(borrow owner)` initializer taking
   `owner: borrowing P08TypedBackingOwner`, with immutable owner identity/serial
   copied into the token. That borrow is a reborrow inside the enclosing
   *actual owner's inout access*. No pointer parameter determines token lifetime.
   Snapshot descriptors were obtained before this borrow; owner fields cannot
   be read or mutated while token-dependent accesses live. The pointee/slot
   borrows are to independently owned reserved objects, not to the owner's
   descriptor fields, so they do not overlap this typed owner borrow.
4. Private geometry/C/R/H construction accepts `borrowing P08SessionLifetime`
   and `@_lifetime(copy sessionLifetime)`. Each access retains immutable token
   evidence plus one typed descriptor (geometry retains its field descriptors).
   Token copies convey no mutation permission. Same token/serial and pairwise
   distinct original identities are checked before constructing Interaction's
   one five-input state and failable owned-key wrapper, then P08StorageSession
   with the exact geometry/interaction union. Validated limits make failable
   construction failure an invariant violation, not late physical initialization.
5. Body consumes once, cleans up, returns an owned value; all access/retired
   values die inside the innermost scope. End token, then typed pointee borrows
   in reverse. Only then reaccess owner, check all physical counts/reset state
   and callback quiescence, and change active→idle. The factory never tries to
   recover or call a consumed host/session. A failed cleanup check forbids
   reuse and final release under the existing invariant disposition.

This is the selected construction mechanism, not proven Swift syntax. SO-03/04
must prove the annotated borrow initializer and nested reborrow through the
actual types without `_unsafeNonescapableResult`, lifetime erasure, blanket
suppression, pointer-only lifetime construction or exclusivity disabling. If
the pinned compiler cannot express this mechanism, stop at its exact diagnostic
for independent review; do not silently replace the token with a pointer local.
The trusted unsafe boundary is confined to reservation binding, typed borrowing
and private descriptor use. Supported callers see a concrete closed owner
configuration/body returning owned reports, never an arbitrary conformer,
raw address/base, `_read`/`_modify` capability getter or duplicating reborrow.

## Algorithms and Data Structures

### Final typed field map and reservation algorithm

Each row below is a complete initialized object/array, with independent
address, `MemoryLayout<T>.stride/alignment` and the stated count. All are
owned by the reservation owner from successful acquisition until final release;
all sessions only borrow them. G rows do not own one another's typed storage.
`R0/R1` and `H0/H1` labels are immutable physical identities, not mutable roles.

| ID / initial role | Static final type/count | Dynamic final type/count |
| --- | --- | --- |
| B0 scopes codec | UInt8 × 1,024; alignment 1 | absent; accounted workspace payload |
| B1 text/render codec | UInt8 × 1,056; alignment 1 | absent; accounted workspace/resolved/render payloads |
| B2 live path codec | UInt8 × 20; alignment 1 | absent; plan retained path payload |
| B3 drawing plan codec | UInt8 × 112; alignment 1 | absent; plan retained plan payload |
| G0 layout workspace | StaticCounterLayoutWorkspace × 1 | DynamicLayoutWorkspace × 1 |
| G1 resolved storage | StaticCounterResolvedLayoutStorage × 1 | DynamicResolvedLayoutStorage × 1 |
| G2 reference table | InlineArray<64, SemanticRecordReference?> × 1 | absent; Dynamic resolved storage owns references |
| G3 plan | StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace> × 1 | DynamicDrawingPlanWorkspace × 1 |
| G4 render | QualifiedRender × 1 | DynamicRenderWorkspace × 1 |
| C0 candidate records | CounterStaticCandidate × 1 | CounterDynamicCandidate × 1 |
| H0 candidate hits | CounterStaticHits × 1 | CounterDynamicHits × 1 |
| R0 prepared records | CounterStaticCommitted × 1 | CounterDynamicCommitted × 1 |
| R1 committed records | CounterStaticCommitted × 1 | CounterDynamicCommitted × 1 |
| H1 committed hits | CounterStaticHits × 1 | CounterDynamicHits × 1 |

Five distinct bank *objects* are selected, each with logical capacity two.
StaticTwo objects already own two initialized Optional element slots and their
single count/capacity fields. They are not an Interaction state. Dynamic
objects own their existing uniquely retained Array payloads and single counts.
The access descriptor has bank ID, typed address, complete reserved extent and
immutable logical capacity; count is read/mutated only in that bank object.
No count is cached in the adapter, so exchanging its complete descriptor also
selects the right count without duplicate mutable count storage. Immutable
retained-capacity facts accompany the descriptor when roles change.

For Embedded build the layout from actual MemoryLayout values at the pinned
compiler/target, rather than copying historical offsets. Order the outer
fields as current limits/root/semantic control/semantic element arrays/Canvas
control/Canvas entry, then B0–B3, G0–G4, C0/H0/R0/R1/H1, control, used. Owner
and inventory descriptors remain small lexical Swift values and are separately
charged to their enclosing stack path; if any moves into caller storage, its
actual field is added before the layout is frozen. The outer initialized prefix
records its own fields; it never duplicates a geometry/bank destructor entry.

Use this deterministic checked algorithm for every requested region:

```text
product = count.multipliedReportingOverflow(by: stride)
remainder = cursor % alignment
padding = remainder == 0 ? 0 : alignment - remainder
start = cursor.addingReportingOverflow(padding)
end = start.addingReportingOverflow(product)
require count >= 0, stride >= size, alignment > 0; no overflow
require end <= suppliedByteCount and base+start address arithmetic does not overflow
require absolute address % alignment == 0; half-open regions pairwise disjoint
cursor = end
slotBytes = checked roundUp(cursor, maximumFieldAlignment)
totalBytes = checked slotBytes * 4
```

All additions/conversions, including absolute addresses and UInt32 audit fields,
are checked; no `offset + stride * count` unchecked precondition remains.
Retained supplied extent may exceed required object extent. Charge the full
extent and classify surplus/alignment/tail as padding, never as extra elements.
An empty or misaligned reservation fails before binding. Freeze numeric offsets,
count/stride/alignment and firmware byte constant from the first authorized
current-target layout transcript; this note supplies the exact derivation, not
guessed numeric ABI sizes. SO-04 ends at a **provisional source checkpoint**:
the checked formula, typed field order, prefix ledger and provisional C constant
are reviewable, but numeric layout and SO-04 acceptance stay open. The existing
SO-07 nRF counter route registers bounded target-compiled layout facts in its
current P08CounterRuntime object: each original field's offset/count/size/stride/
alignment, cursor end/max alignment, rounded slot extent and four-slot total.
The remaining-completion realization replaces the proposed literal data table
with 129 constant-return measurement roots. Swift's documented `@section`
constant initializer forms do not include this checked layout initializer;
its folding into literal section data is not assumed. Each root queries the
same private `counterVisitEmbeddedLayout` checked traversal and exactly converts
its result to UInt32. That single traversal contains all 25 typed queries/counts
in the original order. Its synchronous nonescaping visitor receives only copied
numeric region metadata. Runtime construction collects those regions in its
existing InlineArray; measurement selects a scalar without constructing that
array. No second numeric layout or type list is maintained. Inlining hints on
the traversal and its append operation expose the derivation to optimization;
they do not prove folding or a resource bound. No measurement root runs and no
global initializer, raw layout substitute or alternative numeric ABI is added.

The read-only extractor's terminal leaf must initialize r0 with an immediate
(`movs`, `mov.w` or `movw`), optionally replace its upper half with `movt`, then
return with `bx lr`, consuming the entire body with no relocation. The reviewed
final correction permits at most **two** whole four-byte unconditional Thumb
`b.w` tail thunks before that unchanged leaf; these preserve LR and introduce no
call, stack or memory effect. Object thunks require the exact canonical encoded
start addend (-4), one `R_ARM_THM_JUMP24` REL relocation at offset zero, and the
actual linked symbol-table/index resolving a unique defined Thumb function.
Final ELF thunks require signed displacement decoding with PC = instruction
address + 4 and a unique function-start destination, with no residual relocation.
Every body, edge, relocation identity and leaf is recorded separately for the
object and final ELF. Reject longer paths, cycles, interior/ambiguous/undefined
targets, overlap or arithmetic overflow, calls, indirect/conditional branches,
loads, stack work, initialization templates, unknown instructions and extra bytes.
The exact root inventory belongs
only to the actual object/firmware, not repeated diagnostic-control objects.
Require all 129 exact global defined function roots. Separately classify at most
**258** defined STB_LOCAL functions under the measurement prefix, recording their
identities, bytes, Thumb/executable bounds and duplicate checks; none is a fact
root. Names vary under compiler merging and confer no authority. Extra exported,
weak, undefined or data symbols, missing roots and duplicates remain failures.
A root reaching any helper still needs the complete bounded semantic proof;
classification cannot hide a bad root or admit arbitrary helper effects.
The existing SO-08 supported firmware invocation retains those roots through
explicit linker undefined roots and section GC; no RAM pointer table is needed.
Read-only extraction from those exact artifacts supplies
`so07-layout-facts.json` and `so08-layout-and-c-reservation.json` in the new
immutable receipt. The latter compares the facts with the actual C
`counter_backing.0` symbol (the exact supported GCC spelling), its map ownership,
size/alignment and source constant in
`firmware/nrf52840/applications/signal-analyzer-static/src/counter_main.c`.
Independently verify every checked field bound/disjoint interval and rounded
summary. The full actual C reservation remains charged: its four supplied slot
origins use the source slot stride, which must be divisible by the measured
maximum alignment; its base must satisfy both source and measured alignments.
Required slot extent may be smaller than supplied slot spacing. Record their
surplus without silently using the required extent as the physical spacing.
Charge all actual retained measurement code, duplicate bodies, linker padding
and metadata in the image/stack accounting; an accepted immediate root has no
stack work, but this alone establishes neither total flash cost nor fit.
No standalone probe/compiler/IR capture is added. These named derived reports
have no current output path or result until the authorized drivers emit their
actual receipt. Missing/unfolded roots or any mismatch reject numeric evidence;
they do not authorize a broader decoder, earlier capture or source variant.
C-constant correction/recompile requires a separately specified allowance.
The remaining-completion correction 1 supplies that allowance for the
[observed extent failure](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-remaining-layout-initial-diagnosis.md):
actual target checked-layout disassembly requires 32,000 bytes per slot, replacing
the insufficient 30,176-byte provisional input consistently in Swift and C.
Four retained slots therefore charge 128,000 bytes, an increase of 7,296 bytes.
Semantic capacities, all region counts, workload, alignment and resource ceilings
are unchanged. This diagnostic-derived minimum is a corrected source input;
successful strict numeric materialization, final C-symbol comparison and fit
remain unproven until the registered current artifacts establish them.
Only matching current-target evidence can validate numeric SO-04 acceptance;
SO-08 cannot claim fit without linked construction/IRQ/resource attribution.

Native fields use the compiler's actual typed layout; record addresses/deltas,
Optional tag/payload padding, byte arrays, outer reservation padding, owner/
inventory descriptor and stack extents. There is no manual pointer arithmetic
into Optional payloads. The language's typed inout unwrap determines the
payload address; a nil slot never enters a session. These costs may exceed the
Embedded raw layout and must be measured separately.

The grouped suite correction wraps only native Static G4's Optional in a private
typed container with a UInt32 tail field. Actual native evidence found C0 reusing
four bytes of G4's claimed Optional stride. The tail occupies that reuse location;
it changes neither G4's count/stride nor the overlap/retained-extent rules. The
factory checks wrapper size equals stride, covers the Optional's full stride,
preserves alignment and contains the actual typed slot range, using checked
address arithmetic. No universal 40-byte ABI is assumed. Both whole-wrapper and
slot borrows enclose the original synchronous reservation. The existing metadata
formula charges the complete reservation stride minus original slot extents, so
any wrapper/tail/outer-layout delta is charged once; helper locals, captures and
frames still require emitted accounting. Embedded raw layout is unchanged. This
is a source realization pending current native/ARMv6 validation, not numeric fit.

The Static descriptors share existing byte *codecs*: layout and resolved use
B0/B1; render uses B1 under its existing non-overlapping phase ranges. They do
not overlay live typed Swift records or bind those bytes to workspace types.
One private geometry access serializes those algorithms as today. G0/G1/G4
objects themselves have disjoint typed addresses; their raw byte-codec ranges
and phase/published marker obligations remain documented and tested. A changed
codec overlap would stop this design, rather than treating disjoint descriptor
addresses as proof that payload use is safe.

### Initialization and exact successful-prefix unwind

Validate schema/model/semantic owner identities, all extents, distinct bank IDs,
configured capacities and pair equality before acquiring objects. Initialization
order is B0–B3, G0–G4, C0,H0,R0,R1,H1 for Static, and G0,G1,G3,G4,C0,H0,R0,R1,H1
for Dynamic. The outer profile initializes its non-storage-session fields first;
its failure cleanup encloses this initializer and destroys its own successful
prefix only after any storage prefix has been unwound.

- Embedded B rows initialize UInt8 cells, counting each completed cell; no
  BSS-zero assumption. Native B rows install one complete zero-initialized
  InlineArray in each initially nil typed slot; the typed initializer owns its
  temporary until installation, then the inventory owns the whole array. There
  is no second initialize over live native cells. Four entries retain exact
  element counts; native unwind clears the acquired array Optional once.
- G0/G1 call their current failable constructors over already acquired codecs;
  G2 constructs its one nil reference table; G3 constructs current drawing base
  then its StaticRecordDrawingWorkspace wrapper; G4 constructs the current
  Static render base then QualifiedRender wrapper. Dynamic calls each current
  workspace constructor separately using unchanged limits/maximumSemanticRecords
  126. No full StaticCounterGeometry/DynamicCounterGeometry temporary is made.
- Each bank calls its existing single-bank initializer at capacity two. Its
  InlineArray sentinels/Array reservation are initialized by that type. Install
  only a successful complete T, then append its inventory entry. Fault-before-
  install destroys the constructor temporary and leaves no acquired T. Fault-
  after-install records T first so unwind owns it. Existing Dynamic allocation
  failure trap policy is unchanged; no recovery from an allocator trap is claimed.
- On ordinary validation/constructor/fault failure, destroy the recorded prefix
  in reverse: each complete T once, each array's exact successful element count,
  clear entry/count after destruction, return an owned failure with owner reserved.
  Native clears only the acquired per-object Optional to nil; unacquired nil slots
  are never unwrapped. Embedded deinitializes only acquired typed objects, then
  leaves their binding reserved for the same T; final reservation release occurs
  after destruction. No old live type is rebound.

Constructor temporaries are real costs: each workspace/base/wrapper, one
InlineArray<64,...> initializer, one StaticTwo bank including its InlineArray<2,...>,
Dynamic constructor/Array reservations, final Optional assignment and any compiler
writeback, owner/inventory copies, geometry access descriptors, five access values,
InteractionState then failable Optional owned-key result, session/supplied/pipeline/
coordinator/state rewrites and quiesced Optional/retirement. Nested allocation
or inlining can overlap them with the enclosing frame. Final destination syntax
is not evidence of scalarization, stack placement or smaller peak.

### Descriptor exchange and existing transaction semantics

P08CandidateAccess delegates C0 operations directly; P08CommittedAccess and
P08HitAccess delegate record/append/reset to their selected typed object. Their
private descriptor uses a typed Static/Dynamic variant (Dynamic case absent
under Embedded), never an untyped pointer/erased bank. Geometry likewise holds
private typed profile variants. No selected access calls the owned bank's
`exchangeContents`, because that swaps payloads. Instead exchange swaps the
complete private descriptor of two compatible accesses, retaining each access's
common immutable session evidence and logical capacity.

Before session acquisition, require C capacity covers action limit, equal R
logical capacities cover actions, equal H logical capacities cover hits, and
each full extent covers its type/retained element capacity. Same-owner/serial,
profile, distinct bank IDs and expected R/H pairing are construction invariants.
finishCandidate keeps its existing identity/generation/capacity preflight. No
new fallible check is inserted between accepted offer and R exchange, H exchange,
revision assignment. Those serialized operations permit no observer, callback,
allocation or reentry. Counts travel with the selected physical bank; unequal
counts are deliberately tested. Reset then empties the former committed banks.
Refusal/discard swaps nothing and retains committed routing/revision as today.
Complete SemanticCompleteIdentity values stay independently owned in every
record; no semantic reference or index replaces a key.

Unequal sufficient physical reservations are admitted: use a test reservation
with one R or H extent larger than its required typed-object extent, capacity
still two, retain and charge the full surplus. Dynamic allocator capacity may
also differ. Neither surplus changes logical capacity; below-two physical
capacity fails before session, unequal logical R/H pair capacities fail,
equal-two succeeds and above-required extents succeed without clamping workload.
Original physical inventory/destructors never follow mutable role labels.

## Lifecycle and State

Physical states are reserved→initialized/idle→session-active→initialized/idle→
released. Failure of checked initialization returns reserved after unwind;
reinitialize initialized/active or release active is invalid and cannot overwrite
or destroy objects. Final release of idle empties original inventory in reverse,
then ends reservation borrows and reservation storage. Repeated release is an
invariant failure; deinit asserts no active session and performs release only
if it still owns initialized objects. No destructor infers logical teardown.

Each fresh session starts all banks empty with initial physical role assignment,
new Interaction state (idle, nil limits/error/revision, zero key counters/staging),
reset geometry and cleared pointer capture/source/admission/wake. Persistent
identity/generation allocators retain their existing exhaustion/stale-action
semantics; session acquisition cannot resurrect an old captured action.

### Complete carriers and consuming retirement

Use S15's complete suppressed G/C/R/H constraints in both supplied types,
pipeline, both states/owners and CounterRetiredStorage. All consuming init
unions include geometry+Interaction as well as model/root/semantic/values and
scopedControl (or borrow control for the trusted raw route). Session.intoSupplied
consumes self and all five existing scoped inputs with the exact six-part S15
union; it transfers the private fields directly inside the trusted file.
P08StorageSession init depends on geometry+interaction. No convenience init,
helper return, state case or generic helper loses a dependence.

Both host state enums use inert(supplied,activationSpan), active(coordinator,
optional cache ticket,activationSpan), retired(CounterRetiredStorage,activationSpan).
All current mutating switch-consume rewrites retain `@_lifetime(self: copy self)`.
Live host init retains supplied+activationSpan. Active retirement releases the
cache ticket through models at its current pre-quiescence point; coordinator
quiesce stops/drains/finalizes, then consumes `takeQuiescedOpportunity()`'s
lifetime-dependent Optional once. Its `.some` pipeline is consumed directly by
`retireQuiescedStorage()`, never `let semantic = returned.semantic.borrowedStore()`
from a dying carrier. Pipeline transfers its owned semantic/geometry/Interaction
fields into CounterRetiredStorage with the complete union and ends remaining
model/root/value/control/endpoint obligations after quiescence. Inert supplied
uses consuming retireInertStorage without constructing a coordinator.
Retired reset is semantic.resetAfterQuiescence→geometry.reset→Interaction.resetAllStorage,
with complete `self: copy self` dependence. Current terminatePresentation
already clears committed routing with interaction.resetAllStorage before
root.shutdown. Preserve that terminal invalidation; the later mandatory retired
Interaction reset observes empty banks and never resolves another candidate or
destroys a physical bank object. Distinguish these idempotent empty resets from
once-only candidate resolution, host teardown and physical T destruction in the
transcript. Per-attempt geometry.reset likewise does not release a G object.
Retired stays scoped until host/body
ends, even after logical teardown step eight.

### Every body return and cleanup owner

| Reachable return / stage, both profiles | Cleanup performed by the trusted body's stage holder before its defer ends |
| --- | --- |
| Pre-host/session failure injected before intoSupplied | Reset geometry and Interaction in the held session, release only acquired outer scopes; no endpoint/coordinator/host teardown invented. Return owned failure. |
| Supplied constructed; host construction/validated factory refusal | Consume supplied into inert retired storage, reset semantic→geometry→Interaction; end control/model/root/value lifetimes. No coordinator extraction. |
| Foreign-join negatives return failure while inert | Preserve supplied unchanged and zero construction/client effects; continue same host or retire inert on an owned early return. Existing snapshot comparisons remain. |
| Activation fails before runtime or at steps 1–7 | Stop/refuse application delivery and input, detach installed observations and stop source if acquired, cancel pointer/callbacks, drain callbacks; release cache ticket if held; quiesce constructed coordinator once and finalize active attempt. Retire active or inert according to actual acquired stage, release registrations/platform/application owners, reset retired storage, invalidate report. Respect existing activation progress and no duplicate teardown. |
| Candidate fails at semantic/layout/Interaction/drawing/render/offer | Existing RuntimeCompletePipeline cleanup resolves each begun candidate once, releases read/frame pins and resets attempts. Body holder does not repeat per-attempt resolution. On early body exit it quiesces/tears down host once and retires/resets. |
| Accepted commit; retryable/nonretryable refusal; idle no-work | Existing pipeline commits/exchanges or discards without exchange and finalizes once. A continuing body retains live host; a returning body takes the same full shutdown path. No special successful-return escape. |
| Normal lifecycle helper return; repeated host.teardown; failed reactivation | Perform/observe eight-step teardown once and verify unavailable admission/input, detached observations, no cache/pins/registrations/pending candidates/callbacks. Holder recognizes completed teardown, ends scoped host/retired value; does not replay steps. |
| Body returns owned report/checks, then next session | Retired/access/activation-span scope ends; factory ends all typed borrows, verifies empty physical banks/reset geometry and only then idle. New session restores initial role assignment with all banks empty. |
| Final reservation exit | Owner destroys each original G/bank/B entry once in reverse; outer profile destroys control/Canvas/semantic/root/limits only after all dependent users end; reservation/backing ends last. |

The holder's finish must be implementable for every case before source acceptance;
no `guard return` can precede its installation. It consumes an Optional stage
by switch/take once; any owned failure report is stored separately. The existing
per-attempt booleans, phase machine, semantic store and Interaction state remain
the only logical authorities. Stop/drain and pin/registration assertions are
real cleanup checks; a diagnostic log or compiler nonescape result cannot stand
in for them. Traps and throwing-body recovery are outside this contract.

## Runtime Profiles and Platforms

Static and Dynamic use the same Interaction transaction algorithm, descriptor
exchange and cleanup order. Existing owned Static/StaticSix/Dynamic aliases and
Cycle/analyzer retained dispatchers remain owned. Native owned coordinator
probes retain their returnWorkspaces route with explicit Copyable & Escapable
constraints; selected scoped hosts return only owned counts/reports. Auditing
selected storage cannot temporarily copy a Dynamic geometry/bank to measure it.

The closed factory excludes aliases structurally: native reservation is private,
noncopyable, pinned and unavailable to callers; Dynamic arrays/workspaces are
constructed directly into unique slots and never exported/copied. No COW alias
is shared with an owned probe. Embedded validates distinct slots/ranges and
excludes service/IRQ callbacks from bank access until stopped/drained. Calls
into source/repository/display cannot reacquire the owner; active flag and
existing host/pipeline reentry checks reject attempted synchronous reentry.

Hold actual typed Swift accesses throughout. Compile-time exclusivity rejects
provable overlaps; Swift runtime exclusivity remains enabled for unresolved
ones. Record actual compiler enforcement/flags for macOS Static/Dynamic, Pi
Dynamic and Embedded Static independently. Runtime trap tests run only on native
routes with positive twins; cross-target compile/inspection is not execution.
If an unresolved target overlap has no actual runtime enforcement, redesign its
private structural borrow to make the overlap statically impossible; do not
mark it proved from a flag or an unexecuted negative. There is no unchecked
Sendable, Task/async transfer, disabled-exclusivity or reference erasure route.

## Resource and Failure Behavior

The physical ledger has two axes: immutable original physical ID/address/extent/
destruction and mutable transaction role→descriptor/count. Before/after swaps
physical totals are identical. Charge every G/B/bank field and its padding,
Optional tags on native, owner/token/descriptors/inventory/lifecycle/serial,
Interaction state/control and each supplied/pipeline/coordinator/host/retired
carrier. State metadata counts once; do not subtract adapter MemoryLayout as
though it were the owned bank. Surplus retained bytes count even with zero records.

Replace withBacking consumers with owned measurement facts: concrete owned
banks expose bounded physical extent/count/stride/alignment facts; state combines
owned facts without exporting a capability or invoking a caller on bank storage.
The selected owner builds equivalent facts from its original inventory; role
measurements derive from its private descriptor mapping. Inline identity bytes
are partitions of record reservations, never additional allocations. Geometry
facts account individual G fields and B regions rather than an imaginary
StaticCounterGeometry aggregate; Dynamic existing retained-payload visitors
remain value-only instrumentation. counterValidateBacking reconciles all 26
families with the physical-region transcript and checked UInt32 conversions.

SO-08 must attribute actual linked Pi/nRF images, maps and disassembly, including
C entry/caller and caller backing, Swift construction closure, final-region
initializer/Optional/base/wrapper temporaries, nested token/borrow helpers,
closure context/capture copies, state switches, owned failure returns and
consuming retirement. Enumerate feasible call paths, use each real frame,
add ABI spill/save/alignment and feasible IRQ nesting including preempted frame,
IRQ wrapper/hardware stack and handler callees. Sequential graph and host phases
are maxima, not sums; simultaneously live caller/backing/construction/helper
frames are summed. Missing/unresolved indirect-call/IRQ paths stay unknown,
never zero. Preserve all RAM/flash/static-heap/Dynamic allocation, workload,
source/admission/three model-transition banks and timing limits.

The last qualified nRF link at `63e717d1` reports flash 299,332, RAM 152,320,
caller BSS 120,704 and heap zero. Its enclosing construction frame at 0x17a48
reserves **58,648 local bytes against 27,648**, already failing before caller/
callee/IRQ additions; rejection/lifecycle helpers reserve 4,768/8,392. This
note replaces none of those measurements. New slot size, native stack costs,
Dynamic peaks, compiler composition, exclusivity and complete fit are unproved.

## Test and Diagnostic Seams

All are required evidence, not current passes. Keep SO-01's independent action,
semantic, pixel, graph first-error, join/wake, rejected-admission/timestamp and
old compiler-negative causes. Each new negative has a matching successful twin
with only the forbidden operation/input changed.

| Criteria | Focused evidence at SO-03–08; every row remains unmet |
| --- | --- |
| IN-SO-001 | Six exact headers; state five-input initializer; owned-key failable Optional; conditional owned copy/escape; each C/H0/R0/R1/H1 independently lifetime-limiting, direct and generic; four pinned profiles. |
| IN-SO-002 | R/H address+count+extent+role transcripts over repeated unequal-count commits; refusal/discard no exchange; equal logical/unequal sufficient extents; below/equal/above/unequal capacity cases; semantic reuse, complete keys, generation/stale-action/first-excess outcomes. |
| IN-SO-003 | All 171 tracked caller dispositions refreshed only for changed source; four withBacking caller repairs; owned analyzer/dispatcher/Cycle/native-return compatibility; private construction/extraction/arbitrary-conformer negatives; owned facts reconcile every physical bank. |
| RP-SO-001 | Numeric current-target layout, original inventory and byte ledger; injected failure before/after every T acquisition and at array prefixes; exact reverse successful-prefix destruction; initialized address exactly once; old Keys Optional absence; unequal retained extent accounted. |
| RP-SO-002 | Both profiles' every cleanup-table return, all seven activation failures, every candidate failure/refusal/commit, consuming coordinator Optional and retirement, repeated sessions and final release; statically rejected overlap and separately classified native runtime-exclusivity traps. |
| RP-SO-003 | Four full carrier matrices; linked Pi/nRF artifact/ABI/allocator/RAM/flash and complete feasible stack+IRQ ledger, Static zero heap and matched bounded Dynamic costs. |
| HC-SO-001 | Actual session→supplied→pipeline→coordinator→host→retired chain; geometry, five banks, model/root/semantic/value/control and activation span each independently; copy, use-after-consume, escape, Optional/tuple/generic/closure erasure, owned-only returns, construction/extraction, escaping/Sendable/task/async and overlap controls. |
| HC-SO-002 | Complete current→new sites above; initialization/body-return/repeated-session transcripts and backing last; same provenance/capacity validation before activation; old independent action/semantic/pixel controls unchanged. |
| HC-SO-003 | Fresh exact caller/source/compiler/macro/route identities, all four registered finite routes and early target images, full resources; independent Strong P08 exit. HC-RD-003 stays unmet until measured passing replacement; P09–P12/hardware/timing stay separate. |

Counters/logs are immutable observations and never semantic controls. Record
physical destruction IDs independently from role IDs after many exchanges.
Fault injection is confined to fixture acquisition seams, never used in a
production path to skip initialization, cleanup or workload.

## Rejected Implementation Alternatives

Retaining a second selected owned Keys/geometry beside scoped accesses duplicates
storage/control and invalidates measurement. Copying Dynamic arrays to freeze an
audit introduces COW aliases. Calling owned exchangeContents copies/swaps bank
payloads instead of role descriptors. A pointer-local lifetime token loses the
actual owner. Native raw rebinding of initialized InlineArray bytes or a heap
fallback reservation does not establish the selected Static typed/zero-heap
contract. A full aggregate initialize(to:) for geometry/Interaction hides the
same enclosing-frame risk. These are rejected private realizations; the accepted
architecture's rejected alternatives remain in ADR-039.

## Open Implementation Questions

The representation and cleanup mechanism above remains the reviewed direction.
The [accepted applicability disposition](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so02-execution-proposal.md#accepted-owned-analyzer-applicability-disposition-evidence-unresolved)
preserves both pre-existing analyzer factories unchanged and keeps their actual
model/root/target/factory integration and owned-return evidence mandatory and
unresolved in ITERATION-004 I4-07 with the existing separate P09 handoff. The
independent SO-03 readiness check passed; only the recorded one-native-invocation
slice is authorized. Shared owned dispatcher and all six operation consumers
remain selected coverage. SO-03 uses an ordinary owned measurement protocol and
fixed owned facts, with concrete bank conformances and four mechanical owned
helper bounds; no seventh scoped protocol/storage requirement/state ledger is
introduced. The future scoped owner supplies physical facts from its original
inventory. Compiler acceptance
of the common-token nested borrow, private factory access control, native typed
Optional-slot projection/address stability, full state/carrier unions and
consuming cleanup holder is unproved. Numeric ABI layout, constructor/writeback
stack behavior, Dynamic allocator peaks and all target fit/IRQ attribution remain
unproved. They are required implementation evidence, not deferred correctness
work or permission for a new exploration. An implementation difficulty is not
permission to change the contract; the exact forbidden fallback or diagnostic
stops the affected task for independent review/upstream routing.

## Code and Evidence Links

- [P08 dispatch/receipt](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md#so-02-physical-design-dispatch--2026-10-13).
- [SO-01 inventory](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so01-inventory.md)
  and [tracked caller/source index](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so01-caller-index.md).
- [Bounded SO-03 packet; later slices remain proposed](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/so02-execution-proposal.md).
- [Current Embedded backing](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/StaticCounterEmbeddedBacking.swift),
  [geometry](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterGeometry.swift),
  [Static adapters](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterStaticGeometry.swift),
  [physical measurement](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterStorageMeasurement.swift),
  [assembly](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterHostAssembly.swift).

The original SO-02 checkpoint described proposed file/types; subsequent frozen
source now contains them. The addendum above is the current derived direction
for the remaining repeat-host finding; independent Strong design review precedes
any separate bounded source allowance. All acceptance criteria/statuses and
historical budgets remain unchanged. FW-037/I4-06 remains the separate Core-wide
assessment.

## Deferred and Follow-up Work — validation cost

[FW-038](../future-work/fw-038-scoped-contract-validation-cost.md) preserves the
question of reducing repeated scoped compiler validation cost after correctness
evidence is recorded, without weakening lifetime, positive/negative or profile
coverage. The current registered driver and resource gates remain unchanged.
