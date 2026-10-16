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

**Independent design review: BLOCKED at `5b382914`.**
[Focused authority/realization review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-fixture-metadata-independent-design-review.md)
finds no required contract amendment, but identifies surplus donor overlap and a
missing concrete prebinding custody/cleanup seam. Resolve both before the proposed
diagnostic or source work; the proposal below remains unimplemented.

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
original whole four-slot backing and active index. It selects a distinct idle
donor `(active + 1) % 4`, validates the entire 4×34,720 span, checked slice bounds,
disjointness, alignment and idle phases before binding anything. Existing public/
package routes still receive the same caller backing. No new global or heap.

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
   (foreign stored-field lenders), and directly required driver/tests/qualification.
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
