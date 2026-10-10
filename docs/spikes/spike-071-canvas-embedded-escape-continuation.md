---
id: SPIKE-071
feature: external-application-integration
title: Canvas Embedded and Escape Continuation
status: active
authors:
  - codex
created: 2026-10-10
updated: 2026-10-10
source:
  - RFC-014
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-070
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# SPIKE-071: Canvas Embedded and Escape Continuation

## Authorization and baseline

Eugene's “Please proceed” after the SPIKE-070 terminal report authorizes the
proposed bounded assertion correction and missing Embedded/escape/resource
checks. Baseline `21f3bea2`, clean working tree. Keep SPIKE-070 terminal and its
experiment files unchanged. Commit registration, evidence, then RFC disposition.
This is post-MVP iteration-3 analyzer/counter stack evidence under accepted
PROPOSAL-007; the feature stays at RFC. No architecture approval is inferred.

## Target Questions

1. Does evaluating the typed throwing reads before combining Bool values remove
   SPIKE-070's Embedded test-assertion failure without changing candidate semantics?
2. Does the same corrected source pass both native profiles and compile on Pi
   ARMv6 and nRF Embedded, before interpreting any compiler-negative control?
3. Do return-local, outer-storage, escaping-closure, stored-field, nested-helper
   escape and overlapping-mutation controls reject for their intended reason on
   all four configurations?
4. What allocator references, indirect calls and ARM/VFP ABI remain in the nRF
   object after section GC rooted at the externally supplied-storage driver?

## Bounds / Stop Conditions

- **60 active minutes from 06:26:14 UTC; wall deadline 07:26:14 UTC**, including
  registration, analysis and commits; no excluded waiting initially.
- **48 compiler/link/executable invocations; three repair rounds total**, with
  the known assertion correction counted as round 1. Same candidate only.
- Matrix: four positive compilations + two native runs + six negative controls
  on four configurations + sectioned nRF compilation/rooted relocatable link =
  **32 planned calls**, up to 16 reserved calls for repairs/targeted controls.
- Stop at any exhausted ceiling or decisive contract/scope incompatibility.
  Report supported recommendation, incompatible or inconclusive. No automatic
  successor, replacement API or production adoption.
- No production edits, SDK installation, hardware, firmware host integration,
  new source grammar, C-P3 owner pool, performance campaign or storage decision.
  Keep generated target artifacts in their existing `.build/` target roots.
- Toolchain version/doctor reads, source generation, hashes and object inspection
  are inventory, not compiler/run trials. Preserve every actual trial and input.

## Method

Copy the SPIKE-070 fixture into a new disposable experiment directory. Preserve
its source transformer, contextual root descriptor, extra draw FrameRead
argument, fixed visitor and unsafe host-backing preconditions. In the two
failing assertions evaluate each `throws(AccessFailure)` read into an owned
scalar first, then compare/and nonthrowing values. No new candidate mechanism.

Pin the same local Swift 6.3.2, ARMv6 destination and Cortex-M4F hard-float
configuration. Retain the tested LifetimeDependence + Lifetimes flags; their
production adoption is still a separate policy issue. Compile Embedded first,
then validate all four positive configurations before the six-case negative
matrix. Require intended compiler diagnostics, not simply a failing exit code.

Inspect symbols, relocations, disassembly, sections and attributes of the nRF
object and rooted relocatable object. Distinguish unreferenced symbol-table
entries from live allocator relocations. Report finite indirect drawing-table
calls honestly. A relocatable fixture is not a full linked firmware or stack,
whole-image allocation, timing or hardware result.

## Reproduction

Sources/evidence: `experiments/spike-071-canvas-embedded-escape-continuation/`.
Append-only runner records commands, compiler/source hashes, diagnostics and
source snapshots. Keep its terminal marker after reporting. Prior evidence is
linked from [SPIKE-070](spike-070-protocol-canvas-versioned-access.md).

## Results

Pending within the authorized bounds.

## Limitations

All SPIKE-070 source/owner/Layout limitations remain. Only frozen reads are
lowered; native profile flags do not prove Dynamic class-owner equivalence.
Neither this fixture nor its negatives are complete coverage of every framework
route. B0 storage, production contextual View evaluation, full field/helper
coverage, owner tickets/C-P3, exact layouts and full supported-image costs remain
RFC blockers regardless of this experiment's result.

## Disposition

Active. Feed the terminal evidence into RFC-014 without changing approval state.
A further extension requires explicit authorization and a new bounded method.

## References

- [RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md)
- [Prior result](../../experiments/spike-070-protocol-canvas-versioned-access/evidence/result.md)
- [C contract](../iterations/iteration-003-review/rfc-014-c-contract.md)
- [Current activity plan](../iterations/iteration-003-review/memory-efficiency-plan.md)
