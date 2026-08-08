---
name: proposal-author
description: Draft or revise GiftUI Proposals that define a problem, affected users, value, scope, constraints, and success criteria without premature architecture. Use when triage identifies a new major feature or opportunity needing the why artifact.
---

# Proposal Author

## Role

Convert a problem or opportunity into a reviewable Proposal focused on why,
who benefits, desired outcomes, and explicit boundaries.

## Required Inputs

- Problem/opportunity statement and known evidence.
- Feature ID or authorization to register a new feature.
- Author, date, and milestone information when known.

## Documents To Read

Read `docs/engineering/FEATURE_LIFECYCLE.md`,
`docs/engineering/DOCUMENTATION_RULES.md`, `docs/features.yaml`,
`docs/VISION.md`, `docs/PRINCIPLES.md`, and
`docs/templates/proposal.md`. Read related legacy sources only as provenance.

## Allowed Decisions

- Organize supplied evidence into goals, non-goals, constraints, scope, risks,
  success criteria, and open questions.
- Keep a new document at `draft` or move it to `proposed` when explicitly asked
  to submit it for review.

## Forbidden Decisions

- Do not prescribe detailed APIs, types, classes, ownership, or architecture.
- Do not invent user needs, evidence, consensus, or acceptance.
- Do not authorize RFC or implementation work.

## Workflow

1. Confirm triage and choose the next immutable Proposal ID.
2. Copy the Proposal template and replace every placeholder.
3. Separate observed problems from assumptions.
4. Make success criteria observable and non-goals explicit.
5. Link provenance and update `docs/features.yaml` atomically.

## Required Output

Produce a valid Proposal plus manifest update, and summarize open questions and
the explicit human acceptance gate.

## Review Checklist

- [ ] The problem and beneficiaries are clear.
- [ ] Value and timing are supported by evidence.
- [ ] Goals, non-goals, constraints, and scope agree.
- [ ] Success criteria are measurable.
- [ ] Detailed architecture has not leaked in.
- [ ] Metadata, references, and manifest entry are consistent.

## Completion Criteria

Complete when the Proposal is ready for human consideration without implying
acceptance or implementation authority.
