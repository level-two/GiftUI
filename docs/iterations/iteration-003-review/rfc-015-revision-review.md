# RFC-015 revision review — 2026-10-13

**Verdict: not ready.** This review and revision
of [RFC-015](../../rfcs/rfc-015-p08-scoped-storage-ownership.md) started at
`b39a4f35`. It uses the RFC reviewer and author skills and is an authoring pass,
not an independent re-review or compiler proof. The immutable
[initial review](rfc-015-initial-review.md) remains unchanged. Its R1–R4 already
had draft responses at this baseline; this pass addresses the additional gaps
below without declaring those findings independently closed.

The feature remains at draft RFC stage for this ownership decision, under
accepted PROPOSAL-007 and ITERATION-003 I3-04/I3-05. It is post-MVP work preserving
the Signal Analyzer and four-stack regression boundary. Accepted ADR-007/008,
ADR-035/036/038 and the current SPEC-011/013/015 contracts govern the comparison;
their statuses and contracts are unchanged.

## Findings and revisions

| ID / severity | Location and gap at the reviewed baseline | Draft resolution and remaining evidence |
| --- | --- | --- |
| V1 — blocker | Exact candidate carrier signatures / Complete carrier obligation: private noncopyable geometry/Interaction fields require explicit consuming retirement transfers. The blanket “No new result carries a scope” conflicts with the required internal scoped Optional/retirement flow. Restricting CounterReturnedWorkspaces alone leaves the existing unconstrained pipeline returnWorkspaces member constructing an owned-only result. | Add a scoped CounterRetiredStorage carrier, inert/quiesced consuming transfers and reset operation; preserve the coordinator Optional's lifetime through host retirement. Restrict returnWorkspaces itself to owned G/C/R/H. B1 still requires compiler evidence for the complete path, including owned compatibility. |
| V2 — blocker | Initialization / R3–R4: the factory consumes its session into a callback yet assigns cleanup generically to the library. It cannot operate on that consumed host afterward. Repeated sessions also lack a rule connecting old physical bank contents to newly initialized transaction metadata. | Assign logical cleanup to structured cleanup in the closed trusted assembly body and physical borrowing/destruction to the factory/owner. Specify reserved, initialized, active, reset and final-release transitions; reset all routing before reusing initialized banks. Distinguish physical inventory from the single Interaction control owner and separately supplied host control. B2 retains early-return, partial-failure, reset, generation and destruction proof. |
| V3 — blocker | R3 / commit / Memory: “compatible” capacities and “role pointer” exchange do not specify stable logical capacities or count/extent transfer. The existing measurement formula uses inline generic layouts and cannot simply substitute small access adapters for physical banks. | Require equal immutable logical capacities within each new P08 role pair, with fully accounted physical extents that cover them; reject mismatches before a session. Exchange the complete descriptor, preserve serialized infallible commit and measure physical storage from the owner's inventory separately from handles/control. B2 retains repeated-swap and ledger proof. Existing owned bank semantics stay unchanged. |
| V4 — blocker in gate description | Open Questions B4 says approval requires a new ADR, while Decision Summary extracts that ADR after RFC approval. This creates circular gate ordering. | Follow the canonical sequence: evidence/disposition, human RFC approval, proposed ADR extraction and acceptance, Spec amendment approval, ready plan, implementation. The wording gap is corrected; no approval is supplied by this review. |

## Source checks

- [CounterPipelineOwner](../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterPipelineOwner.swift)
  currently declares `returnWorkspaces(checks:)` on the general owner and consumes
  it into `CounterReturnedWorkspaces`. Its termination path clears Interaction
  state and shuts down the root after cycle finalization.
- [CounterHostOwner](../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterHostOwner.swift)
  and [CounterDynamicHostOwner](../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterDynamicHostOwner.swift)
  retire through `takeQuiescedOpportunity()` and field extraction; making those
  fields private/scoped needs a complete replacement transfer, not only a
  constructor lifetime annotation.
- [InteractionState](../../../Sources/GiftUIInteraction/InteractionState.swift)
  preflights prepared/committed capacity, exchanges R/H banks, then resets the
  former committed banks. `resetAllStorage()` clears counts, revision and phase.
  [SPEC-011 lifecycle](../../specs/spec-011-interaction.md#state--lifecycle)
  requires exactly-once candidate resolution and infallible accepted commit.
- [SPEC-013 construction](../../specs/spec-013-runtime-profiles.md#construction-and-validation)
  forbids capacity shrink after validation. Its storage/reset rules distinguish
  attempt cleanup from quiescent full reset. These are constraints on the new
  P08 adapters, not authorization to amend existing owned stores.
- [CounterStorageMeasurement](../../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterStorageMeasurement.swift)
  currently combines `MemoryLayout<C/R/H>` with retained payload bytes and
  subtracts key bytes already inside records. A scoped migration needs explicit
  physical-owner input to avoid omitting those records or counting them twice.

## Remaining gates and suggestions

B1 still needs bounded, separately authorized exact Swift 6.4 evidence for both
profiles and all four target configurations. B2 needs an exact typed physical
realization and lifecycle/resource evidence. B3 needs the complete migration
audit and comparison with a fixture-only ownership-preserving alternative.
B4 needs maintainer disposition of that evidence work under the closed budgets,
followed by normal architectural and implementation gates. No compiler, link,
hardware, experiment or repair allowance is created by these documentation edits.

No additional non-blocking suggestion is needed for this pass. The existing
candidate ADR remains one focused physical-owner / transaction-owner / scoped
access decision after RFC approval. FW-037 already captures Core-wide and
simulator generalization; none of these corrections can be deferred there.
The manifest now links this review and continues to label RFC-015 draft.

## Validation

- `scripts/validate-governance.rb` PASS: 195 authority nodes, 1991 edges,
  7 features, 75 lifecycle artifacts and 9 skills; included task-evidence
  checks passed.
- `git diff --check` PASS.

This is a Markdown/manifest change. No maintained Swift source changed, so no
formatter or repository compilation/test gate was run. Compiler and resource
evidence remain open rather than being inferred from documentation checks.
