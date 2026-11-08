# Approved P08 freeze and certification transfer — 2026-11-08

## Subsequent restricted-use closeout disposition

The [approved S1–S3 disposition](p08-unmet-safety-closeout-disposition.md) permits
iteration-3 closeout with those named gaps explicitly unmet and affected iteration-4
reuse blocked until resolved or replaced and validated. It supersedes any blanket
requirement below to resolve S1–S3 before closure. P08 stays FROZEN / UNMET;
remaining P10, independent overall review, P11/P12/ME-09 and human closure gates
are preserved. Other shared defects and normal contract gates remain binding.


## Approval and status

Eugene explicitly instructed:

> Agreed. Update the governing documents to freeze P08 without marking it PASS, transfer composition-specific certification to iteration 4, preserve shared safety blockers, adjust entry gates, and commit.

This approves ITERATION-003 revision 7 and ITERATION-004 revision 10. P08 is
**FROZEN / UNMET**, not PASS, completed or fully conformant. R07/T8.1 and the
incomplete SO-09 exit remain open. This is a package execution disposition, not a
new Specification lifecycle status. It supersedes the complete-P08 entry prerequisite
in the earlier analyzer transfer and counter-first sequence. Accepted contracts,
resource ceilings, evidence standards and original criterion IDs remain unchanged.
Neither iteration closure nor iteration-4 activation is inferred.

Stop further work whose sole purpose is certifying the current counter host
composition. Preserve source, evidence and historical failures; no cleanup,
rollback, new experiment, repair allowance or hardware action follows. Necessary
shared-safety work is separately identified under its existing owner and authority.
Do not restart a stopped campaign merely to obtain a P08 PASS.

## Recorded baseline and limits

The repository HEAD at this decision is `3054359c765a6f54244d89ab49dd1a6634ab33c9`.
The workspace contains pre-existing uncommitted implementation/evidence changes;
that commit is **not** the identity of a clean, certified P08 image. The observed
[current P08 receipt](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md)
has SHA-256 `0b52c9d27c33c36122740fad50afa839037712b1c9f05a912b62c61e16cc4e50`.
Its current 2026-11-08 disposition is captured here without upgrading its claims:

- Four route receipts and both target links pass within their recorded scopes.
- Native Static finite-workload NoHeap and charged-entry headroom are independently
  reviewed PASS only for the exact image and stated predicates.
- The maintained compiler allocation-effect check FAIL at CounterSemanticCodec
  lifetime/deallocation remains a rejected promise, not an observed allocation.
- Dynamic allocator-bookkeeping reporting is met only for the recorded
  process/default-zone scope; unresolved route coverage and fit are not promoted.
- Pi Dynamic complete stack, provider and target-launch evidence and independent
  overall SO-09 exit remain open.

Use each original receipt's source/compiler/SDK/flags/artifact identities for
reuse decisions. The hash above identifies the receipt observed at freeze, not a
new source snapshot or reproducibility certification. Before dependent extraction,
the handoff must inventory the retained dirty-source inputs and exact artifacts,
classify unresolved predicates and record reuse/refresh/unmet dispositions. That
bounded reconciliation is still required; this document does not claim it passed.

## Responsibility and acceptance allocation

