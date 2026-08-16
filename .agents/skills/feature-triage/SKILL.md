---
name: feature-triage
description: Determine a GiftUI feature's lifecycle state, authoritative artifacts, deferred items, missing prerequisites, and next required artifact. Use when a request proposes major or future work, asks what may be changed, or needs routing before design, exploration, or implementation.
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
6. Linked lifecycle and deferred-track artifacts and affected architecture
   documents as needed.

## Allowed Decisions

- Decide whether work is major or eligible for the lightweight path.
- Apply the canonical RFC scope and decomposition criteria to recommend an
  existing RFC amendment, a separate RFC, or a downstream artifact.
- Determine the evidenced lifecycle stage and missing gates.
- Determine whether MVP inclusion traces to the reference application or a
  required stack validation.
- Recommend the next artifact or review role.
- Route a non-blocking idea to Future Work, Exploration, or Spike without
  treating it as a feature-stage advancement.

## Forbidden Decisions

- Do not design the feature.
- Do not invent manifest relationships or approval.
- Do not promote document statuses.

## Workflow

1. Locate the feature entry and every linked artifact.
2. Verify document status, relationships, supersession, and authority.
3. Compare the evidence with lifecycle gates.
4. Apply the RFC scope and decomposition criteria without treating layers,
   packages, modules, protocols, or document length as automatic RFC boundaries.
5. Identify conflicts and unknowns without resolving architecture.
6. For post-MVP or non-blocking ideas, distinguish cheap capture from work that
   needs structured Exploration or a targeted Spike.
7. Recommend the smallest valid next step and applicable role skill.

## Required Output

Report the feature ID or `unregistered`, current stage, MVP justification or
post-MVP classification, authoritative artifacts, non-authoritative context,
linked deferred items and triggers, missing prerequisites, conflicts, next
artifact/role, and approvals needed.

## Review Checklist

- [ ] Manifest and linked artifacts were inspected.
- [ ] Status was evidenced, not inferred.
- [ ] MVP necessity traces to concrete scope, or post-MVP status is explicit.
- [ ] Major versus lightweight routing is justified.
- [ ] RFC amendment versus separate-RFC routing uses a coherent, independently
  reviewable decision boundary.
- [ ] Missing or conflicting information is explicit.
- [ ] No architecture was designed.

## Completion Criteria

Complete when a maintainer or downstream agent can identify exactly what may
happen next and why.
