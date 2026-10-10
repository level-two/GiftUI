---
id: SPIKE-074
feature: external-application-integration
title: Final Typed Access and Three-Bank Validation
status: completed
authors:
  - codex
created: 2026-10-10
updated: 2026-10-10
source:
  - RFC-014
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-073
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# SPIKE-074: Final Typed Access and Three-Bank Validation

Eugene explicitly authorized this final investigation round: “let's do this
iteration as you propose”, and requested subsequent work move to implementation
where possible. Parent [RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md)
remains draft. This does not approve architecture, production migration or a
numbered iteration amendment. It serves iteration-3 I3-04/05 and the counter /
analyzer stack-validation requirement, not external packaging work.

## Target Questions

- F1: Does the selected fixed-domain View/access contract compile across separate
  GiftUI, application schema, portable presentation and host bridge modules with
  inferred non-Never Body, typed nested/scalar/indexed reads and deferred Canvas?
- F2: Does one model bank plus separate source/admission banks support successful
  empty-candidate replacement, retained-owner refusal, attachment rollback,
  callback exclusion, stale-generation refusal and safe reuse?
- F3: What are the exact fixture storage costs on native and target ABIs? Does
  this mechanism necessarily add a fourth capture bank or otherwise expose a
  contradiction with the selected resource policy?

## Bounds / Stop Conditions

- One candidate; at most **48 compiler/link/execute invocations**, **two repair
  rounds**, and **45 minutes from the first invocation**. All failed commands
  count. Stop on the first ceiling; no extension or automatic successor study.
- Six separately compiled layers: GiftUI contract, unchanged selected analyzer
  Domain values, generated-schema equivalent, portable presentation equivalent,
  host bridge, and driver. Hand-written lowered forms, not a new frontend.
- At most 1,200 new Swift lines, excluding unchanged production input files.
- Four compiler configurations: native Dynamic/Static selection, ARMv6 Linux,
  nRF Embedded. Two native executions; target object compilation/inspection only.
- One ownership implementation with explicitly caller-owned backing and guarded
  transactions. It is not a production runtime replacement or profile proof.
- Negative controls: retain a scoped read in an escaping field; mutate its owner
  before its last read. No generic escape-matrix expansion.
- No production edits, source-language expansion, whole application migration,
  connected hardware, target linking/execution or whole-image feasibility claim.

## Fixed case list and verdict

F1 checks counter scalar/conditional/helper composition, analyzer nested scalar
and capture reads, non-leaf inferred Body, post-layout-key Canvas reads, typed
bad-key/index errors, stable outputs after later mutation, and independent module
imports. Use actual analyzer primitive values and the existing packed capture
record/storage file, without importing Runtime from portable modules.

F2 checks successful transfer with two metadata slots, retained old-owner refusal,
empty installed-model entitlement, metadata/generation refusal, attach report
failure, attempted retain/reentrant mutation during attachment, unchanged old
bytes/registration/dirty state on precommit failure, stale keys after success,
replacement refused during derivation, postcommit drawing failure preserving B,
and source/admission canaries surviving all model-bank operations.

F3 records native MemoryLayout and target-emitted layout constants for records,
metadata, owner, keys and Canvas; rooted target object sizes and allocator
references are diagnostic only. Compare transition bytes with ADR-034 and charge
all additional fixture storage separately. Unknown production costs remain
unknown, never zero.

**Proceed to implementation preparation** only if F1–F3 meet this narrow scope.
Then close architectural experimentation; source migration, production owner
integration, exhaustive conformance and complete-image cost evidence become
explicit downstream obligations behind RFC/ADR/Spec gates. **Stop for decision**
if a selected assumption fails or evidence is incomplete at a ceiling. Record
the failed assumption without silently changing the design or opening a successor.

## Method

[Experiment](../../experiments/spike-074-final-access-ownership/README.md): pinned
Swift 6.3.2 with the existing experimental lifetime flags; separate module build,
finite native transcript, real three-bank raw backing and checked ownership
state machine. Preserve input hashes, source snapshots, diagnostics and repairs.
No claim that a borrowed descriptor itself proves its pointer's pointee lifetime.

## Reproduction

The experiment README and append-only ledger will contain exact commands.
Builds stay under `.build/spike-074/`, `.build/raspberry-pi/spike-074/` and
`.build/nrf52840/spike-074/`. The terminal marker prohibits further trials.

## Results

**Completed: proceed to implementation preparation within the fixed scope.**
All six modules compile on four configurations; both native runs pass 47 checks.
Eight negative controls reject as intended. The target model/owner storage is
292 bytes, plus 40 bytes for two keys and one Canvas; transition backing remains
19,392 bytes. Object allocator references remain, so zero heap is unproved.

48/48 invocations, one/two repairs, 69.633 seconds; terminal with no extension.
The repair fixes the empty-installed-model case order, not the selected design.
[Full result and limits](../../experiments/spike-074-final-access-ownership/evidence/result.md)
preserve exact diagnostics, hashes, ABI evidence, costs and assertion coverage.

## Limitations

The bridge's caller-owned backing/disjointness are explicit trusted preconditions.
The fixture checks the contract and transaction, not the actual reconciler,
complete application lowering, all runtime profiles or final image resources.
These limits must survive a positive result.

## Disposition

Final investigation round complete; no successor allowance. Proceed to
[implementation preparation](../iterations/iteration-003-review/rfc-014-implementation-handoff.md).
Remaining source/production-integration/conformance/resource obligations are
explicit downstream gates, not fresh research rounds. RFC/ADR/Spec approval
remains the normal human lifecycle gate; no production implementation is approved.

## References

- [Typed access contract](../iterations/iteration-003-review/rfc-014-typed-access-contract.md).
- [Selected capacity policy](../iterations/iteration-003-review/rfc-014-capture-policy-choice.md).
- [SPIKE-073](spike-073-fixed-context-body-inference.md).