| Obligation | Iteration 3 / frozen baseline | Iteration 4 owner and completion gate |
| --- | --- | --- |
| Shared ownership, backing lifetime, borrowing/exclusivity, mutation, refusal and cleanup correctness | Preserve required shared checks and demonstrated defects; unresolved safety predicates block use of the affected mechanism until resolved or shown irrelevant to that use | I4-03/07 must retain or repair these guarantees before dependent extraction/adoption; transfer is no safety waiver |
| Counter functional and compiler-control evidence | Retain qualified results; framework/counter P10 reconciliation and required full hardware-free command remain; classify failures precisely | I4-03/04 refresh invalidated external-consumer/module/profile evidence, preserving independent oracles |
| Pi Dynamic whole-route stack, provider/launch, allocator coverage and complete fit for the current composition | Frozen, unmet certification; do not complete the old composition solely for a P08 PASS | I4-03/04, coordinated with I4-07; early feasibility and final supported counter composition proof under I4-AC-013 |
| Other incomplete composition-specific cold/allocation, main/IRQ stack, ABI, RAM/flash and target evidence | Transfer only the identified composition portion of IT-AC-007/008 and P08/P11; retained local facts remain limited | I4-AC-013 before supported counter adoption and dependent analyzer adoption; changed images require applicable fresh proof |
| Compiler allocation-effect failure | Preserve exact failed result; classify whether dependent shared code relies on the rejected promise. No automatic non-applicability or PASS | Affected contract owner and I4-03/07 resolve or obtain a normal explicit contract disposition before relying on that guarantee |
| SO-09 / full P08 exit | Keep historical package exit incomplete; bounded freeze/handoff review is not an exit PASS | I4-03/04/07 map every residual criterion to retained or replacement composition evidence and obtain independent conformance review; no need to certify a retired image merely to tick P08 |
| P12 counter cutover/removal dependent on transferred proof | Preserve baseline and independent controls; do not adopt an uncertified composition or remove necessary inputs | Counter adoption/removal follows I4-AC-013 and functional gates; analyzer P09–P12 transfer remains unchanged |

This is mandatory delivery rescheduling, not optional Future Work. I4-AC-013
carries the transferred counter portions of IT-AC-007/008; IT-AC-004 shared
correctness stays required, IT-AC-005 records both allocations, and IT-AC-010
requires the explicit handoff. Analyzer IT-AC-009 / I4-AC-012 is unchanged.
No task or Spec is marked complete by this transfer.

## Classification rule and bounded freeze review

For every unresolved item, record its criterion, mechanism, affected consumers,
source/artifact, existing evidence, missing premise, owner and destination:

1. A demonstrated shared defect or unproved ownership/lifetime/exclusivity premise
   needed by the proposed consumer remains a blocker for that affected path.
2. A missing bound/measurement for a particular linked composition transfers to
   its replacement's certification. Conditional subproofs transfer with all their
   premises; they do not prove shared safety by themselves.
3. Mixed or unknown items remain blockers to dependent use until the bounded
   assessment separates them. Do not assume every Pi/provider unknown is merely
   composition-specific because it appears in a resource report.

Use retained evidence first. Record a concrete risk before commissioning any
new check; this assessment is not an open-ended old-image proof campaign. Independent
review must verify the classification and residual coverage before the extraction
handoff is accepted. Failed and unexecuted checks remain visible.

## Revised iteration-3 exit and iteration-4 entry

Iteration 3 completes the bounded freeze/handoff review, retained shared/framework/
counter P10 validation, retained P11 accounting, and P12 documentation/only those
removals whose adoption gates actually pass. Run the required hardware-free gate;
record transferred composition/analyzer failures as unmet with cause and destination,
never as a full-suite PASS. A shared failure cannot be relabeled as composition certification. Named S1–S3
gaps have the separate restricted-use closeout disposition linked above; other
shared failures still require their own explicit applicable disposition.
ME-09 requests a human delivery/closure decision with retained results and both
counter-certification and analyzer residuals. Unmet retained obligations require
their own explicit applicable disposition. This amendment does not close iteration 3.

Iteration-4 extraction entry requires that human handoff/closure decision, reviewed
freeze classification, exact retained input identities and normal RFC/ADR/Spec/plan
approvals. **Full P08 PASS and old-composition certification are no longer entry
requirements.** Missing transferred certification alone needs no separate entry
exception. S1–S3 still block affected reuse/adoption, while approved resolution/replacement
work and unrelated
qualified work may proceed. Existing consumed allowances are not reset.

During counter-first extraction, establish early supported-target resource feasibility
before multiplying the pattern. Complete cold/allocation, lifetime/refusal/cleanup,
stack/IRQ, ABI and per-application resource proof on the supported counter host
across all four configurations, including applicable target/provider evidence,
before its adoption and dependent analyzer adoption. Counter feasibility does not
prove analyzer fit or cadence. Preserve independent review and connected-operation
authorization requirements. I4 closure must disposition every transferred obligation.
