# P08 physical representation and ownership assessment

Current implementation boundary: **measured sizing/compilation PASS; resource FAIL**.
[Independent current result review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-measured-sizing-independent-resource-review.md)
verifies 71,088 stack + 138,880 retained backing = 209,968 > 196,608 governed RAM.
Full controls/image stop for this realization; complete peaks/current image remain
unproved. The design review below remains historical; no new source variant,
resource amendment or fit acceptance follows. P08 and nine SO criteria remain open.

Historical design status: **focused independent DESIGN PASS at `26872845`; G01–G03 closed at design scope**.
[Focused reassessment](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-physical-representation-independent-design-reassessment.md)
recommends the concrete bounded source package within existing authority. No
implementation/repair allowance or fit result is created.
[Independent assessment review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-physical-representation-independent-assessment-review.md)
identifies callback-exclusivity, slot ownership/reset and physical/observation
obligations addressed below; no source candidate executed.
Authority is accepted ADR-039 and implementing SPEC-011/013/015, not this note.
The [assessment activity](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-physical-representation-assessment-activity.md)
records authorization. The preceding implementation allowance remains closed at
2/2. P08 fit remains rejected; this assessment creates no repair allowance.

## Actual cause

The frozen final object has a feasible **66,864-byte** stale-action path, with
separate construction 34,800, current-action 60,512 and cleanup 43,848 lower bounds.
[The immutable result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stage-realization-final-result.md)
includes source predicates, exact symbols, section-qualified BL relocations and
caller frames. These are lower bounds, not execution measurements or maxima.
Root/helper splitting reduced some costs, but consuming and borrowing operations
still materialize large aggregate homes. Another annotation-only candidate has
no demonstrated reason to remove them.

One diagnostic-only module compilation, with the original compiler/flags/imported
modules and original source plus scalar roots in a temporary copy, supplies the
missing target type ledger. It constructs no objects, links/runs nothing, and
cannot replace acceptance evidence or the frozen stack object. It exited zero;
all 120 roots have strict constant-return proofs. The original diagnostic parser
wrongly required STV_DEFAULT. Actual roots are exactly STB_GLOBAL/STT_FUNC/
STV_PROTECTED; requiring that exact visibility fixes inventory only. The unchanged
strict byte/relocation/alias/tail decoder proves every fact. The original decoder,
failure reproduction, actual symbol identities, full proofs and command receipts
are [preserved together](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/physical-representation-diagnostic/README.md).

| Actual target type | Size | Stride | Alignment | Meaning |
| --- | ---: | ---: | ---: | --- |
| Pipeline | 3,532 | 3,536 | 8 | Main payload of active coordinator |
| Coordinator | 3,860 | 3,864 | 8 | Pipeline + binding 272 + admission 50 + packing |
| Mandatory host state | 3,889 | 3,896 | 8 | Inert/active/retired payloads, ticket, span, discriminator |
| Host owner | 4,439 | 4,440 | 8 | State + application + assembly and flags |
| Host / Optional host | 4,808 / 4,808 | 4,808 / 4,808 | 8 | Optional introduces no extra size here |
| Endpoint | 1,868 | 1,868 | 4 | Inline endpoint/session/recording payload |
| Tiled endpoint / adapter / session | 1,862 / 1,728 / 578 | 1,864 / 1,728 / 580 | 4 | Actual raster pipeline, not bank descriptors |
| Full recording sink | 1,148 | 1,148 | 4 | Includes 64 Optional glyph records |
| Complete identity / Optional identity | 206 / 206 | 206 / 206 | 2 | Entire bounded owned path; no Optional size overhead |
| Geometry access | 52 | 56 | 8 | Scoped descriptor, not inline geometry backing |
| Candidate / committed / hit access | 50 / 54 / 54 | 56 / 56 / 56 | 8 | Five original-bank descriptors |
| Shared Interaction wrapper | 318 | 320 | 8 | One transaction state and the five accesses |
| Supplied / retired carrier | 758 / 470 | 760 / 472 | 8 | Retained original scopes, not the active endpoint |
| Assembly / report / endpoint configuration | 474 / 347 / 120 | 476 / 348 / 120 | 4 | Owned validation/configuration metadata |
| Reuse fingerprint | 1,404 | 1,408 | 8 | Full logical baseline; not a 19KB logical snapshot |
| Original CounterControl | 4,200 | 4,200 | 8 | Existing final-region control owner |

