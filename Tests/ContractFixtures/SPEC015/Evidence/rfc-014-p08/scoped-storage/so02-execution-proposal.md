# SO-02 concrete next execution proposal — NOT AUTHORIZED

This proposal accompanies the [physical design](../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md).
It requests no permission by inference. Bounded independent verification of the
B1/B2 corrections is next. The source-level analyzer applicability blocker below
means the production allowance is **not ready** merely because documentation
coverage is corrected. After its explicit disposition, the maintainer must
record the bounded
allowance in the existing [P08 receipt](../progress.md) before source/compiler
work. All values below are proposed maxima, not remaining authorized counters.
No compiler, source edit, build, experiment or hardware action ran in SO-02.

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
- `Package.swift`: only existing relevant targets' LifetimeDependence/Lifetimes
  propagation if needed to compile the exact adopted declarations;
- `CounterStorageMeasurement.swift`, `CounterStorageRegions.swift` in SPEC015
  RuntimeDerived and `CycleStorageMeasurement.swift`, `CycleStorageRegions.swift`
  in SPEC013 RuntimeDerived: repair the four withBacking callers together with removal;
  state measurement can return only bounded owned facts, never a callback capability;
- **No edits** to the two analyzer action dispatcher factories or their
  model/root/target dependencies. Compile their actual maintained sources via
  the compatibility cells below; any required correction stops for exact
  applicability/upstream review, not automatic P09 migration.

Implement exact S11 declarations/unions/conditional conformances and selected
operation-only bounds. Add trusted minimal scoped fixture banks to test all
five independent input lifetimes and failable Optional; preserve owned tests
and existing diagnostic causes. No final physical owner or host migration yet.
Record frozen source hashes/diff and intended negative causes before invocation.

Ordered checks proposed:

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

This is a required proposed change to `check-spec-011-owned-keys.py`, not a
claim that its present two-file RuntimeCore tuple covers the affected source.
Use the same one SO-03 command above and, after source/result review, its four
SO-07 profile cells. Existing legacy labels/commands remain once each. The
proposal authorizes no execution until the applicability blocker is resolved.
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

Add these four prerequisite/actual-analyzer cells, with real maintained files:

- `so03-prereq-failure-core`: Sources/GiftUIFailureCore/GiftUIFailureCore.swift.
- `so03-prereq-analyzer-domain`: the eight files under Sources/SignalAnalyzerDomain:
  AcquisitionState.swift, ModuleBoundary.swift, SignalAcquisitionContracts.swift,
  SignalAnalyzerDiagnostic.swift, SignalCaptureChange.swift,
  SignalCapturePublication.swift, SignalPrimitiveValues.swift, SignalValues.swift,
  freezing exactly these eight paths. No glob growth.
- `so03-prereq-analyzer-presentation`: under Sources/SignalAnalyzerPresentation,
  SignalAnalyzerPresentationValues.swift and SignalAnalyzerRuntimeCondition.swift.
  These are the real ViewModel/ActionHandler/action/use-case/fact dependencies,
  compiled as SignalAnalyzerPresentation; no replacement model/handler source.
- `so03-actual-analyzer-factories`: Sources/SignalAnalyzerTargetHost/
  StaticSignalAnalyzerActionDispatcher.swift and, except Embedded,
  DynamicSignalAnalyzerActionDispatcher.swift, compiled in one dedicated
  analyzer-compatibility module importing the actual modules above. This
  focused source closure is sufficient to type-check those real factory bodies;
  compiling a lookalike fixture is not compatibility evidence.

The frozen additional *compiler* cells per invocation are exactly these six
prerequisite/factory cells plus the following 29 probe cells, at most 35 total
in addition to the unchanged legacy driver's enumerated command list. The
inspected legacy compiler counts
are 13 on native profiles (11 module compiles + one layout IR + one link),
12 on Pi (11 modules + IR), and 11 on Embedded (10 modules + IR, no Dynamic).
Thus the SPEC011 maximum is 48 native / 47 Pi / 46 Embedded compiler cells,
with one existing native execute or one existing target ABI inspection. No
retry or additional compile is hidden in a case:

