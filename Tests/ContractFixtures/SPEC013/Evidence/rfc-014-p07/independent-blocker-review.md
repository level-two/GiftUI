# P07 independent contract-blocker review — 2026-10-11

**Not ready for P07 acceptance. The reported contract blocker is confirmed;
the narrow constraint correction is ready for human approval consideration.**

Independent Strong review (`gpt-6-astra`, medium), bounded to clean source
`7bb8dfb26188d25cd0260138289ce408727c305b`, the four P07 commits and existing
proof. This is a blocker review, not the complete P07 exit or P10 gate.
SPEC-013 is implementing; T11.1 stays open. The current requirement is
ITERATION-003 I3-04 / IT-AC-006 runtime derivation on four configurations,
preserving the closed ITERATION-001 analyzer/stack semantics.

## Located finding and routing

1. **Contract decision required for the selected scoped realization.**
   [SPEC-009](../../../../../docs/specs/spec-009-execution-cycle-and-frame-handoff.md#admission-and-action-capture-views)
   lines 612–627 explicitly declare `ExecutionAdmissionSink` and
   `ExecutionOpportunityRunner` with implicit Copyable and Escapable constraints.
   [SPEC-013](../../../../../docs/specs/spec-013-runtime-profiles.md) lines
   565–579 explicitly declare the inheriting `GiftUIRuntimeProfileCoordinator`,
   also with both implicit constraints. They are not unspecified internal
   helper details. Suppressing them changes the normative contract even though
   it leaves existing conformers and operation signatures valid.
2. **The ownership conflict is real.** Accepted
   [ADR-036](../../../../../docs/adrs/adr-036-scoped-model-access-and-bounded-ownership.md#stable-ownership-phases-and-state)
   and SPEC-013's Cycle and retirement order require backing ownership,
   independently retired registrations and backing-last teardown.
   `ObservableModelScope.swift:17,82` ends activation and destroys remaining
   models on callback exit; `ObservableStateRootScope.swift:94–102` shuts down
   root associations. Reopening these factories for separate opportunities
   would not preserve those lifetimes. Copying descriptors out of their actual
   backing borrows supplies no equivalent proof. No permissible internal
   repair is established by this packet. This does **not** prove every possible
   alternative architecture impossible; adopting a different ownership
   realization would need its own evidence and applicable upstream review.
3. **The internal runner repair is permissible.** SPEC-013's Shared pipeline
   failure and mutation seam specifies the associated failure and result
   shapes, not `RuntimeCompletePipelineOwner`'s exact inheritance declaration.
   `bbc753e5` adds scoped-owner support through the runner and forwarding
   helpers without changing ordering, failures, mutation flags or cleanup.
   That distinction does not authorize editing the explicitly specified
   Execution protocols.

## Independent replay

Replayed the existing `scoped-coordinator-proof/reproduce.py` command against
`.build/contracts/spec-013-runtime-cycle/tmp79wv0dbn/macos-static`. Its source
and artifact hash checks passed. Independently verified the compiler executable
SHA-256 against the receipt before running it. Original proof files were restored
byte-for-byte; [independent replay receipt](independent-blocker-replay.json)
records the reviewed commit and matching source/diagnostic hashes.

| Actual scope / protocol constraint | Replayed result |
| --- | --- |
| `Current.swift`: actual Execution protocols | Rejects Copyable conformance |
| `CopyableOnly.swift`: shadow suppresses only Copyable | Rejects Escapable conformance |
| `Proposed.swift`: shadow suppresses both | Compiles, including scoped construction and calls |

The model scope is real; method bodies are intentionally stubs. This proves
the two language constraints, not full `GiftUIRuntimeProfileCoordinator`
conformance, host construction, cycle behavior, zero heap or resource fit.

## Recommended concrete decision

Approve the [packet's option 1](scoped-coordinator-constraint.md#smallest-decision-options):
amend and reapprove SPEC-009 and SPEC-013 so all three named coordinator
protocols explicitly permit `~Copyable, ~Escapable`, preserving every associated
type, argument/result, failure, admission and disposition rule. Propagate those
permissions through actual scoped generic callers/wrappers, with lifetime and
negative compiler checks. This aligns the exact declarations with accepted
ADR-036; the reviewed change does not require a new ownership architecture.

The approval must **not** imply that SPEC-015 is already solved.
[SPEC-015](../../../../../docs/specs/spec-015-host-configuration.md) lines
739–747 retain an implicitly Escapable `MVPHostInstance`; lines 770 onward
govern validation, construction and the instance's exclusive activation route.
A scoped containing host requires an explicit compatible construction/activation
contract before P08 relies on it. Adding `~Escapable` alone does not prove that
route. Review/reapprove any necessary SPEC-015 change separately at that boundary;
do not silently change its factory or lifecycle in an implementation note.

If the maintainer retains the current exact coordinator declarations, keep the
concrete P07 join stopped and return its ownership realization upstream. The
review grants neither alternative-architecture approval nor a workaround budget.

## Partial implementation assessment and remaining gates

No additional material defect found in the bounded limits/audit and internal
runner diff. The ten new audit fields participate once in checked summation;
candidate/published capacities are compared independently; required new limit
arguments have no legacy defaults. Existing receipts correctly distinguish
native values execution from cross-compilation and ABI inspection. They compile
a selected module slice, not the complete profile bindings or application.
The fixture's synthetic byte counts prove arithmetic, not physical allocation.

Actual Dynamic/Static owners, cycle/fault transcripts, refusal/retry,
publication, bank reuse, teardown and exactly-once cleanup remain unproved.
Full associated-type/concrete conformance remains part of that integration.
P07 requires a separate completed-package Strong review; P08 has not started.
No normative contracts, production code, lifecycle status or manifest authority
changed in this review. This is a current blocker, not deferred work.
Consecutive unproductive repair counter remains **0/2**.
