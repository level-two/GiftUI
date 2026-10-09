# RFC-014 application ownership audit

**2026-10-09 — design evidence, not an adopted ownership contract.** Parent:
[draft RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md),
B1/B2. Source baseline: `e391c632` (production unchanged since I3-T01).
This source inspection follows the completed SPIKE-069; it runs no new experiment.
It supports the [source-design comparison](rfc-014-source-design-options.md).

## Result

Neither application currently establishes the retained-model bound needed to
approve RFC-014's proposed capture pool. The analyzer normally mutates one model,
but several host objects independently retain it. The counter's required
replacement transcript has no complete maintained model/host implementation.
**Do not choose four capture slots from an assumed R=0.**

Here R means distinct detached, application-owned analyzer snapshots, excluding
the installed and staged model snapshots. Multiple references to the same model
are not multiple snapshots. Model slots, snapshot backing, observation
registrations and Canvas pins have separate counts and lifetimes. Counter model
retention consumes counter model/control storage, never analyzer capture slots.

## Analyzer: source findings

| Owner or value | Observed lifetime / behavior | Consequence for the proposed runtime |
| --- | --- | --- |
| [SignalAnalyzerView](../../../Sources/SignalAnalyzerPresentation/SignalAnalyzerView.swift), `@State viewModel` | Initializer supplies a model; body reads state and passes an owned `SignalCapture` through waveform/channel/trace declarations into Canvas. | Existing value semantics are safe independently of a borrowed backing scope. Replacing these values with snapshot selections is an explicit presentation migration, even if `@State`, `body` and Canvas syntax survive. |
| [SignalAnalyzerViewModel](../../../Sources/SignalAnalyzerPresentation/SignalAnalyzerPresentationValues.swift), typed action handler and model methods | Start, Stop, Clear and window selection mutate the same model. Clear changes capture contents; it does not replace root model identity. Attach/detach controls the sink. | Normal application actions do not create a history of detached models. Sink detachment is not model destruction. |
| [DynamicSignalAnalyzerPiLifecycleOwner](../../../Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiLifecycleOwner.swift), `constructApplicationOwners`, `applicationState`, `resetProfileStorage` | Stores `model` from construction through profile reset. Exposes its state and uses it for opportunities. | A replacement through a runtime root alone would not retarget this stored reference. The host must either follow the installed association or participate in replacement. |
| [DynamicSignalAnalyzerApplicationFailureOwner](../../../Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerApplicationFailureOwner.swift), effects object | Stores a `let model`; presentation failure mutates that stored model. | Retaining the owner retains the original model. A replacement design must also retarget failure effects; otherwise an error can update the former model. This is a proposed-replacement hazard, not an observed bug in today's fixed-root lifecycle. |
| [DynamicSignalAnalyzerPiInitialPresentationOwner](../../../Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiInitialPresentationOwner.swift), `prepareOpportunity`, `cleanup`, `quiesce` | Caches `attemptModel`, copies it to `model` at interaction commit. Quiesce cancels input and admission without clearing these model fields. | An attempt and an installed presentation can retain model references beyond body evaluation. Their release/retarget points must be explicit, including failed derivation and shutdown. |
| [StaticSignalAnalyzerNRFApplicationStorage](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFApplicationStorage.swift), `bindRoot`, `withModel` | The generic host composition creates the reference model, binds a Static root and forwards borrowing callbacks with generic results. | This source does not prove that arbitrary callback results cannot escape or establish the physical embedded model representation. |
| [StaticSignalAnalyzerNRFModelLocation](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelLocation.swift) and [capture metadata](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelCaptureState.swift) | Embedded location tracks generation/registration and accesses the profile snapshot region. Its handle carries a raw location pointer plus generation, with a documented enclosing-storage lifetime requirement. The six actions do not replace the root. | A scoped non-owning pointer is not an application ownership ticket. This generated single-location implementation does not prove a future multi-slot runtime pool or detached-model reclamation. |

The Dynamic lifecycle above is used by the Pi process and native Pi rehearsal;
this audit does not relabel it as complete four-configuration owner evidence.
The Static generic composition and embedded location are deliberately separate
rows: passing one does not establish the other's storage safety.

[Action-dispatch tests](../../../Tests/GiftUIHostConfigurationTests/SignalAnalyzerHostActionDispatchTests.swift)
include `replacementBetweenCaptureAndDispatchCancelsAndRetainsNeitherModel`:
it explicitly clears the application's `former` reference before asserting
release and stale-action cancellation. That is useful existing contract coverage,
not proof that the production lifecycle/failure/presentation caches above have
been retargeted. No tests were rerun for this source-only audit.

