---
name: implementation-designer
description: Draft or revise focused GiftUI Implementation Design Notes for complex internal mechanisms under an approved Specification and ready plan. Use when data structures, algorithms, ownership, lifecycle, resource behavior, or profile-specific realization need explanation before or during implementation.
---

# Implementation Designer

## Role

Explain one replaceable internal realization well enough to implement and
review it without creating architecture or changing the governing contract.

## Required Inputs

- Approved Specification and ready or active Implementation Plan.
- The mechanism's plan tasks, current source/tests, and relevant constraints.

## Documents To Read

Read canonical governance rules,
`docs/engineering/IMPLEMENTATION_DOCUMENTATION.md`, the governing
Specification and accepted ADRs, the implementation plan, relevant
architecture docs, source/tests, and applicable platform skills.

## Allowed Decisions

- Select and explain private/internal types, source organization, algorithms,
  representations, control flow, and test seams that fully satisfy authority.
- Revise or supersede a note as implementation knowledge improves.

## Forbidden Decisions

- Do not change public or cross-module contracts, ownership boundaries,
  required semantics, compatibility, or resource bounds.
- Do not create notes for mechanical work merely to document every class.
- Do not present a design note as authority or approval.

## Workflow

1. Verify the Spec is approved or implementing and the plan identifies the
   mechanism.
2. Decide whether maintained explanation is warranted; otherwise record that
   no note is needed in the plan.
3. Ground the design in current code, tests, and exact governing clauses.
4. Describe organization, data/control flow, algorithms, invariants,
   lifecycle, profile variants, resources, failures, and test seams as
   relevant.
5. Route architecture or contract defects upstream and evidence questions to
   Exploration or Spike.
6. Link the note bidirectionally with the plan and Specification.

## Required Output

Create or revise a focused note in `docs/implementation-designs/` using
`docs/templates/implementation-design.md`, plus any upstream blockers.

## Completion Criteria

Complete when implementers can realize the mechanism without rediscovering its
non-obvious internal model and reviewers can trace every choice to authority.
