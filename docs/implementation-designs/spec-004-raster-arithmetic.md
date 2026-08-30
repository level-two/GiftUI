---
spec: SPEC-004
feature: capability-system
title: Implementation Design — Checked Raster Arithmetic
status: draft
authors:
  - codex
created: 2026-08-30
updated: 2026-08-30
implementation_plan: ../implementation-plans/spec-004-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Checked Raster Arithmetic

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note examines the checked effective-alignment, row-byte, region, usage,
and capacity-minimum mechanism assigned to SPEC-004 plan task `T2.1`. It does
not select encoding/lifetime policy, assemble the public resolver, change any
public width, or reinterpret an unavailable reason.

The note remains `draft` because the governing contract currently requires
overflow results that cannot be produced from its own constructible typed
inputs. No production arithmetic implementation should claim T2.1 conformance
until that conflict is resolved upstream.

## Governing Contract

The mechanism is governed by SPEC-004 `Byte-bound and region arithmetic`,
`Error Handling`, `Testing Requirements`, acceptance criterion `CR-010A`, and
plan tasks `T2.1`, `T2.4`, and `T3.1`. ADR-019 requires deterministic bounded
allocator-independent resolution; ADR-020 fixes the composite raster inputs
and quantitative bounds.

## Current-Code Context

`GiftUICapabilities` already admits only nonzero `CapabilityExtent` values
with `UInt16` dimensions and only nonzero `UInt16` row alignments. Candidate
and surface region maxima are also `UInt16`. Byte counts and all required
arithmetic outputs are `UInt32`. Typed construction prevents malformed values
from reaching the future resolver.

The current internal workspace owns two fixed candidate slots. No public
resolver exists yet, so T2.1 can still be corrected without compatibility or
migration cost.

## Proposed Internal Organization

Once the contract conflict is resolved, keep arithmetic in one internal,
value-only helper used by candidate evaluation. It should accept one typed
requirement, realization, surface contribution, policy, and selected encoding;
return either a fixed geometry/usage record or the exact capability-domain
reason; use no collection or closure; and expose a package-internal test seam
for every checked operation.

The public resolver remains the only future public entry point. Arithmetic
helpers and their intermediate records remain replaceable implementation
details and must not create an alternate public contract.

## Data and Control Flow

For one candidate and encoding, the intended control flow is:

1. validate logical extent and region admission;
2. compute `gcd`, then checked `alignment / gcd * otherAlignment`;
3. checked-multiply width by bytes per pixel;
4. checked-round the row upward without a wrapping `value + alignment - 1`;
5. select full-surface height or the deterministic tallest tiled height;
6. checked-multiply row bytes by region height for raster, then payload;
7. copy the representable payload usage to in-flight usage; and
8. compare each usage with the three-owner minimum ceiling in raster,
   payload, then in-flight order.

Any selected realization record should be constructed only after all steps
succeed, so no partial value survives a failure.

## Algorithms and Data Structures

Euclid's algorithm supplies a bounded `gcd`. LCM should divide before its one
checked multiplication. Row round-up should use remainder and checked padding
addition. Capacity minima are direct comparisons among exactly three fixed
values. Full-surface and tiled height selection require no search or
collection.

However, the approved widths prove these required overflow sites unreachable:

- For two `UInt16` alignments, `lcm(a, b) <= a * b <= 65_535² =
  4_294_836_225`, which is below `UInt32.max` (`4_294_967_295`). The checked
  LCM multiplication therefore cannot overflow.
- `UInt16.max * 4 = 262_140`, so unaligned RGB565/RGBA8888 row multiplication
  cannot overflow `UInt32`.
- If LCM exceeds the unaligned row, the rounded row is exactly that
  representable LCM. Otherwise the rounded row is less than
  `262_140 + 262_140`, also representable. Aligned-row round-up therefore
  cannot overflow.
- Raster and payload usage are both specified as the same
  `rowBytes * regionHeight`. Raster multiplication is checked first. If it
  succeeds, repeating the same multiplication for payload must also succeed;
  a payload-only arithmetic overflow cannot occur.

Raster usage overflow remains reachable when a large representable row is
multiplied by a nonzero `UInt16` region height. That single reachable case does
not satisfy the mandated shared-site and payload-domain overflow fixtures.

## Lifecycle and State

Arithmetic is pure per invocation. It retains no input borrow, mutates no
contribution, and writes a workspace candidate only after complete success.
The enclosing resolver must reset both candidate slots on every return, but
that lifecycle belongs to `T2.3`.

## Runtime Profiles and Platforms

All profiles must use the same fixed-width algorithm and return value-equal
results. Compiler specialization may differ; arithmetic semantics and reason
precedence may not. The width proof applies equally to the Apple, ARMv6, and
Embedded Swift compilers because the public raw widths are fixed.

## Resource and Failure Behavior

The intended helper is allocation-free, constant-space, and bounded by a
small fixed count of Euclid iterations and checked operations. It must return
the assigned `RasterPresentationUnavailable` value without trapping,
saturating, wrapping, or weakening the candidate.

Implementing wider private test inputs would not repair the conflict: such
fixtures would no longer be constructible resolver inputs and would falsely
claim conformance with the typed resolver requirements.

## Test and Diagnostic Seams

After upstream resolution, table-driven tests should cover both encodings,
unequal alignments, full/tiled regions, zero ceilings, each three-owner
minimum, exact 3,840-byte nRF usage, and every genuinely reachable overflow
site. The tests must distinguish site-local arithmetic helpers from public
resolver fixtures and must not manufacture invalid typed records.

## Rejected Implementation Alternatives

- Widen only private helper inputs for overflow tests: rejected because those
  values cannot reach the typed resolver and would mislabel test coverage.
- Perform payload multiplication with deliberately different operands:
  rejected because the approved contract defines raster and payload usage by
  the same formula.
- Use wrapping or saturating arithmetic to manufacture a reason: rejected by
  SPEC-004's fail-closed checked-arithmetic rules.
- Silently omit unreachable fixtures: rejected because `CR-010A` and the plan
  explicitly require them.

## Open Implementation Questions

One blocking Specification decision is required. The authoritative contract
must either widen/change the input domains so the mandated overflow cases are
constructible, remove or revise unreachable overflow outcomes and fixtures
using the fixed-width proof, or define genuinely different raster/payload
usage operands. Choosing among those options changes public or normative
behavior and is outside implementation authority.

## Code and Evidence Links

- [Capability values and fixed storage](../../Sources/GiftUICapabilities/GiftUICapabilities.swift)
- [Focused capability tests](../../Tests/GiftUICapabilitiesTests/GiftUICapabilitiesTests.swift)
- [SPEC-004 contract driver](../../scripts/contracts/run-spec-004.sh)
