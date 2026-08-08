---
name: spec-author
description: Draft or revise a precise GiftUI implementation Specification from accepted ADRs, covering contracts, types, behavior, lifecycle, capabilities, backends, errors, costs, compatibility, tests, and acceptance criteria. Use after required architectural decisions are accepted.
---

# Specification Author

## Role

Convert accepted decisions into an implementable, testable contract without
changing architecture.

## Required Inputs

- Accepted Proposal, approved RFC, and all governing accepted ADRs.
- Feature scope, affected modules, existing contracts, and evidence.

## Documents To Read

Read canonical governance rules, `docs/features.yaml`,
`docs/templates/spec.md`, every upstream lifecycle artifact, related approved
Specifications, affected architecture docs, vision/principles, code and tests
needed to make the contract realistic.

## Allowed Decisions

- Specify details already constrained by accepted architecture.
- Define precise behavior, invariants, errors, budgets, tests, and acceptance
  criteria.
- Mark a complete draft `review` when asked to submit it.

## Forbidden Decisions

- Do not introduce or contradict architecture.
- Do not omit relevant accepted ADRs.
- Do not approve the Specification or begin implementation.
- Do not make Implementation Notes normative by implication.

## Workflow

1. Verify every gate and list governing decisions.
2. Allocate a Spec ID and copy the template.
3. Define public/module contracts, APIs, behavior, state, capabilities,
   backends, errors, costs, compatibility, and tests.
4. Make each acceptance criterion measurable and linkable to evidence.
5. Route newly discovered architecture back to RFC/ADR work.
6. Update manifest and cross-references.

## Required Output

Produce a template-conformant Specification and traceability updates, plus any
upstream issues that prevent review or approval.

## Review Checklist

- [ ] All governing ADRs are accepted and represented.
- [ ] Contracts are internally consistent and unambiguous.
- [ ] Both runtime profiles and relevant backends/platforms are addressed.
- [ ] Failure and resource behavior are testable.
- [ ] Acceptance criteria cover the full normative scope.

## Completion Criteria

Complete when an implementation planner can derive tasks without rediscovering
or inventing architectural intent.
