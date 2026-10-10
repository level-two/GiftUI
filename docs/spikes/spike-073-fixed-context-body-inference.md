---
id: SPIKE-073
feature: external-application-integration
title: Fixed Context Body Inference
status: completed
authors:
  - codex
created: 2026-10-10
updated: 2026-10-10
source:
  - RFC-014
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-072
  - SPIKE-074
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# SPIKE-073: Fixed Context Body Inference

Disposable evidence for [SR-Q2](../iterations/iteration-003-review/rfc-014-stable-read-revision.md).
Eugene authorized revising the draft decisions and activities answering the open
questions. This study checks one language mechanism; it does not extend the
terminal SPIKE-072 integration experiment or approve a new public API.

## Target Questions

Can a non-generic evaluation requirement taking one concrete nonescapable read
context infer custom associated Body from `some View`, including a result-builder
conditional and opaque helper, without generated custom Body aliases? Can the
same borrowed context read unchanged owner storage with no snapshot bank while
rejecting overlapping mutation and escape?

## Bounds / Stop Conditions

- At most 16 total compiler/link/execute invocations, two source repair rounds,
  and 30 elapsed minutes after the first invocation. Every failed attempt counts.
- Four configurations: macOS Dynamic/Static flags, ARMv6 Linux, nRF Embedded.
  Native execution only; target object compilation is not target execution.
- One minimal Swift fixture, a native entrypoint, and two negative conditional
  builds (overlapping owner mutation; escaping read context).
- Stop on any ceiling without extension, even if inconclusive. No follow-on
  experiment, actual module integration, schema frontend, hardware, whole-image
  memory claim or production edits.

## Method

Use the pinned local Swift 6.3.2 compilers and the same experimental lifetime
features as SPIKE-072. Define a minimal View protocol with an explicit leaf
marker, result builder, custom opaque bodies and a concrete Span-backed read
context. Store each scalar only once. Exercise typed failures, two evaluation
scopes separated by owner operations, and a deferred Canvas read before allowing
the next write. This is a hand-written internal candidate, not proof that
unchanged authored Swift has already been transformed correctly.

## Reproduction

Run details and exact commands are recorded in the
[experiment README](../../experiments/spike-073-fixed-context-body-inference/README.md).
The runner is terminal and refuses further trials. Record commands, compiler
versions, input hashes, diagnostics, repairs and invocation count. Build outputs
stay under `.build/`, ARMv6 under `.build/raspberry-pi/`, nRF under
`.build/nrf52840/`. No global toolchain changes.

## Results

**Completed: finite mechanism supported.** Four positive configurations compile;
both native runs pass 15 checks each, and both negative controls reject as intended
on all four configurations (eight rejections). There are no explicit custom Body
aliases. The final candidate reads a single scalar bank and preserves previously
owned output across the next mutation cycle.

15/16 compiler/link/execution invocations, one of two allowed repair rounds,
approximately 41 seconds of the 30-minute budget. No extension. The initial typed
catch error and correction remain in the [exact ledger](../../experiments/spike-073-fixed-context-body-inference/evidence/ledger.json).
[Terminal result and limits](../../experiments/spike-073-fixed-context-body-inference/evidence/result.md)
include ABI inspection and reproduction links.

## Limitations

A fixed scalar context does not establish a general typed schema ABI, model
ownership, source transformation, real SemanticCore/Canvas integration, full
application coverage, target linking/execution or production resource bounds.
The two native flags do not exercise the real runtime profiles.

## Disposition

SR-Q2's narrow language question is answered. Feed this result into RFC-014;
full context/schema/module and source-coverage integration remain blockers.
The source is disposable and cannot become production through this experiment.

## References

- [RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
- [SPIKE-072](spike-072-contextual-traversal-integration.md).
- [SE-0244 associated type inference](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0244-opaque-result-types.md#associated-type-inference).

The separately authorized [SPIKE-074](spike-074-final-access-ownership.md) is the
final contract/ownership validation round. It does not reopen this terminal study.
