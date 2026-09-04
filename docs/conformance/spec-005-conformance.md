---
spec: SPEC-005
feature: giftui-mvp-architecture
title: SPEC-005 Conformance Report
status: collecting
reviewers:
  - codex
created: 2026-09-04
updated: 2026-09-04
implementation_plan: ../implementation-plans/spec-005-implementation-plan.md
related_future_work:
  - FW-001
  - FW-002
  - FW-003
related_explorations: []
related_spikes:
  - SPIKE-005
supersedes: null
superseded_by: null
---

# SPEC-005 Conformance Report

> This collecting report records evidence. It does not authorize the
> governing Specification's `implemented` transition.

## Review Scope

- Governing contract: [SPEC-005 Deterministic Text Resource Contract](../specs/spec-005-text-resources.md), status `implementing`.
- Derived plan: [SPEC-005 Implementation Plan](../implementation-plans/spec-005-implementation-plan.md), status `active`.
- Reviewed implementation revision: `98273db3c433ce3abc0f9b81d97e7e262ef48d67`.
- Design notes: [reference package generation](../implementation-designs/spec-005-reference-package-generation.md) and [static resource layout](../implementation-designs/spec-005-static-resource-layout.md), both `current`.
- Environments: Apple Swift 6.3.3 macOS arm64 dynamic/static host execution; project-local Swift 6.3.2 ARMv6 and Embedded Swift/nRF52840 hardware-free cross-builds.

The authority chain remains accepted/approved and SPEC-005 remains required by
the MVP Signal Analyzer's deterministic text across all four configurations.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `TR-001` | pass | [Authority audit](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-0/authority-audit.md) | Manifest, authority, Spike, and Future Work links are reciprocal and correctly classified. |
| `TR-002` | blocked | [Compiler boundaries](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-0/compiler-boundaries.md), [downstream blocker](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-4/downstream-integration-blocker.md) | The owned leaf/concrete-package graph passes; production layout, render, raster/backend, and host consumers await implementation under SPEC-007/008/014/015. No exception exists. |
| `TR-003` | pass | [Exact declarations](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-1/exact-declarations.md), [canonical serialization](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-1/canonical-serialization.md), [four-profile corpus](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-5/four-profile-semantic-corpus.md) | Exact widths, bytes, identities, bounds, and digests pass. |
| `TR-004` | pass | [Reference generation](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-3/reference-generation.md), [provenance](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-3/provenance-and-build-validation.md) | Adopted source, license, coverage, hashes, generation, and both required-realization validations pass. |
| `TR-005` | pass | [Accessor behavior](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-1/accessor-behavior.md), [validated behavior](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-2/validated-behavior.md) | Scalar, replacement, CR, LF, and CRLF behavior is exact with no fallback. |
| `TR-006` | pass | [Validated behavior](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-2/validated-behavior.md), [four-profile corpus](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-5/four-profile-semantic-corpus.md) | Logical glyph and geometry values are equal across all four profiles. |
| `TR-007` | pass | [Validation corpus](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-2/validation-predicate-corpus.md), [owner mappings](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-4/owner-adapter-mappings.md) | All local errors, pairwise precedence, overflow, and owner mappings pass without partial results. |
| `TR-008` | pass | [Common catalogue](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-2/common-catalogue-admission.md), [payload subsets](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-3/payload-subset-compositions.md), [resource images](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-5/static-resource-images.md) | One identity/catalogue and target-specific availability/omission are proved. |
| `TR-009` | pass | [Payload borrowing](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-1/payload-borrowing.md), [synchronous offer](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-4/synchronous-offer.md), [allocation](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-5/static-path-allocation.md) | Exact-once synchronous traversal and ended borrows pass with zero measured allocation. |
| `TR-010` | pass | [Bounds](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-1/layout-capacity-and-work-bounds.md), [resource images](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-5/static-resource-images.md) | Type/table limits, zero allocation, omission, flash, RAM, and conservative stack ceilings pass. |
| `TR-011` | blocked | [Pristine rebuilds](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-5/pristine-rebuilds.md), [resource timing](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-5/resource-only-timing.md) | Standalone commands and registered gates pass; T6.3's final clean-checkout gate remains to be recorded. No exception exists. |
| `TR-012` | pass | [Authority audit](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-0/authority-audit.md), [final boundary audit](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-6/final-boundary-audit.md) | Source, interface, product, concrete-package, portable Presentation, and non-goal audits pass. |
| `TR-013` | pass | [Validated behavior](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-2/validated-behavior.md), [owner mappings](../../Tests/ContractFixtures/SPEC005/Evidence/milestone-4/owner-adapter-mappings.md) | Geometry, breaks, availability, lookup failure, and unchanged Foundation facts are complete. |

## Required-Test Results

All four standalone drivers, two pristine four-profile rebuilds, the default
top-level gate, and `scripts/test.sh all-hardware-free` have passed. T6.3 will
repeat the complete registered gate from a final clean checkout after the
remaining audit changes land.

## Profile, Backend, and Platform Evidence

macOS dynamic/static results include host execution. ARMv6 and nRF results are
compiler, linker, ELF, ABI, section, symbol, and semantic cross-build evidence
only. No remote Pi, connected board, deployment, service restart, or flashing
occurred. Production backend and host evidence is blocked with T4.4.

## Resource and Performance Evidence

The nRF bitmap composition adds 23,024 bytes flash, zero fixed writable RAM,
and a conservative 1,004-byte validation stack, within all ceilings; outline
bytes/provider are absent. Resource-only host timing is below 2.5 milliseconds
for 4,096 worst-record glyph lookups/borrows against 250 milliseconds. Layout,
raster, cache, transfer, connected-target, and concurrent-capture timing are
not claimed here.

## Deviations and Exceptions

No implementation divergence, failed requirement, or approved exception is
known. TR-002 is blocked by absent downstream production consumers. TR-011
remains open only for the final clean-checkout gate.

## Deferred Work Audit

FW-001 through FW-003 remain captured, reciprocal, untriggered, and outside
the approved contract. SPIKE-005 remains completed evidence rather than
implementation authority. No deferred item conceals required current work.

## Review Conclusion

Eleven criteria pass and two are currently blocked. The report does not yet
support requesting the human `implemented` transition. T6.3 must close its
evidence, while TR-002/T4.4 remains blocked until the downstream
governing Specifications create and integrate their production consumers.
