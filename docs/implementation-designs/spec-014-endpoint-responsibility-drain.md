---
spec: SPEC-014
feature: giftui-mvp-architecture
title: Implementation Design — Endpoint Responsibility and Drain
status: current
authors:
  - codex
created: 2026-09-13
updated: 2026-09-13
implementation_plan: ../implementation-plans/spec-014-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Endpoint Responsibility and Drain

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot amend SPEC-014.

## Purpose and Boundary

This note records how endpoint admission, a display-owning raster session,
responsibility transfer, validation-only draining, terminal cleanup, and
failure preservation cooperate for T7.1-T7.5. It does not change the
SPEC-009 offer API, SPEC-014 result mappings, display grammar, or failure
authority.

## Governing Contract

- [SPEC-014 offer, reservation, and consumption](../specs/spec-014-backend-integration.md#offer-reservation-and-consumption)
- [SPEC-009 one-shot frame endpoint](../specs/spec-009-execution-cycle-and-frame-handoff.md#one-shot-frame-endpoint)
- [ADR-010 synchronous one-shot handoff](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [T7.1-T7.5](../implementation-plans/spec-014-implementation-plan.md#milestone-7-join-the-one-shot-endpoint-failure-mapping-and-health-boundary)

## Current Organization

`OneShotRasterBackendEndpoint` owns immutable admission facts and sequencing.
Its generic `RasterOfferSessionSink` owns the concrete surface, display target,
active reservation, stream grammar, sticky raster/display errors, and terminal
cleanup. The endpoint never stores a producer body or operation.

The offer API exposes provenance before the body but exposes the header only
through the body's first `sink.begin` call. Admission therefore validates
provenance, immutable configuration, idle state, and exact reservation bounds
before body invocation. The reserved sink validates header work and resources
at `begin` before any surface/display mutation.

## State and Ownership

The endpoint guards one active offer. The session moves through idle, reserved,
streaming, transferred/draining, and terminal states. Before transfer, any
non-complete body result discards raster/writer state and cancels once. After
transfer, every body result is accepted; physical output stops after a local
fault, but grammar and all borrowed views are drained before one frame finish.

The endpoint retains only local errors and backend/display-owned state after
the body. Display health remains target-owned and is projected directly.

## Failure Precedence and Testing

Pre-body tests record validator, reservation, and body counts for every exit.
Post-body tests cover every stream result before and after transfer, exact
cancel/finish counts, producer-error preservation, illegal transfer results,
sticky local errors, health projection, and diagnostic non-interference.

## Code and Evidence Links

T7.1 is implemented by
[`OneShotRasterBackendEndpoint.swift`](../../Sources/GiftUIBackendIntegration/OneShotRasterBackendEndpoint.swift)
and covered by
[`OneShotRasterBackendEndpointTests.swift`](../../Tests/GiftUIBackendIntegrationTests/OneShotRasterBackendEndpointTests.swift)
with evidence in
[`endpoint-admission.md`](../../Tests/ContractFixtures/SPEC014/Evidence/milestone-7/endpoint-admission.md).
Links for T7.2-T7.5 will be added with those tasks.
