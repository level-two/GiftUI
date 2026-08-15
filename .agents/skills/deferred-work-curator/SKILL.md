---
name: deferred-work-curator
description: Capture, classify, cross-link, revisit, close, or promote GiftUI Future Work, Explorations, and Spikes. Use when an idea, optimization, unanswered question, experiment, or intentionally postponed decision appears during Proposal, RFC, ADR, Specification, planning, implementation, or review work and must be preserved without expanding current scope.
---

# Deferred Work Curator

## Role

Preserve useful uncertainty cheaply without turning it into current scope,
architecture, roadmap commitment, or implementation authority.

## Documents To Read

Read `docs/engineering/FEATURE_LIFECYCLE.md`,
`docs/engineering/DOCUMENTATION_RULES.md`, `docs/engineering/AI_AGENT_RULES.md`,
the source artifact or implementation context, and the matching template under
`docs/templates/`. Read `docs/features.yaml` only to reuse an existing feature
key; capture does not require registering one.

## Classification

- Use Future Work for one cheap idea, opportunity, question, or postponed
  decision that primarily needs preservation and a revisit trigger.
- Use Exploration when questions, hypotheses, competing directions, or an
  evidence plan need structured investigation without a required decision.
- Use Spike when a bounded prototype, benchmark, or implementation experiment
  is the efficient way to answer named questions. Prefer a parent Exploration;
  an RFC may be the parent when the evidence is needed for active design.
- Keep the item in the current artifact as a blocker when current correctness,
  coherence, or approval depends on its answer.

## Capture Workflow

1. Verify that deferral does not make the source artifact incomplete or
   misleading.
2. Allocate the next unused ID for the selected type and copy its template.
3. Preserve the source, observation, why deferred, explicit non-goals, and at
   least one concrete revisit trigger.
4. Cross-link the new ID from the source metadata and `Deferred and Follow-up
   Work` section. Keep relationships bidirectional.
5. Do not change current requirements, milestone, roadmap, decisions,
   acceptance criteria, or implementation tasks.

## Exploration And Spike Workflow

Define target questions before investigating. For a Spike, record bounds and
stop conditions, method, reproduction details, results, and limitations.
Treat code under `experiments/spike-NNN-short-slug/` as disposable. Never copy
it into production or operate connected hardware/external systems without the
normal authorization for those actions.

## Revisit And Promotion

Re-evaluate only when a recorded trigger occurs, a planned milestone depends
on the item, or material new evidence appears. Record one disposition:
continue, pause, close, abandon, supersede, or promote.

- Promote Future Work to an Exploration when evidence is needed.
- Promote to a Proposal when GiftUI is ready to evaluate investment.
- Feed an Exploration into an RFC only when an accepted Proposal already
  covers the problem.
- Feed a Spike into its parent only as evidence.

Preserve the original artifact, update its status/disposition and
`promoted_to`, and create reciprocal links. Promotion never bypasses human
approval gates and never goes directly to an ADR, Specification, or production
implementation.

## Required Output

Produce the smallest valid artifact and source cross-reference, or explain why
the item is a current blocker and cannot be deferred. Report current scope as
unchanged and name the revisit trigger or promotion gate.

## Review Checklist

- [ ] The selected artifact is the least ceremonial adequate form.
- [ ] Deferral does not hide a current-scope requirement or decision.
- [ ] Source and deferred artifact link both ways.
- [ ] Revisit triggers are concrete; “later” is absent.
- [ ] Candidate language remains non-authoritative.
- [ ] Spike code and results are not treated as production authority.

## Completion Criteria

Complete when a future maintainer can recover why the item matters, why it was
deferred, what would reopen it, and which gate applies next without using chat
history.
