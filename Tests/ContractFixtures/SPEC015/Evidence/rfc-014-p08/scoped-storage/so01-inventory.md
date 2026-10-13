# SO-01 contract, necessity and caller inventory — 2026-10-13

Documentation-only result at source `59d98712`. No Swift source, generator,
compiler, test, build, experiment or hardware execution occurred. This inventory
does not prove a declaration compiles, a lifetime is enforced, or storage fits.
All nine SO criteria, HC-RD-003, P08/R07/T8.1 and later package gates stay open.

## Authority and delivery boundary

[ADR-039](../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md) is
accepted; [S11/S13/S15](../../../../../../docs/iterations/iteration-003-review/rfc-015-spec-amendments.md)
are approved and applied. The [shared plan](../../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md)
and SPEC-011 T12.1 / SPEC-013 T11.1 / SPEC-015 T8.1 adopt SO-01–09.
The [handoff](../../../../../../docs/iterations/iteration-003-review/rfc-015-p08-handoff.md)
and [delivery allocation](../../../../../../docs/iterations/iteration-003-review/rfc-015-delivery-allocation.md)
govern this slice. Existing ADR-007/008/035/036/038 responsibilities remain.
This is post-MVP ITERATION-003 I3-04/I3-05: runtime-derived finite counter and
target stack validation, preserving the closed ITERATION-001 analyzer controls.
Full RFC-015 delivery is ITERATION-004 I4-07; iteration selection grants no
exception or additional execution budget.

The necessity test below uses three dispositions:

- **P — required change/proof:** an actual finite counter dependency, changed
  shared declaration, compatibility break, or existing P08 safety/fit gate.
- **O — preserve owned:** inspect and validate the existing owned route; only a
  necessary compatibility edit is in P08. No uniform scoped conversion.
- **R — I4-07 residual:** full-scope reconciliation, downstream integration and
  conformance beyond the P08 dependency/proof. No adopted-path safety/fit duty
  can be assigned R merely because it is difficult or fails.

## Caller-to-disposition table

Paths in this table are repository-relative. `Counter/` means
`Tests/ContractFixtures/SPEC015/RuntimeDerived/`; `Cycle/` means
`Tests/ContractFixtures/SPEC013/RuntimeDerived/`. The accompanying
[complete caller index](so01-caller-index.md) records concrete files, symbols,
line locations and source SHA-256s for direct and expanded transitive searches.
The table below identifies the necessary change and preserved behavior for each
caller family; the index is not an automatic edit allowlist.