| Fixed label / number of compilations | Required operation/input coverage |
| --- | --- |
| `so03-state-owned`, `so03-state-scoped`, `so03-state-failable` — 3 | Owned conditional copy/return and scoped moves, actual state and failable Optional; existing owned banks versus trusted scoped fixture inputs. |
| `so03-union-{C,H0,R0,R1,H1}-{direct,generic}-{positive,escape}` — 20 | Each of the five actual state initializer inputs independently limits lifetime; each negative has its exact positive twin. No unconstrained combinatorial generator. |
| `so03-state-copy-negative` — 1 | Reject scoped state copy for noncopyability, paired with state-scoped move above. |
| `so03-consumer-operations-positive` — 1 | Instantiate actual record append/appendProjected/dispatch, Canvas append, Transaction.build, Coordinator.build including its private discard branch through a failing occurrence, and Transaction.resolve accepted/refused. All operation consumers borrow/inout the same trusted scoped state; typed model/root/semantic dependencies remain real. Also call ExecutionGestureAdapter down/move/up on a scoped resolver. |
| `so03-retained-dispatcher-owned-positive`, `so03-retained-dispatcher-scoped-negative` — 2 | Instantiate actual RuntimeInteractionDispatcher with owned records and ordinary owned ActionModelTargetAccess; scoped Records rejection must come from the explicit retained bound. This controlled dispatcher probe does not replace the actual factories. |
| `so03-analyzer-owned-return-positive`, `so03-analyzer-scoped-records-negative` — 2 | Call both actual make factories (Static only on Embedded), preserve owned returned/copyable dispatcher, reject scoped records at the factory's owned constraint. Real ViewModel/root/target dependencies above; no extension invented to force conformance. |

All 35 cells are compile invocations, not 35 build loops. They use the pinned
compiler/flags already recovered by the driver. On native profiles extend the
existing single link/execute pair to run the positive operation/owned checks;
no second binary/link/execute loop. On targets compile/inspect only. A negative
must fail for its named ownership/lifetime cause, never a prerequisite/import/
root-type error; a failure in a prerequisite or positive cell stops immediately
and preserves partial evidence. Record exact total legacy+35 argv cells and
applicability before the first invocation; missing sources or more cells stop
for a proposal amendment. The legacy script is finite and inspected, not an
unlimited budget hidden under one invocation.

At SO-07 also explicitly register these seven RuntimeCore files in
`check-spec-013-runtime-cycle.py`'s current source tuple. Its existing Drawing/
Observable/profile prerequisite cells already compile the actual dependencies;
there is no added compiler invocation for this tuple extension. The counter
recipe replay then receives the complete current runtime tuple. The four
SPEC-011 profile cells carry the fixed B2 operation/owned/analyzer coverage;
no separate broad analyzer/P10 build is inferred. The 14 SO-07 driver maximum
therefore remains 4 SPEC011 + 4 SPEC013 + 2 native host + 4 counter, each with
its frozen internal cells. Reuse the unchanged SO-03 SPEC011 cell if qualified.

### Owned analyzer source applicability blocker

Read-only inspection at `eab732c9` identifies a **source-level concern, not an
observed compiler failure**: both actual factories declare owned root adapter/
pointer inputs, then call Dynamic/StaticObservableRootTargetAccess(root: root).
Those maintained alias files now resolve to ObservableStateRootTargetAccess,
a ~Copyable/~Escapable scoped type requiring ObservableStateModel &
ObservableModelMutation and an initializer with root scope, identity and ordinal.
The actual SignalAnalyzerViewModel declares _GiftUIObservableReference;
ActionModelTargetAccess remains the owned withCurrentModel protocol, whereas
the scoped target exposes mutate and does not declare that conformance.
Factory source was last changed at `44ac06a8`; the aliases at `a38b86f1`.
This mismatch predates the proposed S11 implementation. Package.swift selects
both factory files for its ordinary native SignalAnalyzerTargetHost target;
they are not in that target's exclusion list. P08 counter drivers do not
currently compile them; their old route passes therefore prove no applicability
exception or analyzer compatibility.

No source repair is chosen here. Independent review/upstream must determine
how to obtain the required unchanged owned factory compatibility within the
accepted P08 path and preserve exact owner contracts. A scoped dispatcher,
new model/root architecture, shadow conformance/stub target, conditional source
exclusion or P09 migration is not an allowed correction. If satisfying the
real factory check needs such work, the affected production allowance remains
blocked for exact upstream contract/applicability disposition. The reviewer must
also decide whether preserving these unchanged source files plus the real owned
RuntimeInteractionDispatcher semantic positive twin satisfies the P08 allocation,
with full actual-factory reconciliation retained for I4-07. This is an unresolved
authority/coverage disposition, not a selected exception. Until explicitly
resolved, required actual-factory compatibility cannot be silently assigned
optional/I4-07 merely because it is a baseline problem. The finite
real-source cells above specify what evidence would be required after that
disposition; they are not a route expected to fail and advertised as ready.
There is currently no passing actual-factory evidence or production allowance.

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

All currently authorized production counters remain **zero/new allowance
pending**. Historical helper 2/2, B03 1/1, GOT 1/1, prior image/backing-image,
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
