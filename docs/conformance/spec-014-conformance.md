---
spec: SPEC-014
feature: giftui-mvp-architecture
title: SPEC-014 Conformance Report
status: complete
reviewers:
  - codex
created: 2026-09-13
updated: 2026-09-13
implementation_plan: ../implementation-plans/spec-014-implementation-plan.md
related_future_work: [FW-010, FW-014]
related_explorations: []
related_spikes: [SPIKE-001, SPIKE-002, SPIKE-004]
supersedes: null
superseded_by: null
---

# SPEC-014 Conformance Report

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.

## Review Scope

- Governing contract: [SPEC-014 Raster Backend and Display Integration Contract](../specs/spec-014-backend-integration.md), status `implementing`, SHA-256 `3f4f60671f1f0e099e45cd7bd0732258ebea900f8c39cf3083318d7e61ae8561`.
- Completed plan: [SPEC-014 Implementation Plan](../implementation-plans/spec-014-implementation-plan.md).
- Reviewed implementation revision: `c5c8f125c95b58eb99ed0fae350d7cca75523a22`.
- Environments: Apple Swift 6.3.3 macOS arm64 dynamic/static host execution;
  project-local Swift 6.3.2 ARMv6 and Embedded Swift/nRF52840 hardware-free
  compile, link, and artifact inspection.

The reviewed authority chain remains accepted/approved and the feature
manifest remains in implementation. No implementation record changes the
approved ownership, synchronous one-shot handoff, capability, failure, raster,
resource, or hardware contracts.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `BI-001` | pass | [module checker](../../scripts/contracts/check-spec-014-module-contract.rb), [downstream host registry](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-8/downstream-consumer-registry.md), [profile declarations](../../scripts/contracts/check-spec-014-value-profiles.sh) | Exact owner graphs, the explicit SPEC-015 consumer, and five import-negative fixtures pass. |
| `BI-002` | pass | [capability checker](../../scripts/contracts/check-spec-014-capability-fixtures.rb), [endpoint admission](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/endpoint-admission.md) | Four exact effective values, every mismatch, and no pre-construction target probing pass. |
| `BI-003` | pass | [nRF evidence](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-8/nrf52840-cross-build.md), [platform high-water](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/platform-tile-high-water.md) | Exact 480 x 4, 960-byte row, 3,840-byte one-slot path links without a framebuffer. |
| `BI-004` | pass | [transaction corpus](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/transaction-failure-corpus.md), [endpoint cleanup](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/endpoint-stream-cleanup.md) | Header bounds precede mutation; every reservation terminates once. |
| `BI-005` | pass | [transaction corpus](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/transaction-failure-corpus.md) | Zero/one/multi payload, slot reuse, identity exhaustion, and writer misuse pass. |
| `BI-006` | pass | [tile workspace](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/operation-major-tile-workspace.md), [borrow lifetime](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/borrow-lifetime-evidence.md) | One producer/operation borrow, no replay/list/framebuffer, and exact bounds pass. |
| `BI-007` | pass | [full-surface comparison](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-5/full-surface-comparison.md), [tiled equivalence](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/tiled-raster-equivalence.md), [macOS comparison](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-8/macos-profile-equivalence.md) | Logical pixels and canonical bytes compare with zero tolerance. |
| `BI-008` | pass | [canonical raster](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-4/canonical-recording-raster.md), [borrow lifetime](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/borrow-lifetime-evidence.md) | Exact glyph identity and one payload borrow are preserved without fallback or retention. |
| `BI-009` | pass | [stroke raster](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-4/stroke-raster.md), [tiled equivalence](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/tiled-raster-equivalence.md) | All 17 SPEC-012 vectors match full-surface and tiled pixels/bytes exactly. |
| `BI-010` | pass | [endpoint admission](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/endpoint-admission.md), [transaction corpus](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/transaction-failure-corpus.md) | Every reservation/body result, count, retained error, cleanup, and disposition is covered. |
| `BI-011` | pass | [failure drain](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/tiled-failure-drain.md), [health isolation](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/endpoint-health-diagnostics.md) | Pre-transfer faults reverse; accepted faults drain and update health once. |
| `BI-012` | pass | [failure mapping](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/backend-owner-failure-mapping.md), [transaction corpus](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/transaction-failure-corpus.md) | Equality/first-excess and fifteen-stage first-failure order are fail-closed. |
| `BI-013` | pass | [resource instrumentation](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-8/resource-instrumentation.md), [ARMv6](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-8/armv6-cross-build.md), [nRF](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-8/nrf52840-cross-build.md) | Layouts pass; static worst-case frame has zero allocation instructions; sections/maps/symbols are recorded. |
| `BI-014` | pass | [borrow lifetime](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-6/borrow-lifetime-evidence.md), [endpoint cleanup](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/endpoint-stream-cleanup.md) | No Core/resource/operation/body/sink address survives the offer. |
| `BI-015` | pass | [canonical driver](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-8/canonical-loader-driver.md), [macOS](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-8/macos-profile-equivalence.md), [ARMv6](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-8/armv6-cross-build.md), [nRF](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-8/nrf52840-cross-build.md) | One registered driver confines SPEC-014 evidence to `.build/spec-014/`. |

## Required-Test Results

On 2026-09-13, `swift test` passed 667 Swift Testing tests plus the XCTest
suites with zero failures. Governance validation passed 133 nodes and 1,522
edges; the registry reported 13 drivers; dependency checks passed 67 targets
and 233 direct acyclic edges. The four-profile comparator joined 19 shared
fixture IDs with zero field differences. The exact final commands are:

```sh
scripts/contracts/run-spec-014.sh --profile macos-dynamic
scripts/contracts/run-spec-014.sh --profile macos-static
scripts/contracts/run-spec-014.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-014.sh --profile nrf52840-embedded
scripts/test.sh
```

## Profile, Backend, and Platform Evidence

macOS dynamic/static provide behavioral host execution for recording,
RGBA8888, RGB565 framebuffer, and tiled paths. ARMv6 supplies a static EABI5
hard-float image. nRF supplies an Embedded Swift/Zephyr ELF with ARMv7E-M,
VFPv4-D16, and VFP-register arguments for `nrf52840dk/nrf52840`.

ARMv6 and nRF are hardware-free evidence. This review does not claim target
execution, connected framebuffer/PiScreen/TFT behavior, remote access,
deployment, service restart, or flashing.

## Resource and Performance Evidence

All eight layouts meet their bounds on 32-/64-bit compilers. Pi records 7,680
tile/payload/in-flight bytes, 15 tiles/payloads, and 240 regions. nRF records
3,840 bytes, 80 tiles/payloads, and 320 regions with no framebuffer. Its
optimized fixed-storage entry constructs, rasterizes, submits, and finishes
the worst-case frame with zero heap-allocation instructions. Cross-target
reports include sections, symbols, maps, stack bounds, and explicit
`cross-build-not-executed` timing.

## Deviations and Exceptions

No divergence, failed criterion, or approved exception was found. The earlier
borrowing-property and SPEC-012-vector blockers were resolved through
authorized corrections and are not waived requirements. Hardware-free
evidence is not represented as connected-target evidence.

## Deferred Work Audit

FW-010 and FW-014 remain captured, unpromoted, and outside the MVP contract.
Neither is required by a current criterion, and no deferred item conceals a
correctness gap.

## Review Conclusion

All fifteen criteria have reproducible passing evidence with no deviation or
exception. The evidence supports requesting explicit human authorization for
SPEC-014's `implemented` transition. That authorization has not been given in
this review, so SPEC-014 remains `implementing`.
