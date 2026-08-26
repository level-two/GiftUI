---
id: SPIKE-008
feature: canvas-drawing
title: SPEC-012 Exact Canvas Declaration and Callable Evidence
status: completed
authors:
  - codex
created: 2026-08-26
updated: 2026-08-26
source:
  - SPEC-012
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-004
  - SPIKE-007
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPIKE-008: SPEC-012 Exact Canvas Declaration and Callable Evidence

> This Spike provides compile/link and negative compile evidence for draft
> SPEC-012. Its declarations, callable, storage, fixtures, and executable are
> disposable and do not define a replacement contract or authorize
> implementation.

## Parent Gate

Draft SPEC-012 could not advance through review without compiling and
inspecting its exact Canvas callable specialization, noncopyable
`GraphicsContext` and `Path`, nonescaping `withPath` scope, borrowed `stroke`
argument, and throwing cleanup with the supported macOS and Embedded Swift
compilers. SPIKE-004 established bounded plan feasibility, and SPIKE-007
established the static generated-callable storage premise, but neither compiled
the exact scoped throwing form introduced by SPEC-012.

The Signal Analyzer requires Canvas for its grid and four digital traces on
all MVP configurations. This Spike addresses only the missing declaration and
callable evidence; it does not implement drawing or alter the approved Canvas
architecture.

## Target Questions

1. Do SPEC-012's exact public Canvas, `GraphicsContext`, `Path`, shading,
   style, cap, join, and error declaration spellings compile with the supported
   macOS and Embedded Swift compilers?
2. Does a generated finite callable with bounded typed captures compile with
   the exact synchronous throwing `(inout GraphicsContext, Size)` signature?
3. Can supported client source construct a scoped noncopyable Path inside
   `withPath` and submit that borrowed Path through `GraphicsContext.stroke`?
4. Do normal and throwing exits reset scoped Path storage, and can concrete
   `DrawingError` values be thrown in the Embedded Swift image?
5. Do illegal borrowed-Path consumption and Path escape attempts fail
   compilation on both compilers?
6. Does the hardware-free Embedded declaration image retain the required
   ARMv7E-M hard-float ABI, zero configured heaps, and no newly linked forbidden
   runtime dependency?

## Bounds / Stop Conditions

- Reproduce only the exact public declaration shapes and the smallest
  generated tagged Canvas callable needed to exercise them.
- Use macOS Swift 6.3.3 and the repository-pinned Swift 6.3.2, Zephyr 4.3.0,
  Zephyr SDK 0.17.4, board `nrf52840dk/nrf52840`, and Swift target
  `armv7em-none-none-eabi`.
- Limit runtime semantics to one successful path/stroke and one deliberate
  throwing cleanup path on macOS.
- Limit Embedded validation to hardware-free compile, link, diagnostic, ELF,
  ABI, size, heap-configuration, and symbol inspection. Do not flash or operate
  a connected board.
- Stop with a negative result when an exact form is rejected; preserve the
  diagnostic and do not invent a replacement API inside the Spike.
- Keep disposable code under
  `experiments/spike-008-spec-012-exact-canvas-declarations/`.

## Method

The candidate reproduces SPEC-012's public declaration spelling and defines a
generated noncopyable tagged callable with bounded typed captures. The callable
uses the exact throwing `inout GraphicsContext` and `Size` signature. A macOS
runtime fixture counts cleanup on normal and throwing `withPath` exits.

Compile-negative variants enable the intended `withPath` plus `stroke`
composition, consume a borrowed Path, or return a Path from `withPath`. The
runner requires each negative fixture to fail with its expected diagnostic on
both supported compilers.

For Embedded Swift, a declaration-only variant disables concrete thrown error
values so the remaining declarations can link. It is compared with a
configuration-equivalent baseline. A separate exact-throwing build preserves
the compiler's rejection. The final linked declaration image is inspected for
CPU/ABI attributes, configured heaps, linked sizes, and candidate-introduced
forbidden runtime symbols.

