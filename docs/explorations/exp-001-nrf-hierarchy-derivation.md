---
id: EXP-001
feature: signal-analyzer
title: nRF Hierarchy Derivation and Stable Role Bindings
status: draft
authors:
  - codex
created: 2026-10-04
updated: 2026-10-04
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

# EXP-001: nRF Hierarchy Derivation and Stable Role Bindings

This captures the uncertain replacement candidate in draft ITERATION-002.
It does not approve architecture, select remediation, or change SPEC-001.

## Questions / Hypotheses

1. Can the actual portable analyzer declaration derive normal and diagnostic
   semantics into bounded caller-owned storage on Embedded Swift without a
   heap, reflection, or forbidden runtime dependency?
2. Can model text, modifiers and actions use declaration-derived stable roles
   instead of coordinated numeric ordinals, even if packed storage is retained?
3. Can a candidate preserve structural identity, observable attachment, action
   generation, text/layout/render parity and complete failure cleanup?
4. What are assembled flash, RAM, stack and derivation-time costs relative to
   the same pinned build of the current implementation?

## Scope

The boundary is generated analyzer topology/packed semantic records, affected
UTF-8 pools, model text/modifier writers, the topology updater and its projection
fixtures, and expansion/layout/render/action consumers. Static Canvas
specialization, fonts/resource generation, package splitting, capture retention
and target performance optimization are non-goals.

## Known Constraints

SPEC-001 and SPEC-005/006/007/010/011/012/013/015 govern declarations, bounded
ownership, identity, parity and production joins. Static zero-heap, ABI and
forbidden-symbol requirements remain mandatory. Use paired Swift 6.3.2/Zephyr
pins under `.toolchains/nrf52840/`, board `nrf52840dk/nrf52840`, and generated
firmware under `.build/nrf52840/`. Current toolchain guards limit linked RAM to
196,608 bytes and flash to 1,048,576 bytes, warning at 917,504 flash bytes.
These ceilings do not decide acceptable replacement deltas or derivation time.
Agree those comparison thresholds before judging feasibility. Hardware-free
size does not prove physical cadence or stack high-water.

## Candidate Directions

- Retain packed projection and generate/check stable semantic-role bindings.
- Derive bounded records at runtime from portable structural witnesses.
- Generate complete tables and role bindings offline from one declarative
  intermediate input, replacing updates that patch existing generated files.

Retaining the current design is valid. Less maintenance coupling need not mean
a different physical storage representation.

## Evidence Plan

1. Freeze compiler/configuration/source hashes and baseline assembled costs;
   enumerate the exact files and manual bindings a candidate replaces.
2. Agree allowed flash/RAM/stack deltas and derivation-time limits, specifying
   startup-only versus per-publication work and simultaneously live storage.
3. Create a disposable bounded Spike using the actual normal/diagnostic analyzer
   declarations and common owners. Cover running/stopped/cleared and 1/2/5-second
   states; a miniature alternate view cannot prove full replacement.
4. Compare identity, attachments/actions, model text/modifiers, metrics/layout,
   render transcripts and approved pixels. Inject insufficient capacity, invalid
   identity, partial expansion, cleanup and reuse failures.
5. Compare firmware with identical pins and production closure. Check ARMv7E-M
   and VFP ABI, zero heaps and forbidden linked symbols; measure RAM/flash and
   conservative stack bounds. Physical timing/high-water requires a separately
   authorized connected campaign.
6. Stop with a negative/inconclusive result on unsupported declarations, parity
   mismatch, unbounded storage, forbidden runtime or exceeded agreed budgets.
   Route selected public/ownership/profile/resource changes through lifecycle
   gates before production implementation.

## Findings

The current hierarchy has 92 scopes and a 3,024-byte packed semantic region.
Model writers and the updater coordinate numeric ordinals outside the portable
declaration. The isolated updater reproduces both outputs and is idempotent,
but uses existing generated files as inputs. These are maintenance-coupling
and freshness observations, not evidence that runtime derivation is cheaper
or viable. See [CBR-002](../iterations/iteration-002-review/findings.md) and
[hashed results](../iterations/iteration-002-review/evidence/09-hierarchy-generator.json).

The [fresh hardware-free gate](../iterations/iteration-002-review/11-fresh-hardware-free-validation.md)
records the current assembled baseline at 275,600 flash bytes and 191,104 RAM
bytes. This is not a candidate comparison or fresh physical stack/timing proof.

## Remaining Unknowns

No replacement prototype, agreed allowed deltas/derivation budget or measured
candidate firmware exists in this review. Existing declaration feasibility and
current firmware conformance do not answer these questions.

## Disposition

Continue as a proposed bounded investigation for iteration selection. Retain
current production code pending comparative evidence. Audit source assessment
is complete; IT-AC-003's replacement feasibility assessment remains open.

## Revisit Triggers

- ITERATION-002 selects the investigation and comparison budgets are agreed.
- A portable hierarchy change requires another coordinated ordinal update,
  providing a concrete case for stable-role generation.
- A selected candidate changes an owner/profile/public contract: feature triage
  and applicable Proposal/RFC/ADR/Spec gates precede production changes.

## References

- [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
- [Draft ITERATION-002](../iterations/iteration-002-cleanup.md)
- [Step 02](../iterations/iteration-002-review/02-interfaces-and-mappings.md)
- [Step 09](../iterations/iteration-002-review/09-tests-generation-and-entrypoints.md)
- [Topology updater](../../scripts/contracts/generate-spec-001-nrf-topology.py)
- [Model text writer](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelTextWriter.swift)
- [Model modifier writer](../../Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelModifierWriter.swift)
- [nRF pins and resource limits](../../scripts/nrf52840/toolchain.env)