| ID / current file and symbols | Disposition and concrete P08 necessity | Required proof / preserved oracle |
| --- | --- | --- |
| D01 `Sources/GiftUIInteraction/InteractionStorage.swift`: InteractionCandidateRecordStorage, InteractionCommittedRecordStorage, InteractionHitRegionStorage | P, SO-03: exact three Self suppressions allow the five concrete scoped bank accesses through the existing machine. Preserve every method/Identity/count/capacity/result requirement. | IN-SO-001/003, B1/B3; owned records and UInt16 bounds; no seventh Interaction protocol. |
| D02 `Sources/GiftUIInteraction/InteractionValues.swift`: InteractionCandidateBuilder, InteractionGestureResolver, InteractionCommittedActionView | P, SO-03: exact remaining three headers make operation-only build/gesture/dispatch possible. InteractionDispatcher remains owned. | IN-SO-001/003; borrowed reads return owned records/results; keep GestureResolver identity equalities and existing dispatch contract. |
| D03 `Sources/GiftUIInteraction/InteractionState.swift`: InteractionState.init, five private bank fields, withBacking, begin/finish/resolveCandidate | P, SO-03: suppress both implicit constraints, retain exact five-input lifetime union and conditional owned conformances; remove exporting withBacking callback in favor of owned bounded facts. One phase/transaction machine. | IN-SO-001–003; independent five-input copy/escape controls, Optional compatibility, accepted R/H exchange and revision, refusal/discard reset, capacity/error precedence. |
| D04 `Sources/GiftUIInteraction/InteractionOwnedKeyState.swift`: InteractionOwnedKeyState.init?, state, withBacking, append, identityCapacities, resetAllStorage | P, SO-03: state lifetime union, conditional conformances and failable Optional; same complete-key counters/limits; remove callback export. | IN-SO-001–003; no duplicate owner/lease; complete copied keys, semantic reuse, changed identity/role/modifier/target/action and first-excess controls. |
| D05 `Sources/GiftUIInteraction/ExecutionGestureAdapter.swift`: down/move/up Resolver | P, SO-03: Resolver explicitly permits both suppressions and remains borrowed for counter gesture handling. | IN-SO-001/003; same capture/cancel/current presentation behavior and owned outcomes. |
| D06 `Sources/GiftUIRuntimeCore/RuntimeRecordInteractionBridge.swift`: append, appendProjected C/R/H; dispatch Records | P, SO-03: storage bounds and borrowed Records admit scoped state; existing model/root/role/Identity constraints remain. Counter currently uses this dispatch. | IN-SO-001/003; operation-only owned mutation/result, missing/stale target, invalid domain/value and generation checks. |
| D07 `Sources/GiftUIRuntimeCore/RuntimeRecordCanvasInteractionBridge.swift`: append C/R/H | P, SO-03: corresponding counter Canvas action path must accept the same scoped state. | IN-SO-001/003; same semantic/action projection and owned append outcome. |
| D08 `Sources/GiftUIRuntimeCore/RuntimeInteractionCandidateTransaction.swift`: build Interaction; RuntimeInteractionCandidateCoordinator.swift: build/discardCandidates; RuntimeInteractionCandidateResolution.swift: resolve | P, SO-03: explicit operation-only Interaction suppressions through every intermediate, retaining current inout, identity/observable/capture constraints. | IN-SO-001/002/003; one build/finish/offer resolution, same generation allocator commit/discard and failure cleanup. |
| D09 `Sources/GiftUIRuntimeCore/RuntimeInteractionDispatcher.swift`: retained Records/init/dispatch | O/P, SO-03: spell Copyable & Escapable on retained Records after shared protocol relaxation; retain owned Handler/TargetAccess, non-consuming init and InteractionDispatcher conformance. | IN-SO-003; native owned return/copy and stale generation cancellation. No retained scoped dispatcher is needed by current counter source. |
| D10 `Sources/GiftUIRuntimeStatic/StaticInteractionStorage.swift`: Static and StaticSix candidate/committed/hit banks, state aliases; `Sources/GiftUIRuntimeDynamic/DynamicInteractionStorage.swift`: Dynamic banks/alias | O: retain owned bank implementations and aliases through conditional state conformances. No scoped substitution or capacity/allocation change. | IN-SO-001/003, B3; Static/StaticSix size and capacity controls, Dynamic reserved capacity/COW behavior unchanged on owned paths. |
| D11 `Counter/StaticCounterInteractionStorage.swift`: StaticTwo banks/StaticTwoInteractionState; CounterProfileStorage.swift: CounterStaticCandidate/Committed/Hits/Keys, CounterDynamicCandidate/Committed/Hits/Keys | O: these owned concrete types remain for native coordinator/workspace compatibility and physical owner storage; session accesses are distinct capabilities, not duplicated inline banks in carriers. | IN-SO-003; 2 actions/hits, complete keys with 24 per-key / 48 per-bank components, owned return path. |
| D12 `Counter/CounterStorageMeasurement.swift`: CounterCandidateBacking/CommittedBacking/HitBacking, counterMeasureInteraction, CounterReturnedWorkspaces; CounterStorageRegions.swift: counterVisitInteraction | P, SO-03/04/05: repeat Self permissions in fixture measurement contracts; replace both withBacking uses by owned bank facts; keep CounterReturnedWorkspaces explicitly owned G/C/R/H. Physical bytes must not become adapter MemoryLayout. | IN-SO-003, RP-SO-001, HC-SO-002; every original bank/count/extent/identity charge reconciles before/after role swaps; owned workspaces continue to return. |
| D13 `Cycle/CycleStorageMeasurement.swift`: cycleMeasureInteraction; CycleStorageRegions.swift: cycleVisitInteraction | P compatibility only, SO-03: the other two maintained withBacking callers necessarily change when the shared callbacks disappear. CycleCandidate/Committed/HitBacking and CycleReturnedWorkspaces remain owned. | IN-SO-003/B3; keep six-action keys, counts, retained payload/metadata partition and existing RP-RD accounting. Deferring these callback repairs would break a maintained owner gate. |
| D14 `Counter/StaticCounterEmbeddedBacking.swift`: counterEmbeddedField, CounterEmbeddedProfileStorage.init/deinit/audit/reset*, interaction accessor, counterSelectedProfileBacking/counterMakeSelectedProfile | P, SO-02/04: old initialized CounterStaticKeys? object binding/init/get/take/audit/deinit must migrate together; no live overlay. Checked final typed geometry/five-bank initialization and reverse prefix destruction needed by actual nRF host. | RP-SO-001/002, HC-SO-002, B2; old slot/control/used identities and each return path accounted, original destruction inventory independent of role, unchanged workload and no guessed fit. |
| D15 `Counter/CounterProfileStorage.swift`: CounterStaticWorkspaceBacking.withGeometry/measurement, counterValidateBacking, StaticCounterProfileStorage and DynamicCounterProfileStorage init/audit/run/reset* | P, SO-02/04/05: selected counter host needs physical owner/session and owned audit facts; current geometry/interaction Optional take cannot carry new capabilities by copying them. Preserve existing owned run/workspace compatibility. | RP-SO-001–003, HC-SO-002/003; exact typed region/descriptor/padding/temporary accounting, Static no heap, matched Dynamic payload/overhead and alias exclusion. |
| D16 `Counter/CounterGeometry.swift`: CounterGeometry, StaticCounterGeometry, DynamicCounterGeometry, withCounterRenderLimits; CounterStaticGeometry.swift: LocalSemantic, QualifiedLayout, QualifiedRender | P, SO-02/04: finite geometry contract admits scoped Self; final typed physical objects and restricted common-session access replace ordinary by-value geometry in selected host carriers. Existing algorithms/views remain operation-local. | RP-SO-001/003, HC-SO-001/002; all geometry lifetimes, independent escape controls, checked alignment/disjointness; raw internal render callback stays bounded and returns owned result. |
| D17 `Counter/CounterHostOwner.swift`: CounterHostSuppliedStorage, CounterHostSupplied, CounterHostPipeline, CounterHostCoordinator, scoped-control CounterPipelineOwner.init, CounterHostState, CounterHostOwner | P, SO-05: complete G/C/R/H permissions/private fields and geometry+interaction lifetime inputs, consuming session→supplied→pipeline→coordinator→host→retirement path including activationSpan. Replace retired field tuple by scoped retired carrier; consume instead of copying dying fields. | HC-SO-001/002, RP-SO-002/003; inert/failure/active transitions, cache-ticket release before quiescence, reset semantic→geometry→Interaction, every model/root/semantic/value/control/session/span dependence. |
| D18 `Counter/CounterDynamicHostOwner.swift`: CounterDynamicHostSuppliedStorage, CounterDynamicHostSupplied, CounterDynamicHostPipeline/Coordinator, CounterDynamicHostState, CounterDynamicHostOwner | P, SO-05: actual macOS/Pi Dynamic chain uses the shared CounterPipelineOwner, DynamicCounterGeometry and Dynamic keys; it must propagate the same complete union and consuming retirement. | HC-SO-001/002, RP-SO-002/003; same lifecycle and cleanup transcripts as Static, real Dynamic backing ownership with no live shared/COW mutable alias. Not present in Embedded. |
| D19 `Counter/CounterPipelineOwner.swift`: CounterPipelineOwner.init, interaction/geometry fields, returnWorkspaces, handleInput, buildInteractionCandidate, resolve/cleanup; CounterCoordinatorProbe.swift: exerciseCounterCoordinator/runCounterCoordinator/p08CounterCoordinator | P/O, SO-03/05/06: shared pipeline accepts capabilities, but returnWorkspaces becomes an extension available only to owned G/C/R/H. Probe's owned Optional.take→quiesced Optional→owned return continues. | HC-SO-001, RP-SO-002, IN-SO-003; scoped retirement returns owned checks only; build/offer/finalize and admitted queue transcripts unchanged. |
| D20 `Sources/GiftUIRuntimeStatic/StaticRuntimeExecutionCoordinator.swift` and `Sources/GiftUIRuntimeDynamic/DynamicRuntimeExecutionCoordinator.swift`: init, admission/opportunity, takeQuiescedOpportunity | O/P only if required: already explicitly permit both suppressions for Binding/Admission/Opportunity, have consuming constructor union, private setters and lifetime-dependent consuming Optional extraction. Preserve these; no redesign. | RP-SO-002/003, HC-SO-001; direct/generic Optional positive/negative pairs retain every dependence and quiescence requirement. |
| D21 `Counter/CounterHostProbe.swift`: runCounterHost, counterCheckRejectedBindings, counterRunHostLifecycle, p08CounterHost; CounterDynamicHostProbe.swift: runCounterDynamicHost/p08CounterDynamicHost | P, SO-04/05/06: actual body installs cleanup before activation/any failure return, uses exclusive factory and consumes retirement. Four slots/lifecycle variants must be audited, including pre-host return paths. | RP-SO-002, HC-SO-001/002; six rejected joins no effects, seven failure points, teardown once, callback/pin/cache/backing order and repeats. Existing negative seams require exact maintenance. |
| D22 `Counter/CounterHostAssembly.swift`: CounterConstructionInputs/Negative/Observation, CounterHostGraph, CounterHostAssembly.validate; CounterGraphProbe.swift: p08CounterGraph | P evidence, SO-04/06: preserve graph-first valid-only construction; new physical provenance/pair capacity checks occur before session/effects. Only needed physical facts may change input plumbing. | HC-SO-002/003, HC-RD-001/002; 13 edge omissions + 3 hidden/bound-input negatives reject before eight projections; exact nine-stage ledger/report/first error preserved. |
| D23 `Counter/CounterAdmission.swift`: CounterExecutionBinding/CounterAdmission; CounterWakeIntegration.swift: counterServiceHost/counterWakeControls; CounterHostCorpus.swift: counterHostCorpus/counterCheckHostFrame | O/P evidence: already operation-only generic host/coordinator use. Keep control lifetime joins and all wake/scheduler/input behavior, change only necessary capability propagation. | HC-SO-002/003, HC-RD-004, RP-RD-002/004; accepted/refused queue, 34/35 bound, timestamps, wake categories/deadlines, one logical frame and stale action transcripts. |
| D24 `Counter/CounterPixelOracle.swift`: counterCheckPixels; CounterNativeRaster.swift/CounterTiledRaster.swift/CounterRender.swift; CounterModel*/CounterSemantic*/CounterWorkload.swift/CounterApplication.swift/CounterFixedStorageProbe.swift | O/P evidence: independent application, semantic, action and native raw-RGBA/target tiled text+stroke controls continue; geometry/session migration cannot replace them with self-consistency answers. | IN-SO-002, HC-SO-002/003; existing pixels, values 0…9, enabled/disabled actions, tiny Canvas stroke and fixed limits unchanged. No workload reduction. |
| D25 `Counter/CounterRouteEntry.swift`: giftuiRFC014CounterEntry, p08CounterRoute; `scripts/contracts/run-spec-015.sh --corpus rfc-014-counter`, check-spec-015-counter.py | P, SO-07: exact four registered selected routes, generated source list/negative generator seams and recipe hash exceptions must follow changed source explicitly. Generator is maintained; emitted historical negatives are frozen evidence. | HC-SO-003, RP-SO-003, B1/B3; three existing copy/backing negative oracles and positive twins preserved, target Dynamic negative excluded only for Embedded; add required per-input matrix without weakening failures. |
| D26 `scripts/contracts/run-spec-011.sh`, check-spec-011-owned-keys.py; run-spec-013.sh, check-spec-013-runtime-cycle.py; check-spec-015-schema4.py/check-spec-015-scoped-host.py | P compatibility/evidence: owner gates compile shared declarations and owned Cycle/activation fixtures; maintain directly affected generated declarations/caller constraints while keeping existing controls. | IN-SO-001/003, RP-SO-002/003, HC-SO-001/003; source/compiler/macro/input hashes, named expected diagnostics, positive twins and owned returns. No unchanged baseline rerun by inference. |
| D27 `Sources/GiftUIHostConfiguration/SignalAnalyzerPresetHostInstance.swift`: SignalAnalyzerPresetLiveOwner, SignalAnalyzerPresetHostInstance, four factories; RuntimeCompletePipeline/RuntimeCoordinatorContracts and execution owner contracts | O: already admit scoped owner where selected; host's lifetime(copy owner) and activation validation stay. No new protocol relaxation beyond the six Interaction headers. | HC-SO-001/003; host/controller tests and generated schema/graph first-error controls; actual counter owner flows through existing instance. |
| D28 `Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerActionDispatcher.swift`, StaticSignalAnalyzerActionDispatcher.swift: make Records; DynamicSignalAnalyzerPresentationPipeline.swift: interaction/build/resolve/dispatch | O/R under the current applicability amendment below: factory sources/owned constraints unchanged; real shared retained-dispatcher controls in P08, unresolved actual-factory integration/evidence mandatory I4-07/P09 handoff. DynamicInteractionState remains owned. | IN-SO-003/B3; analyzer action/generation, presentation/refusal and native return tests unchanged. Full runtime-derived analyzer migration remains P09/P10/P11, not SO-01's finite slice. |
| D29 `Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedInteractionOwner.swift`: owned state and protocol conformance; NRFApplicationStorage/Owner.withInteraction, PresentationCommitter, InteractionHandler/Session, ApplicationInputOwner, InteractionCandidateProducer | O: owned StaticSix/StaticInteractionState and existing pointers/inout remain; callback Result stays ordinary owned, pointer lifetime duties remain. Embedded custom owner is not converted to scoped storage. | IN-SO-003/B3; analyzer gesture/action/candidate/storage/assembly tests, generation/disabled/refusal and retained handler behavior. |
| D30 analyzer transitive host entry/presentation handoff/runtime storage/embedded gesture and input handlers, firmware StaticPreset/rehearsal hooks, macOS mains (exact paths in index) | O: references to D28/D29 require compatibility checks, no automatic source migration; no new retained scoped path found. | IN-SO-003/HC-SO-003; existing analyzer target/control applicability and later P09–P12 obligations remain; no connected evidence claimed. |
| D31 `Cycle/` owned profiles/pipeline/coordinator/pipeline probes plus `SPEC015/RuntimeDerived/ActivationJoin*`, ScopedHostProbe; SPEC011 InteractionProbe/KeyLayoutProbe | O/P compatibility: preserve owned six-action aliases and owned workspace return; only actual shared declaration/callback break fixes. Existing scoped model/semantic/control/span carriers remain their existing tests. | IN-SO-003, RP-SO-002/003, HC-SO-001; old immutable diagnostic and action/key/count controls stay, without claiming these prove new finite-bank lifetime unions. |
| D32 all unit/test-double callers in complete index | O/P tests: array/test record storage conformers remain owned; ProfileDifferentialTests.exerciseInteraction uses owned states; dispatcher mocks and transaction/coordinator mock builders remain owned. Add only contract-required pairs/corpus, preserve old assertions. | IN-SO-001–003/B3; InteractionCandidateAppendTests, Static/DynamicInteractionStorageTests, ProfileDifferentialTests and all runtime/host tests listed in index are compatibility oracles. |
| D33 maintained generated output and producers | O/P compatibility: SignalAnalyzerPresets.generated.swift imports Interaction and supplies limits only; target generated graph/text/Canvas/model files and finite lowerer do not retain these scoped types. CounterSchema/Counter/Table modules are freshly emitted by the existing lowerer, not migration targets for bank ownership. Preserve schemas/portable declarations/workload. | HC-SO-003/B3; recheck generated text after any changed producer; P10's legacy generated checker 208-vs-168 applicability gap remains open. |
| D34 `scripts/contracts/build-spec-015-counter-image.py`, `scripts/nrf52840/build.sh`, actual firmware main.c root and caller BSS; existing Pi/nRF toolchain/build routes | P, SO-08: current early images must use the adopted chain with exact target ABI, physical regions and complete enclosing construction/helper/feasible IRQ stack accounting. | RP-SO-003, HC-SO-003/HC-RD-003; no link-only fit claim, unchanged RAM/flash/heap/main-stack limits. No deploy, restart or flash. |

