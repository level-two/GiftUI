---
spec: SPEC-002
feature: giftui-mvp-architecture
title: SPEC-002 Conformance Report
status: review
reviewers:
  - codex
created: 2026-08-31
updated: 2026-08-31
implementation_plan: ../implementation-plans/spec-002-implementation-plan.md
related_future_work:
  - FW-005
  - FW-016
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-002 Conformance Report

> This report records evidence. A review-ready report does not authorize the
> governing Specification's `implemented` transition.

## Review Scope

- Governing contract: [SPEC-002 Portable Foundation](../specs/spec-002-portable-foundation.md),
  status `implementing`.
- Derived plan: [SPEC-002 Implementation Plan](../implementation-plans/spec-002-implementation-plan.md),
  completed with a disposition for every task.
- Reviewed implementation revision:
  `3e5b2273d16c93a37e3ef2f858645b60cb15a9c2`.
- Production surface: `Sources/GiftUI/GiftUI.swift`, exact package graph, and
  the first cross-owner adapter fixtures named by the plan.
- Environments: Apple Swift 6.3.3/macOS arm64 dynamic and static profiles;
  project-local Swift 6.3.2 ARMv6 Raspberry Pi cross-build; project-local Swift
  6.3.2 Embedded Swift/nRF52840 Zephyr 4.3.0 cross-build.
- Design notes: none; no trigger required one.

The review used SPEC-002's independent Foundation evidence boundary. It did
not require a backend, runtime, remote Raspberry Pi, connected nRF board,
deployment, service restart, or flash operation.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `PF-001` | pass | [Geometry contract](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-2/geometry-contract.md), [layout/allocation](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-5/layout-and-allocation.md) | Exact `Int32` and public declarations compile in all four profiles. |
| `PF-002` | pass | [Foundation failure mappings](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-4/foundation-failure-mappings.md) | Every rejection discards partial output and maps to the exact SPEC-003 fact fields. |
| `PF-003` | pass | [Geometry contract](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-2/geometry-contract.md), [shared semantic corpus](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-5/shared-semantic-corpus.md) | Scalar limits, rejected edges, empty rectangles, and half-open containment are covered. |
| `PF-004` | pass | [Normalized pointer contract](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-3/normalized-pointer-contract.md) | Exact package visibility, raw widths, phases, min/max values, and mandatory provenance pass. |
| `PF-005` | pass | [Complete boundary audit](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-4/complete-boundary-audit.md) | Exact 12-target/15-edge acyclic graph, interfaces, compiled dependencies, product links, and protected-owner fixture pairs pass. |
| `PF-006` | pass | [Four-profile commands](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-5/four-profile-commands.md), [shared semantic corpus](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-5/shared-semantic-corpus.md) | macOS profiles execute equal transcripts; ARMv6/nRF optimized target IR computes checksum `28`. Cross-builds are not reported as device execution. |
| `PF-007` | pass | [Layout/allocation](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-5/layout-and-allocation.md), [linked-section contribution](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-5/linked-section-contribution.md) | Every layout ceiling and zero-allocation rule passes; four matched image pairs preserve link maps and descriptive deltas. |
| `PF-008` | pass | [Migration closure](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-6/migration-closure.md), [migration ledger](../../Tests/ContractFixtures/SPEC002/migration-ledger.md) | All 24 rows are closed; six PoC inventories are pinned; weakening shims fail the checker. |
| `PF-009` | pass | [Traceability and adapter ownership](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-6/traceability-and-adapter-ownership.md) | Reciprocal Specs, RFC/ADR provenance, supersession, manifest navigation, and split adapter targets pass. |
| `PF-010` | pass | [Scope boundary](../../Tests/ContractFixtures/SPEC002/Evidence/milestone-6/scope-boundary.md) | Review and checker find no downstream behavior or policy defined by SPEC-002. |

No criterion uses an exception.

## Required-Test Results

All commands ran on 2026-08-31 from clean reviewed revision `3e5b227`.

