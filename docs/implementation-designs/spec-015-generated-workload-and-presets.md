---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — Generated Workload and Presets
status: current
authors:
  - codex
created: 2026-09-13
updated: 2026-09-14
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Generated Workload and Presets

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains the deterministic host-only generation mechanism for
SPEC-015 T2.1-T2.4. It does not select workload counts, profiles, capacities,
endpoint semantics, or application behavior; those remain fixed by SPEC-001,
SPEC-008, SPEC-012, SPEC-013, and SPEC-015.

## Governing Contract

The mechanism realizes SPEC-015 `Construction and validation`, the schema-2
workload requirements in `Types / APIs`, HC-004 through HC-006 and HC-013
through HC-015, and plan tasks T2.1-T2.4. ADR-008 preserves module ownership,
ADR-031 requires structural Drawing admission before execution, and ADR-033
fixes the bounded application/action inputs.

## Current-Code Context

`GiftUIHostConfiguration` already owns immutable host values and imports
`GiftUIRuntimeCore`, which exposes the complete nested `RuntimeProfileLimits`
vocabulary. The host target deliberately does not import focused owners behind
Runtime Core. SPEC-001 now supplies the portable five-Canvas hierarchy and its
exact Drawing workload.

## Proposed Internal Organization

One ordered SPEC-015 TSV descriptor records source counts and four physical
preset projections. The checked-in SPEC-001 hierarchy-shape descriptor is a
second input. A host-only Ruby generator validates their shared model, action,
and Canvas counts plus checked operation addition, then emits four reviewable
manifests and one Swift file in `GiftUIHostConfiguration`. Contextual `.init`
expressions build nested runtime limits through Runtime Core without adding
forbidden focused-owner imports.

## Data and Control Flow

The generator reads both descriptors once, rejects missing, duplicate,
malformed, overflowing, or changed hierarchy and normative Drawing minima,
computes one SHA-256 identity over both ordered inputs, and writes outputs in
fixed field and preset order. `--check` regenerates in memory and byte-compares
every output. Neither mode loads or evaluates Swift application code, a client
body, or a Canvas closure.

## Algorithms and Data Structures

Generation uses ordered rows and fixed maps rather than discovery. The source
digest is embedded as four `UInt64` words so static presets carry no String or
heap-owned identity. Common hierarchy limits are emitted once per function
body; profile-specific optional Canvas metadata and storage byte projections
are the only runtime-profile differences. The combined render bound is checked
before emission.

## Lifecycle and State

Generated presets are immutable values. Changing the descriptor invalidates
all manifests and the Swift output; it cannot mutate a live host. Regeneration
has no cache or persistent state beyond checked-in outputs.

## Runtime Profiles and Platforms

All four outputs share hierarchy and application counts. Dynamic projections
carry no static Canvas metadata. Static projections carry the two generated
callable cases and the maximum inline capture record. The macOS pair has equal
extent and common leaves; Pi and nRF projections differ only in the physical
raster region and byte limits fixed by SPEC-015.

## Resource and Failure Behavior

Generation is a host-build action and may allocate. Generated Swift uses finite
integer values and contains no discovery, reflection, service lookup, or live
owner construction. Invalid or stale input fails the checker before compilation.

## Test and Diagnostic Seams

Unit tests compare all four projections, every schema-2 workspace relation,
Drawing minima, combined-operation bound, profile/static metadata, pacing,
cardinality, extent, and raster bytes. The freshness checker provides a
standalone fail-closed evidence seam.

## Rejected Implementation Alternatives

- Runtime reflection over the portable view was rejected because validation
  must not evaluate client code and static hosts require build-time values.
- Hand-maintained Swift presets were rejected because they cannot prove
  descriptor/output freshness or deterministic equality.
- Direct focused-owner imports were rejected because the approved module
  boundary routes the complete limit vocabulary through Runtime Core.

## Open Implementation Questions

None.

## Code and Evidence Links

- `Tests/ContractFixtures/SPEC001/hierarchy-shape-cases.tsv`
- `Tests/ContractFixtures/SPEC015/signal-analyzer-workload.tsv`
- `scripts/contracts/generate-spec-015-workload.rb`
- `Sources/GiftUIHostConfiguration/Generated/SignalAnalyzerPresets.generated.swift`
- `Tests/ContractFixtures/SPEC015/Generated/`