The full 40-row numeric ledger is linked in the packet. Counts below use measured
member data sizes, not invented offsets or an aggregate packing formula:

- `CounterPipelineOwner.endpoint` contributes 1,868 bytes. Four independent
  `rootIdentity/actionIdentity/candidateRootIdentity/candidateActionIdentity`
  Optional complete identities contribute 4 × 206 = 824. Together 2,692 bytes,
  about 76% of the pipeline, are private fixture-owned payloads.
- Models 15, root 24, semantic 92, values 14, control pointer 4, geometry 52 and
  Interaction 318 contribute 619 data bytes. Remaining pipeline fields are the
  original phase/IDs/limits/recovery/header/provenance state and packing.
- Coordinator adds 328 bytes to pipeline data size; binding and admission account
  for 322. The coordinator is a direct composition, not a hidden bank allocation.
- Report retention is duplicated at host and owner/assembly levels, but each
  report is 347 bytes, not the main multi-kilobyte source. Validation ledger is
  only 6 bytes. RuntimeActionGenerationAllocator's Identity is a phantom type;
  it does not contain another identity array.

Frozen-object getters independently support the attribution: recording starts at
adapter +580 and endpoint +688; helpers copy 1,148 recording bytes and 1,024 glyph
bank bytes; actual endpoint copies 1,862 and its control pointer is at +1,864.
Each Optional glyph has size 13/stride 16; 64 × 16 = 1,024. The diagnostic agrees
with these original-object facts. It does not prove all future codegen unchanged.
The 19,272-byte stale helper frame therefore includes several carrier/call homes;
it cannot be charged solely to its 1,404-byte owned baseline.

## Authority versus physical choice

| Mechanism and source | Governing clause | Assessment |
| --- | --- | --- |
| `InteractionState` / `InteractionOwnedKeyState` | SPEC-011 S11.1; ADR-039 decision | Exactly five lifetime-bearing accesses, one transaction machine, owned counters and complete independently owned keys are mandatory. No replacement pointer/lease field or second machine in these types. Already compact; leave unchanged. |
| Supplied/pipeline/retired generic scope types | SPEC-015 S15.1 | Preserve original model/root/semantic/values/control, private geometry/Interaction, constructor lifetime unions and consuming retirement. Do not replace scoped accesses with raw state pointers. |
| State inert/active/retired payloads | SPEC-015 S15.1 | Logical and concrete carrier cases are expressly required. A tag plus external coordinator pointer, separate active owner or heap box would need an approved amendment; it is not a private enum refactor. |
| Static/Dynamic coordinators | SPEC-013 S13.1 and scoped coordinator amendment | Keep stored binding/admission/opportunity, getters, consuming initializer and lifetime union. A borrowed global/heap coordinator is not selected. |
| Endpoint + four pipeline identity fields | Counter fixture; ADR-038 construction joins; SPEC-013 ownership/accounting | These owned values are required for behavior, but their current inline placement in every pipeline carrier is not a mandated core type layout. A private physical realization may change only with explicit ownership, reset and measured cost. |
| Control-resident admission controller | `CounterAdmission.controller` | Existing precedent: private `_modify` yields the original typed control field. It avoids another stored controller in admission; it is not a new unbounded pointer capability. |
| Complete physical/resource proof | SPEC-013 S13.2; SPEC-015 HC-SO-002/003 | Every added nested control field, four slot instances, padding and construction/deinitialization temporary must be charged. Smaller carriers or successful linking are insufficient. |

The five banks are already in original final regions and consumed only as scoped
descriptors. Re-externalizing them or erasing their lifetimes does not target the
remaining mass. Complete keys cannot become hashes, prefixes, semantic-bank
references or borrowed paths: candidate rollback and retained dispatch require
independent full values. Existing current/candidate identity distinctions remain.

