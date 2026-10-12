# RFC-014 task context guide

**Current P08 checkpoint — B03 independently accepted; remaining P08 open, 2026-10-12.**
B01 inventory/review and B02 bounded helper/mask realization are complete. The
single B03 native invocation at source `102382d7` passes1,348,673 reported
assertions/zero failures and23/23 checks; independent Strong result review at
`5475f547` accepts that bounded result. [Review and remaining-work handoff](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/option-b/b03/independent-review.md).
The current user authorizes remaining P08 execution; R01 adds actual rejected-
admission wake/timestamp invariance and multiple-fact/category deadline controls.
Only new controls justify fresh source-specific validation; no unchanged B03
rerun or same-helper repair is authorized. Historical2/2 remains closed; B03's
1/1 attempt is permanently consumed. All other operational/origin gaps, four
registered application routes, actual Embedded endpoint, early linked target
images/resource/ABI and final independent P08 exit remain open. SPEC-015 stays
implementing, its plan active and T8.1/P08 open; P09–P12 pending.

**Historical P08 checkpoint — Option B documents approved; implementation separate,
not started, 2026-10-12.** Eugene selected Option B and instructed that its
required documents be treated as approved, then explicitly said not to proceed
with its implementation in this activity. [Exact approval and limit](rfc-014-spec-approval.md#option-b-construction-graph-amendment--2026-10-12).
Accepted [ADR-038](../../adrs/adr-038-construction-graph-and-operational-contracts.md)
and the amended SPEC-015 graph/operational contract resolve the decision needed
at the prior checkpoint. They do not validate the existing masks or replace
construction, backing, activation or runtime proofs.

Last validated source remains `48a987cd` (1,348,627 assertions / 23 controls);
`cfaa57af` preserves unvalidated graph WIP. Historical **2/2** stays closed;
the later native allowance stays **0/1, unconsumed**. No source edit, compiler
invocation or target build occurred for this documentation activity. SPEC-015
remains implementing, its plan active and T8.1/P08 open. P09–P12 remain pending.
The separate implementation activity starts at the
[bounded B01→B02→B03 sequence](rfc-014-implementation-plan.md#option-b-resumption-sequence--separate-activity),
then the remaining existing P08 gates. No step runs automatically from
this documentation approval. Earlier stops/approvals below are preserved as
history; their decision-required language predates the approved Option B delta.


**Historical P08 checkpoint — graph-boundary decision required, 2026-10-12:**
The user explicitly approved the previously proposed bounded continuation at clean
`87b6a0bf`: dependency trace first, two projection-helper replacements, then one
native gate attempt with no automatic repair. [Trace checkpoint](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7g-graph-stop/bounded-continuation-trace.md)
`fca0a3a9` and sequential independent Strong review found that the current actual
admission11→canonicalWake16 notification is a forbidden upward dependency under
the exact direct graph contract. Backing indirection cannot erase it. Affected
source edits and compilation stopped before the gate; new allowance **0/1** is
unused and prior **2/2** remains closed. Last validated source is `48a987cd`,
1,348,627 assertions and23 controls. The graph WIP in `cfaa57af` stays unvalidated.

[Decision packet](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7g-graph-stop/graph-boundary-decision.md)
recommends moving notification forwarding to enumerated enclosing host boundaries
using existing outcomes, preserving the approved contract. This exceeds the
currently authorized two-helper edit scope and requires explicit approval; the
alternative is a reviewed Specification amendment to construction-only graph
semantics. Neither is implemented or approved. No compiler or target build ran.
SPEC-015 remains implementing, plan active and T8.1/P08 incomplete; graph,
four routes, early linked images and independent exit review remain open.

**Historical P08 checkpoint — unvalidated graph slice stopped, 2026-10-12:**
Last validated source is `48a987cd`: actual canonical wake integration and
[step7f controls](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7f-wake-controls/result.md)
pass 1,348,627 assertions and 23 controls. The subsequent exact construction graph
and activation projection edits are preserved as an **unvalidated WIP checkpoint**.
Two pinned Swift 6.4 `counter-model` compiles stopped in SILGen at
`CounterHostState.constructedRuntimeProjectionIsValid` with the same
`can't set insertion point to a null instruction` assertion. The local resumed
same-blocker guard is **2/2**; no third compile or repair is authorized under this
allowance. [Frozen stop evidence](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7g-graph-stop/stop.md)
was committed in `b3950465`; the following source checkpoint preserves the exact
failed WIP for independent read-only review. This stop does not reopen the closed
activation audit or establish an upstream contract blocker.

[Independent stop review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/remaining-implementation/step-7g-graph-stop/independent-review.md)
upholds the stop at clean `cfaa57af`, verifies both frozen failures, and requires
an exact dependency trace before considering a different projection shape.
Its proposed one-attempt continuation is untested and requires fresh explicit
authorization; no further compiler work is authorized by the review.
Graph validation, four registered routes, early linked target-image evidence and
independent P08 exit review remain open. SPEC-015 stays implementing, its plan
active and T8.1 incomplete. No graph validation or P08 pass is claimed. This
checkpoint supersedes the continuation direction in the historical activation
checkpoint below; its approval and completed evidence remain unchanged.

**Historical P08 checkpoint — activation blocker resolved, 2026-10-12:**
The [approved Swift 6.4 correction](rfc-014-spec-approval.md#swift-64-compiler-baseline-correction--2026-10-12)
`267616c9` is applied and the actual generic-host activation join is verified.
[Independent final audit](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-integration/baseline-final-review.md)
`0555805f` passes the maintained join, fresh macro/core/runtime and Foundation
four-profile regressions, matched resource pairs, ABI and isolated native timing.
Both native P08 component gates pass368 assertions and37 checks, including all
four precise ownership negatives. No contract or resource ceiling was relaxed.

The compiler lifetime-containment and activation-time construction blocker is
closed. Continue P08's finite counter/application integration and four-route
application/early-image acceptance under the existing sequence. Synthetic
component reports and application-stage trace adapters do not satisfy full
validator/application evidence. T8.1, complete P08 and P10–P12 remain open;
SPEC-015 stays implementing and its plan active. [Current evidence](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md)
preserves historical failures, guards and closed budgets.

**Historical P08 stop checkpoint, superseded only by later explicitly bounded work:**
Approved correction `4dbdc2e0`, host propagation `6eda65d0` and schema4 slice
`c39733de` are committed. Both native complete HostConfiguration component gates
pass320 assertions plus ownership/missing-field/generator controls. The attempted
inert owner for an activation-time actual coordinator rejects on the pinned
compiler after two unproductive repairs; [exact stop packet](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-stop/stop.md).
Guard **2/2**; no further affected implementation or compiler alternatives are
authorized without a new bounded decision. This does not prove a compiler bug
or justify changing the approved contract. SPEC-015 implementing/plan active;
P08 incomplete, counter/four routes/early images and independent exit review open.
Original approval packet/probes/review and earlier checkpoints remain historical.
[Receipt](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md).
Evidence-only investigation was separately approved and authorized in `0bc51d70`.
Independent accounting review `c05e6d35` permitted predeclared B under that same
allowance. Its positive failed:3/6 fresh invocations on2/2 layouts, no passing
controls or negatives; conservative candidate guard2/2, productionguard2/2
unchanged. [Finite result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-investigation/result.md)
has completed [independent final review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-investigation/final-review.md).
Its closed allowance grants no further compiler work or production integration;
later bounded scopes are recorded above. Unused calls are not authority.
P09–P12 remain pending.

**Current P07 checkpoint — finite package exit passed, 2026-10-11:**
The explicitly [resumed consuming-owner implementation](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/consuming-owner-resumption.md)
includes audited construction and lifecycle steps 1–6, followed by R1 (`0741894a`)
and R2 (`ad671ea6`) repairs. The original [independent FAIL](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-exit-review.md)
remains preserved. Fresh [repaired four-route evidence](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/repair-final-evidence.md)
uses clean `ad671ea6`; each native route passes 5904 assertions and twelve
compiler negatives across 26 actual Static/Dynamic case pairs. Cross routes pass
selected-module compilation and CPU/VFP checks; no target execution is claimed.
Independent Strong [repair exit review](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-repair-exit-review.md) passes the finite P07 exit at `329570ab`, resolving R1/R2. Full owner conformance remains separate.
Resumed consecutive unproductive repairs: **0/2**. Historical 2/2 stop preserved.
T9.1/T11.1 and P10–P12 remain open. P08 implementation has begun under the current checkpoint.

The bench and stop records below describe earlier boundaries; their statements
that continuation is unauthorized are superseded only by the resumption above.

> **Focused bench complete (2026-10-11):** [candidate 2 passes](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/focused-bench/result.md)
> on Swift 6.3.2: consuming ownership with audit access while coordinator-owned;
> 535 native assertions and one positive / three negative ownership controls.
> Commits `230f2fe8` and `3997da73`; 7/12 diagnostics and both candidates used.
> Candidate 1 still fails. Production source remains at `c234058e`; the complete
> 26-field audit and P07 exit remain unproved. No further bench or production
> repair is authorized by this completed bounded continuation.

> **2026-10-11 explicit continuation:** Eugene authorized only the sequential
> [focused workaround bench](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/focused-bench/authorization.md)
> for options 1 and 2 on Swift 6.3.2. The original 2/2 stop below remains
> historical; production integration and P08 remain stopped. The new bounded
> bench allowance must not be interpreted as an unlimited P07 restart.

**Historical P07 stop before explicit consuming-owner resumption:** the [audited-construction repair guard](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/audited-construction-stop/stop.md)
is exhausted at **2/2**. Source is restored to validated `c234058e`; failed
work and commands are preserved at `e132dfe5`. Earlier resumption instructions
below do not authorize further repair. Actual audited construction, remaining
lifecycle/transcript evidence, final four-route checks and package review remain
open. P08 has not started.

Navigation and assignment clarification for the [P01–P12 sequence](rfc-014-implementation-plan.md),
checked against the working tree on 2026-10-11. This derives from the approved
contracts; it does not define APIs or prove task completion. Read the relevant
package entry after required repository/role orientation. Refresh changed entries
when a package changes its source or validation entry points.

P07 resumed after [explicit approval of the SPEC-009/013 scoped coordinator correction](rfc-014-spec-approval.md#scoped-coordinator-constraint-amendment--2026-10-11).
Read SPEC-009's scoped coordinator amendment and owner T9.1 together with the
SPEC-013 current checkpoint. The historical blocker proof is not current
production evidence after the constraints change. SPEC-015 host lifetime is
still separate; no P08 work is authorized by this correction.

Historical stop: [P07 associated-type decision packet](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/associated-type-constraint.md). The prior three
suppressions are implemented; this new packet inventories the same protocol's
remaining associated requirements. The [exact reviewed correction is approved](rfc-014-spec-approval.md#concrete-coordinator-binding-amendment--2026-10-11);
read its mandatory concrete construction and mismatch/provenance obligations. `027bdc11` preserves partial work honestly, not a package exit.

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

## Current P07 validation entry

Read [final candidate evidence](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/repair-final-evidence.md)
for exact route arguments, source/receipt identities, criterion mapping and limits.
The current selected composition lives in `Tests/ContractFixtures/SPEC013/RuntimeDerived/`:
start with `CycleProfileStorage.swift`, `CyclePipelineOwner.swift`,
`CyclePipelineProbe.swift` and `CycleCoordinatorProbe.swift`. The registered
SPEC-013 migration route builds fresh modules and compares all actual native
profile cases; preserved legacy drivers and the full gate remain P10 work.

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
actual audited consuming-owner construction/lifecycle and both reviewed-defect
repairs through `ad671ea6`, with 5904 native assertions and twelve negatives.
The earlier [constraint-boundary review](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-blocker-review.md)
is historical after approved amendments. The [original exit FAIL](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/independent-exit-review.md)
remains preserved; [current progress](../../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/progress.md)
records R1/R2 repairs and fresh final routes. Separate independent rereview remains
pending. P08–P12 remain pending.
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