| Command | Environment / evidence class | Result |
| --- | --- | --- |
| `scripts/contracts/run-spec-002.sh --profile macos-dynamic` | Apple Swift 6.3.3, `arm64-apple-macosx26.0`, `-O` WMO; host execution | pass |
| `scripts/contracts/run-spec-002.sh --profile macos-static` | Apple Swift 6.3.3, `arm64-apple-macosx26.0`, `-O` WMO; host execution | pass |
| `scripts/contracts/run-spec-002.sh --profile raspberry-pi-armv6` | Swift 6.3.2, Bookworm SDK, `armv6-unknown-linux-gnueabihf`, `-O` WMO; hardware-free cross-build/inspection | pass |
| `scripts/contracts/run-spec-002.sh --profile nrf52840-embedded` | Swift 6.3.2, `armv7em-none-none-eabi`, Embedded Swift `-Osize` WMO, Zephyr 4.3.0/SDK 0.17.4; hardware-free cross-build/inspection | pass |
| `scripts/test.sh` | Governance, driver registry, root tests, diagnostic-buffer generator check, and all registered macOS-dynamic contract drivers | pass |

The standalone reports record revision, dirty state, compiler and SDK identity,
optimization flags, commands, hashes, generated artifacts, and exit code under
`.build/contract-reports/spec-002/<profile>/`. Those generated paths are
replace-on-rerun evidence; the linked milestone records above are the stable
review index.

## Profile, Backend, and Platform Evidence

| Configuration | What was proved | What was not claimed |
| --- | --- | --- |
| macOS dynamic | Complete source/interface/graph checks, semantic execution, allocation execution, layouts, and matched linked image | No downstream runtime/backend conformance |
| macOS static | Same Foundation semantics and resource checks as dynamic under the static profile | No downstream static runtime conformance |
| Raspberry Pi ARMv6 | Exact compiler/SDK/target, complete source and optimized semantic IR, layouts, operation IR, ARMv6 hard-float linked pair | No remote execution or connected Pi evidence |
| nRF52840 Embedded | Exact Embedded Swift/Zephyr pins, complete source and optimized semantic IR, layouts, operation IR, final ARMv7E-M VFP linked pair | No flash or connected-board execution |

SPEC-002 explicitly does not require runtime, backend, host, or connected-
hardware suites for its independent Foundation contract.

## Resource and Performance Evidence

All profiles report the same owned-value layouts: `GeometryScalar` 4 bytes,
`Point`/`Size` 8, `Rect` 16, `ProposedSize` size 13/stride 16,
`PointerPhase` 1, `InputSourceID` 2, the three `UInt32` wrappers 4 each, and
`NormalizedPointerEvent` 28. Every normative maximum passes.

Both macOS profiles execute 10,000 post-warmup construction/arithmetic
iterations with allocation count `0`. Cross-profile optimized IR contains none
of the forbidden allocation, reflection, runtime-discovery, Objective-C,
`Task`, or `MainActor` paths.

Matched candidate-minus-baseline deltas are descriptive, not ceilings:

| Profile | Code | Read-only | Initialized | Zero-initialized | File size |
| --- | ---: | ---: | ---: | ---: | ---: |
| macOS dynamic | +296 B | 0 B | 0 B | 0 B | +96 B |
| macOS static | +296 B | 0 B | 0 B | 0 B | +96 B |
| Raspberry Pi ARMv6 | +272 B | +8 B | 0 B | -288 B | +368 B |
| nRF52840 Embedded | +248 B | 0 B | 0 B | 0 B | +532 B |

## Deviations and Exceptions

No implementation divergence, failed requirement, missing evidence, or
approved exception was found. A conformance pre-review identified that the
earlier ARMv6/nRF transcript recorded the expected checksum after compilation;
revision `3e5b227` corrected that weakness by checking the computed checksum in
optimized target IR. The final results above use only the corrected evidence.

## Deferred Work Audit

FW-005 (alternative geometry scalars) and FW-016 (post-MVP package topology)
retain concrete revisit triggers and remain outside MVP. The lifecycle and
scope audits found no triggered, stale, orphaned, improperly promoted, or
conformance-required deferred item.

## Review Conclusion

Every SPEC-002 acceptance criterion has sufficient reproducible evidence and
is classified `pass`. The report supports requesting explicit maintainer
authorization for the Specification's `implementing → implemented`
transition. This report does not perform or imply that transition; SPEC-002
must remain `implementing` until a human maintainer authorizes it.