## Recommended next design: owned runtime payload in original control

Develop **one concrete private physical-storage candidate**, rather than another
helper/attribute variant. Keep all mandatory core/shared types, carrier cases and
scoped fields unchanged. Add five direct typed stored fields to the **existing
original CounterControl region**: the one endpoint Optional and four complete
owned identity Optionals. Treat these fields as one logical slot, never as a
whole-payload inout aggregate. Remove those same stored values from the moving pipeline.
There is one live payload, not a mirrored state or second transaction machine.
The CounterControl physical region is distinct from candidate bank `c0`.

The pipeline continues to own the exclusive logical use of these values through
its original control dependence. No new raw pointer field, lender, constructor
argument, exposed capability getter, protocol relaxation, heap allocation or
global is needed. Only ordinary owned endpoint/key values enter control storage;
geometry and shared Interaction remain in their mandated fields. Existing actual
control provenance/join checks remain authoritative for both constructors.

The next design must spell out this lifecycle before source work:

1. Original typed CounterControl initialization creates an empty runtime slot.
   Before active construction require it empty. Construct the endpoint in that
   final typed field from the same validated endpoint configuration. Complete
   identities start absent. Do not first construct a second full payload local.
2. Pipeline operations access that original field directly, with private typed
   operation/mutation seams where needed. An endpoint offer must not hold an
   overlapping whole-control or whole-pipeline mutation while its synchronous
   producer touches other fields. The existing admission `_modify` is useful
   precedent, not proof of this more complex callback's exclusivity/codegen.
3. Keep `lastFrame` separate: it is the latest accepted-frame oracle. Reusing it
   as in-progress recording would corrupt refusal/pending and zero-effect checks.
   All 64 glyph records, all snapshot fields and positive/negative effects remain.
4. Quiesce/finish transferred frame before clearing the endpoint. Clear exactly
   the single slot before handing off retired semantic/geometry/Interaction.
   Every early activation failure and repeated teardown must reach the same
   once-only disposition; inert paths must not clear an unowned active payload.
   Retirement still resets semantic, geometry, then Interaction, backing last.
   The ordinary owned `returnWorkspaces(checks:)` consumption path must clear
   this same slot too; implicit destruction of the old inline endpoint must not
   become retention until the enclosing control owner eventually ends. Both
   Static and Dynamic host aliases use this shared pipeline implementation.
5. Fresh session/reconstruction must see an empty slot, no stale keys/endpoint
   phase, and original origin/address. Extend owned observations and all relevant
   empty/zero-effect checks to cover the new slot without returning a capability.

This is a proposed within-contract realization using the existing control owner,
not approval to implement it. Independent design review must confirm the original
control lifetime bounds every new operation and cleanup path. If it instead needs
another physical owner, escaping pointer, relaxed protocol or altered state case,
stop and seek the precise SPEC-013/015/ADR amendment rather than hide that choice.

The gain has a concrete physical cause: remove about 2,692 data bytes plus changed
packing from repeatedly materialized pipeline/state/host carriers. It is not a
prediction of a 2,692-byte stack reduction or fit. The cost is retained storage in
each of four original control regions: 4 × 2,692 = 10,768 payload bytes before
Optional/slot packing and alignment. New exact layout may differ and must be
measured; 32,000 is the old derived minimum, not an immutable resource ceiling.
All four slots and the full C reservation remain charged. As illustration only,
adding 10,768 to historical image RAM 159,744 gives 170,512, leaving 26,096 under
196,608; this is neither a new image measurement nor sufficient resource proof.
No stack or total RAM limit is changed. Native Dynamic must use the same logical
slot policy with its actual bounded retained/allocation costs, not a hidden COW
alias or an unreported extra allocation.

## Other options and validation boundary

