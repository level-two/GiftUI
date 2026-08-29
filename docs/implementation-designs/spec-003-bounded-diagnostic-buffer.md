---
spec: SPEC-003
feature: giftui-mvp-architecture
title: Implementation Design — Bounded Diagnostic Buffer
status: current
authors:
  - codex
created: 2026-08-29
updated: 2026-08-29
implementation_plan: ../implementation-plans/spec-003-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Bounded Diagnostic Buffer

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note fixes the replaceable storage-generation mechanism for SPEC-003 plan
task `T3.2`: an optional downstream diagnostic buffer with profile capacities
64, 16, 16, and 8 plus an explicit capacity-zero build. It does not define new
diagnostic meaning, selection, projection, policy, health, or target profile
semantics.

## Governing Contract

The mechanism realizes SPEC-003 `Diagnostic projection`, `Performance
Requirements`, acceptance criteria `FAIL-AC-09`, `FAIL-AC-10`, `FAIL-AC-13`,
`FAIL-AC-14`, and plan tasks `T3.2`, `T3.3`, `T5.1`, and `T5.3`. ADR-016 keeps
the target optional and downstream; ADR-014 and ADR-015 prevent its storage or
sink result from gaining correctness authority.

## Current-Code Context

`GiftUIFailureCore` owns the 24-byte-maximum record and sink protocol. It is a
dependency leaf and must not import the optional adapter. The package currently
has no inline-array abstraction with already-proven support across Apple Swift,
ARMv6 Swift, and Embedded Swift, so T3.2 cannot depend on an unverified
compiler feature or a heap-backed standard collection.

## Proposed Internal Organization

Add a downstream `GiftUIFailureDiagnostics` target and product importing only
`GiftUIFailureCore`, plus a focused test target. A checked-in deterministic
Ruby generator emits one Swift storage file containing compile-time branches
for capacity zero, 8, 16, and 64. The 16-record branch serves both macOS static
and Raspberry Pi dynamic.

Each nonzero branch contains individually named inline record fields, a count,
a saturating dropped-record count, and generated constant-index switches for
append and read. The zero branch contains no record field. A checked-in
generator-input checksum and a regeneration-diff check keep the mechanical
file reviewable.

## Data and Control Flow

The projecting adapter first applies `GiftUIDiagnosticSelection`. Only a
selected projection constructs a record and calls the buffer generically as a
sink. If `count < capacity`, `consume` writes exactly field `count`, increments
count, and returns `accepted`. Otherwise it changes no record field or count,
saturating-increments `droppedRecordCount`, and returns `saturated`.

Reads accept a bounded `UInt8` index and return the indexed admitted record
only when `index < count`; all other indexes return `nil`.

## Algorithms and Data Structures

Generated fields avoid arrays, pointers, allocation, existentials, reflection,
and runtime registries. The append and read switches have a finite target set
known at compile time. Drop-new behavior never shifts or overwrites storage,
so admission order is the field order and saturation cost is constant.

The generator is implementation tooling, not runtime code. It emits no public
semantic alternatives: every branch exposes the same buffer operations and
differs only in the approved compile-time capacity and resulting storage.

## Lifecycle and State

Initialization zeroes count and dropped count and initializes each inline field
to the same zero-valued placeholder record. Placeholder fields are never
observable beyond `count`. Admitted fields never mutate again. There is no
reset API; teardown releases the enclosing value.

## Runtime Profiles and Platforms

- macOS dynamic defaults to 64 records.
- macOS static selects 16.
- Raspberry Pi/Linux dynamic selects 16.
- nRF52840 static selects 8.
- an explicit capacity-zero flag selects no record storage.

The contract driver fails conflicting or missing profile selection rather than
falling back for static/cross-built evidence. SwiftPM's ordinary developer
build defaults to macOS dynamic only.

## Resource and Failure Behavior

Storage is exactly `capacity * MemoryLayout<GiftUIDiagnosticRecord>.stride`
plus bounded counters and alignment. No record operation allocates. Full and
zero-capacity buffers drop the new record, preserve all admitted data, and
saturate rather than wrap the dropped count. Buffer failure cannot affect the
originating outcome, health, coordinator input, or policy result.

## Test and Diagnostic Seams

Focused tests compile every capacity branch, admit through the exact boundary,
read in order, force one extra record, compare pre/post admitted storage, and
use an internal near-maximum counter initializer to prove saturation. Graph
checks prove no correctness-bearing target imports the adapter. T3.3 compares
correctness outputs with the adapter omitted, enabled, filtered, full, and
failing.

## Rejected Implementation Alternatives

- Heap-backed `Array` or `ContiguousArray`: violates the static common path.
- One 64-record layout for every profile: violates approved default capacities
  and embedded RAM accounting.
- Caller-owned pointer storage: weakens the required first-party buffer and
  complicates lifetime ownership.
- Unverified fixed-array language features: rejected until all pinned
  compilers prove the same syntax, layout, and Embedded Swift availability.
- A hand-maintained 64-case tuple: semantically viable but review-hostile and
  prone to mismatched initialization, append, and read cases.

## Open Implementation Questions

None blocks T3.2. A future compiler-proven fixed-array primitive may replace
the generated fields without changing the target boundary or observable
buffer behavior.

## Code and Evidence Links

- [Generated inline buffer](../../Sources/GiftUIFailureDiagnostics/GiftUIFixedDiagnosticBuffer.swift)
- [Deterministic generator](../../scripts/contracts/generate-spec-003-diagnostic-buffer.rb)
- [Four-branch contract check](../../scripts/contracts/check-spec-003-diagnostic-buffer.sh)
- [Focused tests](../../Tests/GiftUIFailureDiagnosticsTests/GiftUIFailureDiagnosticsTests.swift)
- [Milestone 3 evidence](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-3/diagnostic-buffer.md)
