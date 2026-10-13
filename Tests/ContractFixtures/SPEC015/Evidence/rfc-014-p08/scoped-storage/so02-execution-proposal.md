# SO-03 bounded execution packet; SO-04–09 remain proposed

This packet accompanies the [physical design](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md).
The [independent correction review](so02-independent-review.md#bounded-correction-verification--2026-10-13)
verified B1/B2 documentation and isolated the pre-existing analyzer applicability
question. Eugene explicitly accepted its narrow disposition and the one-invocation
SO-03 next step; the [P08 receipt](../progress.md#so-03-applicability-and-allowance-documentation-dispatch--2026-10-13)
records exact provenance, source preservation and remaining counters. A separate
read-only readiness check of this amended packet precedes source dispatch; it
creates no further permission question. No source/compiler work ran in this
documentation step. Only SO-03 is authorized; SO-04–09 maxima remain proposals.

## First slice: SO-03, then independent result review

Allowed source files:

- `Sources/GiftUIInteraction/{InteractionStorage,InteractionValues,InteractionState,InteractionOwnedKeyState,ExecutionGestureAdapter}.swift`;
- `Sources/GiftUIRuntimeCore/{RuntimeRecordInteractionBridge,RuntimeRecordCanvasInteractionBridge,RuntimeInteractionCandidateTransaction,RuntimeInteractionCandidateCoordinator,RuntimeInteractionCandidateResolution,RuntimeInteractionDispatcher}.swift`;
- `Tests/ContractFixtures/SPEC011/RuntimeDerived/InteractionProbe.swift`,
  `KeyLayoutProbe.swift`, and a new `ScopedStorageProbe.swift` in that directory;
- `scripts/contracts/check-spec-011-owned-keys.py`: register the new focused
  direct/generic five-input/state/failable-Optional/conditional-owned positive
  and expected-negative pairs in its existing pinned route, and the exact
  real-source/prerequisite/internal-cell registration below;
- `scripts/contracts/check-spec-013-runtime-cycle.py`: only add the actual
  ObservableStateProtocols.swift input to its existing Observable module tuple
  in SO-03; its RuntimeCore tuple extension remains proposed SO-07 work;
- `Package.swift`: only existing relevant targets' LifetimeDependence/Lifetimes
  propagation if needed to compile the exact adopted declarations;
- `CounterStorageMeasurement.swift`, `CounterStorageRegions.swift` in SPEC015
  RuntimeDerived and `CycleStorageMeasurement.swift`, `CycleStorageRegions.swift`
  in SPEC013 RuntimeDerived: repair the four withBacking callers together with removal;
  state measurement can return only bounded owned facts, never a callback capability;
- **No edits** to the two analyzer action dispatcher factories or their
  model/root/target dependencies. Preserve the original SO-01 hashes recorded
  in the receipt. Actual-factory compilation/owned-return evidence stays unresolved
  and mandatory in ITERATION-004 I4-07 with the existing P09 integration handoff;
  shared owned dispatcher probes below establish only their named shared contract.

Implement exact S11 declarations/unions/conditional conformances and selected
operation-only bounds. Add trusted minimal scoped fixture banks to test all
five independent input lifetimes and failable Optional; preserve owned tests
and existing diagnostic causes. No final physical owner or host migration yet.
Record frozen source hashes/diff and intended negative causes before invocation.

Authorized ordered SO-03 checks (after independent readiness verification and
source dispatch):

```text
scripts/format-swift.sh
scripts/validate-governance.rb
git diff --check
scripts/contracts/run-spec-011.sh --profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014-swift64/af66aaf967e3fe8f-__4p5wu2/macos-dynamic
```

Maximum: one native driver invocation (including its declared fixed internal
positive/negative compilations and existing layout IR check), zero automatic
production repairs, zero target/image/repository-suite runs. Preserve all
failed output. Commit the source/evidence and stop for separate read-only
Strong result review. A failure's exact cause must be reviewed before any
repair proposal; this first slice does not authorize that repair. Its existing
layout IR output is contract-driver evidence, not a renewal of the failed
historical optimized-IR diagnostic capture.

## B2 exact source registration and fixed internal cells

This is the required SO-03 change to `check-spec-011-owned-keys.py`, not a
claim that its present two-file RuntimeCore tuple covers the affected source.
Use the same one SO-03 command above and, after source/result review, its four
SO-07 profile cells. Existing legacy labels/commands remain once each. The
SO-03 allowance follows the explicit applicability disposition below; later
profile invocations remain proposed and unapproved.
Register/freeze each actual source hash and each label before invoking.

Replace that RuntimeCore source tuple with exactly these seven maintained
files under `Sources/GiftUIRuntimeCore/`:

```text
RuntimeRecordInteractionBridge.swift
RuntimeRecordCanvasInteractionBridge.swift
RuntimeInteractionCandidateTransaction.swift
RuntimeInteractionCandidateCoordinator.swift
RuntimeInteractionCandidateResolution.swift
RuntimeInteractionDispatcher.swift
RuntimeOwnerFailure.swift
```

The last is the actual build-result failure dependency; Resolution supplies
RuntimeActionGenerationSource and the transaction enum extended by Transaction.
Coordinator supplies occurrence/build-result types; no stub copies of those
types or algorithms are permitted. Existing Execution, Interaction, Semantic,
Layout and Observable modules compile from the existing real-source lists.
Before RuntimeCore compile add the following two dependency cells, matching
the maintained runtime-cycle driver's source recipe:

- `so03-prereq-render-lowering`: GiftUIRenderLowering's five actual files
  RenderExtensions.swift, RenderPreflight.swift, RenderProducer.swift,
  RenderProductionValues.swift, RenderStreaming.swift.
- `so03-prereq-drawing`: GiftUIDrawing's CanvasRenderProducer.swift,
  CanvasInvocationSource.swift, CanvasPlanProducer.swift, CanvasStagedValues.swift,
  CanvasSemanticPayload.swift, DrawingLimits.swift, DrawingPlan.swift,
  DrawingValues.swift, StaticCanvasCallableTable.swift, PathConstruction.swift,
  StrokeSnapshot.swift. DrawingValues supplies DrawingProductionError and the
  Canvas bridge uses the actual CanvasSemanticPayload/transfer dependencies.

Extend the existing DynamicRuntime module cell's two-file list with
DynamicObservableModelStorage.swift, DynamicObservableModelRegistration.swift,
DynamicObservableRootAdapter.swift and DynamicObservableRootTargetAccess.swift.
Static's existing five-file list already supplies StaticObservableModelStorage,
StaticObservableRootAdapter/TargetAccess and its owned Interaction stores.
Keep the actual ObservableStateRootTargetAccess/RootScope/Model declarations
from the existing Observable module, with no shadow target adapter. Add
Sources/GiftUIObservableState/ObservableStateProtocols.swift to that existing
module's source tuple in both SPEC011 and SPEC013 drivers: it supplies the real
ObservableStateReconciler/TargetView protocols used by Coordinator/Transaction.
This is source-input registration in an existing module cell, not a new compile
or a stub of those protocols. Fixture operation inputs may implement these real
protocols but cannot shadow their declarations or replace the actual algorithms.

Do not add the former four analyzer prerequisite/factory cells
(`so03-prereq-failure-core`, `so03-prereq-analyzer-domain`,
`so03-prereq-analyzer-presentation`, `so03-actual-analyzer-factories`) or the two
actual-factory probe cells. Their removal records the accepted applicability
boundary; it does not produce passing analyzer evidence.

The frozen additional *compiler* cells per invocation are exactly the two
RenderLowering/Drawing prerequisite cells above plus the following 27 probe
cells, at most 29 total in addition to the unchanged legacy driver's enumerated
command list. The inspected legacy compiler counts remain 13 on native profiles
(11 module compiles + one layout IR + one link), 12 on Pi (11 modules + IR),
and 11 on Embedded (10 modules + IR, no Dynamic). Thus the SPEC011 maxima are
42 native / 41 Pi / 40 Embedded compiler cells, plus one existing native execute
or one existing target ABI inspection: 43 / 42 / 41 total commands respectively.
Only one macos-dynamic invocation is authorized now; target/profile maxima here
bound the still-proposed SO-07 replay. No retry or additional compile is hidden
in a case:

| Fixed label / number of compilations | Required operation/input coverage |
| --- | --- |
| `so03-state-owned`, `so03-state-scoped`, `so03-state-failable` — 3 | Owned conditional copy/return and scoped moves, actual state and failable Optional; existing owned banks versus trusted scoped fixture inputs. |
| `so03-union-{C,H0,R0,R1,H1}-{direct,generic}-{positive,escape}` — 20 | Each of the five actual state initializer inputs independently limits lifetime; each negative has its exact positive twin. No unconstrained combinatorial generator. |
| `so03-state-copy-negative` — 1 | Reject scoped state copy for noncopyability, paired with state-scoped move above. |
| `so03-consumer-operations-positive` — 1 | Instantiate actual record append/appendProjected/dispatch, Canvas append, Transaction.build, Coordinator.build including its private discard branch through a failing occurrence, and Transaction.resolve accepted/refused. All operation consumers borrow/inout the same trusted scoped state; typed model/root/semantic dependencies remain real. Also call ExecutionGestureAdapter down/move/up on a scoped resolver. |
| `so03-retained-dispatcher-owned-positive`, `so03-retained-dispatcher-scoped-negative` — 2 | Instantiate actual RuntimeInteractionDispatcher with owned records and ordinary owned ActionModelTargetAccess; scoped Records rejection must come from the explicit retained bound. This controlled dispatcher probe proves shared owned behavior only; actual-factory evidence remains the mandatory unresolved handoff below. |

All 29 added cells are compile invocations, not 29 build loops. They use the pinned
compiler/flags already recovered by the driver. On native profiles extend the
existing single link/execute pair to run the positive operation/owned checks;
no second binary/link/execute loop. On targets compile/inspect only. A negative
must fail for its named ownership/lifetime cause, never a prerequisite/import/
root-type error; a failure in a prerequisite or positive cell stops immediately
and preserves partial evidence. Record exact total legacy+29 argv cells and
applicability before the first invocation; missing sources or more cells stop
for a proposal amendment. The legacy script is finite and inspected, not an
unlimited budget hidden under one invocation.

At SO-07 also explicitly register these seven RuntimeCore files in
`check-spec-013-runtime-cycle.py`'s current source tuple. Its existing Drawing/
Observable/profile prerequisite cells already compile the actual dependencies;
there is no added compiler invocation for this tuple extension. The counter
recipe replay then receives the complete current runtime tuple. The four
SPEC-011 profile cells carry the fixed B2 operation/shared-owned coverage;
no separate broad analyzer/P10 build is inferred. The 14 SO-07 driver maximum
therefore remains 4 SPEC011 + 4 SPEC013 + 2 native host + 4 counter, each with
its frozen internal cells. Reuse the unchanged SO-03 SPEC011 cell if qualified.

### Accepted owned analyzer applicability disposition; evidence unresolved

Read-only inspection at `eab732c9`, independently verified at `18504c6b`,
identifies a **pre-existing source-level concern, not an observed compiler
failure**. Both actual factories declare owned root adapter/pointer inputs,
then call Dynamic/StaticObservableRootTargetAccess(root: root). Those maintained
aliases resolve to ObservableStateRootTargetAccess, a ~Copyable/~Escapable scoped
type requiring ObservableStateModel & ObservableModelMutation and an initializer
with root scope, identity and ordinal. SignalAnalyzerViewModel declares
_GiftUIObservableReference. ActionModelTargetAccess remains the owned
withCurrentModel protocol, whereas the scoped target exposes mutate and lacks
that conformance. Factory source was last changed at `44ac06a8`; aliases at
`a38b86f1`. Package.swift includes both factories in its native target; counter
passes are no proof of their actual compatibility.

Eugene accepted preserving these exact unchanged factory sources and owned
constraints while validating the actual shared owned RuntimeInteractionDispatcher
and all six operation consumers in this P08 slice. The [allocation](../../../../../../docs/iterations/iteration-003-review/rfc-015-delivery-allocation.md#accepted-pre-existing-integration-gap-disposition--2026-10-13)
and receipt preserve both original hashes. Actual analyzer model/root/target
reconciliation, both factory bodies and owned returned/copyable dispatcher
positive and scoped-Records rejection evidence are **mandatory unresolved
ITERATION-004 I4-07 work**, coordinated with the existing P09 analyzer integration
and P10–P12 conformance/evidence gates. P09 is a separate package, not an iteration
alias. This changes applicability/delivery allocation, not S11 or architecture;
IN-SO-003 and full RFC conformance remain unmet.

The same accepted disposition applies to analogous pre-existing integration/
compatibility gaps outside the selected P08 counter dependency/safety path:
preserve current sources, record the exact gap and missing evidence, and assign
mandatory I4-07 or an appropriate existing next-iteration owner/residual without
repeating the permission request. No additional such gap is asserted by this
bounded SO-03 review. Counter correctness/lifetime/cleanup/fit, newly introduced
regressions or shared compatibility breaks, and new architecture cannot be
moved out under this direction. No scoped retained dispatcher, shadow conformance,
stub target, conditional exclusion or automatic analyzer migration is selected.

## Remaining source work, subject to the recorded allowance and SO-03 review

SO-04→05→06 remains sequential. A coherent source freeze spans all three before
whole-host validation, because removing the old Optional and adding complete
scoped carriers are one dependency chain. Each subtask records its own diff/
source/evidence checkpoint; no intermediate broken overlay is called usable.

Allowed additional maintained files, bounded to SO-01 D03–D26/D34:

- SPEC015 RuntimeDerived new `CounterScopedStorage.swift`, plus
  `StaticCounterEmbeddedBacking.swift`, `CounterProfileStorage.swift`,
  `CounterGeometry.swift`, `CounterStaticGeometry.swift`,
  `CounterStorageMeasurement.swift`, `CounterStorageRegions.swift`,
  `CounterHostOwner.swift`, `CounterDynamicHostOwner.swift`,
  `CounterPipelineOwner.swift`, `CounterHostProbe.swift`,
  `CounterDynamicHostProbe.swift`, `CounterCoordinatorProbe.swift`,
  `CounterFixedStorageProbe.swift`, `CounterGraphProbe.swift`,
  `CounterRouteEntry.swift`, `CounterHostCorpus.swift`;
- new directly corresponding initialization/session/lifecycle/negative fixtures
  in SPEC015 RuntimeDerived and directly corresponding Interaction/runtime unit
  test files from the frozen SO-01 index; list each new path in dispatch before editing;
- Static/DynamicRuntimeExecutionCoordinator.swift only if a required preserved
  constraint/Optional dependence needs correction, with exact contract citation;
- `scripts/contracts/check-spec-015-counter.py`, `check-spec-015-scoped-host.py`,
  `check-spec-013-runtime-cycle.py`, `check-spec-011-owned-keys.py`, existing
  `run-spec-011.sh`, `run-spec-013.sh`, `run-spec-015.sh` and
  `driver-registry.tsv` only for changed input registration/contract pairs;
- `scripts/contracts/build-spec-015-counter-image.py`,
  `firmware/nrf52840/applications/signal-analyzer-static/src/counter_main.c`, and
  that application's `Counter.cmake`: only current field/slot byte constant,
  selected source handoff and existing recipe registration. Limits/board/
  linker ownership policy cannot change;
- affected derived notes/plans/receipt only; accepted contract text/statuses
  stay unchanged. Frozen Evidence snapshots are never edited.

SO-04 records the provisional checked-layout formula/typed field order/prefix
ledger and unvalidated C reservation constant at a source checkpoint. Numeric
SO-04 validation/acceptance stays open for the SO-07 target layout-facts table
and SO-08 ELF/map/C-symbol comparison specified in the design. No earlier probe
is proposed; mismatch or necessary constant correction/rerun stops for separate
allowance. No invented current-target number is accepted. Then
SO-05 completes every carrier/cleanup/retirement path and SO-06 adds the actual
transaction/lifecycle corpus. No automatic compiler probing between these
source tasks. Before whole-host invocation, freeze every allowed/new file,
compiler/flags/macro/core input and exact finite test labels; inspect no-alias,
private visibility and every cleanup path. Then one independent Strong source
review stops the package before SO-07. If a source defect needs a different
contract, stop upstream. No new exploration or variant search is included.

## Known pinned identities and ordered SO-07 proposal

These are inspected existing receipt identities, not guessed new outputs.
`C` is the matching GiftUI/core receipt directory below. `R` is the old runtime
recipe source; changed owners are freshly rebuilt by the owner drivers. `H` is
`.build/contracts/p08-scoped-host-c5eocina`, the existing common host recipe.

| Profile, in order | C | R |
| --- | --- | --- |
| macos-dynamic | `.build/contracts/spec-006-rfc-014-swift64/af66aaf967e3fe8f-__4p5wu2/macos-dynamic` | `.build/contracts/spec-013-runtime-cycle/tmp_63jv4xj/macos-dynamic` |
| macos-static | `.build/contracts/spec-006-rfc-014-swift64/b694e911d7d7658a-gn53u2vi/macos-static` | `.build/contracts/spec-013-runtime-cycle/tmp0q82npqp/macos-static` |
| raspberry-pi-armv6 | `.build/raspberry-pi/contracts/spec-006-rfc-014-swift64/39961046dd4e63d8-aj3k5c43/raspberry-pi-armv6` | `.build/raspberry-pi/contracts/spec-013-runtime-cycle/tmpvq70p7a0/raspberry-pi-armv6` |
| nrf52840-embedded | `.build/nrf52840/contracts/spec-006-rfc-014-swift64/39961046dd4e63d8-lv470rbm/nrf52840-embedded` | `.build/nrf52840/contracts/spec-013-runtime-cycle/tmp9d1k2h7s/nrf52840-embedded` |

Host compiler `.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc` and nRF
compiler `.toolchains/nrf52840/swift/swift-6.4.0-RELEASE-osx/usr/bin/swiftc`
have recorded SHA-256 `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`.
Use the matching receipt's exact target/SDK/flags and macro
`.build/rfc014-p02-swift64/tool/debug/GiftUIMacros-tool#GiftUIMacros`, rechecking
actual hashes. Swift 6, -Osize, whole-module optimization, package giftui,
LifetimeDependence/Lifetimes and existing defines remain. No new compiler,
non-escapable associated-type feature or disabled-exclusivity flag. A stale
unaffected core receipt stops instead of triggering an unbounded rebuild.

At the reviewed complete source freeze, format once, then for each profile in
the table run this exact ordered driver form, substituting that row's profile/C.
`Rfresh` and `Hfresh` mean the actual successful output paths reported by the
preceding commands; log and hash them before use, never invent a directory.

```text
scripts/contracts/run-spec-011.sh --profile PROFILE --compiler-baseline rfc-014 --giftui-build C
scripts/contracts/run-spec-013.sh --profile PROFILE --compiler-baseline rfc-014 --giftui-build C
python3 scripts/contracts/check-spec-015-scoped-host.py --runtime-build Rfresh
scripts/contracts/run-spec-015.sh --profile PROFILE --corpus rfc-014-counter --runtime-build Rfresh --host-build Hfresh
```

Rfresh comes from the second command. Run the third command only on the two
native profiles: that component driver explicitly rejects target profiles.
Hfresh comes from each native third command; for both targets use the fresh
macos-static Hfresh as the host source/recipe receipt, as the existing counter
driver does. Target counter compilation rebuilds its actual selected owners and
does not link those native component objects. The third command compiles
existing owned host/controller component compatibility; it does not substitute
for the fourth's actual counter carriers. All routes retain original
controls and add the complete required scoped negative matrix. Target results
are compile/inspection only. Two native routes execute the lifecycle/transaction
and classified runtime-exclusivity pairs. Cross-profile negative applicability
is explicit, with positive twin and intended failure cause; no broad P10 suite.

Proposed maximum: 14 driver invocations, one per cell (including their declared
fixed internal compiles), no retries on failure. The SO-03 first-slice result
can be reused for its unchanged inputs/cases; record an explicit reuse instead
of a redundant invocation. One proposed source-repair allowance for the entire
SO-04–08 package may be considered **only after** separate Strong diagnosis of
a failure, with a newly recorded exact diff and affected command subset. It
allows at most one rerun of each affected driver and counts against that same
single repair; it is not automatically authorized by an initial allowance.
A second failure or any safety/contract defect freezes evidence and stops.
Successful results do not authorize additional variants or P09.

The top-level registry remains intact. Any wider repository gate required by
code review is a separate explicitly bounded continuation; the default
`scripts/test.sh` currently expands baseline/legacy owners, so this proposal
does not silently run it as a scoped P08 check or claim full repository/P10
acceptance. SO-09 must disclose any remaining required repository validation.

## SO-08 early images, measurement, and independent exit

After a passing frozen four-profile corpus, use the existing Pi/nRF toolchain
and build skills before these two image invocations, once each. Run the skills’ read-only
`scripts/raspberry-pi/doctor.sh` and `scripts/nrf52840/doctor.sh` once first;
any missing/mismatched toolchain stops, with no setup/repair/probe authorization. `PiCounter` and
`NRFCounter` are actual fourth-command outputs; the existing Pi static SDK
JSON is named explicitly. The new image output remains under the existing
per-target .build roots.

```text
python3 scripts/contracts/build-spec-015-counter-image.py --profile raspberry-pi-armv6 --counter-build PiCounter --output .build/raspberry-pi/rfc015-scoped-counter-image --destination-json .toolchains/sdk/swift-6.4.0-RELEASE-raspios-bookworm-armv6/raspios-bookworm-static.json
scripts/nrf52840/build.sh --application signal-analyzer-static --counter-build NRFCounter
```

Maximum: one Pi link and one supported nRF firmware invocation (fresh firmware
objects through current recipe), no automatic image repair/retry. Preserve any
failure before independent review. Inspect emitted ELF/map/disassembly and
source/command/artifact hashes without recompilation. Record ARMv6/VFP and
ARMv7E-M/hard-float ABI, allocator reachability, full original-owner/role ledgers,
RAM/flash and every feasible construction/body-return/helper/IRQ path from the
design. No new diagnostic compiler/IR capture is included. If binary evidence
cannot establish a finite complete stack bound, report the exact missing path
and stop; never substitute smaller source handles/link success or a partial frame.

SO-09 freezes the full applicable matrix, residual I4-07 rows and existing
P08/R07/T8.1 gates for a separate read-only Strong exit review. Any missing fit,
cleanup, lifetime, timing or validation evidence remains unmet. No criterion
becomes fully met from partial P08 coverage; no implemented transition is requested.

## Preserved counters and stops

The authorized SO-03 native driver counter is **0/1 consumed, 1 remaining**;
automatic repair allowance is **0**. SO-04–09 production counters remain
**zero/new allowance pending**. Historical helper 2/2, B03 1/1, GOT 1/1, prior image/backing-image,
phase correction/image and optimized-IR capture 1/1 remain consumed; SPIKE-075's
seven cumulative experiments remain closed. The package's two-consecutive-
unproductive guard persists across author/model/task changes. Independent
review assesses each result as productive or unproductive and preserves the
actual cumulative record; a fresh slice name never resets it. Reaching that
guard stops even with a nominal unused proposed command cell.

The last qualified construction remains 58,648 versus 27,648. No limit,
workload, model-transition bank, source/admission storage, SDK/architecture,
zero-heap or timing relaxation; no remote deploy/restart, flash, connected
target test, P09–P12 execution or new exploration is included.
