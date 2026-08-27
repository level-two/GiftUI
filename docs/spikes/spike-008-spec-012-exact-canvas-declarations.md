---
id: SPIKE-008
feature: canvas-drawing
title: SPEC-012 Exact Canvas Declaration and Callable Evidence
status: completed
authors:
  - codex
created: 2026-08-26
updated: 2026-08-27
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
inspecting its corrected exact Canvas callable specialization, noncopyable
`GraphicsContext` and `Path`, nonescaping `withPath` scope, borrowed `stroke`
argument, typed-throws error model, and throwing cleanup with the supported
macOS and Embedded Swift compilers. The first SPIKE-008 run found an outer-
context exclusivity conflict and Embedded `any Error` dependency. SPEC-012 was
then corrected to pass the active context into `withPath` and use
`throws(DrawingError)` throughout. This rerun checks those corrections.

The Signal Analyzer requires Canvas for its grid and four digital traces on
all MVP configurations. This Spike addresses only the missing declaration and
callable evidence; it does not implement drawing or alter the approved Canvas
architecture.

## Target Questions

1. Do corrected SPEC-012 public Canvas, `GraphicsContext`, `Path`, shading,
   style, cap, join, and error declaration spellings compile with the supported
   macOS and Embedded Swift compilers?
2. Does a generated finite callable with bounded typed captures compile with
   the exact synchronous typed-throws `(inout GraphicsContext, Size)`
   signature?
3. Can supported client source construct a scoped noncopyable Path inside
   `withPath` and submit that borrowed Path through `GraphicsContext.stroke`?
4. Do normal and throwing exits reset scoped Path storage, and can concrete
   typed `DrawingError` values compile and link in the Embedded Swift image?
5. Do illegal outer-context access, borrowed-Path consumption, and Path escape
   attempts fail compilation on both compilers?
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
- Stop with a negative result when a corrected exact form is rejected;
  preserve the diagnostic and return the issue to Specification review.
- Keep disposable code under
  `experiments/spike-008-spec-012-exact-canvas-declarations/`.

## Method

The candidate reproduces SPEC-012's corrected public declaration spelling and
defines a generated noncopyable tagged callable with bounded typed captures.
The callable uses the exact typed-throws `inout GraphicsContext` and `Size`
signature. Its `withPath` body receives the active context and scoped Path as
two `inout` parameters, submits a stroke, mutates the same Path, and submits a
second stroke. A macOS runtime fixture counts cleanup on normal and throwing
`withPath` exits.

Compile-negative variants access the captured outer context while `withPath`
is active, consume a borrowed Path, or return a Path from `withPath`. The runner
requires each negative fixture to fail with its expected diagnostic on both
supported compilers.

For Embedded Swift, the complete corrected callable—including concrete typed
throws and cleanup—links into the candidate image and is compared with a
configuration-equivalent baseline. The image is inspected for CPU/ABI
attributes, configured heaps, linked sizes, and candidate-introduced forbidden
runtime symbols.

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

Rerun completed on 2026-08-27. The corrected declaration shapes and generated
callable compile on macOS and compile/link in Embedded Swift. The callable uses
concrete `throws(DrawingError)`, passes the active context and scoped Path as
two `inout` body parameters, and performs stroke-mutate-stroke reuse without
overlapping access. The macOS runtime fixture passes normal and throwing Path-
cleanup paths.

Illegal captured-outer-context access, borrowed-Path consumption, and
`withPath` Path escape fail compilation on both compilers as intended. Thus the
two blockers recorded by the first run are resolved by the corrected contract,
while the ownership misuse checks remain enforced.

The executable Embedded image provides the following bounded comparison:

| Measurement | Baseline | Declaration fixture | Delta |
| --- | ---: | ---: | ---: |
| Linked flash bytes | 25,780 | 26,180 | 400 |
| Linked RAM bytes | 6,016 | 6,016 | 0 |

The image reports ARMv7E-M and `Tag_ABI_VFP_args: VFP registers`. Both
configured heaps are zero, and it introduces no linked `any Error`, reflection,
Objective-C, task, thread, exception-runtime, or allocator symbol relative to
the baseline. The 400-byte flash delta is bounded executable fixture evidence;
it is not a production cost estimate.

## Limitations

- The linked Embedded image proves compile/link support for typed throws and
  cleanup lowering, but hardware-free validation does not execute either path
  on nRF52840.
- The macOS cleanup result does not establish connected-board behavior.
- Hardware-free evidence does not prove connected-board execution, stack
  high-water, raster correctness, timing, or display behavior.
- Whole-module optimization and the narrow synthetic workload mean the size
  comparison does not measure a future production drawing implementation.
- This Spike checks declaration and ownership mechanics only; it does not prove
  rendering semantics or any other SPEC-012 acceptance criterion.

## Disposition

Completed with positive corrected-contract evidence. All six target questions
pass within the stated hardware-free bounds. The corrected source composition
and concrete typed throws compile/link on both supported compilers; macOS
executes normal and throwing cleanup; the three prohibited ownership forms are
rejected; and the Embedded image passes its ABI, heap, size, and symbol checks.

SPIKE-008 closes the declaration evidence gap recorded by SPEC-012 for DR-001
and the compile/link and symbol-inspection portion of DR-011. It does not approve
SPEC-012, authorize production implementation, establish connected-board
behavior, or satisfy the remaining acceptance criteria. The disposable fixture
must not be copied into production without normal implementation review.

## References

- [SPEC-012: Canvas, Path, and Stroke Drawing Contract](../specs/spec-012-canvas-path-stroke-drawing.md)
- [SPIKE-004: Canvas Path Plan Feasibility](spike-004-canvas-path-plan-feasibility.md)
- [SPIKE-007: Static Action Storage Feasibility](spike-007-static-action-storage-feasibility.md)
- [ADR-029: Scoped Transient Path Snapshot Semantics](../adrs/adr-029-scoped-transient-path-snapshot-semantics.md)
- [ADR-031: Bounded Canvas Failure and Startup-Gate Integration](../adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