Compact recording (64 initialized glyph records plus a presence mask) could save
roughly 248 payload bytes versus 64 Optional strides, but needs unchanged complete
observations and has no credible evidence of closing the 39,216-byte path excess.
Sharing the accepted-frame slot would weaken behavior. Eliminating owned keys or
mandatory enum payloads, adding reference boxing, or moving runtime state behind
an unchecked scoped pointer is an upstream contract choice. Raising the stack
alone remains unsupported by the current lower bound and historical RAM arithmetic.
Compiler/toolchain changes are outside this package.

Bounded candidate files: `CounterPipelineOwner.swift` (direct typed fields, constructors,
access/retirement/reset), `CounterScopedStorage.swift` (full lifecycle/reuse
observations, empty checks), and `StaticCounterEmbeddedBacking.swift` plus C
reservation source (only if newly measured complete layout requires it). Keep
`CounterHostState`, both core coordinators, Interaction types and logical capacities
unchanged. Update exact applicability/driver pins only with actual seven-component
source exclusions; changed compiled sources never qualify for reused controls.

First screen after a separately approved source freeze, using the existing recipe:

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --fresh-focused --select-family so07-layout-facts
```

Review actual object path frames for construction, stale rejection, current action
and cleanup, including all caller homes, before expensive corpus/image work. A
required lower bound over 27,648 rejects fit immediately. A promising lower bound
does not pass: all feasible nesting/IRQ and current linked RAM/flash/ABI/zero-heap
proof remain required. Native Dynamic/Static full behavior and exclusivity must
exercise moved initialization/reset, every failure, original producer/namespace
reuse and complete positive twins. Pi ABI/layout and all 384/202 compiler labels,
5 native controls and 26 reuse labels remain required on changed compiled source;
focused screen omissions cannot become complete coverage. No further compiler
experiment is needed to finish this assessment; source review precedes any candidate.

Recommended decision for the next package is therefore this original-control
payload realization with unchanged contracts/ceilings, rather than a budget
increase or new protocol ownership model. Its retained-memory tradeoff is real
and explicitly charged; fit remains an experimental outcome. If independent
design review cannot establish exclusive original-control ownership, the minimal
upstream question is permission for a distinct typed endpoint/key workspace and
its lender/retirement contract in SPEC-013 S13.1 and SPEC-015 S15.1. That fallback
is not selected here and must not silently change the mandated state payloads or
SPEC-011's six named scoped protocols.


## Concrete source design completing G01–G03

This section completes the gaps from the
[independent assessment review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-physical-representation-independent-assessment-review.md).
It supersedes the earlier conceptual nested-slot wording. These are proposed
source signatures/operations, not compiled syntax or an implementation allowance.

### G01 — stored-field projection and callback map

Proposed direct stored fields in `CounterControl` are `runtimeEndpoint:
CounterEndpoint?`, `runtimeRootIdentity`, `runtimeActionIdentity`,
`runtimeCandidateRootIdentity`, `runtimeCandidateActionIdentity` (each the exact
`SemanticCompleteIdentity?`), `runtimeSlotPhase` (vacant/installing/installed/
quiesced), `runtimeSlotOwner: UInt64?`, and `runtimeLastOwnerSerial: UInt64`.
No enclosing `RuntimePayload` aggregate, proxy reference or additional storage
owner is introduced. Keys are independent complete values, not references into
recording/semantic storage. Stored pipeline counterparts are removed; private
owned get/set key operations address just the corresponding stored control field.
The pipeline additionally retains its one immutable installation serial.

The offered endpoint is borrowed by a **direct stored-field lvalue at the pipeline
call site**, never via a mutating CounterControl method, a whole-slot `_modify`,
a helper taking `inout CounterControl`, or a callback capturing `inout self`.
Before that call copy provenance/header/limits and create the existing lawful
`semantic.borrowedStore()` projection. Pseudocode, with the original Geometry
constraints and explicit nonescaping, synchronous callback:

```swift
// Inside offerAndProduce, after boundary/phase/context work has ended:
let productionSemantic = semantic.borrowedStore()
let productionHeader = header!
let productionLimits = limits
let productionProvenance = provenance!
requireRuntimeClaim() // scalar checks only, before field loans
let observed = counterProduceStoredEndpoint(
    endpoint: &control.pointee.runtimeEndpoint!,
    streams: &control.pointee.streams,
    geometry: &geometry, semantic: productionSemantic,
    header: productionHeader, limits: productionLimits,
    provenance: productionProvenance)
