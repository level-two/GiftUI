---
id: SPIKE-072
feature: external-application-integration
title: Contextual Traversal Integration
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
  - SPIKE-071
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# SPIKE-072: Contextual Traversal Integration

Eugene's “Let's do it” authorizes the proposed integration experiment and
provisional pursuit of mandatory finite source transformation. It does not
approve RFC-014, compiler policy, the five-bank budget or production migration.
Baseline `5eda3063`, clean checkout. This is post-MVP iteration-3 analyzer/counter
evidence under accepted PROPOSAL-007; the feature remains at RFC.

## Target Questions

1. Can genuine root and nested custom View conformers return stable owned Body
   values through contextual evaluation in the actual SemanticCore traversal?
2. Can a parent read borrow end before nested State materialization while the
   same frame remains frozen, with explicit access/binding failures and cleanup?
3. Can the actual CanvasPlanProducer/CanvasInvocationSource seam deliver a
   separate scoped read argument, preserving ordering and mid-list failure cleanup?
4. Can a finite source transformation preserve conditional read effects and
   typed failures? What application routes exceed the tested grammar?

## Bounds / Stop Conditions

- 90 minutes from **07:18:52 UTC**, deadline **08:48:52 UTC**, including recording
  results; 64 compiler/link/executable invocations and four compiler-driven repair
  rounds initially. The executor explicitly adjusted this self-imposed repair
  estimate to five after trial 10 solely for a missed multiline leaf declaration
  in the disposable copy adapter; this deviation is recorded, not attributed to
  maintainer approval. The 90-minute/64-invocation ceilings remain fixed.
  Stop at a decisive candidate incompatibility or those remaining ceilings.
- One contextual candidate, four configurations: macOS Dynamic/Static, Pi ARMv6
  Dynamic, nRF Embedded Static. Pin local Swift 6.3.2 and the previously tested
  LifetimeDependence/Lifetimes flags for experimental code only.
- Keep production sources unchanged. Create reproducible adapted copies under
  `experiments/spike-072-contextual-traversal-integration/`; retain exact diffs
  and hashes. Do not substitute a toy traversal for SemanticCore or toy drawing
  orchestration for CanvasPlanProducer. Fixture storage/workspaces may be bounded
  test adapters; identify their limits explicitly.
- No hardware, full firmware/performance claim, storage-budget adoption, general
  Swift compiler, full application migration, or renewed generic escape matrix.
- Record unsupported or incomplete routes as RFC blockers, not Future Work.
  Compiler rejection is a valid result; no automatic alternative or successor.

## Method

Adapt the actual framework source in disposable copies to the
[contextual design](../iterations/iteration-003-review/rfc-014-contextual-evaluation.md).
Compile a generated root and nested State host, with runtime structural traversal
and no generated graph records. Test owned return then child binding, frozen
coherence, branch/short-circuit failures, capacity refusal and discard. Exercise
actual Drawing orchestration with distinguishable occurrences and a mid-list
failure. Inventory counter/analyzer reads, helpers and mutations against the
finite grammar; do not equate inventory with successful lowering.

Record compiler commands, inputs, logs and all unsuccessful trials. Native
execution supplies behavioral evidence; target object compilation supplies only
compiler/ABI evidence. Review independent expected traversal counts and cleanup.
Commit registration, experiment/evidence, then RFC disposition separately.

## Reproduction

Disposable sources and runner:
`experiments/spike-072-contextual-traversal-integration/`.
Run commands from the repository root. Target outputs stay under `.build/`,
with Pi and nRF artifacts under their established target directories.

## Results

Pending bounded experiment.

## Limitations

No production approval or full C-P3 owner-pool, Dynamic class equivalence,
five-bank accounting, full-image allocation/stack or hardware evidence follows.
Exact source/build compatibility and experimental compiler policy remain review
items even if the tested mechanism succeeds.

## Disposition

Active. Feed terminal evidence into RFC-014 and its CE-1–CE-7 review findings.

## References

- [RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md)
- [SPIKE-071](spike-071-canvas-embedded-escape-continuation.md)
- [Design review](../iterations/iteration-003-review/i3-t02-design-review.md)
