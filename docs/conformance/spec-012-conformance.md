---
spec: SPEC-012
feature: canvas-drawing
title: SPEC-012 Conformance Report
status: complete
reviewers: [codex]
created: 2026-09-19
updated: 2026-09-19
implementation_plan: ../implementation-plans/spec-012-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: [SPIKE-004, SPIKE-007, SPIKE-008]
supersedes: null
superseded_by: null
---

# SPEC-012 Conformance Report

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.

## Review Scope

The review freezes [SPEC-012](../specs/spec-012-canvas-path-stroke-drawing.md)
at pre-report SHA-256
`25f5cdb769af4e5d6cd37925ad447b41ba326687481ed773598b66fb57d055f1`,
the active [implementation plan](../implementation-plans/spec-012-implementation-plan.md),
and implementation revision `13aeda83c526c29fb7af302e530b6669ac945709`.
Evidence covers Apple Swift 6.3.3 macOS host execution and project-local Swift
6.3.2 ARMv6/nRF hardware-free cross-build/link inspection.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `DR-001` | pass | [interface audit](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/interface-audit.md) | Exact public/typed-throws declarations and negative compile cases pass. |
| `DR-002` | pass | [cross-profile corpus](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/cross-profile-corpus.md) | Canvas is one identity-preserving leaf with no unrelated output. |
| `DR-003` | pass | [cross-profile corpus](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/cross-profile-corpus.md) | Invocation, release, re-expansion, and refusal recovery are exact. |
| `DR-004` | pass | [cross-profile corpus](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/cross-profile-corpus.md) | Snapshot isolation and all explicit subpaths pass. |
| `DR-005` | pass | [cross-profile corpus](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/cross-profile-corpus.md) | Combined header, operations, styles, order, and transaction pass. |
| `DR-006` | pass | [cross-profile corpus](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/cross-profile-corpus.md), [target inspection](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/target-inspection.md) | All 17 full-surface/tiled masks and bytes compare with zero difference. |
| `DR-007` | pass | [cross-profile corpus](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/cross-profile-corpus.md) | Validation/capacity precedence, mapping, and lifecycle effects pass. |
| `DR-008` | pass | [cross-profile corpus](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/cross-profile-corpus.md) | B2/capability gates remain independent and contain no drawing storage. |
| `DR-009` | pass | [resource evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/resources.md) | Borrow poisoning and lifecycle audits show no escaped sink/plan/closure. |
| `DR-010` | pass | [interface audit](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/interface-audit.md), [target inspection](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/target-inspection.md) | IDs, inline captures, complete switch coverage, rejection, and no fallback pass. |
| `DR-011` | pass | [resource evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/resources.md), [target inspection](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/target-inspection.md) | Static typed errors/cleanup are zero heap and exclude forbidden dependencies. |
| `DR-012` | pass | [resource evidence](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/resources.md) | Value ceilings and every required distinct storage/resource category are reported. |
| `DR-013` | pass | [interface audit](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/interface-audit.md), [target inspection](../../Tests/ContractFixtures/SPEC012/Evidence/milestone-9/target-inspection.md) | Module ownership/imports and portable independence remain exact. |

## Required-Test Results

`scripts/format-swift.sh` was clean. All four exact `run-spec-012.sh` commands
passed and published immutable run ID
`13aeda83c526c29fb7af302e530b6669ac945709-6d0a435e9fb34c80`.
The focused Drawing suite contains 43 semantic/layout/invocation/path/plan/
cycle/combined-render tests and passes Dynamic/Static equality.

The fast repository gate passes. In the all-hardware-free aggregate, every
SPEC-012 row and the formerly blocking SPEC-007, SPEC-011, and SPEC-013 rows
pass. The aggregate remains nonzero only because the new SPEC-003 resource
pipeline measures over-limit writable-RAM deltas for macOS static and ARMv6.
Therefore plan task T9.5 remains open even though every SPEC-012 row passes.

## Profile, Backend, and Platform Evidence

macOS dynamic/static are host execution. ARMv6 and nRF are hardware-free
cross-build/link/inspection only and verify EABI5 hard-float and
ARMv7E-M/VFPv4-D16/VFP-register ABI respectively. No simulator, connected
display, remote access, deployment, service restart, or flashing is claimed.

## Resource and Performance Evidence

All four compilers reproduce the seven Drawing layouts. Callable capture,
live Path, sealed plan, combined traversal, raster workspace, payload/in-flight
storage, post-acceptance derived storage, stack, heap, timing, sections, RAM,
and flash are reported separately. Optimized target inspection finds zero
forbidden allocation references/instructions and no hidden tiled framebuffer.

## Deviations and Exceptions

No SPEC-012 divergence or approved exception was found. The two current
repository-gate failures belong to SPEC-003 resource conformance and are not
waived or represented as Drawing evidence.

## Deferred Work Audit

SPIKE-004, SPIKE-007, and SPIKE-008 remain feasibility evidence only. No
deferred item conceals a current Drawing correctness requirement.

## Review Conclusion

Every DR criterion has a traceable passing disposition, but the explicit
all-hardware-free repository-gate requirement in T9.5 is not green. This
report does not yet support requesting the `implemented` transition. SPEC-012
remains `implementing`; the plan remains `active` until T9.5 passes.
