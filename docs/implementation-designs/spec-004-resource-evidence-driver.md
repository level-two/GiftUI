---
spec: SPEC-004
feature: capability-system
title: Implementation Design — nRF Resource Evidence Driver
status: current
authors:
  - codex
created: 2026-08-31
updated: 2026-08-31
implementation_plan: ../implementation-plans/spec-004-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — nRF Resource Evidence Driver

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains the matched nRF52840 image construction, load-segment and
named-storage accounting, and conservative resolver-stack inspection used by
SPEC-004 T5.3/T5.4. It does not change the 256-byte stack bound, select a new
resolver realization, complete T5.4 repeatability evidence, or authorize
connected-board work.

## Governing Contract

The mechanism realizes SPEC-004 `Performance Requirements`, `Reproducible
resource evidence`, CR-011 through CR-013, and plan tasks T5.3/T5.4. Accepted
ADR-019 requires measured incremental RAM, stack, flash, initialization work,
and allocator-independent storage; ADR-020 requires explicit bounded composite
resolution.

## Current-Code Context

The production `GiftUICapabilities.swift` is one dependency-free source file.
The nRF toolchain is pinned to Swift 6.3.2, Zephyr 4.3.0, SDK 0.17.4,
`nrf52840dk/nrf52840`, and hard-float `armv7em-none-none-eabi`. The same
application root can build baseline and candidate images through a CMake
boolean; generated build trees and evidence remain under deterministic
`.build/contract-*` roots.

## Proposed Internal Organization

The checked-in application owns only Zephyr configuration, a shared C entry,
the Swift resource probe, and fixed stubs. Baseline compiles the probe's
retained no-op branch alone. Candidate generates one WMO Swift input by
concatenating the exact production source bytes with the probe bytes, then
compiles that input with the contract flags. This avoids duplicate
`.swift_modhash` objects from two WMO output objects while keeping the
production source list and hashes explicit.

The downstream Ruby checker reads final ELF program headers, symbols, and
disassembly. It contains no target behavior and cannot affect the measured
image.

## Data and Control Flow

1. Verify the pinned local nRF environment without flashing.
2. Pristine-build baseline and candidate with identical board, Zephyr, C,
   linker, staging, entry, and heap settings.
3. Record final ELF/map hashes and emit program headers, sections, symbols,
   size-sorted symbols, and disassembly.
4. Classify RAM by RAM-addressed `PT_LOAD` memory size and flash by non-RAM
   `PT_LOAD` file size; retain signed candidate-minus-baseline deltas.
5. Sum named capability globals separately from the shared display-staging
   symbol.
6. Build a final-image function table from text symbols, derive fixed frame
   bytes from pushes and constant stack subtraction, resolve direct calls by
   address, and select the maximum acyclic reachable path beginning at the
   production resolver.
7. Fail closed on a missing resolver, dynamic stack adjustment, reachable
   unresolved indirect call, cycle, or exceeded bound.

## Algorithms and Data Structures

All report state is host-side and finite over the final symbol/disassembly
files. Function nodes hold address, size, fixed frame bytes, direct callees,
and an indirect-call flag. Call-graph traversal tracks the active path to
reject recursion and adds one frame per simultaneously live call; sibling
paths contribute their maximum rather than their sum.

## Lifecycle and State

Every driver run replaces only its profile's generated/report trees. No build
artifact or measurement state enters production source, and no result is
cached across repository revisions.

## Runtime Profiles and Platforms

The matched firmware pair is nRF-specific hardware-free evidence. The same
driver separately emits 32-bit ARMv6 and 64-bit macOS layout reports, but it
does not reinterpret cross-built images as connected-target execution.

## Resource and Failure Behavior

The checker reports totals, signed deltas, named storage, staging, work, and
stack independently. Current evidence passes every T5.3 bound, including an
80-byte conservative resolver path against the 256-byte ceiling.

## Test and Diagnostic Seams

The four profile drivers exercise layout extraction. The nRF driver builds and
inspects the pair and fails closed on any resource breach. The checker itself
is syntax checked and its result is preserved in the stable T5.3 evidence
record; T5.4 must later add pristine repeatability and complete normalized
metrics.

## Rejected Implementation Alternatives

- Compile production and probe as separate WMO source objects: rejected after
  the pinned BFD link failed on the duplicate Swift module-hash arrangement.
- Measure the outer resource-probe frame as resolver stack: rejected because
  the approved bound begins at the production resolver entry.
- Ignore reachable callees or accept a runtime watermark: rejected by the
  conservative final-image contract.
- Treat the original 540-byte result as an exception: rejected because the
  approved bound requires a conforming internal realization or renewed review.

## Open Implementation Questions

None for T5.3. T5.4 still owns two-build repeatability and the complete matched
image/call-graph evidence required before conformance.

## Code and Evidence Links

- [SPEC-004 contract driver](../../scripts/contracts/run-spec-004.sh)
- [nRF resource checker](../../scripts/contracts/check-spec-004-nrf-resources.rb)
- [resource fixture](../../Tests/ContractFixtures/SPEC004/ResourceHarness/README.md)
- [T5.3 resource evidence](../../Tests/ContractFixtures/SPEC004/Evidence/milestone-5/nrf-resource-boundary.md)
