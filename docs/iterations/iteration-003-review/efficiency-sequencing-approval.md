# Memory/efficiency sequencing approval and lifecycle review

Date: 2026-10-09. Maintainer: Eugene.

## Instruction and reviewed proposal

After reviewing the detailed plan and the recommendation to address memory and
execution efficiency before backend extraction, Eugene instructed:

> Cool, cool, cool. Let's then reorganize iterations scopes and update all needed documents. And please commit everything.

The presented recommendation kept runtime graph derivation in iteration 3,
allowed backend ownership/dependency analysis alongside profiling, and moved
backend/platform extraction, focused packages and complete external application
setup to iteration 4. It linked the detailed ME-01–09 plan and draft iteration-4
scope, retaining four-FPS/80-events-per-second requirements and full memory/stack
proof. This instruction approves applying that presented sequencing to the
scope records and committing the work.

The exact prior documents and existing packet-65 preparation work are preserved
in commit `86caf53c` (`Record runtime derivation evidence and efficiency planning
baseline`). Earlier revision-2 and revision-3 approval provenance remains in
[scope-review-and-approval.md](scope-review-and-approval.md) and
[runtime-derivation-scope-amendment.md](runtime-derivation-scope-amendment.md).

## Approved scope changes

- ITERATION-003 becomes active revision 4, **Runtime Memory and Efficiency**.
  ME-01–09 coordinates evidence, cost accounting, bounded alternatives, required
  contract approvals, implementation, validation and backend handoff.
- I3-04 / IT-AC-006 remains required for both applications across all four
  configurations. The counter may use an isolated repository composition for
  iteration-3 evidence; genuine external package eligibility moves to iteration 4.
- I3-05 and IT-AC-007–010 add measured data-flow/cost accounting, complete storage
  and stack/lifetime safety, existing sustained performance and a backend handoff.
- I3-01/02/03 and IT-AC-001/002/003 transfer to I4-01/02/03 and I4-AC-001/002/003.
  Preserve their IDs and mark them transferred, not met. IT-AC-004 remains in
  iteration 3 and is revalidated by I4-AC-004. IT-AC-005 keeps iteration-3
  evidence/behavior/disposition documentation; external author guides move to
  I4-AC-005. Runtime derivation is also preserved by I4-AC-004.
- ITERATION-004 becomes **approved revision 1**, not active. Production
  extraction waits for iteration-3 memory, sustained performance, runtime
  derivation and compatibility gates, or a specifically accepted exception.
- External-integration delivery moves to ITERATION-004 in the manifest and
  PROPOSAL-007/RFC-013 target milestones. Runtime-derivation decisions feeding
  iteration 3 may be reviewed independently of public package/API selection
  where they form an independently reviewable decision boundary.
- FW-027/FW-032 resumption is selected for iteration 3. FW-016/FW-030 keep their
  existing promotion chain and now trace to iteration-4 delivery.

## Authority and operational boundaries

This is iteration-scope approval. PROPOSAL-007 remains accepted, RFC-013 remains
draft, and previously accepted ADRs and owner Specifications remain authority.
The change neither selects an optimization nor approves a performance redesign,
public API, representation, new module or new resource ceiling. Independent
performance decisions need applicable investment/RFC/ADR/Spec gates; major
implementation requires approved contracts and ready Spec implementation plans.

SPEC-001's sustained workload requirements and past exception records remain
unchanged. A historical exception does not satisfy new IT-AC-008/009 evidence.
No connected action, firmware flash, remote deployment or service restart is
authorized by this scope instruction. SPIKE-067's stop at 744/768 invocations
and 30/30 corrections remains enforced; a new work plan is not a budget reset.

## Reconstruction — 2026-10-09

The [authorized history cleanup](preparation-archive.md) preserves this approval,
iteration-3 revision 4 and iteration-4 revision 1. It consolidates preparation
records and replaces the detailed work order with the
[current activity plan](memory-efficiency-plan.md). Original criteria, matrix,
transfers, exclusions and separate approval gates remain in force. No iteration
closure, architecture approval or study-budget extension is inferred.

The original review/validation transcript remains in tagged history; its results
are historical, not checks performed against the reconstructed documents.
