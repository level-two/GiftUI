---
spec: SPEC-005
feature: giftui-mvp-architecture
title: Implementation Design — Reference Package Generation
status: current
authors:
  - codex
created: 2026-09-01
updated: 2026-09-01
implementation_plan: ../implementation-plans/spec-005-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-005
supersedes: null
superseded_by: null
---

# Implementation Design — Reference Package Generation

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note records how production Swift reference-resource inputs are derived,
pinned, regenerated, and checked for drift. It does not select a font, alter
the adopted bytes, define a runtime registry, or promote the disposable
SPIKE-005 generator or firmware organization into production.

## Governing Contract

The mechanism realizes SPEC-005's `Adopted reference package`, canonical
manifest, performance, and licensed-resource testing requirements, acceptance
criterion TR-004, and implementation-plan tasks T3.1 through T3.4. ADR-023
owns the exact resource identity and ownership boundary; ADR-006 requires
profile-equal logical facts.

## Current-Code Context

`GiftUITextResources` owns the package-level identities, descriptors, views,
canonical byte emitter, SHA-256 implementation, accessors, and validator.
SPIKE-005 preserves the adopted Inter 4.1 inputs and output evidence but its
Python, C, and firmware source remain disposable. The production generator is
therefore reviewed as a separate implementation and emits only data consumed
by the package-internal concrete-resource target.

## Proposed Internal Organization

- `ThirdParty/Inter-4.1/` owns the exact upstream font and OFL text.
- `scripts/text-resources/` owns tool/input pins, environment setup, generation,
  and two-pass verification.
- `Sources/GiftUIReferenceTextResources/Generated/` owns deterministic Swift
  catalogue and payload inputs plus a machine-readable generation manifest.
- The concrete target added by T3.2 owns view conformance and assembly; the
  generator does not emit host or runtime policy.

## Data and Control Flow

The generator first verifies the source, license, Python, fontTools, Pillow,
and FreeType pins. It subsets and renames the source, reconstructs the exact
mapping, metrics, bitmap strike, outline fixture, records, canonical bytes,
and all three adopted digests, then refuses output if any adopted count or
identity differs. Verification generates into two fresh temporary roots,
compares them byte for byte, and compares the result with checked-in output.
`--update` replaces only the generated reference-resource directory.

## Algorithms and Data Structures

Mappings, metrics, realization descriptors, and raster records are emitted as
bounded switch tables. Payloads are emitted as nested tuples of explicit
`UInt8` literals in 32-byte groups. This keeps the bytes compiler-visible and
avoids collection initialization; T3.2 and T5.2 must prove exact layout and
zero-allocation borrowing on every selected profile. The grouping is an
internal source-size choice and does not affect payload identity.

## Lifecycle and State

Inputs and checked-in outputs are immutable. Regeneration produces a complete
candidate directory and publishes it only through the explicit update mode.
Runtime package validity is not inferred from generation: T3.2 still runs the
SPEC-005 validator for both required realizations before admitting the
complete package.

## Runtime Profiles and Platforms

Generation runs only in the pinned macOS ARM64 Python environment. Its output
contains one common catalogue plus separable bitmap and outline provider
sources so later target composition can omit an unselected provider without
changing the catalogue or `FontResourceID`.

## Resource and Failure Behavior

Every mismatch fails closed before checked-in output is accepted. Generation
may allocate because it is build tooling; generated runtime access must meet
the zero-allocation and finite-resource bounds proved by later tasks. No
generated file contains mutable runtime state.

## Test and Diagnostic Seams

The standalone verification script proves two-pass reproducibility and stale
output detection. The registered SPEC-005 driver independently audits input
hashes, pins, output names, output hashes and sizes, table row counts, payload
byte counts, descriptors, and the adopted identity without requiring the
generator environment to be installed.

## Rejected Implementation Alternatives

- Reusing the SPIKE-005 generator directly was rejected because the spike
  explicitly classifies that mechanism as disposable.
- Runtime parsing of a font or canonical manifest was rejected because the
  contract requires generated immutable data and no runtime file format.
- Swift arrays were rejected for payload ownership because collection
  initialization would conflict with the static zero-allocation path.

## Open Implementation Questions

None for T3.1. Compiler layout, payload omission, and static-resource section
measurements remain evidence tasks in T3.2, T3.3, and T5.3.

## Code and Evidence Links

- `scripts/text-resources/generate-reference-resources.py`
- `scripts/text-resources/verify-reference-generation.sh`
- `Tests/ContractFixtures/SPEC005/Evidence/milestone-3/reference-generation.md`
