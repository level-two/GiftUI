---
id: FW-036
feature: giftui-mvp-architecture
title: Swift Compiler Upgrade Assessment
status: captured
authors:
  - codex
created: 2026-10-11
updated: 2026-10-12
source:
  - RFC-014
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-004
---

# FW-036: Swift Compiler Upgrade Assessment

## Revisit — 2026-10-12

The separate-authorization trigger occurred during P08. The maintainer approved
the [reviewed Swift 6.4 baseline correction](../iterations/iteration-003-review/rfc-014-spec-approval.md#swift-64-compiler-baseline-correction--2026-10-12)
after the minimal and actual scoped activation controls established that 6.4
rejects the wrapped lifetime escape accepted by 6.3.2 and 6.3.3. The compiler and
matching ARMv6 SDK pins are now applied. The
[activation integration evidence](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-integration/result.md)
and [blocker resolution record](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/blocker-resolution.md)
track the fresh compatibility checks and their limits.

Disposition: continue this captured ITERATION-004 assessment with the approved
6.4 baseline as its starting point. Reuse the recorded comparison, macro/build
compatibility and target/resource evidence instead of repeating the original
version-selection question. The iteration's broader integration criterion is
unchanged; this revisit does not claim its completion. The observations below
preserve the original 6.3.2 context and are not the current adoption restriction.

## Observation / Opportunity

RFC-014 P07's pinned Swift 6.3.2 rejects the attempted scoped in-place-lend
construction with four unlocated noncopyable-copy compiler errors. A newer
compiler might remove this blocker or improve ownership tooling. That is a
hypothesis: no newer compiler has been tested against the preserved failure.
The [P07 stop](../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/audited-construction-stop/stop.md)
remains current implementation evidence.

## Why Deferred

The current package fixes its compiler baseline. The maintainer selected
focused workaround tests on that baseline now and requested a compiler
assessment in the next iteration. P07's required audited construction is not
deferred; the assessment is not a promise that upgrading will finish it.

## Potential Value

Evaluate a patch release and a newer minor release against the exact failure
or a validated reduction, with unsafe-lifetime rejection controls. Determine
matching Raspberry Pi 1 ARMv6 SDK availability, Embedded Swift compatibility,
SwiftSyntax/macros and build-tool changes. Produce a cost/risk estimate and an
upgrade-or-retain recommendation. Recheck candidate availability at execution.

## Current Non-goals

No compiler installation or adoption now; no global Swift/Xcode selection,
ARMv7 substitution, automatic Zephyr upgrade, weakened lifetime checks, revised
resource budgets or connected hardware work. Current evidence stays associated
with its original compiler. Any adoption needs the applicable ADR/Spec review
and fresh affected four-configuration behavior, ABI, size, allocation and stack
evidence; old results must not be relabeled.

## Revisit Triggers

Start of ITERATION-004 I4-05, before package extraction depends on a compiler
choice; or separate explicit maintainer authorization if P07 cannot find a
contract-preserving workaround on 6.3.2.

## Disposition

Captured and scheduled as an assessment in ITERATION-004 revision 2,
I4-05 / I4-AC-006. On 2026-10-11, after discussing compiler-upgrade cost/impact,
Eugene instructed: “Please add this as a task to the next iteration. And please
proceed with your options 1 and 2 - in a focused test bench try to find workaround.”
This approves the assessment commitment and focused current-baseline bench,
not a compiler version change or architecture amendment.

## Current-baseline bench evidence

The [authorized P07 bench](../../Tests/ContractFixtures/SPEC013/Evidence/rfc-014-p07/focused-bench/result.md)
found a passing consuming-ownership direction on Swift 6.3.2 (`3997da73`), while
the pointer-owner borrowed projections still fail. Use this distinction during
I4-05: an upgrade is not demonstrated necessary for the tested ownership route,
and the original compiler failure remains a useful compatibility case. Full P07
audited construction and target evidence remain open.

## References

- [ITERATION-004 task and criterion](../iterations/iteration-004-backend-and-application-integration.md)
- [RFC-014 sequence and follow-up](../iterations/iteration-003-review/rfc-014-implementation-plan.md)
- [Pinned compiler selection](../../scripts/contracts/compiler-baseline.sh)
- [SPEC-013](../specs/spec-013-runtime-profiles.md)
