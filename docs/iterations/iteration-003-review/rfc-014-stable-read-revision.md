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