All four maintained `.withBacking` call sites are D12/D13; the two definitions
are D03/D04. Searches found no additional maintained storage-export callback
under that name. Remove the definitions only together with those compatibility
repairs. Other `withInteraction`, model/semantic/Canvas lifetime callbacks and
operation-local unsafe callbacks are different contracts, not replacement bank
export APIs.

## Actual route and compiler identities

The common registered entry is `scripts/contracts/run-spec-015.sh --profile
<profile> --corpus rfc-014-counter --runtime-build <matching receipt>
[--host-build <matching host receipt>]`, delegated to check-spec-015-counter.py.
It derives flags/compiler from the RuntimeCycleProbe recipe, verifies compiler,
macro, source/artifact hashes and rebuilds selected runtime owners. Host receipt
defaults to `.build/contracts/p08-scoped-host-c5eocina`. Future receipts must
freeze their actual paths; these old paths are not authorization to execute.

Read-only identities below come from the four immutable
[phase-split receipts](../remaining-implementation/r07-firmware-recipe/production-attempt/backing-realization/phase-split/result.md)
at source `63e717d1`. They remain the last qualified route results; SO-01 has
not rerun them or relabeled them as scoped-storage validation.

| Profile | Actual root/owner/storage selection | Compiler/target/features and preserved result |
| --- | --- | --- |
| macos-static | p08CounterRoute→p08CounterGraph+p08CounterHost→CounterHostOwner→StaticRuntimeExecutionCoordinator→CounterPipelineOwner; non-Embedded StaticCounterProfileStorage, StaticCounterGeometry, StaticTwo banks. Main also exercises owned coordinator/model/semantic/fixed-storage probes. | host Swift 6.4.0, arm64-apple-macosx26.0, MacOSX26.5.sdk; no Dynamic-route define; full-surface native endpoint. p08-counter-qo3vbsn0: 1,349,555 assertions, 0 failures, 24/24. |
| macos-dynamic | route Dynamic define selects p08CounterDynamicHost→CounterDynamicHostOwner→DynamicRuntimeExecutionCoordinator; DynamicCounterProfileStorage/Geometry/banks. The common source module also compiles Static compatibility. | host Swift 6.4.0; same macOS target/SDK, GIFTUI_DYNAMIC_PROFILE and GIFTUI_COUNTER_ROUTE_DYNAMIC; full-surface native endpoint. p08-counter-e00kvr4q: 1,349,501/0, 24/24. |
| raspberry-pi-armv6 | Dynamic route, Linux counterDynamicHostKind=.raspberryPiDynamic; same Dynamic chain, tiled endpoint. | host Swift 6.4.0; armv6-unknown-linux-gnueabihf; matching `.toolchains/sdk/swift-6.4.0-RELEASE-raspios-bookworm-armv6/raspios-bookworm` SDK, usr/lib/swift_static, lld, GCC SDK toolchain, -march=armv6 -mfloat-abi=hard -mfpu=vfp; GIFTUI_COUNTER_ROUTE_DYNAMIC + GIFTUI_COUNTER_TILED. p08-counter-kwh6apf1: compile/negative 28/28, no execution. |
| nrf52840-embedded | giftui_rfc014_counter_entry(write,backing,byteCount)→Static route graph+host; CounterEmbeddedProfileStorage with 4 caller slots, StaticCounterGeometry/StaticTwo keys; selected host kind .nrf52840Static; tiled writer. | `.toolchains/nrf52840/swift/swift-6.4.0-RELEASE-osx/usr/bin/swiftc`; armv7em-none-none-eabi; Embedded, Cortex-M4 hard float/fpv4-sp-d16; GIFTUI_COUNTER_TILED; -Xfrontend -function-sections/-disable-stack-protector. p08-counter-yhrdgas4: compile/negative 26/26. Board nrf52840dk/nrf52840; image must verify VFP ABI. |

