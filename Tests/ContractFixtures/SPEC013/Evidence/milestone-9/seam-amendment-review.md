# Shared pipeline seam amendment review — 2026-10-02

**Approved by the maintainer on 2026-10-02.** The maintainer explicitly
accepted both coordinated SPEC-013/SPEC-015 amendments after this review.
The Specifications are now approved and authoritative; the review itself
does not establish implementation or conformance. No production Swift source
was changed in this review or approval update.

## Defect and repair

The mutation failure branch cannot report prior application; the runner
therefore finalizes partial application as unchanged, without a semantic-dirty
wake. The reproduction remains in SPEC-001 milestone 10. The fixed framework
carrier also cannot preserve the application's capture-revision mismatch or
reserved-failure capacity rejection. SPEC-015's fixed opportunity result
would narrow the error again even after generalizing the runner.

The amendments add actual mutation progress on failure and parameterize the
shared pipeline, profile/coordinator wrappers, first-failure storage, and host
opportunity with the same bounded owner-failure sum. Application cases and
normalization stay above Runtime Core. Mandatory containment and quiescence
still govern whether a dirty wake can run. No rollback, replay, policy
change, new module edge, or increased storage ceiling is authorized.

This realizes ADR-011's at-most-once/dirty-state requirement and ADR-014/015's
bounded exact-failure and containment requirements using SPEC-009's existing
generic carrier. SPEC-013 retains its 2-byte framework error limit; composed
owner/failure/cycle-result limits remain 4/8/72 bytes. SPEC-001's portable
Signal Analyzer and four supported configurations make the repair necessary
for MVP now. SPEC-013 T9.1–T9.4 order implementation and acceptance evidence;
SPEC-001 T10.5/T10.6 remain blocked until that owner handoff. The approval
gate is resolved; SPEC-013 Milestone 9 still requires plan readiness and execution.

## Validation performed

- `source scripts/lib/swiftpm.sh && giftui_swiftpm --package-path "$PWD"
  --cache-root "$PWD/.build/architecture-review-cache" -- package dump-package`
  produced fresh root manifest JSON. The exact graph check passed: 84 targets,
  373 direct edges, acyclic.
- `check-spec-003-dependencies.rb` passed: 26 active targets; the fixture now
  includes the already approved Pi driver and target-host failure consumers.
  SPEC-003's module contract explicitly places transport/host normalization
  downstream of Failure Core. A synthetic reverse Failure Core-to-Runtime Core
  edge still fails.
- `check-spec-004-dependencies.rb` passed: 12 targets, 14 forbidden imports.
  Target-host's existing Failure Core and Render Lowering edges now match the
  fixture; the existing production normalization/render-offer sources own
  those approved host joins. A synthetic Capabilities-to-target-host edge fails.
- `check-spec-013-module-contract.rb` passed: five owners have exact declared
  edges and actual source imports. The Dynamic layout store's existing Text
  Resources dependency now appears in the fixture; SPEC-013 permits focused
  storage-owner imports. A synthetic Dynamic-to-Static sibling edge fails.
- `amendment-declarations.swift` type-checks against current built modules:
  `xcrun swiftc -typecheck -package-name giftui
  -I .build/arm64-apple-macosx/debug/Modules
  Tests/ContractFixtures/SPEC013/Evidence/milestone-9/amendment-declarations.swift`.
  It checks generic failure/result declarations and both real application
  rejection cases. This is macOS declaration evidence only, not a repaired
  runner, a size measurement, or Embedded feasibility evidence.

The three boundary checks were run with fresh manifest JSON on stdin; each
positive returned zero and each deliberately forbidden mutation returned one.
Checker algorithms and negative predicates were not weakened. These results
are not a passing full owner driver or aggregate gate. The three dependency
fixture repairs were validated with positive and forbidden-edge checks and
are included in the Specification approval commit at the maintainer's request.

Governance validation, governance tooling tests, the 15-driver registry, and
`git diff --check` also pass. These validate documentation/fixture integrity;
they do not discharge the pending runner behavior or resource tests.

## Remaining evidence and gate work

The following work remains required after the maintainer's contract approval;
it is not waived by this review. SPEC-001 T10.8's original full-gate logs remain historical evidence;
the aggregate has not been rerun or claimed green here.

| Owner | Concrete next task | Required result |
| --- | --- | --- |
| SPEC-005 | Regenerate the reference-resource descriptor through its owning generator and review why its input changed. | Fresh input/output digests and unchanged canonical resource behavior. |
| SPEC-006 | Remove or migrate the legacy Pi screen surface through the approved display/driver ownership boundary. | No legacy maintained surface and passing migration negatives. |
| SPEC-008 | Review the embedded semantic/layout join and assign it to the canonical producer; remove algorithm duplication before changing producer inventory. | Approved producer ownership, same render transcript, and forbidden-join rejection. |
| SPEC-009 | Reconcile the declaration-ownership inventory with the canonical ExecutionOpportunityRunner file. | One canonical declaration with bounded generic failure and negative ownership coverage. |
| SPEC-011 | Inspect both ActionGenerationAllocator constructions; eliminate the duplicate owner or prove distinct approved lifetimes. | Exactly one authority per generation domain, no identity reuse, stale-action rejection. |
| SPEC-012 | Reconcile the embedded combined-stroke emitter with canonical focused rendering. | One owner algorithm, identical painter order, bounded operation emission. |
| SPEC-014 | Reconcile migration inventory and actual plan task dispositions with the conformance-report prerequisite. | Honest completion evidence; no status-only gate repair. |
| SPEC-003/004/013 | Rerun complete registered drivers after the boundary repairs and shared seam implementation. | Passing owner drivers in all required profiles; resolve any later assertions on their merits. |
| SPEC-001 | Complete T10.5/T10.6; revalidate T10.7 closures and T10.8, then obtain independently reviewed Pi/nRF pixel references. | No invented reference, complete production joins, unchanged budgets, and required gate/evidence. |

The nRF baseline has only 1,476 bytes of RAM headroom (195,132 used of 196,608).
The amendment does not assert that a generic carrier will fit without fresh
measurements. Required runtime tests, all production carrier layouts, fixed
storage audits, Embedded/ARMv6 builds, zero-heap evidence, and assembled
RAM/flash revalidation remain T9/T10 implementation obligations. Connected
hardware evidence remains separate; no deploy, restart, or flash is requested.
