---
spec: SPEC-005
feature: giftui-mvp-architecture
title: Implementation Design — Static Text-Resource Measurement
status: current
authors:
  - codex
created: 2026-09-04
updated: 2026-09-04
implementation_plan: ../implementation-plans/spec-005-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-005
supersedes: null
superseded_by: null
---

# Implementation Design — Static Text-Resource Measurement

> This note explains a replaceable evidence mechanism for the approved
> resource ceilings. It does not alter the resource package, target profiles,
> or the distinction between hardware-free and connected-hardware evidence.

## Purpose and Boundary

This note records how T5.3 measures linked flash, fixed writable RAM,
validation stack, and target-specific payload omission. It does not define a
production host, raster provider, layout API, backend, or connected-board
runtime measurement.

## Governing Contract

SPEC-005 TR-008, TR-010, and TR-011 require matched optimized images, an nRF
bitmap-only composition, no linked outline payload/provider, at most 96 KiB
incremental text-resource flash, 512 bytes incremental fixed writable RAM, and
a conservative validation stack no larger than 1 KiB. ADR-006 requires the
logical catalogue and identity to remain profile-equivalent; ADR-023 keeps the
nominal resource identities in `GiftUITextResources`.

## Measurement Composition

The nRF baseline and candidate use one Zephyr application, board, linker
script, heap-disabled configuration, C entry point, observable sink, compiler,
flags, and fixed build paths. Both compile the exact `GiftUI` Foundation
source. The candidate additionally compiles the exact maintained
`GiftUITextResources` source, generated common catalogue, generated bitmap
payload, and concrete reference-package source with
`GIFTUI_REFERENCE_BITMAP_ONLY`. The outline generated source is not an input.

For whole-module Embedded Swift measurement, the fixture creates one generated
translation unit from those exact sources after removing only their module
imports. This is a build-only composition technique: source hashes and the
complete compiler/linker commands remain in the immutable report, and no
generated translation unit is committed.

## Resource Accounting

The checker derives flash and RAM from ELF `LOAD` segments and reports signed
candidate-minus-baseline deltas. It records raw program headers, sections,
symbols, map, disassembly, and ELF hashes. Writable RAM delta is the fixed-RAM
measurement; the application disables both Zephyr heap storage and the C
malloc arena. Symbol and map scans require bitmap catalogue/provider evidence
and reject outline payload/provider identities.

The validation-stack checker starts at the retained resource-probe entry,
derives fixed ARM stack adjustments from disassembly, follows direct reachable
calls, and sums the maximum acyclic live-frame path. Whole-module optimization
deduplicates three statically selected helper calls behind PC-relative
register branches; the checker accepts only those named compiler patterns when
the same helper is also present as a direct edge in that function. Every other
indirect call fails closed. The analysis also fails on dynamic stack
adjustments or recursion. This is a conservative static call-chain
measurement, not a connected-hardware high-water mark.

## Lifecycle and Evidence

The driver performs two pristine builds at fixed baseline and candidate paths,
requires byte-identical ELF and normalized measurement results, and publishes
only hardware-free cross-build reports under the immutable SPEC-005 report
identity. It never accesses a remote, deploys, restarts a service, or flashes.

## Rejected Alternatives

- Measuring Swift modules or object files alone was rejected because it cannot
  prove final-link garbage collection or payload/provider omission.
- Comparing unrelated applications was rejected because their runtime and
  linker differences would contaminate the resource delta.
- Using SPIKE-005 firmware was rejected because the spike implementation is
  non-authoritative and does not measure the maintained Swift package.

## Open Implementation Questions

None. Connected-hardware stack high-water and presentation timing remain
outside this independent contract evidence.