Host compiler path is `.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc`.
Both Dynamic selections still run `p08CounterGraph` with the selected Static
audit/profile control before their Dynamic host; this shared graph-first oracle
is not a Dynamic physical-storage measurement. Native Main additionally runs
the owned Static/Dynamic coordinator probes; target entry runs the selected
graph+host root only.

Both installed compiler paths have recorded SHA-256
`79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`.
Every route uses Swift language 6, `-Osize -whole-module-optimization`,
`-enable-experimental-feature LifetimeDependence`,
`-enable-experimental-feature Lifetimes`, `-package-name giftui`,
`-parse-as-library`, `-enable-testing`, the pinned macro executable
`.build/rfc014-p02-swift64/tool/debug/GiftUIMacros-tool#GiftUIMacros`,
and its matching core receipt. No nonescapable associated type feature is added.
No exclusivity-disabling flag appears in these recorded counter flags;
SO-07 must record actual static/runtime enforcement per target, not infer it.
Package.swift currently enables lifetime features only on selected existing
targets; any necessary flag propagation for newly changed Interaction consumers
must be identified in the bounded source/command allowance, not silently
substitute Xcode Swift. Exact old argv/input/macro hashes remain in each linked
profile's result.json/commands.txt.

`CounterPipelineOwner.handleInput` resolves gesture capture then calls
`RuntimeRecordInteractionBridge.dispatch(captured, records: interaction, ...)`.
It retains no RuntimeInteractionDispatcher. Cycle's operation bridge and the
SPEC011 probe are also operation-only; analyzer factories explicitly return
the owned retained dispatcher. No new retained scoped consumer is selected.

