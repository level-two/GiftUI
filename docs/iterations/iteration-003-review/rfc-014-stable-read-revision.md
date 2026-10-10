# RFC-014: stable reads without a mandatory snapshot copy

**2026-10-10 — current working direction, RFC remains draft.** Parent:
[RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
Eugene instructed: “ok, let's fix then our decisions (if any require it) and
proceed with the activities to get answers to open questions”. This authorizes
this revision and bounded evidence work, not production adoption or approval of
the whole RFC. It follows the discussion distinguishing mutation exclusion from
duplicated storage. No accepted ADR or approved Specification is amended.

## Correction and provenance

[ADR-011](../../adrs/adr-011-serialized-run-cycle-and-publication.md) requires a
non-suspending serialized mutation/derivation sequence and complete publication.
[ADR-025](../../adrs/adr-025-coarse-model-owned-observable-invalidation.md)
requires mutation to stop before derivation. Neither requires a second model
bank. [SPEC-012](../../specs/spec-012-canvas-path-stroke-drawing.md) invokes
Canvas after layout while still deriving, producing owned immutable geometry.
Stable model reads need not last until physical presentation finishes.

The previous [C contract](rfc-014-c-contract.md) chose eager copying as a
semantic baseline while also forbidding current-model writes during drawing.
The [five-bank ledger](rfc-014-c-storage-ledger.md) counted that choice, not an
unavoidable cost. The earlier direction already listed sharing unchanged
current storage as an unselected alternative. This revision selects that
alternative for design and removes mandatory copy-freeze from the baseline.
SPIKE-069–072 results remain historical evidence for their exact candidates.

This document takes precedence over conflicting candidate language in the
earlier C contract, ledger and contextual-evaluation design. They remain
reference analyses of the previous realization, not instructions to implement
separate frozen banks. The parent RFC's current summary and blocker table point
here. Accepted architecture always takes precedence over every draft.

## Revised working decisions

| ID | Direction | Consequence / boundary |
| --- | --- | --- |
| SR-1 | Retain `Canvas: View where Body == Never` as the proposed leaf API. | Custom composed views retain real compiler-derived Body types; no broad Never fallback. Draw remains synchronous after layout. |
| SR-2 | Retain stable typed model ownership independent of graph registration. | View/Canvas copies should not copy entire captures. Ownership, slot generations and retained former models still need a complete design. |
| SR-3 | One serialized derivation reads the existing model version while mutation is excluded. | No required second version, copy, swap, history or version-selection getter. External events enter separate admission. All reachable mutable backing must obey the same exclusion. |
| SR-4 | Keep storage alive through the final model reader, including Canvas invocation or discard. | Individual borrows may end between parent evaluation and child binding. The frame owner remains; binding new State must not mutate/move storage covered by a live borrow. Owned drawing geometry may outlive model access. |
| SR-5 | Preserve familiar authored body/property syntax while revising internal evaluation. | Compiler-derived Body is preferred. A fixed context type per conformance is the first candidate; method-level generic opaque inference is not assumed. Scoped access plumbing remains a separate question. |
| SR-6 | Do not add an OS lock to the baseline. | Existing serialized mutation ownership supplies ordering; generated writes must enforce phase rules. Any concurrent writer, nested reference or escaped access that bypasses it is a blocker, not evidence that serialization is safe. |

Plain immutable values can be copied normally. A mutable untracked reference
does not acquire safety merely by being reachable through a tracked property.
The candidate requires schema/access restrictions or an explicit owned copy for
such data; it does not promise arbitrary Swift object-graph freezing.

## Proposed lifecycle

1. Apply the sealed batch of events/actions and allowed model replacement.
2. Enter deriving and retain model owners; exclude mutation of existing model
   data. Do not copy model contents just to enter this phase.
3. Bind the next State location, then evaluate with a short read borrow.
   Return owned children/keys; end the parent borrow before child discovery.
4. Resolve layout and invoke staged Canvas values with fresh read borrows over
   the same unchanged storage. Copy generated geometry into the drawing plan.
5. Release every staged payload and model read on success or failure before
   reusing/reclaiming model storage. Do not roll back already applied mutations.
6. Continue the existing publish/render/offer sequence. A later cycle can mutate
   after all model readers end; backend work consumes owned output, not models.

No new asynchronous rendering or overlapping model-write capability is added.
If a future requirement introduces either, reopen this decision explicitly.

## Open questions and finite activities

These remain current RFC blockers, not deferred work. No automatic chain of
successor experiments is authorized by this list.

| Question | Activity and stopping point | Result required |
| --- | --- | --- |
| SR-Q1: does any existing consumer require model data after Canvas/plan construction? | Read coordinator, drawing producer, plan and offer contracts/source once; trace success and discard paths. | Named last-reader boundary and any counterexample. No new rendering implementation. |
| SR-Q2: can Swift infer Body with a fixed borrowed context? | One minimal four-configuration compiler study, at most 16 compiler/link/execute invocations, two repair rounds and 30 minutes after first invocation; stop on any ceiling without extending it. | Non-Never custom witnesses exercised, conditional/builder composition, typed failure; negative borrow controls. A fixture pass does not prove complete source lowering or real module integration. |
| SR-Q3: how does ordinary property syntax reach safe storage now? | Compare explicit generated context with typed owner-bound access against current wrappers and the existing application inventory. | Identify what version selection disappears, what lifetime/phase enforcement remains, and a concrete next design seam. Do not implement a general frontend. |
| SR-Q4: what storage is actually simultaneous? | Reconcile existing source/admission/current/replacement/retained-owner ledger with SR-3. | Remove only the unjustified frame-copy term. Keep unresolved retention/overlay costs explicit; no whole-image fit claim. |

The numerical ceilings above are deliberately smaller than SPIKE-072. A failed
fixed-context check ends this activity with its diagnostic; it does not authorize
manual Body derivation, a public API redesign or another broad integration study.

## Storage implication before evidence

Under the previous K=2 non-sharing owner policy, removing F0 removes one
6,464-byte capture bank: source + admission + two current owners = four banks,
25,856 transition bytes, versus the old five-bank 32,320 bytes. This is
conditional arithmetic, not a measured allocation or proof of peak fit.
[ADR-034](../../adrs/adr-034-five-second-transition-capture.md) still permits
exactly three banks (19,392 bytes). The remaining 6,464-byte difference concerns
replacement/retained ownership, not frame freezing. Keep B0 open until an
accepted policy or proved compatible allocation addresses it. Control metadata,
owner tickets, geometry, stack and other resource terms are not included here.

## Exit and adoption boundary

Record one disposition for SR-Q1–4 and stop this package. The next deliverable is
the resulting ownership/access contract amendment, with any remaining decision
stated precisely. No accepted architecture, production source, compiler policy,
resource limit or iteration completion changes through this evidence work.

## Activity results — 2026-10-10

**This bounded package is complete; RFC approval remains blocked.**
[Source input identities](rfc-014-stable-read-inputs.json) record the audit
baseline and hashes. The language check is terminal
[SPIKE-073](../../spikes/spike-073-fixed-context-body-inference.md), scope commit
`0f1ea949`, evidence commit `3a6b1199`. No production sources changed.

### SR-Q1 — last model-data consumer: answered at the contract boundary

The existing ordering supports SR-3 without new overlapping writes:

| Inspected route | Finding | Implication |
| --- | --- | --- |
| [RuntimeCompletePipeline.run](../../../Sources/GiftUIRuntimeCore/RuntimeCompletePipeline.swift) | Applies admitted work, freezes mutation, expands semantics, resolves layout, invokes Canvas/plan, then preflights render, builds interaction, publishes and offers. All calls are synchronous. | No application-model write stage is inserted between body and drawing. Future action dispatch belongs to a later mutation phase. |
| [CanvasPlanProducer.derive](../../../Sources/GiftUIDrawing/CanvasPlanProducer.swift) | Requires deriving; releases each successful callable; failure after acquiring workspace releases pending callables and discards/resets the plan. | No successful callable needs to survive as a model reader after plan construction. Early invalid-phase/reentrancy rejection does not acquire ownership or release the caller's payloads. |
| [RuntimeCoordinatorCleanup](../../../Sources/GiftUIRuntimeCore/RuntimeCoordinatorCleanup.swift), [Dynamic pipeline](../../../Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPresentationPipeline.swift) | Caller tracks acquired storage; Canvas-stage failure includes release/discard actions. Semantic discard also clears Canvas storage. | A model lease must end after this cleanup on failures; do not release it merely because the producer returned an error. |
| [DynamicCanvasCallableStorage](../../../Sources/GiftUIRuntimeDynamic/DynamicCanvasCallableStorage.swift) | Release clears the payload; discard releases all staged payloads. | Staging ownership is explicit and separate from the model's application/registration lifetime. |
| [Static Canvas pass](../../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFCanvasPass.swift) | Uses the same producer and checks `allReleased` on success. | The shared producer's boundary applies to the existing generated Static path; this does not validate a new runtime-derived owner pool. |
| [DrawingPlanView](../../../Sources/GiftUIDrawing/DrawingPlan.swift), [CanvasRenderProducer](../../../Sources/GiftUIDrawing/CanvasRenderProducer.swift) | Rendering reads stroke headers, points and subpaths from the plan; it receives no model or Canvas callable. | Keep plan storage through rendering/offer as required, without retaining a model-data read for that purpose. |

Conclusion: retain model-data access through final Canvas use/discard. Later
interaction/publication can still need registration identity and owner metadata;
ending a data borrow does not authorize destroying a registered/application-owned
model. Keep the existing mutation phase schedule rather than moving writes into
the remainder of the current cycle. This source audit is not a new conformance
proof for every host cleanup path or future borrowed-storage implementation.

### SR-Q2 — compiler-derived Body: answered for the finite mechanism

The [terminal result](../../../experiments/spike-073-fixed-context-body-inference/evidence/result.md)
shows four positive configurations, 15 passing checks in each native run and
eight intended negative rejections. There are no generated custom Body aliases.
Generic callers invoke the custom associated Body witnesses successfully; a
conditional and opaque helper participate in builder inference. One repair made
fixture catch scopes explicitly typed. The total is 15/16 invocations, one/two
repairs and approximately 41 seconds; no ceiling was extended.

The successful *internal* shape is:

```swift
protocol View {
    associatedtype Body: View
    func evaluate(read: borrowing FrameRead) throws(AccessFailure) -> Body
}
// Concrete custom implementation: same non-generic parameters, -> some View.
```

FrameRead borrows a Span over the same scalar storage used during mutation.
Writes between read borrows are refused by the phase guard; ending the owner
phase during a live read rejects at compile time. Storing FrameRead in an
Escapable struct also rejects. These two controls do not prove all possible
escape routes. Root/Nested are evaluated separately, not through real recursive
State discovery. Canvas returns scalar surrogate geometry, not a real plan.

This removes the specific generic-witness obstacle as a reason to change public
body syntax or make the frontend spell every Body type. A fixed scalar context
still does not settle a schema-independent portable context across real modules.
The experimental lifetime flags are evidence configuration, not adopted policy.

### SR-Q3 — property access: draft contract selected, integration unproved

Version selection is gone: the property need not choose between current and
historical frame banks. Lifetime and write authority remain independent of that
simplification. [State](../../../Sources/GiftUI/ObservableState.swift) currently
stores escaping read/replace closures. [Static model storage](../../../Sources/GiftUIRuntimeStatic/StaticObservableModelStorage.swift)
binds a read closure around a temporary unsafe pointer scope and permits a generic
callback result. [Dynamic model storage](../../../Sources/GiftUIRuntimeDynamic/DynamicObservableModelStorage.swift)
uses an unowned capture. These are existing mechanisms, not proof that a new
key-only View safely carries borrowed model access through drawing. A phase bit
alone cannot prove pointee lifetime or prevent raw aliases bypassing it.

| Access route | What remains necessary | Disposition |
| --- | --- | --- |
| Generated explicit context, with borrowed typed model facades | Bind/check owner and generation before reads; forward access into model-reading helpers; reject escape; preflight writes and preserve coarse reporting. | Preferred next internal contract candidate. Remove snapshot-selection logic and manual Body-type derivation from its responsibilities. |
| Owner-bound ordinary property getters | Give every stored handle a real lifetime/ownership rule and a safe typed route on both profiles; prevent unchecked reference/alias writes. | Viable comparison, not ruled out by Body inference. Existing unowned/raw-pointer closures are insufficient evidence. |
| Global or task-local current context | Implicit owner routing and runtime/profile coupling. | Not selected; removing a copy does not justify this new dependency. |

A borrowed typed facade could expose ordinary `model.value` getters inside a
bound evaluation, checking identity once when binding the facade. That is a
candidate contract, not a tested macro or a guarantee that all reads become
infallible (capture indexing and user helpers still have their own errors).
[The existing application inventory](../../../experiments/spike-072-contextual-traversal-integration/application-coverage.md)
remains useful for computed properties, nested aggregates, loops, mutation and
helper effects; its frozen-bank and manual Body-derivation assumptions are no
longer requirements. No complete frontend is built by this package.

Follow-up disposition: the [typed access contract](rfc-014-typed-access-contract.md)
now defines that boundary: application-generated schema protocols, a domain fixed
per compiled View conformance, concrete nonescapable facades, compiler-derived
Body, typed capture selections and checked writes. Its matrix maps the real
counter/analyzer source routes. This settles the draft contract direction, not
cross-module compilation, complete lowering, pointer lifetime or physical costs.
Those remain B1/B2/B4 engineering gates; no public syntax decision is pending.

### SR-Q4 — storage: three-bank policy selected, ownership proof remains

| Simultaneous capture reservation | Previous candidate | Stable-read candidate, same K=2 non-sharing assumption |
| --- | --- | --- |
| Acquisition source | 6,464 | 6,464 |
| Admission | 6,464 | 6,464 |
| Installed/current model | 6,464 | 6,464 |
| Replacement or retained former model | 6,464 | 6,464 |
| Separate frame copy F0 | 6,464 | 0 |
| Transition bytes only | 32,320 | 25,856 |

The 6,464-byte reduction is conditional accounting, not a measurement. It does
not establish that four banks are minimal, fit in the whole image, or are allowed
by ADR-034. The [ownership audit](rfc-014-ownership-audit.md) still identifies
independent host caches and retained application owners; removing a frame copy
does not release them or authorize revocation.

Follow-up disposition: Eugene explicitly selected
[three banks with bounded replacement refusal](rfc-014-capture-policy-choice.md).
Two metadata slots do not reserve two populated captures; an installed analyzer
owns one model-bank entitlement, even when empty. Independently retained owners
remain valid and can prevent replacement. A guarded transaction may transfer the
bank to an empty candidate only when the former model's last ownership is
explicitly released. The linked failure matrix defines the required checks.
B0 now needs proof of this realization, not a fourth-bank policy decision.
The existing domain SignalCapture value contract is unchanged.

## Review and next deliverable

Author consistency review only: **not ready for RFC approval**. SR-Q1 and SR-Q2
have bounded answers. SR-Q3 has a [typed access contract](rfc-014-typed-access-contract.md),
and SR-Q4 has the maintainer-selected [three-bank ownership policy](rfc-014-capture-policy-choice.md).
The requested access/ownership design package is delivered. No additional
maintainer policy choice is currently pending. These dispositions do not prove
the generated contract or ownership transaction in the real runtime.

The next engineering deliverable must validate the exact selected contract
against real module boundaries and application routes, including replacement
failure/retention and cleanup. Keep B0–B4 open for their concrete integration,
lifetime, source-coverage and complete-resource obligations. Do not restart a
generic compiler experiment or expand a mini-language by trial and error.
Any pre-adoption executable study needs its own explicit scope and stop conditions;
no study or production migration is opened by this documentation package.
Existing architecture/Spec and resource approval gates remain unchanged. No new
deferred artifact is appropriate because the remaining proofs block this RFC.
