---
name: feature-triage
description: Determine a GiftUI feature's lifecycle state, authoritative artifacts, missing prerequisites, and next required artifact. Use when a request proposes major feature work, asks what may be changed, or needs routing before design or implementation.
---

# Feature Triage

## Role

Act as the lifecycle entry point. Classify and route work without designing the
feature.

## Required Inputs

- A feature ID, request, problem statement, or affected area.
- Any explicit approval or status-transition instruction from a maintainer.

## Documents To Read

1. `docs/engineering/FEATURE_LIFECYCLE.md`
2. `docs/engineering/DOCUMENTATION_RULES.md`
3. `docs/engineering/AI_AGENT_RULES.md`
4. `docs/MVP_SCOPE.md`, `docs/VISION.md`, and `docs/PRINCIPLES.md`
5. `docs/features.yaml`
6. Linked lifecycle artifacts and affected architecture documents as needed.

## Allowed Decisions

- Decide whether work is major or eligible for the lightweight path.
- Determine the evidenced lifecycle stage and missing gates.
- Determine whether MVP inclusion traces to the reference application or a
  required stack validation.
- Recommend the next artifact or review role.

## Forbidden Decisions

- Do not design the feature.
- Do not invent manifest relationships or approval.
- Do not promote document statuses.

## Workflow

1. Locate the feature entry and every linked artifact.
2. Verify document status, relationships, supersession, and authority.
3. Compare the evidence with lifecycle gates.
4. Identify conflicts and unknowns without resolving architecture.
5. Recommend the smallest valid next step and applicable role skill.

## Required Output

Report the feature ID or `unregistered`, current stage, MVP justification or
post-MVP classification, authoritative artifacts, non-authoritative context,
missing prerequisites, conflicts, next artifact/role, and approvals needed.

## Review Checklist

- [ ] Manifest and linked artifacts were inspected.
- [ ] Status was evidenced, not inferred.
- [ ] MVP necessity traces to concrete scope, or post-MVP status is explicit.
- [ ] Major versus lightweight routing is justified.
- [ ] Missing or conflicting information is explicit.
- [ ] No architecture was designed.

## Completion Criteria

Complete when a maintainer or downstream agent can identify exactly what may
happen next and why.