// All endpoint/producer loans have ended here.
control.pointee.backend.envelopeRejections += observed.invalidEnvelopeRejections
control.pointee.backend.endpointHealthObservation = observed.health
precondition(observed.health == control.pointee.backend.health)
if let recording = observed.acceptedRecording { control.pointee.lastFrame = recording }
```

`counterProduceStoredEndpoint` has `endpoint: inout CounterEndpoint`,
`streams: inout Int`, `geometry: inout G`, `semantic: borrowing
SemanticRecordStore<CounterPayload>`, and owned header/limits/provenance arguments;
it returns only `CounterOfferObservation`. Its producer captures only these
separate formal arguments and a local `RenderProductionError?`. It increments the
separate streams field and invokes the unchanged `semantic.withPublishedView` /
`geometry.produce` algorithm. It never captures pipeline, control pointer, slot
owner metadata or key fields. Results retain the actual offer failure and producer
error; owned observations are evaluated before any assertion autoclosure.

Both concrete `CounterEndpoint` implementations gain an internal
`offerAndObserve(provenance:body:) -> CounterOfferObservation` leaf. It executes
the same invalid-envelope control, checks no extra reservation/body call, installs
the real provenance, performs the one real offer, then returns actual health and
accepted full recording. It does **not** publish control/backend diagnostics.
The existing protocol `offer(provenance:body:) -> FrameOfferResult` remains a
wrapper around the same operation's result; the sole actual pipeline call uses
`offerAndObserve` and publishes the observation exactly once after its endpoint
loan ends. No protocol signature/associated type or escaping capability changes.
The tiny owned observation contains result, retained production error, invalid
probe count, health and optional pure `CounterRenderSink` recording (all glyphs).
It contains no endpoint/adapter/control/geometry value or stored callback.
Source inventory must confirm no other concrete call relied on publishing these
fixture diagnostics inside protocol `offer`; any such caller must use the same
post-loan publication seam rather than lose its checks.

The source-level separation obligations are:

| Call / original source | Actual lender and loan | Callback touches; required boundary |
| --- | --- | --- |
| Both pipeline constructors, lines 198/630 | Original control; no endpoint-field inout yet | Claim/install metadata are scalar leaf accesses. Construct endpoint before assigning its field; constructor backend diagnostics finish before field installation. No user/runtime callback is admitted while installing. |
| Pipeline offer 526–537 | Only direct `runtimeEndpoint` field plus separate `streams`; pipeline geometry field and borrowed semantic scope | Producer uses only those formal fields/scopes. No whole-pipeline or whole-control mutation occurs until this call returns. Header/limits/provenance are owned local facts. |
| Tiled Endpoint 216–225 / Native 237–249 | Concrete endpoint self, internally actual endpoint and sink | Invalid-envelope/real-offer algorithm remains. Endpoint-health/envelope diagnostic publication is moved out of the loan, as above. No whole-Control access/helper here. |
| Tiled target 104–158 | Its own target/writer values within endpoint; precise sibling backend stored fields | Read `offer`; mutate backend active/counts/health/submitted fields by direct stored lvalues. No mutating CounterControl/whole-backend function call. Finish/cancel returns before any slot transition. |
| Tiled tile storage / writer | `backend.tile`, `backend.coverage` exact array fields | Replace/reset loops touch only these arrays. Borrowed-run / C-write byte loan covers only tile array, ends before health/counter updates. Callback ABI exposes pixels only, no control/endpoint capability; existing nonreentry rule remains mandatory. |
| Native surface / writer / target | `backend.surface` versus separate `backend.payload`, plus precise scalar backend fields | FullSurface emitter can read surface while writer writes payload; never borrow whole backend around that callback. Reservation/finish/cancel are field-specific. All original pixel loops/capacities remain. |
| Recording/health observation | Borrow only installed endpoint after offer returns, no mutating endpoint loan at the same time | Read owned facts; no callback, wake, admission, slot install/clear or full-Control copy. Publish `lastFrame` and backend facts after endpoint loan ends. |
| Wake/admission | Existing control methods before offer, or after offer during disposition/finalization | `initializeCounterWake`, boundary injection, `emitCounterWake`, controller submit/scheduler service never execute inside endpoint/producer loans. counterServiceHost already ends scheduler access before host.runOpportunity. |
| Quiescence/clear | Scalar claim validation, short endpoint idle/health observation; end loan; then field clears | No finish/cancel/reset callback is invoked while any endpoint observation or clear is in progress. Logical finalization has already resolved the synchronous offer. |

In Tiled/Native storage/target methods, replace any coarse mutation helper found
on these paths by concrete leaf signatures over the actual named stored fields,
for example `counterStoreTile(tile: inout InlineArray<800, UInt8>, coverage: inout
InlineArray<50, UInt8>, ...)`, called with those two direct lvalues. Do not create
an inout whole-backend wrapper spanning producer/display callbacks. Existing
control pointers stay private implementation handles; pointer identity is a
provenance check, **not** the argument for exclusivity. The argument is the
actual original typed field loans, their disjoint stored-field paths and the
absence of whole-parent access across the listed callback edges. The source
review must verify this map; supported compiler/runtime exclusivity cases then
validate the realized seam. No unchecked projection or disabled guard is allowed.

Native tests must later include the concrete disjoint positive (endpoint offer
with backend/streams production) and overlapping endpoint-vs-endpoint loan
negative, with the existing diagnostic/trap classification. A runtime result is
additional evidence, not a replacement for the source borrow map. The foreign
pixel writer retains its existing synchronous nonreentry obligation; this design
adds no callback authority to it.

### G02 — sole installation claim and complete disposition

`runtimeLastOwnerSerial` starts zero in the original control. Both constructors
perform the same private installation sequence, independent of selected producer
origin. In particular nil producer origin remains valid for ordinary unbound
`CounterCoordinatorProbe` construction. Guard all field/phase/owner vacancy before
mutation; use checked UInt64 increment, with overflow an invariant failure before
any claim or endpoint side effect. No wrapping or reset while that original
control object lives. Store the resulting serial in the noncopyable pipeline and
in scalar control metadata. The ticket alone confers no access: it is used only
by that pipeline with its original control dependence, current phase and private
construction path. Immutable producer provenance continues to guard retained
admission/action callbacks separately, before they touch any new field.

Minimal operations (not an arbitrary conformer API):

```swift
// Private to the finite fixture implementation; no returned scoped capability.
claimRuntimeSlot(control: UnsafeMutablePointer<CounterControl>) -> UInt64
installRuntimeEndpoint(configuration: HostEndpointConfiguration,
                       control: UnsafeMutablePointer<CounterControl>, claim: UInt64)