## Reproduction

From the repository root:

```text
scripts/nrf52840/doctor.sh
experiments/spike-008-spec-012-exact-canvas-declarations/run.sh
```

The runner writes stable summaries and compiler diagnostics under
[`experiments/spike-008-spec-012-exact-canvas-declarations/evidence/`](../../experiments/spike-008-spec-012-exact-canvas-declarations/evidence/).
Transient firmware and detailed ELF reports remain under
`.build/nrf52840/spike-008-*`.

## Results

Completed on 2026-08-26. The individual declaration shapes and generated
callable's throwing signature compile on macOS and compile/link in Embedded
Swift when concrete thrown values are disabled. The macOS runtime fixture
passes both normal and throwing Path-cleanup paths. Illegal borrowed-Path
consumption and `withPath` Path escape fail compilation on both compilers as
intended.

Two independent exact-contract blockers were reproduced:

1. **The intended Path submission source form fails on both compilers.**
   `withPath` holds a modifying access to `GraphicsContext`; calling
   `context.stroke(path, ...)` within its closure is rejected as an overlapping
   access to `context`. Moving `stroke` after the closure is unavailable because
   the noncopyable Path cannot escape.
2. **Concrete throwing fails in Embedded Swift.** Each
   `throw DrawingError...` expression is rejected because the compiler cannot
   use a value of protocol type `any Error` in Embedded Swift.

The declaration-only Embedded image provides the following bounded comparison:

| Measurement | Baseline | Declaration fixture | Delta |
| --- | ---: | ---: | ---: |
| Linked flash bytes | 25,780 | 25,780 | 0 |
| Linked RAM bytes | 6,016 | 6,016 | 0 |

The image reports ARMv7E-M and `Tag_ABI_VFP_args: VFP registers`. Both
configured heaps are zero, and it introduces no linked reflection,
Objective-C, task, thread, or allocator symbol relative to the baseline. The
zero size delta is declaration-only evidence after whole-module elimination;
it is not a production cost estimate.

## Limitations

- The linked Embedded image disables concrete thrown values and therefore does
  not prove throwing cleanup or runtime error propagation on nRF52840; the
  exact variant fails before link.
- The macOS cleanup result does not establish Embedded Swift support.
- Hardware-free evidence does not prove connected-board execution, stack
  high-water, raster correctness, timing, or display behavior.
- Whole-module optimization removes unused declaration machinery, so the size
  comparison does not measure a future production drawing implementation.
- This Spike does not compare replacement API or error-model candidates. That
  work belongs in Specification review and, if architecture must change, the
  applicable RFC/ADR amendment path.

## Disposition

Completed with negative evidence. Target questions 1, 2, 4, and 6 pass only in
the qualified forms recorded above; question 5 passes; question 3 fails on both
compilers, and exact concrete throwing in question 4 fails on Embedded Swift.

SPIKE-008 closes the evidence-gathering task but does not close SPEC-012's
approval gate. SPEC-012 must remain draft and return to Specification review.
Its supported Path-submission source form and Embedded error model require
correction, followed by a rerun of this Spike's exact negative variants. If a
correction changes accepted ownership or failure architecture, RFC-009 and the
governing ADRs require amendment or supersession before the Specification can
advance.

## References

- [SPEC-012: Canvas, Path, and Stroke Drawing Contract](../specs/spec-012-canvas-path-stroke-drawing.md)
- [SPIKE-004: Canvas Path Plan Feasibility](spike-004-canvas-path-plan-feasibility.md)
- [SPIKE-007: Static Action Storage Feasibility](spike-007-static-action-storage-feasibility.md)
- [ADR-029: Scoped Transient Path Snapshot Semantics](../adrs/adr-029-scoped-transient-path-snapshot-semantics.md)
- [ADR-031: Bounded Canvas Failure and Startup-Gate Integration](../adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
