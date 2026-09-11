---
spec: SPEC-008
feature: giftui-mvp-architecture
title: SPEC-008 Conformance Report
status: complete
reviewers:
  - codex
created: 2026-09-11
updated: 2026-09-11
implementation_plan: ../implementation-plans/spec-008-implementation-plan.md
related_future_work:
  - FW-001
  - FW-003
  - FW-004
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-008 Conformance Report

> This complete report records evidence. The maintainer separately authorized
> the governing Specification's `implemented` transition on 2026-09-11.

## Review Scope

- Governing contract: [SPEC-008 Normalized Rendering Contract](../specs/spec-008-rendering.md), status `implemented` after complete conformance review and explicit maintainer authorization on 2026-09-11.
- Completed plan: [SPEC-008 Implementation Plan](../implementation-plans/spec-008-implementation-plan.md).
- Reviewed implementation revision: `03ec470bcff90be7379810b9b2a2e219682a1a61`.
- Four-profile evidence run: `c98c420834f90820d655316ac470fad86d1d375b-4c33a13788ae2679`.
- Clean three-profile comparison: `7b4eb21a68eb6240824c155f8eec0c22e1ed6aa4-01d653bd40508bb8`.
- Clean nRF inspection: `ee8645f17d9e30d3cd67a0b9a07b35f1e91fe978-93d8efe80a3707ac`.
- Environments: Apple Swift 6.3.3 macOS arm64 dynamic/static host execution;
  project-local Swift 6.3.2 ARMv6 and Embedded Swift/nRF52840 hardware-free
  cross-build and artifact inspection.

The accepted Proposal, approved RFCs, and accepted ADRs listed by SPEC-008
remain authoritative and consistent. The contract supplies the Signal
Analyzer's shared backend-free text, opaque color, foreground/background, and
normalized-operation path across all four MVP configurations.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `RD-001` | pass | [declaration profiles](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-1/declaration-profile-compilation.md), [repository gate](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/repository-gate.md) | All four compilers accept the exact public surface and reject clear, alpha, storage, and unbounded String access. |
| `RD-002` | pass | [bounded text](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-1/bounded-text.md), [text integration](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-6/text-declaration-integration.md) | Exact UTF-8/integer boundaries and invalid-declaration short-circuit behavior pass without trap, allocation, repair, layout publication, or render invocation. |
| `RD-003` | pass | [canonical corpus](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-6/canonical-corpus.md), [recording verification](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-3/recording-verification.md) | Five cases match exact headers, fills, glyph groups, order, geometry, identity, indices, baselines, clips, and RGB. |
| `RD-004` | pass | [clip and damage](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-5/clip-damage.md), [consumer seams](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/consumer-seams.md) | Both damage modes, empty/off-surface behavior, repeated attempts, and absence of frame-history ownership pass. |
| `RD-005` | pass | [failure corpus](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-6/failure-corpus.md), [failure precedence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-5/failure-precedence.md), [producer lifecycle](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-4/render-producer-lifecycle.md) | All local errors, mappings, precedence, capacity/ordinal/snapshot edges, begin/discard/reset counts, reentry, and atomic-current behavior pass. |
| `RD-006` | pass | [text lowering](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-5/text-lowering.md), [render resource instrumentation](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-6/render-resource-instrumentation.md), [package boundaries](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/package-boundaries.md) | Exact positioned resources stream synchronously with no remeasurement, identity translation, retained borrow/list, glyph array, or per-field transcript. |
| `RD-007` | pass | [profile equivalence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-6/profile-equivalence.md), [three-profile comparison](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/three-profile-comparison.md), [nRF inspection](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/nrf-render-inspection.md) | Recording/dynamic/static values, results, mappings, limits, structural capacities, and edge behavior match; cross-target claims remain inspection-only. |
| `RD-008` | pass | [repository gate](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/repository-gate.md), [four-profile evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/four-profile-evidence.md), [nRF inspection](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/nrf-render-inspection.md) | Layout bounds, four drivers, affine work, zero static allocation, workspace, stack, timing dispositions, sections, symbols, and maps pass. |
| `RD-009` | pass | [Signal Analyzer surface](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/signal-analyzer-render-surface.md), [four-profile evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/four-profile-evidence.md) | Every required label/value/status/error/style/hierarchy variant fits the declared backend-free limits. |
| `RD-010` | pass | [package boundaries](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/package-boundaries.md), [direct render views](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-2/direct-render-views.md) | Dependency and import-negative checks preserve owners and keep every profile on shared lowering. |
| `RD-011` | pass | [consumer seams](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/consumer-seams.md), [Canvas coexistence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/canvas-coexistence.md), [Button coexistence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-7/button-coexistence.md) | Review found no raster, pixel, frame-disposition, capability, profile-selection, platform, driver, hardware, interaction/hit-map, or Canvas/stroke authority in SPEC-008. |