requireRuntimeClaim(control: UnsafeMutablePointer<CounterControl>, claim: UInt64)
markRuntimeQuiesced(control: UnsafeMutablePointer<CounterControl>, claim: UInt64)
clearRuntimeSlot(control: UnsafeMutablePointer<CounterControl>, claim: UInt64)
```

Each operation is synchronous, performs only its precise fields, and holds no
whole-parent inout across constructor/backend/user code. Claim is not an externally
available capability getter. Actual physical-control address/provenance validation
remains the existing construction-join duty. A failed duplicate claim reads and
rejects; it must not clear, replace, increment or destroy the live owner's fields.
`requireRuntimeClaim` checks matching serial, permitted phase and endpoint presence.
Only the pipeline's terminal/consuming release path can call clear; a producer,
admission adapter, observation or already-consumed retired carrier has no such
operation. Clear requires matching quiesced claim and endpoint idle state with no
active backend reservation. Failed cleanup retains the claim and forbids reuse;
it does not clear optimistically. Every normal failure return from preflight has
vacant state. Constructor invariant traps are not recoverable failure paths.

| Entry / transition | Responsible value and exact action | Exit invariant |
| --- | --- | --- |
| Physical prefix before control initialized | Factory prefix unwind; no slot exists | Never inspect an uninitialized control field |
| Initialized control / failed assembly, join, early1–3, inert host early4 | No pipeline, hence no claim; original inert semantic/geometry/Interaction cleanup | Vacant, endpoint nil and all four keys nil |
| Raw-control constructor (198) and scoped-control constructor (630) | Existing valid root/configuration checks before claim; claim→installing(serial); run same endpoint constructor, then store endpoint and nil keys; phase installed; retain serial in resulting pipeline | Exactly one installed endpoint, same canonical config/backing and no new origin prerequisite |
| Failed installation before a normal value return | Installing owner alone ends any locally completed construction and clears its own field prefix/claim; no returned pipeline | Vacant; original constructor counters keep their required meaning. Current initializers trap on violated invariants, not recovered errors |
| Active cycle / candidate failure / accepted or refused offer | Same pipeline serial; existing shared transaction/cleanup actions resolve every synchronous offer; candidate/current keys stay distinct | Installed across cycles; failure does not release the payload early or replay input |
| Host cleanup1–3 | Refuse input; stop/detach; cancel callbacks | No slot clear or second owner |
| Cleanup4 quiesce/finalize | Actual coordinator/pipeline termination resolves active attempt, pins/reads and display finish/cancel; verify endpoint idle and backend inactive; mark same claim quiesced | Quiesced, keys still owned until release |
| Cleanup5 routing retirement | Existing registration/cache-ticket order unchanged | Quiesced, no late producer allowed |
| Cleanup6 releasePlatformOwners→takeQuiescedOpportunity→retireQuiescedStorage | Consume exact pipeline; validate serial/quiescence, clear endpoint and four keys, then metadata owner→nil/phase vacant; retain last-issued serial. Return original retired semantic/geometry/Interaction carrier | No live runtime payload before retirement; exactly one clear |
| Ordinary owned coordinator takeQuiescedOpportunity→returnWorkspaces | Same consuming clear, then return only original Copyable/Escapable workspaces | Unbound route vacant before its actual control borrow ends |
| Cleanup7 profile reset / cleanup8 report invalidation | Existing retired reset semantic→geometry→Interaction, then report invalidation | Preserve all eight hooks/order; no slot work duplicated here |
| Repeated teardown, failed activation before/after runtime, lexical defer | Existing progress determines whether pipeline exists. Installed owner follows cleanup4–6; inert branch has no claim. Repeated hooks never call a consumed pipeline | Vacant; no second clear and no synthesized owner |
| Body completion, physical release, same-address reconstruction | Assert vacancy before control deinit/reinit and after ordinary owned body returns; only then original reverse physical destruction / original initializer | A new control may reset serial only after every old scoped user is ended; no old pipeline survives to exploit serial reuse |

The ordinary CounterControl remains a trusted finite fixture value, not a public
copyable active-owner API. All whole-control construction/copy/reconstruction
sites must be inventoried; they require vacancy. Active snapshots use only named
owned observations. No active control copy, whole-control assignment, whole-slot
snapshot or deinit/reinitialize is permitted while its pipeline is authoritative.
This is enforced at the finite factory/reconstruction/snapshot seams and by source
review, not by treating a copied pointer/serial as ownership proof. The existing
noncopyable pipeline and factory scope forbid two supported live owners. A future
need for arbitrary copyable active-control clients is outside this design.

### G03 — full owned observations and physical charge

Extend the existing owned fingerprint with a `CounterRuntimeSlotObservation`:
phase, owner serial, last-issued serial, endpointPresent, all four complete
Optional identities and endpoint observation. Obtain this before and after each
stale label without calling owner operations. Evaluate comparison Bool before
assertion autoclosures. Do not retain a control, endpoint, adapter, raw byte view,
closure or bank pointer inside an observation.

`CounterEndpointObservation` names immutable effective presentation, descriptor,
payload limits and realization; actual body/reservation counts, last display
error and retained producer error; sink capacity/descriptor/limits, failure,
streamCompleted, presentationResponsibilityAccepted, retainedProducerError,
isIdleForOffer; health; and the complete pure recording value. The latter retains
capacity/header/counts/finishes/discards/points/stroke header and **all 64 Optional
glyph records** compared field-by-field, with no checksum or prefix truncation.
Native adds actual reservation/glyph header and target completion facts
(backend submitted bytes/rows, active/reservation counts); its writer is a
synchronous local, never an invented persistent endpoint field.
Tiled adds exposed target writer fields (written bytes/regions, origin/pixels,
remaining/completed) and the same session public phase/outcome facts. Maintained
core private phase/work tracking is not claimed to be a raw struct equality;
existing actual stream, idle, transfer, refusal and capacity controls still prove
its behavioral contract. No core getter/protocol relaxation is proposed for this
observation. Existing complete pixel comparisons remain independent.

Keep `lastFrame` as a separate accepted-recording observation and compare its
complete fields/records where required; it is not the runtime recording bank.
Preserve every old fingerprint/positive-twin field. Stale prepare/delivery and
admission checks reject on original producer before reading/writing slot keys,
claim or endpoint. Existing first/second host order, raw-identity collisions,
namespace continuity and all 26 labels remain. A matching new observation is not
an alternative to these original effect counts or actual sealed action delivery.

Vacancy checks include endpoint=nil, four keys=nil, owner=nil, phase=vacant;
last-issued serial may be nonzero. They are required at physical-control prefix
unwind/destruction, successful and failed activation/body completion, both
consuming return paths, ordinary owned callback return and every reconstruction.
Installation checks assert empty keys and canonical endpoint startup projection;
quiescence checks assert actual endpoint idle/backend inactive before clear.
Counters for successful install/clear and failed duplicate claims are owned test
facts, measured/charged if stored. They may not add a second mutable authority.

Measure the enlarged CounterControl, each new direct field and serial/phase
metadata, compiler padding and alignment. Recompute all 25 target regions with the
same checked derivation and compare the full actual four-slot C symbol reservation;
full slot spacing, surplus and slot-origin alignment remain required. Enlarging
the control under a stale 32,000 constant must fail rather than truncate. The
native Optional padding design for other regions is unchanged. Dynamic uses the
same logical fields in its original control owner, charges actual retained bytes,
allocation count/bookkeeping and exclusive borrow/COW rules; it must not allocate
a side payload per pipeline or omit the original control increase. Constructor,
install/clear, temporary observations, deinit and feasible IRQ stacks are additional
costs. None is proved away by these signatures or scalar type facts.

Final proposed minimal scope is CounterPipelineOwner (direct fields, claim,
constructors/operations/consuming clear), CounterScopedStorage (new owned facts,
all scoped prefix/reconstruction/cleanup checks), CounterTiledRaster and
CounterNativeRaster (concrete offer observations and precise stored-field backend
leaves), CounterProfileStorage and CounterCoordinatorProbe (ordinary-control
completion/vacancy guards). CounterAdmission and CounterWakeIntegration need no
new semantics under this map: their whole-Control operations stay outside endpoint
loans; include an edit only if source realization reveals a mapped violation.
Update measured StaticCounterEmbeddedBacking/C reservation and exact qualification
pins as already specified. No mandated CounterHostState, core coordinator,
Interaction declaration, protocol relaxation, ownership boundary, capacity or
resource ceiling change is selected.

Next step is focused independent review of this completed map/matrix, then a
separately bounded source package if accepted. Preserve old 2/2 and diagnostic 1/1;
this assessment has not started a source/repair cycle. The early nRF recipe above
must reject oversized feasible paths before full current-source corpus/images.
Native positive/overlap controls must exercise the actual projected callback seam,
all eight cleanup hooks, unbound owned release and stale/wrong-owner/duplicate
installation without another owner's destruction. Keep all five original native
controls unchanged; register any supplemental seam pair separately with explicit
labels/statuses rather than silently replacing an original case or calling a
changed count the old five. Passing any focused subset
cannot establish full P08 fit or acceptance.
