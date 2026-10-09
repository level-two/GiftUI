---
id: SPIKE-068
feature: external-application-integration
title: Candidate Transfer Lower Bound
status: planned
authors:
  - codex
created: 2026-10-09
updated: 2026-10-09
source:
  - RFC-013
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# SPIKE-068: Candidate Transfer Lower Bound

## Target Questions

Does the retained analyzer Layout/Render/operation-major transfer path already
require more wire time than the candidate's 250 ms frame budget, even with
zero CPU cost? Measure mandatory fill coverage, not whole candidate speed.

## Bounds / Stop Conditions

Part of the single [authorized candidate assessment](../iterations/iteration-003-review/candidate-go-no-go.md):
same 16:11:26 UTC deadline, 24-invocation and two-repair ceilings, with no reset
under this new ID. SPIKE-067's historical 744 invocations and 30 corrections
remain separate and exhausted. This changes the method to early whole-candidate
falsification; it does not resume the archived stack-closure ladder.

Only native source/geometry evidence and source-derived transfer arithmetic.
No connected action, production edit, compiler install or full target build.
Stop if a mandatory lower bound exceeds 250 ms; do not optimize the rejected
transfer strategy. A compiler/tool error is missing evidence, not a timing failure.

## Method

Use the selected firmware source list to rehearse its current generated semantic
control, common Layout and Render fill operations on the host. Record clipped
fill rectangles. Count every fill's transmitted RGB565 pixels because the
retained endpoint completes and submits each operation before the next.
Ignore glyph/stroke/command/CPU costs to obtain a conservative lower bound.
Read width, height, bytes/pixel and SPI limit from actual target source.

The candidate requires equivalent layout/operations and retains this endpoint;
a counterexample in its production control therefore refutes that preserved
execution strategy. Generated control topology is not runtime-derivation proof.

## Reproduction

Disposable sources and driver: `experiments/spike-068-candidate-transfer-bound/`.
Build/run commands, source/compiler hashes, output and accounting will be
retained with the results. Any combined native source fixture is explicitly
weaker than the supported target's separate-owner firmware composition.

## Results

Not run at registration. See the parent assessment for the frozen gates.

## Limitations

No measured target execution time, complete candidate, stack/heap/lifetime proof,
counter realization or conformance transition follows from this probe.

## Disposition

Pending one terminal result within the parent's budget. There is no successor
experiment authorized by a negative or missing result.

## References

- [RFC-013](../rfcs/rfc-013-external-application-and-backend-integration.md)
- [Candidate and explicit continuation authorization](../iterations/iteration-003-review/candidate-go-no-go.md)
