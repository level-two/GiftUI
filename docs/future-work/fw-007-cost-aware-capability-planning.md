---
id: FW-007
feature: capability-system
title: Cost-Aware Capability Realization Planning
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-10-16
source:
  - RFC-006
  - ADR-018
  - docs/implementation-designs/spec-015-p08-structured-operations.md
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-007: Cost-Aware Capability Realization Planning

## Observation / Opportunity

A future GiftUI feature may have several conforming realizations with
materially different RAM, CPU, transfer-bandwidth, latency, energy, or flash
costs. A planner could compare declared costs and target budgets when choosing
between hardware acceleration, framebuffer operations, partial redraw, full
redraw, or another conforming implementation.

## Why Deferred

The MVP capability set is small and can use explicit composition policy with
deterministic preference among the few realizations actually present. A
general cost algebra or optimizer would be speculative until an accepted
feature supplies competing measured implementations and a choice that fixed
policy cannot express adequately.

## Potential Value

- Select a conforming implementation that fits target-specific resource and
  responsiveness budgets.
- Make hardware acceleration an explicit optimization rather than a semantic
  prerequisite.
- Explain why one realization was selected when several are available.

## Current Non-goals

- No universal cost units, optimization function, benchmark framework, or
  capability-aware render planner is required by RFC-006.
- Hardware scrolling, alpha compositing, shadows, and other non-MVP rendering
  features are not added to the current milestone.

## Revisit Triggers

- An accepted feature has at least two conforming realizations whose measured
  trade-offs cannot be handled by a simple explicit target policy.
- A hardware-acceleration feature such as scrolling is proposed and must
  choose among hardware, buffered software, partial-redraw, and full-redraw
  paths under real target budgets.
- Repeated target-specific preference rules demonstrate a shared planning
  problem rather than intentional product policy.

## Disposition

Captured. Promotion requires measured evidence and the normal Exploration or
Proposal gate; it does not expand the MVP capability system.

## Configuration memory estimates — P08 follow-up, 2026-10-16

The maintainer asked whether enabled capabilities could produce accountable
memory estimates interactively, after compilation, and after exercising the
application. The [P08 construction evidence](../implementation-designs/spec-015-p08-structured-operations.md)
shows why these should be separate evidence levels: target storage layouts were
measurable, while source ownership and noncopyability did not prevent physical
stack copies. The final stack rejection is only a lower bound, not a peak estimate.

A candidate report could combine immediate capacity/backend/layout formulas,
exact linked static storage and flash, conservatively bounded compiled call paths,
and separately labelled runtime high-water observations. Configuration inputs must
include workload capacities, target/profile/backend and concurrency, not only
capability flags. Shared storage is counted once; simultaneous lifetimes, thread
stack reservations, IRQ policy and allocator overhead must be explicit. Application,
framework, platform and validation-harness costs need separate attribution.

Each number should identify whether it is exact for a pinned artifact, an upper
bound under named assumptions, an estimate, an observed peak, or unresolved.
Unknown indirect calls, recursion, library costs or callbacks must block a claimed
bound instead of becoming zero. A passing stress run is not a worst-case proof.
Compiler/SDK/flags/source changes invalidate the applicable compiled certificate.
Cached measurements may accelerate interactive estimates but cannot silently
certify a changed build. Capability deltas are composition-dependent, not universal
additive prices; final linked accounting remains authoritative for static bytes.

This reporting layer could precede automatic realization selection and complement
[generated configuration](fw-006-generated-target-configuration.md). Revisit when a
maintainer authorizes a bounded resource-tooling exploration or a configuration UI
needs budget feedback. First assess feasibility on one pinned Embedded target and
real application, preserving unknowns and distinguishing reserved from used memory.
No estimator implementation, new experiment, P08 repair allowance, resource waiver,
or automatic planner is authorized by this capture; P08's existing fit blocker stays
current rather than being deferred here.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
