---
id: FW-038
feature: giftui-mvp-architecture
title: Scoped Contract Validation Cost
status: captured
authors:
  - codex
created: 2026-10-14
updated: 2026-10-15
source:
  - SPEC-015
  - RFC-013
  - docs/iterations/iteration-004-backend-and-application-integration.md
related_future_work:
  - FW-039
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

On 2026-10-15, Eugene asked whether the parallel P08 application/test structure
could be removed while retaining meaningful coverage, and whether that work fits
the upcoming framework, test-application and backend separation. Read-only
inventory found 44 Counter/StaticCounter Swift files (10,663 lines, including
probes) under `Tests/ContractFixtures/SPEC015/RuntimeDerived`. The Python driver
builds these outside the root SwiftPM target graph; firmware consumes a derived
CMake recipe. This reuses framework sources but creates separate application and
build orchestration responsibilities.

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

Captured; not promoted or independently scheduled. The 2026-10-15 request is
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
