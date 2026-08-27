---
id: SPIKE-006
feature: observable-reference-state
title: SPEC-010 Embedded Declaration Compile and Link Evidence
status: completed
authors:
  - codex
created: 2026-08-26
updated: 2026-08-27
source:
  - SPEC-010
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-003
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPIKE-006: SPEC-010 Embedded Declaration Compile and Link Evidence

> This Spike provides compile/link evidence for the 2026-08-26 SPEC-010
> declaration revision. Its fixture model,
> sink route, storage, executable entry point, and measured code shape are
> disposable and do not define production implementation or capacities.

## Parent Gate

The 2026-08-26 draft SPEC-010 could not close review while its exact `State`,
`_GiftUIObservableChangeSink`, `_GiftUIObservableReference`, and
`_GiftUIObservationAttachment` declarations lacked checked-in Embedded Swift
compile/link evidence. Completed SPIKE-003 established the representation
family's feasibility but did not compile the exact declarations later written
in SPEC-010.

The Signal Analyzer requires one substantially shared observable-state source
across dynamic macOS, Raspberry Pi/Linux, and static nRF52840 configurations.
This Spike addresses only the nRF52840 hardware-free declaration gate.

## Target Questions

1. Do SPEC-010's exact public declaration spellings compile and link with the
   pinned Embedded Swift compiler for `nrf52840dk/nrf52840`?
2. Can one bounded typed model instantiate the constrained property wrapper,
   conform to the consuming-sink protocol, report through the noncopyable
   sink, and detach the returned attachment in the same linked image?
3. Does that declaration fixture preserve the required Cortex-M4F hard-float
   ABI while retaining no allocator entry point or newly introducing linked
   reflection, Objective-C, task, thread, or allocator symbols?
4. What linked flash and RAM delta does this narrow fixture add over a
   configuration-equivalent Embedded Swift baseline?

## Bounds / Stop Conditions

- Compile exactly one bounded value-model conformance and one
  `@State var model: ObservableModel` declaration; do not implement a runtime
  profile, state reconciler, mutation owner, or presentation-fact adapter.
- Use Swift 6.3.2, Zephyr 4.3.0, Zephyr SDK 0.17.4, board
  `nrf52840dk/nrf52840`, and Swift target `armv7em-none-none-eabi`.
- Keep both configured heaps at zero and compare against one baseline with the
  same Zephyr and compiler configuration.
- Limit validation to hardware-free compile, link, ELF, ABI, size, and symbol
  inspection. Do not flash or operate a connected board.
- Stop with a negative result if compilation, linking, ARMv7E-M, VFP argument,
  zero-heap, allocator, or forbidden introduced-symbol checks fail.

## Method

The candidate reproduces SPEC-010's public declaration spellings with the
minimal bodies needed to compile an executable fixture. A bounded
`ObservableModel` value conforms to the observable protocol. The fixture
constructs the constrained property wrapper, consumes a noncopyable change
sink, invokes its synchronous report route, receives an attachment, and
detaches that attachment.

A configuration-equivalent baseline links the same C entry point and Zephyr
configuration without the SPEC-010 declarations. The runner performs pristine
builds, checks heap configuration and ELF attributes, rejects retained
allocator entry points, compares linked symbol sets, and records linked
LOAD-segment flash and RAM totals.

## Reproduction

From the repository root:

```text
scripts/nrf52840/doctor.sh
experiments/spike-006-spec-010-embedded-declarations/run.sh
```

The disposable fixture and runner are under
[`experiments/spike-006-spec-010-embedded-declarations/`](../../experiments/spike-006-spec-010-embedded-declarations/).
Transient firmware and detailed reports remain under
`.build/nrf52840/spike-006-{baseline,candidate}/`.

## Results

All target questions passed with this pinned environment:

| Measurement | Baseline | SPEC-010 declaration fixture | Delta |
| --- | ---: | ---: | ---: |
| Linked flash bytes | 25,780 | 25,796 | +16 |
| Linked RAM bytes | 6,016 | 6,016 | 0 |

The exact declaration spellings compiled and linked in Embedded Swift. The
candidate instantiated the property wrapper and exercised the consuming
noncopyable sink, attachment result, and detach requirement in one image.

The final ELF reports ARMv7E-M and `Tag_ABI_VFP_args: VFP registers`. Both
configured heaps are zero. No allocator entry point remains linked, and the
candidate introduced no reflection, Objective-C, task, thread, or allocator
symbol relative to the baseline. Stable hashes, measurements, ABI attributes,
and the introduced-symbol result are recorded in the experiment's
[`evidence/summary.md`](../../experiments/spike-006-spec-010-embedded-declarations/evidence/summary.md).

## Limitations

- Compile/link evidence does not prove connected-board execution, runtime
  semantics, interrupt safety, actual stack high-water, or production Signal
  Analyzer capacity.
- Whole-module size optimization can specialize or remove declaration
  machinery after type checking. The +16-byte result measures this exercised
  fixture, not the future production module's metadata or generic code cost.
- The fixture's model, route token, attachment value, and property-wrapper
  storage are disposable. They do not select a runtime representation or
  authorize copying this code into production.
- SPIKE-003, host conformance fixtures, Raspberry Pi evidence, and the future
  SPEC-010 contract runner remain responsible for the broader acceptance
  criteria; this Spike answers only the exact Embedded declaration question.

## Disposition

Completed for the 2026-08-26 declarations. The 2026-08-27 SPEC-010 review
replaced the `Void` report result and forgeable raw attachment and added
`@ObservableStateHost` generation plus the state-host traversal witnesses.
Those revised exact declarations require their own OS-001 compile evidence;
this completed Spike remains valid family-level feasibility evidence but no
longer closes that current review gate. The Spike neither approves the
Specification nor authorizes implementation.

## References

- [SPEC-010: Observable Reference State Contract](../specs/spec-010-observable-reference-state.md)
- [SPIKE-003: Portable Observable Reference State Feasibility](spike-003-portable-observable-reference-state-feasibility.md)
- [ADR-024: Structurally Owned Observable Reference State](../adrs/adr-024-structurally-owned-observable-reference-state.md)
- [ADR-025: Coarse Model-Owned Observable Invalidation](../adrs/adr-025-coarse-model-owned-observable-invalidation.md)
- [ADR-026: Profile-Equivalent Bounded Observable State Realization](../adrs/adr-026-profile-equivalent-bounded-observable-state.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
