---
id: FW-038
feature: giftui-mvp-architecture
title: Scoped Contract Validation Cost
status: captured
authors:
  - codex
created: 2026-10-14
updated: 2026-11-08
source:
  - docs/iterations/iteration-003-dev-ux-improvement.md
  - SPEC-015
  - RFC-013
  - docs/iterations/iteration-004-backend-and-application-integration.md
related_future_work:
  - FW-037
  - FW-039
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-038: Scoped Contract Validation Cost

## Iteration-4 scope narrowing — 2026-11-08

I4-01–04/I4-07 retain coverage-preserving consolidation necessary for supported
external integration. CC-03 and other cleanup receive named dependency or defer
dispositions; unrelated runner/accounting/validation optimization remains here.
Revisit on a measured supported-build/validation bottleneck or a concrete
consumer requirement. No mandatory broad cleanup or new proof controller follows.

This follows the approved [revision 12](../iterations/iteration-004-backend-and-application-integration.md);
earlier broader scheduling statements below are historical. Capture status is unchanged.

## Observation / Opportunity

During P08 compatibility2, the counter module compiled and the registered scoped
compiler matrix began. The [driver](../../scripts/contracts/check-spec-015-counter.py)
recompiles the trusted counter source for each positive/negative variant: 384
registered controls per non-Embedded profile and 202 for Embedded. This creates
substantial repeated work before runtime validation. The active run is not a
controlled performance benchmark, and no aggregate speedup is established.

On 2026-10-15, Eugene asked whether the parallel P08 application/test structure
could be removed while retaining meaningful coverage, and whether that work fits
the upcoming framework, test-application and backend separation. Read-only
inventory found 44 Counter/StaticCounter Swift files (10,663 lines, including
probes) under `Tests/ContractFixtures/SPEC015/RuntimeDerived`. The Python driver
builds these outside the root SwiftPM target graph; firmware consumes a derived
CMake recipe. This reuses framework sources but creates separate application and
build orchestration responsibilities.

## Immediate process adoption — 2026-10-31

