---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — P08 scoped fixture metadata backing
status: draft
authors: [codex]
created: 2026-10-16
updated: 2026-10-16
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# P08 scoped fixture metadata backing

**Grouped B01/B02 design correction ready for focused reassessment; no diagnostic/source execution.**
[Focused authority/realization review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-fixture-metadata-independent-design-review.md)
historically blocked `5b382914` on surplus overlap and missing prebinding custody.
The finite ranges and caller-stack custody below replace those incomplete rules.
No contract amendment has been identified; reassessment precedes the proposed
diagnostic. The proposal remains unimplemented and all earlier budgets stay closed.

This is one replaceable physical proposal, not Specification authority or source
approval. [New authorization/activity](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-structural-memory-reduction-activity.md)
permits this assessment; earlier budgets remain closed. No maintained source,
compiler, target execution or resource limit changed during design.

## Purpose and governing contract

Select a substantive reduction for the [current rejection](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-measured-sizing-stack-preflight-result.md):
71,088 required stack plus 138,880 backing exceeds 196,608 RAM. Preserve main stack
27,648, RAM 196,608, all workloads, all four retained slots, and all existing
logical/storage capacities. The proposal relocates **owned fixture metadata**,
never scoped host/state/pipeline values, into an exclusively idle caller slot.

[ADR-039 Decision](../adrs/adr-039-scoped-storage-ownership.md#decision) requires one
actual typed owner/session for geometry and five banks, final-region initialization,
complete lifetime propagation, restricted factories, prefix unwind and backing-last.
Its rejected alternatives exclude an ordinary escaping lease and rebinding live
initialized storage. [S13.1/2](../specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract)
requires the actual owner's exclusive typed borrow, excludes reentry/aliases and
requires all metadata, temporaries and physical roles in the ledger.
[S15](../specs/spec-015-host-configuration.md#s152-additional-acceptance-criteria)
preserves the actual carrier chain, original inventory, first errors and cleanup;
physical offsets/fit must be established before source work.

Neither accepted clause requires four simultaneously initialized counter profiles.
The four raw caller slots are the existing derived realization, which stays fully
reserved and charged. `CounterScopedStorage.swift:2160` runs scenarios sequentially;
`:2177` keeps only slot 0 live for two sequential hosts; `:2610` runs early/failure
cases one selected reservation at a time. Graph selection `:2353` also encloses
one reservation. Fault/exchange helpers close each instance before the next case.
No four-slot count reduction or omitted case is proposed.

## Selected organization

For Embedded only, a private fixed-Int-result selection operation receives the
original whole four-slot backing and a finite case plan. The range map below
selects a donor disjoint from the **complete supplied active reservation**, including
surplus. Caller-stack custody validates the entire 4×34,720 span, checked slice
bounds, disjointness, alignment and idle phases before binding anything. The old
adjacent-donor formula is rejected. No new global or heap.

### B01 — complete finite reservation map

All intervals are half-open offsets within the same 138,880-byte caller region:
S0=[0,34720), S1=[34720,69440), S2=[69440,104160), S3=[104160,138880).
No donor is selected from an active reservation's unused tail or by its used-byte
cursor. Every row also checks that donor/active masks are idle in the shared custody.

| Existing Embedded cases | Complete active reservation | Donor | Preserved details |
| --- | --- | --- | --- |
| Graph/constructor rejection controls | S0 | S3 | All existing graph modes and first-error/read observations. |
| Host scenario 0,1,2 | S0,S1,S2 respectively | S3 | All original normal/failure/retry cases. |
| Host scenarios 3…8 | S3 | S2 | All original six quiescence modes. |
| Two-host same-address reuse | S0 throughout both hosts | S3 throughout | Same original inventory/control and distinct model/semantic namespaces; no pair release between hosts. |
| Early 1…5; candidate failure raw 0…10 | S0, each invocation | S3 | Every existing case/label retained. |
| Exchange, surplus=0 | S0 | S3 | Original equality/below/above retained-capacity observations unchanged. |
| Exchange, surplus=64 | **S0+S1=[0,69440)** | **S3** | Same two-slot supplied view; r1+64 yields cursor34777/rounded34784; reserve both slots despite the smaller used extent. |
| Invalid r0 extent | S0 | S3 | Same stride-minus-one descriptor, expected invalidReservation before acquisitions. |
| Fault before/after each14 IDs and every b0/b1/b2/b3 prefix | S0 | S3 | All existing 1024/1056/20/112 prefix ranges and initialized-prefix traces retained. |

The surplus row leaves S2 idle. No active span reaches S3 except the ordinary
scenario-3…8 row, whose donor is S2. Cursor34777/rounded34784 is existing-source
surplus arithmetic, not a new scratch measurement or an extent reduction. Guards
validate actual checked derivation against the row's full supplied extent before
binding; a new/unlisted case has no default donor and fails closed. Tests enumerate
every row and boundary, including rejection of S1 as donor for the surplus row.

### B02 — caller-stack custody, before any raw binding

Custody lives as one initialized local in the private Embedded corpus dispatcher,
not in donor/active bytes. It is neither a geometry/bank owner nor a session token.
Minimal source-equivalent declarations (design signatures, not maintained code):

```swift
fileprivate enum P08CallerPhase: UInt8 {
    case idleDeinitialized, activeReserved, donorReserved, running, cleaning, poisoned
}
fileprivate enum P08OwnerProgress { case absent, reservedEmpty, initializedIdle, released }
fileprivate struct P08CallerCustody: ~Copyable {
    private let bytes: UnsafeMutableRawBufferPointer
    private var phases: InlineArray<4, P08CallerPhase> = .init(repeating: .idleDeinitialized)
    private var busy = false
    private var metadataPrefix: UInt8 = 0
    private var ownerProgress: P08OwnerProgress = .absent
    init(exclusiveCallerBytes: UnsafeMutableRawBufferPointer) // bounds/alignment only; no binding/read of pointees
    mutating func run(_ plan: P08EmbeddedCasePlan, inputs: P08OwnedCaseInputs) -> Int
    // No public init, raw-slice getter, arbitrary callback, scoped Result or returned descriptor.
}
```

`P08EmbeddedCasePlan` is a file-private finite enum for exactly the table's graph,
hostScenario, twoHosts, early, candidateFailure, exchange(surplus0/64), invalidExtent
and fault(id/completed/afterInstall) cases. Owned inputs are the existing identities,
writer, limits/scenario facts; no scope-bearing value enters custody. Its stack
phase/prefix/cleanup-progress bytes are explicitly charged in the final ledger.
Progress is not competing bank authority: cleanup checks the real owner's lifecycle
and acquisition count before applying its allowed disposition.

**Concrete route topology:** Embedded `p08CounterRoute` calls one package bridge
`p08RunEmbeddedCorpus(write:backing:)` implemented beside private custody in
CounterScopedStorage. That bridge constructs custody first and calls private
`runGraph(custody: &custody)`, `runScopedCases(custody: &custody)` and
`runHostCases(custody: &custody)` sequentially. Each invokes `custody.run(plan)`.
Embedded direct package probe entries use a fixed one-operation bridge through
this same custody constructor; they cannot accept or return an active custody.
Native package routes retain their current realization.

The Embedded raw-slice entry to `withP08SelectedStatic` at 1895 is replaced by this
finite operation route. `counterSelectedProfileBacking` and `p08SurplusBacking`
cease to be independently callable Embedded slice suppliers. Direct helpers at
2502–2530 become operation bodies receiving already-prepared typed objects and
owned case facts, **not** raw backing. Their original loops at 2594–2613 select
the corresponding plans, including surplus and every fault. No P08EmbeddedOuter
binding constructor is called except the common cold prepare path under custody.
Reconstruction at 1833 stays within the twoHosts operation's same reserved pair;
it does not enter selection again or release S0/S3 between hosts.

`run` holds the actual exclusive inout custody borrow for its entire operation.
It first requires busy=false and all selected phase entries idle, computes the
checked table ranges, sets busy=true and reserves **all** active-mask entries plus
the donor before any bind. It then calls a concrete cold/run/cleanup helper with
private bytes/owned range facts and separate progress fields; that helper never
captures the whole custody. The operation body gets only the earlier listed
disjoint typed objects. It has no custody/raw-span parameter or selection callback
to invoke. No factory accepts an arbitrary body at this entry seam.

This is a closed fixture call-topology proof: the actual installed C pixel writer
is `spi_tft_write_rgb565`, takes only pixel/rectangle arguments, and does not call
the counter root or receive its function-local `counter_backing`. No Swift callback
is passed custody or the whole caller span. Same-span nested fixture entry from
those callbacks is thus absent; accidental internal reborrow of custody conflicts
with its still-live inout run borrow. The trusted C entry retains its preexisting
exclusive-caller-buffer requirement; no claim is made to make arbitrary forged C
aliases safe. No global registry, public lease or donor-resident sentinel is added.

After logical cleanup and all scoped/typed borrows end, `run` verifies real owner
disposition, reverse metadata destruction, ended descriptors and full deinitialized
active/donor state before marking every reserved phase idle and clearing busy.
Failure of cleanup poisons the custody and forbids reselection/rebinding. Returning
the corpus requires busy=false, prefix=0 and all four phases idle. A separately
entered probe may construct fresh custody only after its previous call returned
with this invariant and under the same exclusive-input contract.

**Reserved metadata is not initialized banks.** Before owner construction,
ownerProgress=absent. After the owner object is initialized but before successful
`initializeP08Backing`, it is reservedEmpty. If another metadata constructor fails,
or bank initialization fails and the existing owner unwinds its bank prefix, require
real acquired=0/lifecycle=reserved and deinitialize that owner object directly;
**do not call finishReservation**, whose existing contract permits only idle/released.
Successful initialization records initializedIdle. Only after consuming session
cleanup returns to real idle may finishReservation/release destroy the original
bank inventory; released is verified before metadata owner deinit. An already
released body is accepted once without another destruction. Active or incomplete
reset is never treated as a releasable prefix. Metadata reverse-prefix cleanup and
the original fourteen-bank/geometry destruction transcript remain distinct.

The donor holds seven **separate, fully initialized typed objects**, not a giant
new aggregate or uninitialized storage for scoped values:

| Metadata object | Existing logical role / lifetime |
| --- | --- |
| `P08EmbeddedOuter` | Existing active-slot typed descriptors and outer initialization/destruction responsibility. |
| `P08TypedBackingOwner` | The same sole geometry/five-bank owner, with the same identity, serial, inventory and lifecycle. |
| `P08ReuseFingerprint` | One owned before-baseline, invalid until actual capture completes; immutable thereafter. |
| `InlineArray<14, P08InitializedEntry?>` | Existing original-inventory comparison facts. |
| `P08HostReuseTranscript` | Existing retained original action/event/admission/application observations. |
| `StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>` | Existing foreign-root lender used by rejected-binding controls. |
| `CounterControl` | Existing foreign control, not another active pipeline or transaction owner. |

Checked per-type size/stride/alignment and cursor roundup derive nonoverlapping
donor offsets. All seven count=1 extents must fit 34,720 and required alignment must
fit the existing eight-byte base/spacing. Target values are **not yet measured**;
failure forbids implementation of this layout. Keep active 25-region/129-root
measurements unchanged; add explicit donor metadata rows to the physical ledger.

Cold initialization returns only private descriptor/control facts and owned status,
never an aggregate metadata value or scoped capability. Use normal typed binding
and `initialize(to:)` for each complete object. No `load(as:)` of uninitialized
memory, bitcast, raw aggregate stores, synthesized unsafe conformance or heap.
An out-of-line cold initializer and destructor are justified to prevent those
construction homes spanning the live callback; fit is still measured, not inferred.
`initialize(to:)` may materialize a complete temporary owner or other object in
that cold helper. No zero-copy claim is made. Its invocation must return before
the active callback begins; both cold construction/destruction peaks are separate
required stack paths and must pass the unchanged limit.

The initialized owner is borrowed as its actual T lvalue. A concrete file-private
operation projects all disjoint objects before entering callbacks, conceptually:

```swift
func runSelectedFixture(
    owner: inout P08TypedBackingOwner,
    outer: borrowing P08EmbeddedOuter,
    before: inout P08ReuseFingerprint,
    original: inout InlineArray<14, P08InitializedEntry?>,
    transcript: inout P08HostReuseTranscript,
    foreignRoot: inout StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>,
    foreignControl: inout CounterControl
) -> Int
```

These are separate actual typed objects, not overlapping whole-scratch `inout`
access followed by callback reentry. `withP08Storage(backing: &owner)` still makes
its token from the actual owner's exclusive typed borrow. Geometry/bank accesses
retain every original annotation/dependency. No session/host/scoped result is
stored in donor memory or returned by the scratch operation. Its descriptor is
not a replacement lifetime token and exposes no capability getters.

The foreign-scope helper receives root/control as distinct typed formal loans;
its original root.withLifetime encloses the same six rejected joins and actual
model scopes. Reset/reinitialize foreign owned values only after their prior
root/model callback has ended. Main model/root/semantic/value lenders remain the
original active-slot fields. Mandatory CounterHostState and core protocols stay.

## One before-baseline and complete comparisons

Keep exactly the current complete field set, including independent accepted
lastFrame, endpoint recording/configuration/phase, actual backend counters/health,
four full keys/provenance, admission, scheduler observations and every scalar.
Neutral fully typed initialization is explicitly **invalid as an observation**.
Private phase goes empty→capturing→frozen once at the current second-host before
point. Capture writes every field from actual state, then grants only a borrowing
comparison operation; no setter/refresh is available during stale checks.

Replace `P08ReuseFingerprint(control) == expected` with streaming typed comparison
against that same frozen baseline. Recording comparison reads all 64 Optional
entries directly and compares all other recorded fields; no copies into `a`/`b`
or current full snapshot. Endpoint matching lives inside each Native/Tiled wrapper
to read actual private fields; it returns owned Bool only. Backend matching reads
the actual separate backend. Evaluate each borrowed-field Bool before combining
it; no borrowed self in assertion/short-circuit autoclosures. Compare all baseline
fields exactly; no digest, sampled subset, invented zero or lastFrame substitution.

Capture/match operate through typed inout/borrowing parameters, one bounded fact
or recording element at a time, without aggregate snapshot return. The baseline
may become private ~Copyable to prohibit accidental copies; no protocol or scoped
Self conformance changes. Stale-action rejection needs only a borrowed host (its
existing operations are borrowing), so remove that helper's unnecessary inout;
mutating input/admission/source/current helpers keep their required inout access.
This is a lawful interface reduction, not a claimed codegen guarantee.

The original action stays immutable. Prepare and delivery, input, admission and
source checks all use the same baseline. Keep current positive twins, actual
down/up action execution, full frame checks, two model namespaces, all 26 route
labels and eight cleanup steps in the same order.

## Slot phases, binding and cleanup

| Phase | Active slot | Donor | Permitted transition |
| --- | --- | --- | --- |
| Selection | raw/deinitialized | raw/deinitialized | Exclusive original caller span; distinct indexes and all guards checked. |
| Prepare | outer initialized, banks reserved→idle | Seven typed objects initialized by prefix | Record each metadata success; original bank owner initializes the same 14 objects. |
| Host/session | original initialized objects; active scoped session | Typed metadata retained, frozen baseline read-only after capture | Donor cannot be selected for a profile; no whole-donor access/rebinding. |
| Host reconstruction | original owner idle, no scoped accesses | Original metadata remains | Preserve same addresses/IDs; only the already-reviewed main outer reconstruction runs. |
| Logical completion | quiesced/reset; owner idle | End retained transcript observations and baseline borrows | Exactly the existing stop/drain/retire/reset order. |
| Physical completion | original 14-object inventory destroyed once, then outer values | Deinitialize metadata in reverse, outer last after owner.finishReservation | No destructor callback may use a released control; release both roles to idle last. |
| Later case | May choose either old index as active | No old donor pointers remain | Rebind only deinitialized memory to its next type before initialization. |

The C caller remains the byte-region owner; donor custody adds no geometry/bank
owner or transaction machine. Preserve one 14-entry bank/geometry inventory; add
a separate seven-entry **factory metadata initialization trace**, with explicit
parent ownership, to the combined physical ledger. It is not role-dependent bank
destruction authority. Failure unwinds its successful metadata prefix; initialized
bank owner is finished before its outer can be destroyed. No session on failure.
Cleanup invariant failure prevents reuse/rebinding, exactly as S13.1 requires.

Memory binding is a real proof obligation, not an exclusivity-test substitute.
Previously initialized donor profile values must all have been deinitialized,
their sessions/model pins/callbacks ended and every old typed descriptor dead.
Only then may raw storage be rebound. This differs from ADR-039's prohibited
rebinding of an initialized slot. [Swift SE-0107](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0107-unsaferawpointer.md#memory-initialization)
permits rebinding deinitialized storage and invalidates old typed pointers; it is
language background, not authority to change GiftUI ownership. Reuse slot 0/1/2/3
across all case orders in the ledger; never assume an unused slot from retention
alone. The private selection scope excludes nesting/reentry on the same span.

## Costs and decision

All four slots still retain **138,880 bytes**; donor metadata overlays an idle
interval already fully charged. The ledger records its actual type costs once
inside that interval and remaining donor padding; it must not add those bytes
again or omit their lifetime/owner. Native Static/Dynamic keep their existing
typed reservations and use the same comparison algorithm with lexical owned
metadata; no COW/shared mutable alias or new allocation.

Known current Control size/stride is 6,920. The original inventory copy span is
392 bytes in current code; the full current-fingerprint helper reserves 5,192
local bytes plus saved registers, which is a stack home, **not** a sizeof proof.
The other six metadata sizes and donor padding require target facts.

This removes the *need* for long-lived stack-resident outer owner/metadata,
foreign control/root and before-baseline, and eliminates the second full current
snapshot plus its nested initializer. Source-separated typed objects eliminate
the giant workspace-return convention; cold initializer temporaries end before
host entry. Live nonescapable carriers remain on the stack. No numeric stack
saving/upper bound is promised. Early measurement must cover cold prefix/destructor
and all live helpers, including the remaining 12,664 session and 8,552 stale-action
homes if codegen retains them. Stop if main/IRQ/total RAM still cannot fit.

Streaming-only is the smaller alternative, but merely removing the measured
5,208+7,768 nested current-snapshot homes leaves 58,112 if other frames stay fixed,
before omitted costs. That illustrative subtraction is not a new-source bound
and gives no credible acceptance claim; do not select another helper-only loop.

The recommended next action is focused independent physical-design review of this
exact temporal-role realization, then a single targeted size diagnostic before
source. S13/S15 do not explicitly fix a permanent type for an uninitialized raw
caller slot, so no contract amendment is proposed **if** that review confirms the
conditions above. If “original inventory” is interpreted to require permanently
typed profile regions across cases, the smallest upstream decision is explicit
permission for this one idle-slot metadata role under complete deinit/rebind and
unchanged total bytes; do not silently implement that interpretation.

## Bounded implementation and validation handoff

1. One existing-module diagnostic compilation, not a new runtime/probe: copy the
   current CounterScopedStorage source to scratch and append scalar size/stride/
   alignment accessors for the seven existing types above plus checked seven-row
   cursor/offset/maximum-alignment/rounded extent. Use the exact current counter
   module argv/toolchain/flags with scratch output and that one copied source.
   Strictly decode only those named diagnostic roots; no stored objects, linking
   or execution. Reject extent>34,720 or alignment>8. Preserve diagnostic-only
   provenance; it cannot serve as acceptance. This precise type-layout question
   is not answered by existing 129 active-profile roots.
2. If measured/reviewed, bounded source files are CounterScopedStorage (selection,
   scratch initialization/borrow/cleanup, baseline and complete case plumbing),
   CounterPipelineOwner (recording/fact capture and matching operations), both
   CounterNativeRaster/CounterTiledRaster (private-field matching), CounterHostProbe
   (foreign stored-field lenders), CounterRouteEntry/CounterScopedStorageProbe
   (one Embedded custody dispatcher), StaticCounterEmbeddedBacking (remove the
   bypassing Embedded raw-slice supplier), and required driver/tests/qualification.
   Active layout/C constants, core HostState/Interaction/protocols stay unchanged.
3. Check actual predecessor compiler argvs: CounterHostProbe may be a compiled
   component dependency, requiring rebuilding that component; never metadata-
   qualify a changed compiled source. Freeze source and independently review.
4. Fresh nRF module/layout first, then bounded complete required stack paths and
   actual metadata bindings. No full corpus/image if conclusively unfit. If
   promising, full nRF controls/current image and focused Native Dynamic/Static
   and Pi runtime/negative-family/exclusivity controls retain all positive twins.
   Add donor overlap/oversize/misalignment, prefix-failure, early 1–5, both-host,
   each donor/active index, repeated cleanup/rebind, baseline-capture-once and
   every-field/64th-record mutation negatives. Preserve original source labels.
5. A new implementation allowance, if design stays within authority, must be
   recorded before source; one initial grouped candidate with at most two
   cause-grouped corrections and the two-unproductive guard is proposed. No
   previous budget is reused. No limit/ownership/workload change is automatic.

### Exact bounded diagnostic recipe, only after design review

Use `.build/nrf52840/p08-fixture-metadata-layout-diagnostic/` as scratch output.
Copy only the current `CounterScopedStorage.swift` there, preserving its basename,
and append 31 scalar roots for these seven existing types in order:

1. `P08EmbeddedOuter`
2. `P08TypedBackingOwner`
3. `P08ReuseFingerprint`
4. `InlineArray<14, P08InitializedEntry?>`
5. `P08HostReuseTranscript`
6. `StaticObservableRootAdapter<CounterOwnedModel, SemanticCompleteIdentity>`
7. `CounterControl`

Each type contributes size/stride/alignment; seven checked cursor offsets and
final cursor/maximum alignment/rounded extent make 31 roots. Prefix diagnostic
names `giftui_p08_fixture_diagnostic_`, never the accepted 129-root namespace.
Use scalar checked arithmetic, no runtime array/table initialization. Reject
unsupported code through the existing strict ELF/tail/immediate/literal proof;
diagnostic code is not run or linked and does not qualify a maintained receipt.

The argv is the exact `-module-name P08CounterRuntime` command in
`.build/nrf52840/contracts/p08-counter-nl16wjri/result.json`, split with shlex.
Replace that one source token by its appended scratch copy; redirect only output
paths (`-o`, `-emit-module-path` and any other present output-path flags) plus
module-cache path into the scratch directory. Preserve compiler, all semantic
flags, module/package name, imports/preparation `-I` paths and every other source
token/hash. Save the derived argv before its **one** invocation, stdout/stderr,
source diff, tool/input/object hashes and root proofs. No compiler retry or source
repair loop is included; mechanical invocation errors are reported separately.

This answers only whether the declared typed metadata fits one 34,720-byte,
eight-aligned idle interval and gives the physical offsets required for design.
It cannot establish source realization, borrowed-lender legality, native layouts,
stack codegen, current image fit or accepted P08 behavior. Review authority and
binding/lifetime proof before even this diagnostic; no diagnostic was executed
during the present assessment.
