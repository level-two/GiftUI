# Numbered Iteration Scopes

An iteration records a bounded delivery commitment: its goal, included work,
exclusions, success criteria, and required evidence. It groups work governed
by the existing [feature lifecycle](FEATURE_LIFECYCLE.md); it does not approve
architecture, amend Specifications, or authorize major implementation.

## Identity and registration

- Use consecutive, immutable IDs: `ITERATION-001`, `ITERATION-002`, and so on.
  Allocate the next number after the highest registered ID. Never reuse or
  renumber an ID, including an abandoned iteration.
- Store each scope at `docs/iterations/iteration-NNN-short-slug.md`, starting
  from the [iteration scope template](../templates/iteration-scope.md).
- Register the ID and repository-relative scope path in the top-level
  `iterations` mapping of `docs/features.yaml`. List participating feature
  keys in the scope's `features` metadata; this is independent of feature
  lifecycle status and Proposal, RFC, ADR, and Specification numbering.
- Milestones are subdivisions of an iteration. An iteration may contain
  several milestones and involve several features; a feature may span several
  iterations. Scope membership does not reset existing feature approvals.

MVP is [ITERATION-001](../iterations/iteration-001-mvp.md). Its existing
`MVP` milestone labels remain valid aliases. The numbered scope holds the
authoritative MVP requirements and exit criteria. Numbering does not rename
historical feature artifacts or change their requirements or dispositions.

## Assemble and approve the scope

1. Review captured Future Work and existing findings. Merge overlaps and
   identify which items need an Exploration or Spike before committing to
   implementation. Capturing an item does not commit it to an iteration.
2. Write a concrete goal and choose the smallest useful set of outcomes.
   Record included items with their sources and lifecycle routing, explicit
   exclusions, dependencies, and unresolved scope questions.
3. Give success criteria stable local IDs, such as `IT-AC-001`. For each,
   specify an observable result, the configurations where it must hold, and
   the evidence needed to verify it. Link governing contracts instead of
   copying or redefining their acceptance criteria. An investigation may have
   an evidence-and-disposition outcome without promising an implementation.
4. A human maintainer explicitly approves a particular scope revision before
   it becomes a delivery commitment. Record who approved it, when, and the
   instruction or evidence establishing approval.
5. Link the approved scope from its roadmap or implementation records as
   relevant. Route selected work through existing lifecycle gates; local fixes
   and mechanical maintenance may use the lightweight path.

Required metadata is defined by the template. `created` is the date the
numbered record was created, not an invented historical start date. Revision
numbers begin at 1. `approved_revision` and `approval` are null until approval.

### Audit before final scope selection

For cleanup work, a draft scope may describe a bounded audit whose findings
inform the final commitment. Read-only review may begin before scope approval;
use the [Codebase Review Process](CODEBASE_REVIEW.md) to record coverage,
evidence, and dispositions. Separate review outcomes from proposed fixes.
Select remediation and its validation boundaries before approving the scope
and deriving implementation tasks. Where feasibility remains uncertain, an
iteration may commit to an investigation and disposition instead of promising
a replacement. Neither audit findings nor scope approval bypass feature gates.

## Status and scope changes

Allowed statuses are `draft`, `approved`, `active`, `closed`, and `abandoned`:

```text
draft → approved → active → closed
draft / approved / active → abandoned
```

`approved` means the product commitment is accepted, not that downstream
implementation gates passed. Use `active` when work on that commitment begins.
`closed` records an explicit maintainer closure decision with evidence.

Keep the approved baseline in force while discussing amendments. Prepare the
proposed change as a reviewable diff; do not apply it as an approved baseline
until the maintainer explicitly approves it. Record an approved amendment in
the revision history with its reason, affected scope/criteria, date, and
approval provenance; increment `revision` and `approved_revision` together.
Preserve earlier baselines in Git history and retain criterion IDs. A new
delivery commitment receives a new iteration ID rather than rewriting a
closed iteration. Corrections and evidence updates that do not change the
commitment update `updated` without incrementing the scope revision.

A finding necessary to satisfy the approved baseline is current work. Other
findings are deferred or proposed as an explicit scope amendment; they do not
silently enlarge the iteration. An upstream contract or architectural change
still needs its normal approval, even when an iteration amendment is approved.

## Closure and follow-up

Before closure, record a disposition for every success criterion: met, unmet,
or an explicitly approved exception, with evidence and its limitations. Link
Specification conformance reports where they establish those results. Preserve
remaining work through linked Future Work with concrete revisit triggers.

Only a human maintainer may approve scope baselines, amendments, exceptions,
closure, or abandonment. Record closure/abandonment provenance in `closure`.
Closing an iteration does not turn failures or missing evidence into passes,
mark Specifications implemented, or demonstrate full product conformance.

## Existing MVP baseline

The maintainer registered MVP as `ITERATION-001` on 2026-10-04. Its detailed
scope and exit criteria were consolidated into that numbered record without
changing the established baseline. It also links the already recorded
2026-10-03 closeout, including approved exceptions. This preserves existing
history; it is not a new closure or a claim that full measured MVP conformance passed.
