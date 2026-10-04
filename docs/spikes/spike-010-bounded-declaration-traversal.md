---
id: SPIKE-010
feature: signal-analyzer
title: Bounded Analyzer Declaration Snapshot Traversal
status: completed
authors:
  - codex
created: 2026-10-04
updated: 2026-10-04
source:
  - EXP-001
related_future_work: []
related_explorations:
  - EXP-001
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# SPIKE-010: Bounded Analyzer Declaration Snapshot Traversal

## Target Questions

Can a precisely bounded snapshot lowering traverse the actual analyzer body
with the shared semantic engine on the paired Embedded compiler? Does this
prerequisite avoid the whole-module failure in SPIKE-009, and what does keeping
it reachable in the actual firmware cost?

## Bounds / Stop Conditions

Hardware-free only, actual body/subview/geometry source, 42 acquisition/window/
diagnostic/capture combinations, and two expansion refusal limits. Stop at a
compiler restriction or a traversal-count/cleanup mismatch. Do not implement
new observable attachment, identity, packed publication, drawing or action
execution contracts. No production adoption or connected work. No replacement
cost/timing budget was agreed, so this is a prerequisite experiment.

## Method

The runner copies the complete maintained `SignalAnalyzerView.swift`, retaining
its body, subviews, control styles and draw functions. Three explicit root
edits remove the host macro, replace `@State` with a stored value and replace
the wrapper initialization. It copies the actual view-state/window/action
declarations, diagnostic-to-bounded-text conversion and waveform geometry.
The local value carrier supplies the actual model's visible-range formula;
its capture is a caller-owned four-transition buffer with low baselines.
This is **snapshot lowering**, not the original class/observable model.

The existing `expandSemanticTree` visits that declaration with a bounded
counter workspace and sink. The workspace assigns sequential identities;
these are deliberately not production structural identities. The sink decodes
actual layout primitives/modifiers, accepts the disabled payload, and counts
occurrences. It does not construct packed semantic records. No miniature
replacement view is used.

The copied firmware retains the old production path and adds one startup call
to the prototype so linker garbage collection cannot remove it. Consequently
the linked delta is the incremental cost of this counting prerequisite, not
the cost of a complete replacement after deleting old machinery.

## Reproduction

From the root after the production firmware/native-owner builds:

```sh
scripts/nrf52840/doctor.sh
python3 experiments/spike-010-bounded-declaration-traversal/run.py
bash docs/iterations/iteration-002-review/build-research-firmware.sh spike-010-bounded-declaration-traversal
python3 docs/iterations/iteration-002-review/measure-research-elf.py experiments/spike-010-bounded-declaration-traversal/evidence/elf-comparison.json .build/nrf52840/signal-analyzer-static .build/nrf52840/spike-010-bounded-declaration-traversal/firmware
```

The runner recovers the exact production Ninja compiler/options, hashes every
copied source and native owner object, and uses project-local module caches.
Native execution uses the repository's selected native compiler; the separate
object and linked image use paired Swift 6.3.2 with Cortex-M4F hard-float.

## Results

**Positive prerequisite evidence.** Both native and Embedded compilation pass.
All 42 cases produce 41 semantic nodes, 16 body evaluations, 51 modifiers,
17 texts, five Canvases and three actions: 92 render scopes. All 84 depth/node
refusals discard publication and reset workspace activity; 42 subsequent
fresh calls succeed. These counts agree with the measured portable hierarchy.
The latter calls create fresh workspaces; they are not a same-buffer reuse
test or evidence of transactional packed-storage rollback.

| Linked metric | Production | Production plus probe | Delta |
| --- | ---: | ---: | ---: |
| Flash | 275,600 | 309,784 | +34,184 bytes |
| RAM | 191,104 | 191,104 | 0 |

ARMv7E-M/VFP ABI, disabled Zephyr/libc heaps, allocator-symbol checks and the
existing allocation refusal stub pass. The same configured stack reservation
is retained. This makes the narrow counting prerequisite compilable; it does
not establish a complete zero-heap runtime replacement.

[Commands, hashes and traversal output](../../experiments/spike-010-bounded-declaration-traversal/evidence/result.json)
and [paired ELF comparison](../../experiments/spike-010-bounded-declaration-traversal/evidence/elf-comparison.json).

## Limitations

- Sequential counter identities, snapshot carrier and counting sink omit
  stable identity, observable binding/generations, action execution, text
  bytes, Canvas callable capture and packed layout/render/pixel parity.
- Capture coverage uses empty or four transitions and a short diagnostic;
  it does not exercise every retained-record capacity or 96-byte diagnostic.
- No firmware execution, physical cadence or stack high-water occurred.
  `-Xllvm -stack-size-section` on the standalone object emits no `.stack_sizes`
  section with this paired compiler/target; that request is not a stack bound.
  Whole call-chain and interrupt costs cannot be inferred from RAM or counts.
- The +34,184-byte delta is additive and lacks the missing full sink/state
  machinery. It cannot be extrapolated into replacement savings or acceptance.

## Disposition

Complete the bounded prerequisite experiment. SPIKE-009's whole-module
restriction does not rule out explicit snapshot lowering, but full runtime
replacement remains a materially larger design/conformance effort. Retain the
packed production hierarchy for cleanup planning; consider clean offline
generation separately. Feed these results to EXP-001, without changing its
architecture or approving production work.

## References

- [EXP-001](../explorations/exp-001-nrf-hierarchy-derivation.md)
- [SPIKE-009](spike-009-nrf-hierarchy-role-bindings.md)
- [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
- [Disposable sources and runner](../../experiments/spike-010-bounded-declaration-traversal/run.py)
- [Step 18](../iterations/iteration-002-review/18-bounded-declaration-traversal.md)
