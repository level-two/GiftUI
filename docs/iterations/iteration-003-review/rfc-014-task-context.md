# RFC-014 task context guide

Navigation and assignment clarification for the [P01–P12 sequence](rfc-014-implementation-plan.md),
checked against the working tree on 2026-10-11. This derives from the approved
contracts; it does not define APIs or prove task completion. Read the relevant
package entry after required repository/role orientation. Refresh changed entries
when a package changes its source or validation entry points.

## Build context in this order

1. Read the assigned package's dependency/exit and model-routing rows in the
   sequence. Check its latest receipt and `git status --short`; preserve ongoing
   work. A source file's existence does not prove its migration is complete.
2. Open its owner plan's **Current owner checkpoint** and matching rows in
   **Acceptance-Criterion Matrix** through the [owner mapping](rfc-014-implementation-plan.md#owner-plan-and-criterion-mapping).
   Earlier checked tasks and conditional migration sections preserve history;
   they do not supersede the current checkpoint.
3. Read the linked Spec's **RFC-014 runtime amendment**, relevant referenced
   baseline clauses and governing accepted ADRs. Start with
   [ADR-035](../../adrs/adr-035-runtime-derived-records-and-exact-identity.md) for records/identity,
   [ADR-036](../../adrs/adr-036-scoped-model-access-and-bounded-ownership.md) for access/ownership,
   and [ADR-037](../../adrs/adr-037-protocol-canvas-and-scoped-post-layout-drawing.md) for Canvas.
   The [approval map](rfc-014-spec-amendment-review.md) locates the amendments.
4. Open the source and test exemplar below, then follow the symbols needed for
   that slice. Search the named owner directories before broadening to callers.
   Open historical experiments when a named unresolved issue needs their evidence;
   do not replay the investigation by default.

These are starting points, not exhaustive read/edit lists or exemptions from
required skill reading. Before cheaper execution, the assigning agent records
exact files, symbols, invariants and commands in the existing package receipt.
Refresh stale links/APIs against current contracts and source; do not make the
worker guess a replacement contract.

## Package entry points

Code/test paths below are repository-relative. Exemplars show existing behavior
and style; they do not establish RFC-014 coverage or supply a new oracle. Full
regression and four-configuration obligations remain in the owner matrices.

| Package | Contract to open first | Source entry / existing test or evidence exemplar |
| --- | --- | --- |
| P01 | [SPEC-002](../../specs/spec-002-portable-foundation.md); PF-006/007 and compiler amendment | `scripts/contracts/compiler-baseline.sh`, `scripts/contracts/run-spec-002.sh`; [completed receipt](../../../Tests/ContractFixtures/SPEC002/Evidence/rfc-014-p01/result.md). Reuse its identities, not a new baseline study. |
| P02 | [SPEC-006 amendment](../../specs/spec-006-declarative-view-semantics.md#rfc-014-runtime-amendment); DV-RD-001–004 | `Sources/GiftUI/DeclarativeView.swift`, `Sources/GiftUIMacros/FiniteSourceLowering.swift`; [finite lowering note](../../implementation-designs/spec-006-finite-source-lowering.md), [completed receipt](../../../Tests/ContractFixtures/SPEC006/Evidence/rfc-014-p02/result.md). |
| P03 | [SPEC-010 amendment](../../specs/spec-010-observable-reference-state.md#rfc-014-runtime-amendment); OS-RD-001–004; owner **T10.1** | `Sources/GiftUIObservableState/ObservableModelOwnership.swift`, `Sources/GiftUIObservableState/ObservableModelScope.swift`, `Sources/GiftUIObservableState/ObservableStateReplacementTransaction.swift`; `Tests/GiftUIObservableStateTests/ObservableStateReplacementTransactionTests.swift`; [ownership note](../../implementation-designs/spec-010-stable-model-ownership.md), [current progress](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/progress.md). |
| P04 | [SPEC-006 amendment](../../specs/spec-006-declarative-view-semantics.md#rfc-014-runtime-amendment); DV-RD-001–004 | `Sources/GiftUISemanticCore/SemanticRuntimeRecords.swift`, `SemanticRecordStore.swift`, `SemanticRecordExpansion.swift`, `SemanticStandardPayload.swift`; `Sources/GiftUIObservableState/ObservableSemanticBodyBinding.swift`; both profile `*SemanticRecordStorage.swift` files. `Tests/ContractFixtures/SPEC006/RuntimeRecords` and `scripts/contracts/check-spec-006-runtime-records.py`; [passed package exit](../../../Tests/ContractFixtures/SPEC006/Evidence/rfc-014-p04/progress.md#final-p04-package-exit--2026-10-11), [independent review](../../../Tests/ContractFixtures/SPEC006/Evidence/rfc-014-p04/exit-review.md), [bank note](../../implementation-designs/spec-006-runtime-record-banks.md). |
| P05 | [SPEC-007 amendment](../../specs/spec-007-layout.md#rfc-014-runtime-amendment), [SPEC-011 amendment](../../specs/spec-011-interaction.md#rfc-014-runtime-amendment); LY-RD-001–002, IN-RD-001–002 | `Sources/GiftUISemanticCore/SemanticRecordLayoutView.swift`, `SemanticRecordRenderView.swift`; `Sources/GiftUIInteraction/InteractionOwnedKeyState.swift`; `Sources/GiftUIRuntimeCore/RuntimeRecordInteractionBridge.swift`, `RuntimeInteractionCandidateResolution.swift`. Fixtures: `Tests/ContractFixtures/SPEC007/RuntimeDerived` and `SPEC011/RuntimeDerived`; drivers `check-spec-007-bank-layout.py` and `check-spec-011-owned-keys.py` under `scripts/contracts`. [Passed shared exit](../../../Tests/ContractFixtures/SPEC011/Evidence/rfc-014-p05/progress.md#final-p05-package-exit--2026-10-11), [independent review](../../../Tests/ContractFixtures/SPEC011/Evidence/rfc-014-p05/independent-exit-review.md). |
| P06 | [SPEC-012 amendment](../../specs/spec-012-canvas-path-stroke-drawing.md#rfc-014-runtime-amendment); DR-RD-001–004 | `Sources/GiftUI/Canvas.swift`; `Sources/GiftUIMacros/FiniteSourceLowering.swift`, `CanvasWitnessLowering.swift`; `Sources/GiftUIDrawing/CanvasPlanProducer.swift`, `CanvasStagedValues.swift`, `CanvasSemanticPayload.swift`; `Sources/GiftUIRuntimeCore/ObservableCanvasInvocationSource.swift` and both profile Canvas stores. Fixtures: `Tests/ContractFixtures/SPEC012/RuntimeDerived`; driver: `scripts/contracts/check-spec-012-protocol-canvas.py`. [Passed package exit](../../../Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/progress.md#final-p06-package-exit--2026-10-11), [independent repair review](../../../Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/repair-exit-review.md), [current design note](../../implementation-designs/spec-012-static-canvas-lowering.md). |
| P07 | [SPEC-013 amendment](../../specs/spec-013-runtime-profiles.md#rfc-014-runtime-amendment); RP-RD-001–004 | `Sources/GiftUIRuntimeCore/RuntimeCompletePipeline.swift`, `Sources/GiftUIRuntimeCore/RuntimeCoordinatorCleanup.swift`; `Sources/GiftUIRuntimeDynamic/DynamicRuntimeExecutionCoordinator.swift`, `Sources/GiftUIRuntimeStatic/StaticRuntimeExecutionCoordinator.swift`; `Tests/GiftUIRuntimeCoreTests/RuntimeCompletePipelineTests.swift`. |
| P08 | [SPEC-015 amendment](../../specs/spec-015-host-configuration.md#rfc-014-runtime-amendment); HC-RD-001–004 | `Sources/GiftUIHostConfiguration/CheckedMVPHostConfigurationValidator.swift`, `scripts/contracts/generate-spec-015-workload.rb`; `Tests/GiftUIHostConfigurationTests/HostConfigurationTests.swift`; [finite counter inventory](../../../experiments/spike-072-contextual-traversal-integration/application-coverage.md). This inventory is not an implemented counter host. |
| P09 | [SPEC-001 amendment](../../specs/spec-001-signal-analyzer-reference-application.md#rfc-014-runtime-amendment); SA-RD-001–004 | `Sources/SignalAnalyzerPresentation/SignalAnalyzerView.swift`, `Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiAssembly.swift`, `Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFAssembly.swift`; `scripts/contracts/check-spec-001-revision-boundary.rb`, `scripts/contracts/compare-spec-001-target-actions.rb`. |
| P10 | Nine acceptance matrices in the [owner mapping](rfc-014-implementation-plan.md#owner-plan-and-criterion-mapping) | `scripts/contracts/driver-registry.tsv`, `scripts/test.sh`; each owner's contract fixtures and conformance report. Establish the exact artifact covered by each result; historical checkboxes are not migration results. |
| P11 | Resource/workload clauses of [SPEC-001](../../specs/spec-001-signal-analyzer-reference-application.md), [SPEC-002](../../specs/spec-002-portable-foundation.md), [SPEC-013](../../specs/spec-013-runtime-profiles.md), [SPEC-015](../../specs/spec-015-host-configuration.md) and affected owner matrices | P10's exact artifacts and reports; `scripts/contracts/check-spec-013-resource-instrumentation.sh`; [measurement requirements](memory-efficiency-plan.md#measurement-requirements). Collection and interpretation are separate assignments. |
| P12 | [Migration gates and completion boundary](rfc-014-implementation-plan.md#known-blockers-and-completion-boundary) and nine owner matrices | `scripts/contracts/inventory-spec-001-production-sources.py`, `scripts/contracts/generate-spec-001-nrf-topology.py`, `Package.swift`; owner reports. Strong prepares the exact removal list after adoption gates; `Generated` in a filename is not a sufficient removal criterion. |

## Settled decisions that do not need rediscovery

P03's State declaration slice now starts at `Sources/GiftUI/ObservableState.swift`
and the same finite lowering owner used by P02. Its generated-source/storage
probe is `Tests/ContractFixtures/SPEC010/RuntimeDerived/StateProbe.swift`; the
progress record's step 3 supplies current four-profile core and component receipts.
It uses a fixture binder. Step 4 adds `ObservableModelMutation.swift` and
`MutationProbe.swift` for checked operation/discovery component evidence; its
receipt does not prove application operation adoption. Step 5 adds `ObservableStateRootScope.swift`, `RootProbe.swift` and
`LayoutProbe.swift`, and migrates both profile root activation factories. Its
real callback/transfer/replacement/retirement checks remain selected-component
evidence. Step 6 removes captured allocation contexts from report routing and
records actual split report layouts. Step 7 repairs generation precedence. Step 8 records the explicitly approved
[SPEC-006/010 scoped visitor amendment](rfc-014-spec-approval.md#scoped-visitor-constraint-amendment--2026-10-10).
Step 9 implements the noncopyable/nonescapable lexical binder, nested generated
traversal, matching candidate-offer transfer, profile target access and terminal
retaining-sink teardown. The historical [visitor blocker](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/lexical-visitor-blocker.md)
is resolved by that amendment; its original reproduction remains evidence
against the former contract. Step 10 repairs the separately confirmed root-entry
phase finding by rejecting invalid activation before lending report storage.
The regression covers every rejected phase, valid inverse nesting, scoped throws
and retained-owner cleanup. Separate Strong verification passes P03 at `15b47e2a`;
the [final package exit](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/progress.md#final-p03-package-exit)
records matched receipts and review limits. P04 subsequently passed after separate
Strong review at `037607c7`. P05 passed after separate Strong review at
`42b5f639`. P06 passed after the explicitly approved scoped-source amendment
and separate Strong repair review at `59c80b52`; all captured Canvas model keys
bind before authored drawing, including read-free paths. P07 has committed
limits/audit and internal scoped-runner steps, but its actual coordinator join
is stopped at the [reviewed SPEC-009/013 constraint boundary](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-blocker-review.md).
Resume from its [progress receipt and decision packet](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/progress.md),
not a package-pass assumption. P08–P12 remain pending.
Do not infer complete-module, coordinator or linked-resource completion from
these component probes.

These reminders point into contracts; read the full clauses when editing the
mechanism. They reduce search, not the risk rating of the underlying work.

| Question | Settled answer / source |
| --- | --- |
| Which View ABI and lowering owner? | P02 edits existing GiftUI declarations and GiftUIMacros in place; no parallel lowering module or migration ifdefs. See the [direction correction](rfc-014-implementation-plan.md#p02-direction-correction--2026-10-10). |
| Does a copied key keep a model alive? | No. Backing ownership precedes validation; tickets, pins and registrations have distinct lifetimes. See [SPEC-010 model access](../../specs/spec-010-observable-reference-state.md#model-read-ownership-and-mutation-contract). |
| Can an empty replacement avoid the bank limit? | No. Installed empty models reserve the entitlement; retained A or a second populated B refuses before commit. Precommit failure preserves A; later draw failure preserves committed B. See [SPEC-010 transaction](../../specs/spec-010-observable-reference-state.md#analyzer-replacement-transaction). |
| Are bank indices or hashes persistent identity? | No. Exact paths establish identity; Interaction owns complete keys independently of semantic-bank reuse. See [SPEC-006](../../specs/spec-006-declarative-view-semantics.md#rfc-014-runtime-amendment) and [SPEC-011](../../specs/spec-011-interaction.md#rfc-014-runtime-amendment). |
| Does semantic publication commit action routing? | No. Routing changes on accepted offer; refusal preserves prior committed routing. See [SPEC-011](../../specs/spec-011-interaction.md#rfc-014-runtime-amendment). |
| Should Layout resolve models or invoke Canvas? | No. Layout borrows semantic input; drawing uses the separately scoped post-layout route. See [SPEC-007](../../specs/spec-007-layout.md#rfc-014-runtime-amendment) and [SPEC-012](../../specs/spec-012-canvas-path-stroke-drawing.md#rfc-014-runtime-amendment). |
| Can all generators be removed at cutover? | No. Expanded production topology goes; fonts, finite type/schema adapters and bounded resource generation may remain. Schema 4 cannot default missing fields. See [SPEC-015](../../specs/spec-015-host-configuration.md#schema-4-runtime-workload-and-validation). |

## Ready-to-assign means no hidden design question

Supply one compact context packet in the existing receipt using the sequence's
dispatch fields: exact criterion, source symbols, one test exemplar, independently
expected result, commands with concrete arguments and evidence destination.
State **remaining implementation choice: none** only when true. Otherwise name
the choice and keep its resolution with the appropriate tier. Do not invent
future APIs now: fill P07–P12 packets when their dependencies stabilize, using
the navigation above. This is preparation within existing packages, not a new
planning phase or approval gate.

For example, a P03 Economy assignment can collect results from the established
identity/backing component driver:

- Read the [P03 progress record](../../../Tests/ContractFixtures/SPEC010/Evidence/rfc-014-p03/progress.md)
  and its component-only boundary. The assigning agent selects an exact P02 core
  build receipt/profile from that record and verifies availability.
- Run `scripts/contracts/check-spec-010-model-identities.py --giftui-build <verified-path>`
  with that concrete path. The placeholder is not a runnable handoff. The driver
  checks source/artifact/compiler identities; return stale or missing inputs to
  the assigning agent instead of substituting a recent build or compiler.
- Record exit status, commands, assertion counts, diagnostics and report paths.
  Compare to the matching recorded profile, distinguishing native execution from
  cross-compilation. Do not edit Swift, fix failures or mark OS-RD criteria met.
- Stop after the requested runs. Only the separate Strong review can disposition
  the P03 exit; a collected receipt alone cannot pass the package. This example
  requests no rerun by itself.

For new tests, derive expected outcomes from the contract or preserved oracle
before cheaper execution. Copying production output into expected values does
not establish correctness.

## Command and context pitfalls

- P01/P02 receipts supply the verified migration invocations:
  `scripts/contracts/run-spec-002.sh --profile <profile> --compiler-baseline rfc-014`
  and `scripts/contracts/run-spec-006.sh --profile <profile> --compiler-baseline rfc-014`.
  P03 now uses the registered `scripts/contracts/run-spec-010.sh --profile <profile>
  --compiler-baseline rfc-014 --giftui-build <verified-core-directory>` route.
  P05 similarly uses the registered SPEC-007 and SPEC-011 routes with
  `--compiler-baseline rfc-014 --giftui-build <verified-core-directory>`; its
  shared receipt supplies exact commands and pinned inputs. These validate the
  explicit P02 receipt before reuse; the legacy default gate
  is preserved for P10 rather than weakened during staged migration.
- P03 progress records selected-file component builds, not passing complete
  modules. Broad failures during staged migration need owner attribution; they
  do not authorize compatibility shims or unrelated repairs.
- Format maintained Swift before repository validation. P10 owns
  `scripts/test.sh all-hardware-free`; onboarding does not require running it.
  Reuse evidence only with valid input/artifact identity and applicability.
- On handoff, preserve the diff, current progress, exact failed check, narrowed
  cause and repair count. Re-read changed inputs rather than all history. A
  packet requiring a contract change goes upstream; stronger reasoning is not
  a substitute for the missing authority.