## Physical and cleanup inputs for SO-02

Current Embedded reservation is four 30,176-byte slots (120,704 bytes). Old
CounterEmbeddedProfileStorage binds geometry workspace bytes at 21,812
(stride 2,212), `CounterStaticKeys?` at 24,024 (stride 2,412, alignment 4),
CounterControl at 26,440 (stride 3,728, alignment 8), and used Bool at 30,168.
These are historical/current **old layout** facts, not a replacement layout.
The initializer initializes the Optional to a complete five-bank owned state;
runCounterHost moves `interaction.take()` through local keys into supplied.
The audit currently copies/reads owned interaction and subtracts inline type
sizes. The destructor destroys the Optional once, then workspace/Canvas/
semantic/root/limits in reverse. SO-02 must specify a replacement reservation,
typed objects and full original physical destruction ledger before any rebind.

CounterStaticWorkspaceBacking.withGeometry currently nests four byte-region
borrows and constructs an ordinary StaticCounterGeometry by value.
Static geometry owns workspace/resolved/references/plan/render descriptors over
those codecs; Dynamic geometry owns its four Dynamic workspaces with retained
payloads. SO-02 must name every typed geometry object, not count only an adapter.
Existing byte-codec overlays are not permission to alias live typed objects.

The current complete host body nests root.withLifetime→semantic.withLifetime→
canvas.withLifetime→control pointer→activationBacking. Static host uses private
rejected-join/lifecycle helpers; Dynamic body contains its actual lifecycle.
Current supplied and pipeline initializers omit geometry+interaction in their
lifetime lists because those inputs are presently owned. New geometry/five-bank
accesses must depend on one actual-owner session and be consumed through all
those paths. Static/Dynamic active retirement currently borrows semantic and
moves/copies fields out of the extracted opportunity; replace it with consuming
retirement and preserve cache release, stop/drain, pins and once-only resolution.

