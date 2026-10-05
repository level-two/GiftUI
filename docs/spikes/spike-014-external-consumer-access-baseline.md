---
id: SPIKE-014
feature: giftui-mvp-architecture
title: External Consumer Access Baseline
status: completed
authors:
  - codex
created: 2026-10-05
updated: 2026-10-05
source:
  - EXP-002
related_future_work:
  - FW-016
  - FW-030
related_explorations:
  - EXP-002
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# SPIKE-014: External Consumer Access Baseline

Bounded, hardware-free preparation for [ITERATION-003 revision 2](../iterations/iteration-003-dev-ux-improvement.md)
under [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md).
Results are evidence, not production APIs or a complete counter application.

## Target Questions

1. Can an independently named consumer compile a small portable counter/status
   declaration against current native and Embedded `GiftUI` modules?
2. Can that consumer name the existing display-extension and host-assembly
   contracts without joining GiftUI's package identity?
3. Which needed consumption products are absent from the current manifest?

## Bounds / Stop Conditions

- Use current source and already built native/Embedded modules; record their
  hashes and compiler versions. No rebuild of production owners or API edits.
- At most one positive portable-declaration probe and separate negative display
  and host access probes per compiler. Stop at the first meaningful barrier;
  do not bypass it with a shared package name or blanket public annotations.
- A positive result requires the compiler to emit an object. Expected negatives
  must contain the relevant access/type diagnostic; toolchain/environment errors
  are inconclusive, not evidence of an API restriction.
- Use the supported nRF compiler/target and Cortex-M4F hard-float options.
  Outputs remain under `.build/`; no linked firmware, allocation/performance
  claim, connected action, package restructuring or general lowering prototype.
- No consumer resource budget is selected: declaration/object probes cannot
  establish assembled flash/RAM/stack. Full-consumer budgets remain a contract
  prerequisite.

## Method

Create disposable sources and a reproduction driver under
`experiments/spike-014-external-consumer-access/`. Compile using a distinct
consumer module/package name against current module search paths. Enumerate
products from the current package manifest separately. Direct compiler access
to an existing module is explicitly weaker than a supported package product.

## Reproduction

From the repository root, run
`python3 experiments/spike-014-external-consumer-access/run.py`. Existing native
modules and nRF firmware owner modules are prerequisites; run the nRF doctor
first. Outputs are under `.build/iteration-003/spike-014/` for native evidence
and `.build/nrf52840/spike-014/` for Embedded objects/logs. The
[captured results](../explorations/exp-002/preparation-2026-10-05/evidence/spike-014-results.json)
retain exact commands, compiler versions, module/source hashes and object/log
identities; native Swift is 6.3.3 and Embedded Swift is 6.3.2.

## Results

Six bounded probes completed. The portable counter/status declaration emits an
object under both native and actual Embedded compilers. DisplayTarget and
HostPresetBootstrap are inaccessible to the independently named consumer under
both compilers; all four negative probes contain the intended access diagnostic.
The manifest inspection identifies eight needed modules without a direct
library product. There was no production-source change or connected action.

The first driver attempt used a relative SwiftPM cache path and stopped before
compiler probes with an invalid-path error. The driver was corrected to absolute
paths, and the successful rerun supplies the retained results; the first error
is not classified as a framework/access failure.

## Limitations

- Does not construct or execute a runtime, observable model, Canvas callable,
  display adapter, host lifecycle or input pipeline.
- Does not prove external package resolution, Pi consumption, target firmware
  linking, exact pixels, allocations, resource ceilings or connected behavior.
- Existing module provenance must remain explicit; no fresh full owner-gate pass
  follows merely from importing a built module.

## Disposition

Completed: the named declaration/access/product questions were answered within
the bounds. Feed evidence to parent EXP-002 and
[PROPOSAL-007](../proposals/proposal-007-external-application-integration.md),
subsequently [accepted by Eugene](../iterations/iteration-003-review/proposal-007-acceptance.md)
on 2026-10-05. Acceptance clears the RFC-design prerequisite, not the evidence
limits of this completed Spike.
The complete observable-state/Canvas/host consumer and its setup/resource control
remain unproven. No Spike code is promoted to production or establishes an API.

## References

- [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md)
- [FW-030](../future-work/fw-030-application-integration-experience.md)
- [Backend inventory](../explorations/exp-002/backend-foundation-inventory-2026-10-05.md)
