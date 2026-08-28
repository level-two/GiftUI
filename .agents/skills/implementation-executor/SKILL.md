---
name: implementation-executor
description: Implement an approved GiftUI Specification through its ready plan and current design notes, updating code, tests, task dispositions, and evidence without changing architecture or contract. Use for authorized major implementation work after planning.
---

# Implementation Executor

## Role

Deliver an approved Specification in traceable increments while keeping code,
tests, the active plan, design explanations, and evidence aligned.

## Required Inputs

- Approved or implementing Specification.
- Ready or active Implementation Plan and any required current Design Notes.
- Repository state and applicable platform/toolchain constraints.

## Documents To Read

Read canonical governance and implementation-documentation rules, the complete
authority chain, active plan and relevant design notes, affected source/tests,
MVP scope, and applicable toolchain/build skills.

## Allowed Decisions

- Make local implementation choices within the approved contract.
- Implement plan tasks, add tests, collect evidence, and update task status.
- Update or request focused Design Notes when implementation knowledge changes
  without crossing their authority boundary.

## Forbidden Decisions

- Do not reinterpret or relax a Specification to fit existing code.
- Do not introduce architecture in code, plans, tests, or Design Notes.
- Do not claim platform or connected-hardware evidence from a host build or
  simulator.
- Do not mark a Specification `implemented`.

## Workflow

1. Verify authority, plan readiness, prerequisites, working-tree state, and
   the next dependency-complete task.
2. Mark the Specification `implementing` and plan `active` when authorized
   implementation actually begins, updating required traceability.
3. Implement the smallest coherent task or vertical slice and its specified
   tests/evidence.
4. Update task disposition and any design note materially invalidated by the
   code change.
5. Pause affected work and report upstream architecture or contract defects;
   capture optional discoveries through the deferred track.
6. Continue until the requested boundary is complete, then hand evidence to
   conformance review.

## Required Output

Produce code and tests mapped to plan tasks, current implementation records,
validation results, and an explicit account of remaining tasks and blockers.

## Completion Criteria

Complete when the requested plan boundary is implemented and validated, its
records match the code, and all evidence needed for the boundary is linked.
