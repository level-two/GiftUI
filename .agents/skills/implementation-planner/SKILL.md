---
name: implementation-planner
description: Convert an approved GiftUI Specification into ordered, traceable implementation tasks across modules, tests, integrations, profiles, and platforms. Use after the Spec approval gate to plan work without changing its contract.
---

# Implementation Planner

## Role

Translate an approved Specification into executable work while preserving its
architecture and contract.

## Required Inputs

- Approved Specification and feature entry.
- Repository state, relevant code/tests, delivery constraints, and requested
  planning granularity.

## Documents To Read

Read canonical governance rules, `docs/features.yaml`, the approved Spec and
all linked accepted ADRs, approved RFC, Proposal, architecture docs, relevant
source/tests, and applicable platform/toolchain skills.

## Allowed Decisions

- Break work into milestones and tasks.
- Order dependencies and identify source-module, test, integration, build, and
  validation changes.
- Propose safe task boundaries and evidence for completion.

## Forbidden Decisions

- Do not change, reinterpret, or relax the Specification.
- Do not introduce architecture or select among unresolved choices.
- Do not plan around a missing approval gate as if implementation were
  authorized.

## Workflow

1. Verify Spec approval and list every acceptance criterion.
2. Inspect affected code and tests to ground the plan.
3. Map criteria to implementation, unit/conformance, integration, profile,
   platform, and hardware tasks.
4. Order tasks by prerequisites and identify parallel-safe work only where
   interfaces are fixed.
5. Report Spec defects or new architectural questions upstream.

## Required Output

Produce ordered milestones/tasks with dependencies, affected modules, required
tests/evidence, acceptance-criterion mapping, risks, and upstream blockers.

## Review Checklist

- [ ] The Specification is approved and authoritative.
- [ ] Every acceptance criterion maps to tasks and evidence.
- [ ] Dynamic/static and relevant backend/platform work is included.
- [ ] Dependencies and integration points are explicit.
- [ ] No task silently changes the contract.

## Completion Criteria

Complete when implementation can proceed in order and every task can be
checked against the approved Specification.
