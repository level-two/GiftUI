---
id: FW-038
feature: giftui-mvp-architecture
title: Scoped Contract Validation Cost
status: captured
authors:
  - codex
created: 2026-10-14
updated: 2026-10-14
source:
  - SPEC-015
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-038: Scoped Contract Validation Cost

## Observation / Opportunity

During P08 compatibility2, the counter module compiled and the registered scoped
compiler matrix began. The [driver](../../scripts/contracts/check-spec-015-counter.py)
recompiles the trusted counter source for each positive/negative variant: 384
registered controls per non-Embedded profile and 202 for Embedded. This creates
substantial repeated work before runtime validation. The active run is not a
controlled performance benchmark, and no aggregate speedup is established.

## Why Deferred

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

Captured; not promoted or scheduled.

## References

- [SPEC-015](../specs/spec-015-host-configuration.md#deferred-and-follow-up-work).
- [P08 ownership design](../implementation-designs/spec-015-p08-scoped-storage-ownership.md).
- [Compatibility2 freeze](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-compiler-compatibility2-source-freeze.md).
