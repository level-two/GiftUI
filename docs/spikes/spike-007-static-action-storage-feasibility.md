---
id: SPIKE-007
feature: giftui-mvp-architecture
title: Static Action Storage Feasibility
status: completed
authors:
  - codex
created: 2026-08-26
updated: 2026-08-27
source:
  - SPEC-011
  - SPEC-012
  - RFC-011
  - ADR-033
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPIKE-007: Static Action Storage Feasibility

> This Spike produced compile, link, runtime-shape, and dependency evidence
> used by RFC-011 and proposed ADR-033, and supplies reusable retained-closure
> evidence to SPEC-012. Its declarations, callable encodings, capacities,
> fixtures, and code are disposable and do not establish production contracts
> or authorize implementation.

## Parent Gate

RFC-011 used this Spike's negative retained-closure evidence and positive
finite tagged-action evidence to select bounded typed application actions for
the portable path. Proposed ADR-033 extracts that architecture. SPEC-011 still
cannot advance until ADR-033 is accepted and the callable-based draft contract
is revised to exact bounded-action declarations and storage rules.

This Spike's primary gate is SPEC-011. SPEC-012 may reuse its result only for
the common question of directly retaining a captured escaping closure versus a
generated bounded callable. It does not prove SPEC-012's exact throwing,
scoped-`inout` Canvas callable or noncopyable Path declarations. It does not
select a production representation, set production capacities, change
action-generation or identity semantics, approve either Specification, or
authorize implementation.

## Target Questions

1. Do SPEC-011's exact public `Button`, title-initializer, `disabled`, and
   package action-record declaration shapes compile in the repository's
   supported Embedded Swift configuration?
2. Can a noncopyable bounded record store and synchronously invoke an escaping
   Swift closure on nRF52840 without a linked allocator, reflection, exception,
   task, thread, Objective-C, or unavailable runtime dependency?
3. Can a generated finite tagged callable union represent heterogeneous
   Signal Analyzer actions, store only bounded typed payloads, replace a record
   by generation, and dispatch exactly once without those dependencies?
4. What linked flash, linked RAM, fixed storage, and conservative fixture-stack
   costs does each viable candidate add relative to a matched baseline?
5. Which SPEC-011 implementation suggestions are supported, rejected, or need
   narrower wording based on the evidence?

## Bounds / Stop Conditions

- Exercise four logical Signal Analyzer controls and a fixed table capacity of
  32 actions, matching SPEC-011's independent fixture.
- Compare a direct noncopyable stored-closure candidate with one generated
  finite tagged callable-union candidate and a configuration-equivalent
  baseline. Do not design a general callback, gesture, or type-erasure system.
- Verify replacement by generation, disabled rejection, stale-generation
  rejection, exact-once dispatch, and deterministic table exhaustion using a
  host semantic fixture or an equivalent deterministic entry-point transcript.
- Use hardware-free compile/link evidence for `nrf52840dk/nrf52840`; do not
  flash or operate connected hardware.
- Keep disposable code under
  `experiments/spike-007-static-action-storage-feasibility/` and generated
  firmware under `.build/nrf52840/`.
- Stop each candidate at the first reproducible compiler, linker, allocation,
  runtime-dependency, bounded-storage, or semantic failure. A failed candidate
  remains useful negative evidence.
- Stop and report `inconclusive` if the pinned repository-managed toolchain
  cannot build the matched images. Do not install a global toolchain, install
  an SDK under `/opt`, or change Xcode/global Swift selection.

## Method

Create one disposable fixture with the declaration spelling needed by
SPEC-011 and two static storage candidates:

1. **Direct stored closure:** place `@escaping () -> Void` in a noncopyable
   action record held by a fixed-capacity table and invoke it synchronously.
2. **Generated tagged union:** generate a finite enum-like tag and bounded
   payload record for the four fixture actions, then dispatch through a total
   switch without retaining a closure.

Build a matched baseline and both candidates with the pinned Embedded Swift,
Zephyr, and Cortex-M4F hard-float configuration. Inspect the linked ELFs for
allocation and forbidden runtime symbols, CPU/ABI attributes, flash/RAM, and
fixed storage. Run deterministic host semantics for generation replacement,
disabled and stale rejection, exact-once dispatch, and exhaustion. Record a
pass, fail, or inconclusive result for each target question.

## Reproduction

The experiment provides one repository-root entry point:

```text
experiments/spike-007-static-action-storage-feasibility/run.sh
```

It prints the source revision and toolchain configuration, runs semantic
fixtures, builds all matched hardware-free images, inspects the linked ELFs,
and emits stable evidence under the experiment directory.

## Results

