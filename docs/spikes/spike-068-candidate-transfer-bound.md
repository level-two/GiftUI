---
id: SPIKE-068
feature: external-application-integration
title: Candidate Transfer Lower Bound
status: completed
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

[Disposable sources, recipe and raw evidence](../../experiments/spike-068-candidate-transfer-bound/README.md)
retain exact input/compiler identities and commands. Native Swift 6.3.3 compiled
the selected sources with `GIFTUI_NRF_EMBEDDED`, combining them after removing
imports and extracting the production semantic-variant enum. This is explicitly
weaker than the supported target's separate-owner firmware composition.

## Results

**Decisive failure of G3 for the retained execution strategy.** The normal running
screen produces a 320 × 220 root background and nine fills totaling 127,120
clipped pixels. RGB565 requires 254,240 bytes. The target's display SPI limit
is 4 MHz, so fills alone need at least **508.48 ms**, excluding commands,
glyph/stroke pixels, bus gaps and CPU work. The root background alone needs
281.6 ms. Both exceed the frozen 250 ms budget. See the
[machine-readable decision](../../experiments/spike-068-candidate-transfer-bound/evidence/decision.json)
and [raw rectangles](../../experiments/spike-068-candidate-transfer-bound/evidence/attempt-2-run.log).

The operation-major endpoint submits each fill before proceeding, so overlapping
backgrounds count repeatedly. No retained-surface comparison or controller fill
elides these bytes. This source-preserved property, not host execution time,
connects the geometry result to the target transfer lower bound.

Experiments stopped at **2026-10-09 15:24:23 UTC**. Two compiler-driver invocations
(first failed) and one native execution were issued, with one probe repair.
Compiler/linker subprocesses were not individually traced; conservatively charge
the full 24-invocation allowance closed rather than claiming an exact child
count. The failed compile omitted a composition enum and a rectangle unwrap;
the repair changed only the probe, not production or candidate semantics.

## Limitations

No measured target execution time, complete candidate, stack/heap/lifetime proof,
counter realization or conformance transition follows from this probe.
The generated control is deliberate: runtime derivation must preserve its layout
and the candidate explicitly retains the operation-major transfer semantics.
This does not reject a materially different renderer/transport design.

## Disposition

Completed: the necessary transfer-cost question was answered. Feed the G3
failure to RFC-013's [candidate assessment](../iterations/iteration-003-review/candidate-go-no-go.md)
as a **NO-GO** for this candidate. G1/G2 remain unproved, not follow-up tasks.
No further experiments are authorized by this result, and no Spike code is
promoted to production.

## References

- [RFC-013](../rfcs/rfc-013-external-application-and-backend-integration.md)
- [Candidate and explicit continuation authorization](../iterations/iteration-003-review/candidate-go-no-go.md)
