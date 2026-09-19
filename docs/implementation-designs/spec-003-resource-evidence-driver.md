---
spec: SPEC-003
feature: giftui-mvp-architecture
title: Implementation Design — Resource Evidence Driver
status: current
authors:
  - codex
created: 2026-09-19
updated: 2026-09-19
implementation_plan: ../implementation-plans/spec-003-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Resource Evidence Driver

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains the four-profile matched-image builder, Mach-O/ELF section
accounting, final-image call graph, and conservative stack analysis used by
SPEC-003 T5.4. It does not change a resource bound, waive a failed profile,
claim connected hardware, or complete T5.4 without four passing profiles.

## Governing Contract

The mechanism realizes SPEC-003 `Performance Requirements`, `Reproducible
resource evidence`, `FAIL-AC-16`, `FAIL-AC-17`, and plan task T5.4. ADR-014
requires bounded portable outcomes; ADR-015 keeps residual disposition finite;
ADR-016 keeps diagnostic storage outside the correctness path.

## Current-Code Context

`run-spec-003.sh` already pins and validates all four compilers and builds the
semantic, allocation, layout, and latency probes. The resource addition uses
the same profile flags and report roots. `GiftUICorrelatedFailure` is in a
focused production source file so the candidate can link the exact correlation
object it exercises without making unrelated execution statics indivisible in
one WMO object.

## Proposed Internal Organization

The checked-in resource harness has separate baseline and candidate entry
sources plus one common fixed-width C sink and finite memory helpers. Both
images expose the same `giftui_spec003_resource_entry(UInt32) -> UInt32`
boundary. The baseline retains a no-op. The candidate imports production Core,
Diagnostics, and the focused Failure Execution correlation object; it retains
the default health, counter, and buffer storage while measuring the
diagnostics-disabled outcome/policy path.

The shell driver owns pristine compilation and tool invocation. The Ruby
checker owns only normalization, accounting, graph traversal, limit checks,
and fail-closed diagnostics. No analysis code enters a target image.

## Data and Control Flow

1. Delete and recreate one stable pristine build root.
2. Build baseline and candidate with identical target, optimization, runtime,
   main/sink support, and linker mode.
3. Copy the final image, map, sections, symbols, loaded-library set, and
   disassembly to `resources/build-N/{baseline,candidate}`.
4. Classify allocatable writable and code/read-only sections, preserving
   signed candidate-minus-baseline deltas.
5. Resolve the retained production entry in final disassembly, traverse every
   direct callee, and reject reachable indirect calls, cycles, missing bodies,
   and dynamic stack adjustments.
6. Add each frame's decoded fixed stack adjustment to the maximum child path;
   count reachable nRF instructions separately.
7. Repeat from the same generated path and byte-compare both images and all
   normalized reports.

## Algorithms and Data Structures

Mach-O accounting reads `LC_SEGMENT_64` sections and treats `__DATA_CONST` as
read-only after dyld fixups. ELF RAM uses non-executable writable `PT_LOAD`
memory sizes; its section report decomposes all allocatable sections. Code is
the sum of allocatable non-writable sections after excluding debug, symbol,
string, note, comment, and loader-only material.

Function nodes contain final address, decoded frame bytes, direct callees,
indirect/dynamic-stack flags, and instruction count. ARM/Thumb pushes and
constant `sp` subtraction and arm64 pre-indexed saves/subtractions contribute
to the frame. Branches inside the same function are not calls. A DFS active
set rejects recursion; sibling calls contribute their maximum rather than
their sum.

## Lifecycle and State

Each profile run replaces only its generated tree and immutable staging
report. The two builds reuse the same generated path to prevent paths from
changing final hashes. Published reports remain revision/input-digest keyed.

## Runtime Profiles and Platforms

macOS uses arm64 Mach-O, `otool`, Apple `llvm-objdump`, and `nm`. ARMv6 uses a
static Swift runtime ELF with the pinned SDK and LLVM tools. nRF uses two
Zephyr final ELFs with the pinned Cortex-M4F hard-float environment. Cross
profiles inspect only; they do not deploy, execute remotely, or flash.

## Resource and Failure Behavior

The analyzer fails before publishing on a limit breach, changed library set,
missing named storage, unresolved reachable body, indirect call, recursion,
dynamic stack, or non-repeatable image/report. Negative deltas are retained.
The common C helpers give compiler-emitted `bzero`, `memset`, and `memcpy`
calls finite final-image bodies instead of assuming a shared-library frame.

## Test and Diagnostic Seams

Each exact standalone profile command is the integration test. The report
contains `resource-summary.tsv`, `sections.tsv`, `call-graph.tsv`, maps,
disassembly, symbols, libraries, commands, inputs, and image hashes for both
builds. The repository registry continues to invoke the same commands.

## Rejected Implementation Alternatives

- Link the entire `GiftUIExecution` WMO object: unrelated statics become an
  indivisible resource contribution and do not represent the focused path.
- Accept shared-library stubs as zero-frame calls: this would undercount a
  body not present in final-image evidence.
- Use runtime watermarks: they cannot replace the specified static bound.
- Normalize a negative delta to zero or omit section padding: both would
  rewrite the measurement rather than report it.

## Open Implementation Questions

None for T5.4. Exact-runner macOS latency is complete under T5.5; connected
ARMv6 execution and latency evidence remains in T6.2.

## Code and Evidence Links

- [SPEC-003 contract driver](../../scripts/contracts/run-spec-003.sh)
- [resource analyzer](../../scripts/contracts/check-spec-003-resource-evidence.rb)
- [matched resource harness](../../Tests/ContractFixtures/SPEC003/ResourceHarness/README.md)
- [T5.4 resource evidence](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/resource-images.md)