Completed on 2026-08-26 with the repository-managed Swift 6.3.2 compiler,
Zephyr 4.3.0, Zephyr SDK 0.17.4, board `nrf52840dk/nrf52840`, Swift target
`armv7em-none-none-eabi`, Cortex-M4F hard-float flags, and `-Osize`.

The exact public `Button`, title-initializer, `disabled`, and escaping-action
declaration shapes compile in Embedded Swift. A noncopyable action record also
compiles. The decisive result depends on whether the callable persists across
an install/return/dispatch boundary:

| Candidate | Flash | Delta | Linked RAM | Fixed data + BSS delta | Allocator path | Result |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Matched baseline | 25,780 B | 0 B | 6,016 B | 0 B | none | control |
| Persistent stored closure | 26,220 B | +440 B | 6,016 B | +36 B | `swift_allocObject` → `posix_memalign` | fail |
| Generated tagged callable | 26,064 B | +284 B | 6,012 B | +36 B | none | pass |

The direct candidate's captured closure compiles and links, but installing it
into committed storage retains `swift_allocObject`, `posix_memalign`, `free`,
and `swift_release`. With both Zephyr and libc heaps configured to zero, the
fixture's allocation stub returns failure and the generated allocation wrapper
traps. Making only the enclosing record noncopyable therefore does not satisfy
SPEC-011's static zero-heap requirement.

The generated candidate uses the exact constraint
`Callable: ~Copyable & InteractionCallable`, a finite four-case tag, bounded
typed payloads, and one noncopyable persistent record. It compiles and links
without an allocator or candidate-introduced reflection, Objective-C, task,
thread, exception, or throw dependency. The generic parameter must explicitly
include `~Copyable`; omitting it makes Swift require the callable to conform to
`Copyable`.

The shared 32-record semantic fixture passes exact-capacity admission,
deterministic overflow, generation replacement, stale-generation rejection,
disabled rejection, and exact-once dispatch. Conservative complete fixture
stack bounds are 8 bytes for the baseline, 80 bytes for the direct candidate,
and 56 bytes for the tagged candidate. All three ELFs report ARMv7E-M and VFP-
register argument passing. Stable evidence is under
[`experiments/spike-007-static-action-storage-feasibility/evidence/`](../../experiments/spike-007-static-action-storage-feasibility/evidence/).

## Limitations

- Hardware-free compile/link evidence cannot prove connected-device timing,
  stack high-water, input-driver behavior, or display interaction.
- The semantic table fixture runs on the host; the Embedded Swift images prove
  persistent representation, dispatch shape, linking, ABI, and dependency
  closure but are not executed on connected hardware.
- The generated candidate covers four representative actions and one retained
  record. It proves the representation mechanism, not the production generator
  or SPEC-011's complete 32-record table implementation.
- Disposable tag values, payloads, fixture functions, and measured capacities
  are not production contracts.

## Disposition

Completed. Target Question 1 passes: the public declarations and noncopyable
record shape compile. Target Question 2 fails for a captured closure that
persists for the committed-record lifetime because it retains an allocator
path. Target Questions 3 and 4 pass for a generated finite tagged callable:
the exact noncopyable generic constraint compiles, persistent dispatch is
bounded and zero-heap, and resource evidence is recorded.

For Target Question 5, the evidence establishes that making an
escaping-closure record noncopyable does not remove allocation. The finite
tagged candidate demonstrates that a bounded typed representation and direct
dispatch are feasible without an allocator, but it does not establish a
production generator or require a callable abstraction. RFC-011 used those
results to approve bounded typed application actions, and proposed ADR-033
extracts that decision. SPEC-011 remains `draft` pending ADR acceptance and a
contract rewrite; this Spike does not approve declarations or authorize
implementation.

SPEC-012 reuses the negative direct-retention result and the positive generated
callable mechanism, so its static profile cannot persist the source Canvas
closure directly. Its exact throwing, scoped-`inout` callable specialization
and noncopyable `GraphicsContext`/`Path` declarations remain a separate
compiler-evidence gate; this Spike does not resolve them.

## References

- [SPEC-011: Button Interaction and Activation Contract](../specs/spec-011-interaction.md)
- [SPEC-012: Canvas, Path, and Stroke Drawing Contract](../specs/spec-012-canvas-path-stroke-drawing.md)
- [RFC-011: Bounded Application Actions and Model-Target Dispatch](../rfcs/rfc-011-bounded-application-actions.md)
- [ADR-033: Bounded Application Actions and Model-Target Dispatch](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-011: Serialized Run Cycle and Semantic Publication](../adrs/adr-011-serialized-run-cycle-and-publication.md)
- [ADR-013: Provenance-Validated Input Admission](../adrs/adr-013-provenance-validated-input-admission.md)
- [GiftUI nRF52840 toolchain skill](../../skills/giftui-nrf-toolchain/SKILL.md)
