---
id: FW-028
feature: signal-analyzer
title: Embedded Owner Partitioned Output Diagnostics
status: captured
authors:
  - codex
created: 2026-10-02
updated: 2026-10-02
source:
  - SPEC-001
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-028: Embedded Owner Partitioned Output Diagnostics

## Observation / Opportunity

During SPEC-001 T10.4, the pinned Embedded compiler successfully emitted the
selected canonical owner modules with per-source WMO output partitions, but
the ARM linker returned failure with orphan-section warnings and no useful
error. A single translation unit per owner linked successfully, preserving
distinct modules, imports, and compiler dependency isolation. The root cause
of the partitioned-output failure was not established.

## Why Deferred

Current production has passing canonical module, actual forbidden-import,
native rehearsal, hard-float, zero-heap and RAM/flash evidence. Understanding
the unused partitioned-output form is not necessary to deliver that join.
The SPEC-013 mutation/failure defect remains a current blocker elsewhere;
it is not deferred by this item.

## Potential Value

- A bounded compiler/linker reproduction may improve diagnostics or reduce
  reliance on source concatenation within each existing owner.

## Current Non-goals

- No compiler upgrade, topology change, removed imports, relaxed isolation,
  resource-budget increase, or connected-board operation.

## Revisit Triggers

- The pinned Swift/CMake/Zephyr SDK versions change.
- Same-owner source concatenation causes a measured correctness or build issue.
- A compiler or linker fix explicitly addresses this output form.

## Disposition

Captured; no investigation or replacement strategy is authorized.

## References

- [SPEC-001 implementation plan](../implementation-plans/spec-001-implementation-plan.md), T10.4.
- [Canonical owner evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/canonical-embedded-contracts.md).