Eugene requested explicit governing-document updates and a mandatory ruleset.
The [iteration-3 rules and workflow](../iterations/iteration-003-dev-ux-improvement.md#mandatory-memory-ruleset)
now require representative pattern qualification, grouped migration, integrated
repair, dependency-based evidence refresh and complete existing acceptance gates.
They also require one current summary/receipt and measured validation cost.
This execution-policy portion applies now using existing drivers; it does not
wait for P08 completion or iteration-4 infrastructure consolidation. Required
coverage remains unchanged and no speedup has yet been measured.

The remaining runner/application/package redesign below stays captured for
iteration 4. This partial process adoption neither closes FW-038 nor promotes
a deferred architecture or authorizes an experiment.

## Concrete accounting cleanup finding — 2026-10-31

**CC-03 — Resource proof has become an execution subsystem.** The reviewed
[CounterPhysicalAccountingEngine and visitors](../../Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterProfileStorage.swift)
carry request/resume phases, intermediate counters, type-layout requests and
callback visitors to qualify accounting under the allocation constraint. This
is primarily Counter fixture/integration complexity, not a demonstrated defect
in every production owner. The accepted graph/accounting implementation remains
valid evidence within its recorded boundary.

Assess small concrete facts supplied by physical owners and a bounded accounting
operation over those facts, keeping observation separate from mutable accumulation
where appropriate. Candidate success is fewer request/callback/forwarding layers
and independently maintained accounting facts, with exact region inventory,
ordered reports, overflow/refusal behavior and initialization/destruction costs
preserved. Keep the old/new oracle independent. Do not infer savings from fewer
source lines or allocator-symbol counts.

[FW-037](fw-037-core-wide-storage-ownership-generalization.md#concrete-contract-cleanup-findings--2026-10-31)
owns CC-01/02/04 configuration/traversal/descriptor boundaries. The shared
[iteration-4 allocation](../iterations/iteration-004-backend-and-application-integration.md#contract-cleanup-after-iteration-003)
requires structural before/after counts, equivalent contract coverage and
comparable focused/full validation timings, with actual resource deltas and
unavailable measurements reported. A speedup is a hypothesis until measured.

Eugene explicitly selected capture and post-ITERATION-003 scheduling on
2026-10-31. Revisit with I4-06 assessment and I4-01–04 consolidation after the
iteration-3 delivery/closure decision; P08 PASS alone does not start this cleanup.
This creates no P08–P12 cleanup subtask or prerequisite. Required current safety,
allocation and fit corrections remain current work; broader cleanup must not be
used to postpone them. Existing runner consolidation remains part of this item.

## Consolidation Candidate for Iteration 004

Evaluate this with existing I4-01–04 package/backend/consumer work and I4-07
ownership delivery, through draft RFC-013. The desired outcome is removal of
redundant infrastructure, not removal of required proof. Candidate dispositions:

- Put reusable framework/backend behavior with its owning production modules;
  keep application behavior in the finite external counter consumer already
  required by ITERATION-004. Do not promote every fixture helper into public API.
- Move ordinary behavioral assertions to the owning module's existing test
  suite; keep cross-module counter/analyzer scenarios as integration tests using
  the supported assembly and build paths.
- Retain compiler-negative tests for ownership, lifetime, exclusivity and access
  restrictions. Assess smaller fixtures and reusable compilation separately;
  preserve actual-owner integration checks, positive twins, diagnostic causes,
  applicable profiles and compiler passes required by the approved contracts.
- Retain actual ARMv6/Embedded build, ABI, memory/stack and connected-target proof
  where required. A common test entry point need not mean SwiftPM runs every
  kind of test, and host unit tests cannot replace target evidence.
- Map each existing check to a retained test, justified duplicate or obsolete
  investigation before removing drivers. Preserve historical evidence as history;
  stop treating source snapshots or receipts as the maintained build definition.

Before retiring the old path, demonstrate equivalent contract coverage and a
clean supported consumer build without handwritten framework source lists or
privileged shared-package access. Record cold/warm and focused/full timings;
no speedup or safe matrix reduction is established by this capture. Exact module
boundaries and changes to required evidence remain upstream review decisions.

## Why Infrastructure Consolidation Remains Deferred

The current P08 task must establish the existing lifetime/ownership proof first.
Changing its driver structure or accepted evidence during a failed-source repair
would complicate attribution. Validation cost does not waive any required check.

## Potential Value

A later investigation could assess reusable compilation work or smaller trusted
fixtures while preserving source identity, mandatory ownership/lifetime compiler
passes, exact positive twins, classified rejection causes and profile coverage.
Whether such reuse is valid and faster remains an open question.

## Current Non-goals

No current matrix reduction, compiler-flag change, cached result substitution,
typecheck-only replacement, target substitution or new performance commitment.
No experiment or implementation is authorized by this capture.

## Revisit Triggers

Revisit after the P08 correctness boundary is recorded and before expanding the
scoped compiler matrix or scheduling repeated full-profile validation. Any proposed
optimization must first define evidence equivalence and a bounded measurement.

## Disposition

Captured for remaining infrastructure consolidation. The 2026-10-31 execution
policy is adopted in iteration 3 without a new criterion or lifecycle promotion.
The 2026-10-15 request is
recorded as a consolidation candidate for the existing ITERATION-004 separation
work. Revisit when RFC-013 package/access and supported build design resumes,
before maintaining a second counter path through extraction. This capture does
not amend approved iteration revision 4, authorize immediate P08 deletion, or
waive its open safety/fit obligations.

## References

- [SPEC-015](../specs/spec-015-host-configuration.md#deferred-and-follow-up-work).
- [P08 ownership design](../implementation-designs/spec-015-p08-scoped-storage-ownership.md).
- [Compatibility2 freeze](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-compiler-compatibility2-source-freeze.md).

- [ITERATION-004](../iterations/iteration-004-backend-and-application-integration.md), I4-01–04 and I4-07.
- [RFC-013](../rfcs/rfc-013-external-application-and-backend-integration.md), draft package/assembly decision boundary.

[FW-039](fw-039-counter-prepared-lending.md) separately preserves the unexecuted
prepared-lending construction optimization; it does not change this validation
consolidation capture or authorize a source attempt.