Unproved local choices handed to SO-02: typed object layout and checked offsets;
concrete final-region initializers/temporary moves; disjoint typed borrowing
and private unsafe bridge; common-token construction; pair capacities/retained
extents and role descriptor exchange; prefix unwind; idle/active/release state;
all early-return cleanup guards; Dynamic alias exclusion; physical measurement
API and audit split; resource attribution. None requires changing the accepted
contract merely to write the design note. A need for retained scoped dispatcher,
omitted lifetime input, new nonescapable associated type, disabled exclusivity,
duplicated state machine or relaxed limits must stop upstream.

## Current applicability amendment — 2026-10-13

The original inventory/source identities remain the `59d98712` snapshot. The
[explicit maintainer disposition](../../../../../../docs/iterations/iteration-003-review/rfc-015-delivery-allocation.md#accepted-pre-existing-integration-gap-disposition--2026-10-13)
amends D28–D30 evidence allocation: preserve both unchanged legacy analyzer
factory files and owned constraints; P08 validates actual shared owned dispatcher
and all six operation consumers. Actual analyzer ViewModel/root adapter/scoped
target alias/initializer/ActionModelTargetAccess reconciliation and actual-factory
owned returned/copyable positive and scoped-Records rejection evidence remain
mandatory unresolved ITERATION-004 I4-07 work, coordinated with existing P09
integration and P10–P12 evidence. P09 is a separate package, not ITERATION-004.
IN-SO-003/full RFC conformance stays unmet; unchanged hashes are not compatibility
proof. Original hashes and the exact source mismatch are in the [receipt](../progress.md#so-03-applicability-and-allowance-documentation-dispatch--2026-10-13).

Analogous pre-existing integration/compatibility gaps outside the selected P08
counter dependency/safety path use the same explicit disposition: exact gap and
missing evidence, unchanged source and mandatory next-iteration owner/residual,
without repeating permission. No additional gap is asserted by this bounded
SO-03 closure review. Counter correctness/lifetime/cleanup/fit, newly caused
regressions/shared compatibility breaks and new architecture cannot be deferred.

## Criterion allocation and exact residual handoff

These rows identify required P08 coverage and remaining full delivery. Every
criterion remains unmet. SO-09 must replace planned allocation with exact
source/evidence IDs and a precise residual list; it cannot assume that a planned
subcase passed or that no residual remains.

| Criteria / old obligations | P08-required subcases | I4-07 residual after P08 |
| --- | --- | --- |
| IN-SO-001 / B1 | D01–D08 declarations; both state unions and conditional owned/failable Optional; direct/generic independently scoped five-bank and geometry chain copy/escape pairs on all four routes. | RFC-wide declaration/caller/test reconciliation after iteration-4 integration and complete owner conformance disposition. No known required P08 matrix subcase deferred. |
| IN-SO-002 / IN-RD-001/002 | Actual same-session R/H paired exchanges, unequal counts, equal logical/unequal sufficient physical extents, unequal/undersized rejection before session, accepted/refused/discarded paths, semantic reuse, identity/generation/capacity/stale action transcripts. | Reconcile unchanged reusable key/action controls against full RFC scope and any integration changes. No adopted counter transaction case deferred. |
| IN-SO-003 / B3 | Complete caller inventory, mandatory four callback repairs, shared owned dispatcher/native compatibility and unchanged analyzer factory sources under the explicit amendment, inaccessible construction/extraction/arbitrary-conformer controls, measurement of every physical bank before/after swaps. | Mandatory actual analyzer model/root/target/factory reconciliation and owned returned/copyable positive/scoped-Records rejection evidence, coordinated with existing P09 integration; complete full consumer/conformance reconciliation including packaging changes. Optional scoped analyzer/retained-dispatcher conversion is excluded from RFC-015 itself, not residual implementation. |
| RP-SO-001 / RP-RD-001 | All selected physical objects/bytes/padding/control/provenance/inventory, fault at every typed acquisition and reverse successful prefix, pair-capacity boundary tests, no live Optional overlay. | Full-scope physical documentation/conformance reconciliation and refresh of paths later changed by integration. No finite owner's physical field or fault path deferred. |
| RP-SO-002 / RP-RD-002 | Both profile pre-host/failure/candidate/commit/refusal/quiescence/repeat-session paths, consuming coordinator Optional/retirement and once-only reset/cleanup, classified exclusivity positive/negative twins. | Full-scope lifecycle evidence reconciliation after iteration-4 integration. No reachable selected-body cleanup path deferred. |
| RP-SO-003 / RP-RD-003/004 | Four-profile entire lifetime matrix, real linked Pi/nRF early images, allocation/ABI and complete construction/helper/feasible IRQ ledger, unchanged limits and matched Dynamic costs. | Full owner conformance/reuse reconciliation; later analyzer integration evidence remains its own P09–P12 work and may force refresh, not a substitute for P08 fit. |
| HC-SO-001 / HC-RD-001/002 | D17–D21 actual complete chain; each bank, geometry, model/root/semantic/value/control/activation span independently; copy/use-after-consume/escape/Optional/tuple/generic/closure/workspace/Sendable-task/construction/extraction/overlap controls with positive twins. | Full RFC carrier/conformance reconciliation and changed external integration refresh; no listed counter lifetime/control category deferred. |
| HC-SO-002 / HC-RD-002/004 | One slot/binding/init/control/audit/deinit migration, before-activation validation and first error, fault/early/repeat transcripts, original action/semantic/pixel controls unchanged, backing last. | Full-scope documentation and conformance reconciliation for paths changed in iteration 4. No initialization or cleanup safety duty deferred. |
| HC-SO-003 / HC-RD-003, P08/R07/T8.1 | Actual four routes/images and ABI/allocator/nested-stack/RAM/flash; source identities, independent P08 exit, exact residual handoff. | Full RFC/I4-AC-008 conformance and human lifecycle disposition after consuming P08 report; P09–P12/hardware/unmet timing remain their original separate obligations. |
| B4 | Accepted ADR/applied contracts/derived plans already recorded; SO-01→SO-02 and independent Strong design review; separate bounded production allowance before SO-03/validation. | Any remaining full-delivery plan/conformance approvals and explicit implementing→implemented transitions. None invented by inventory or commit. |

The current source does not reveal a separable unused scoped implementation
that must be built only for I4-07. It does reveal substantial **residual review,
integration refresh and full conformance work** above. If P08 necessarily
supplies all implementation subcases, SO-09 must say so explicitly and still
carry these open dispositions. FW-037/I4-06 Core-wide assessment and external
packaging I4-01–04 remain separate; no new deferred idea is introduced here.

## Preserved evidence and remaining gates

Existing latest nRF supported image at source 63e717d1 links with flash 299,332,
RAM 152,320, caller BSS 120,704, heap 0 and ARMv7E-M/VFP. Its actual enclosing
construction closure at 0x17a48 reserves **58,648 local bytes versus 27,648**,
a conclusive failure before caller/callee/alignment/IRQ overlap. Its called
rejection/lifecycle helpers reserve 4,768/8,392; smaller helpers do not pass
the enclosing construction. Graph/host phases are sequential. No current-source
Pi image, target execution, complete P11 peak or scoped-storage fit is claimed.

Old checker oracles to retain exactly: counter-host-copy contains `noncopyable`;
Static/Dynamic backing negatives require `lifetime-dependent variable 'escaped'
escapes its scope` and activationBacking/root.withLifetime/semantic.withLifetime/
canvas.withLifetime/withUnsafeMutablePointer provenance. Static generator's five
whole-line seams must each equal one; change them only alongside a necessary
source seam. New session tests must isolate each additional owner independently;
the old multi-input diagnostic alone cannot prove it. Target routes are compile
controls, not execution. Raw-geometry expiry remains qualified, not upgraded by
source inventory.

Historical helper 2/2, B03 1/1, GOT/image/backing-image, phase correction/image
and IR capture 1/1 are closed. SPIKE-075's seven experiments stay closed; its
native shadow declarations/return-boundary results are not production proof.
The failed IR capture exit -5/empty output remains unexplained. No allowance or
two-consecutive-unproductive guard is reset here.

SO-02 receives this inventory and the handoff checklist. Its only authorized
next output is the focused physical design note and derived links, followed by
separate Strong review. Production source/commands/profiles/attempts/repairs
must then be made concrete for a separate recorded allowance. SO-01 identifies
no new contract/scope blocker; all named physical realization/fit items remain
unproved. P09 cannot start from this documentation result.