## Required-Test Results

The macOS dynamic repository gate passed governance, formatter lint, explicit
driver registration, 388 Swift tests, and every registered macOS-dynamic
contract driver. The 17 declaration fixtures and 13 value layouts passed on
all four compilers. The four exact SPEC-008 drivers passed with complete
command, compiler, SDK/target, optimization, repository, digest, result,
resource, and measurement records. Focused profile and nRF report auditors
then passed against clean immutable reports.

Reproduction commands and immutable run identities are recorded in the
[repository gate](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/repository-gate.md),
[four-profile evidence](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/four-profile-evidence.md),
[three-profile comparison](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/three-profile-comparison.md),
and [nRF inspection](../../Tests/ContractFixtures/SPEC008/Evidence/milestone-8/nrf-render-inspection.md).

## Profile, Backend, and Platform Evidence

macOS dynamic and static provide behavioral host execution and Mach-O
inspection for `arm64-apple-macosx26.0`. Raspberry Pi provides a static
cross-build for `armv6-unknown-linux-gnueabihf`. nRF provides an Embedded
Swift/Zephyr cross-build and linked ELF inspection for
`armv7em-none-none-eabi` on `nrf52840dk/nrf52840`, including ARMv7E-M,
VFPv4-D16, and VFP-register argument attributes.

No pixel backend or platform host is part of this review. ARMv6 and nRF
evidence does not claim target execution, display/input validation, remote
access, deployment, service restart, or flashing. Every report records these
distinctions explicitly.

## Resource and Performance Evidence

All 13 values meet their exact or maximum layouts on all compilers. The Signal
Analyzer observes 30 of 64 operations, 139 of 512 glyphs, clip depth 4 of 16,
62 of 128 semantic scopes, 32 of 128 layout scopes, traversal depth 6 of 32,
21 of 64 text lines, and foreground depth 5 of 32. Logical workspace use is
109 of 352 bytes; the foreground region is exactly 32 three-byte `Color`
slots. Maximum recursive call-stack high-water is six frames.

The concrete one-slot workspace probe is 22 bytes with stride 22 on every
compiler. Both macOS profiles record zero post-warmup allocations and nine
`ContinuousClock` lowering samples; ARMv6 and nRF optimized SIL contain zero
production-entry allocation instructions. Cross-target timing is explicitly
not executed. Baseline/candidate linker maps, section deltas, images, and
symbol inventories are retained per profile. These descriptive results are
not runtime-profile or host budgets owned by SPEC-013/SPEC-015.

## Deviations and Exceptions

No implementation divergence, failed criterion, or approved exception was
found. The prior foreground-workspace and unreachable-arithmetic blockers were
resolved by the maintainer-approved 2026-09-11 Specification amendment; they
are not waived requirements. Hardware-free builds are not represented as
connected-target evidence.

## Deferred Work Audit

FW-001, FW-003, and FW-004 remain captured, unpromoted, and outside the MVP
contract. Rich/international text, advanced font delivery/rasterization, and a
retained render tree are not required by any current criterion and conceal no
correctness gap.

## Review Conclusion

All eleven acceptance criteria have reproducible passing evidence, with no
deviation or exception. The maintainer explicitly authorized that transition
on 2026-09-11, so SPEC-008 is now `implemented`. This report records the
decision; it did not grant the authorization.
