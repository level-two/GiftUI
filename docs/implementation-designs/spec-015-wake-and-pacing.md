---
spec: SPEC-015
feature: giftui-mvp-architecture
title: Implementation Design — Wake and Pacing State
status: current
authors:
  - codex
created: 2026-09-14
updated: 2026-09-14
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Wake and Pacing State

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains the bounded host state and checked time arithmetic used for
SPEC-015 T5.2. It does not choose pacing values, runtime wake semantics, retry
policy, clocks, schedulers, executors, or platform APIs.

## Governing Contract

The mechanism realizes SPEC-015 `Opportunity and pacing`, HC-011 and HC-018,
and plan task T5.2. [ADR-011](../adrs/adr-011-serialized-run-cycle-and-publication.md)
requires later sealed admission and at-most-once mutation, while
[ADR-012](../adrs/adr-012-bounded-handoff-refusal-recovery.md) requires finite
host pacing without replay.

## Current-Code Context

`GiftUIExecution` already owns wake-reason vocabulary and runtime-local
empty-to-nonempty accumulation. `GiftUIHostConfiguration` owns the exact
`HostPacingPolicy`, host scheduling, lifecycle admission, and the fixed
250,000-microsecond frame and fact-service limits.

## Proposed Internal Organization

One inline `HostWakePacingController` stores the accumulated wake-reason bits,
the first pending fact time, the preceding opportunity start, and whether an
opportunity is executing. It returns a wake directive to its caller instead of
invoking a scheduler or runtime itself. This keeps a wake callback incapable
of synchronously entering the controller.

## Data and Control Flow

The first accepted fact records the service-window start and returns
`requestWake`; later reasons coalesce and return `coalesced`. The host asks for
the next disposition at a monotonic timestamp. It receives `wait(until:)`
before the frame boundary, `run` at the boundary through the deadline, or a
typed invariant failure after the deadline. Beginning an opportunity atomically
takes the reasons and service window; completion records the opportunity start
as the next frame-pacing origin.

## Algorithms and Data Structures

All timestamps are `UInt64` microseconds. Both `last opportunity + minimum
frame interval` and `first fact + maximum service latency` use checked
addition. The permitted start is the frame boundary; it must not exceed the
fact deadline. No queue, timer, closure, task, thread, or dynamically growing
collection is stored.

## Lifecycle and State

The controller begins available and idle. Opportunity begin is legal only
when pending work is ready. Reentrant begin/complete, time regression, missed
deadlines, and arithmetic overflow fail closed. Quiescence is idempotent when
idle, rejects active work, clears pending reasons, and makes later admission
unavailable.

## Runtime Profiles and Platforms

Dynamic and static hosts use the same value and transitions. Concrete targets
supply monotonic timestamps and realize the returned wait/wake directives
through their target-local scheduler or loop.

## Resource and Failure Behavior

The state is fixed-size inline storage and performs no allocation. Timing and
lifecycle violations are local finite enum values; mapping and residual policy
remain owned by the host failure adapter.

## Test and Diagnostic Seams

Focused tests cover just-before, at, and just-after the boundary and deadline,
wake coalescing, facts admitted around a seal, non-reentrant entry, monotonic
time, checked overflow, quiescence, and four-per-second sustained scheduling.
The returned decisions are evidence; diagnostics do not affect them.

## Rejected Implementation Alternatives

- Storing scheduler closures was rejected because the controller can return a
  finite directive without retaining platform behavior.
- A periodic tick without a first-fact deadline was rejected because it cannot
  prove the service-window bound.
- Saturating timestamp arithmetic was rejected because it would conceal an
  invalid pacing input rather than fail closed.

## Open Implementation Questions

None.

## Code and Evidence Links

- `Sources/GiftUIHostConfiguration/HostWakePacingController.swift`
- `Tests/GiftUIHostConfigurationTests/HostWakePacingControllerTests.swift`
- `Tests/ContractFixtures/SPEC015/Evidence/milestone-5/wake-and-pacing.md`