## Counter: requirements and missing implementation

The [consumer workload](../../explorations/exp-002/preparation-2026-10-05/consumer-study.md)
requires one observable integer model, two typed actions, ten finite text values,
and the optional scalar Canvas stroke. It also requires an application-owned
update and **root-model generation replacement**, including stale-input rejection.
Replacement is a host mutation scenario; it is not a third Counter button.

The [PortableCounter probe](../../../experiments/spike-014-external-consumer-access/PortableCounter.swift)
only receives text and a disabled flag. It has no model binding, execution or
Canvas ownership. It cannot establish a retained-owner limit. The proposed
complete counter should have one installed model, one replacement staging slot,
and an explicit policy for any retained former model. No capture pool is needed:
the Canvas payload owns the integer selected at declaration.

## Proposed common ownership rules

These are review candidates, not amendments to ADR-024/026 or SPEC-010.

1. Separate the application owning ticket from copyable identity/read tokens and
   observer registrations. Tokens carry owner identity, slot and allocation
   generation, but cannot dereference backing without an active owner scope.
   Copying a token neither forks the model nor creates an untracked owner.
2. Give each application an explicit finite ownership capacity. An owning ticket
   must be tracked on acquire/transfer/release; ordinary handle copying cannot
   stand in for this accounting. A noncopyable ticket is a candidate mechanism,
   not yet proven across classes, Static storage and all host error paths.
3. Host services that mean “the installed root” should use a typed current-root
   route resolved during their authorized mutation/read phase. They should not
   each own a historical root. This includes status, acquisition/failure effects,
   and presentation attempt setup. Never use this route for delayed Canvas:
   Canvas resolves its declaration-selected snapshot, not the current root.
4. Reserve candidate model/snapshot/registration capacity before replacement;
   attach successfully before committing the association. Failed attachment or
   capacity leaves the old association intact. Retarget host routes at the
   replacement boundary, not at later presentation success. Replacement survives
   subsequent derivation failure under ADR-024.
5. An explicitly retained former application owner remains valid after observer
   detachment. Release its backing only when its last owning ticket and all
   framework pins end. Refuse a later replacement before commit if the declared
   finite capacity cannot cover all live owners. Do not revoke external ownership
   to make an R=0 application budget fit.
6. Freeze model data through traversal, Layout and Canvas invocation/discard.
   Replacement/mutation waits for that phase to end. Shutdown cancels/drains
   phase users before releasing backing. An experiment that models an old pin
   across a replacement does not itself prove a legal production phase sequence.

Recommendation: design the two selected hosts without retained model history,
using current-root routes for services and explicit ownership transfer on
replacement. Separately preserve the framework's ability to retain a former
application-owned model within a declared capacity. This reduces unnecessary
retention without changing ADR-024 by silently destroying application owners.
It does **not** yet establish R=0 or a physical slot count.

## What is required to settle R and B0

A four-slot proposal must prove its peak, not just its state after cleanup.
A transient old cache remaining after replacement commit already counts as
application retention. Either eliminate that ownership at the commit boundary,
charge it, or prove that its backing can occupy the retiring/staging role and
that no new reservation overlaps. Calling it “temporary” is not a capacity proof.

For each selected host and each failure edge, the next ownership contract must
show an explicit ledger at: initial construction; replacement reservation;
attach failure; association commit; later derivation failure; semantic removal;
last external-owner release; Canvas discard/invocation; and teardown. Record
application owners, framework pins, model/snapshot slots and registration
identities separately. Include repeated replacement with one deliberately
retained former owner and exact first-excess refusal, not only the happy path.

Until that ledger is complete, `(4 + R) × 6,464` is only RFC-014's conservative
non-sharing transition-backing model. Metadata, owner tickets and pins cost
additional bytes. Its four-slot base already conflicts with accepted ADR-034;
R=0 alone would not approve it. A three-slot alternative still needs a complete
replacement/rollback protocol with preserved five-second retention.

## Disposition

The audit closes the question of where concrete source retention risks occur;
it does not close B1/B2. No new deferred item is needed: these are current
correctness blockers owned by RFC-014. General ownership histories and general
application compilation are outside the selected workload; no support for them
is implied. This document changes no source, accepted ADR, approved Spec,
iteration scope, experiment allowance or resource limit.
