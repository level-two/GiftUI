# AI Agent Rules

These rules apply to repository-aware AI agents working on GiftUI. Root
instructions route agents here; role-specific procedures live in
`.agents/skills/`.

## Required orientation

Before drafting or implementing major feature work:

1. read [Feature Lifecycle](FEATURE_LIFECYCLE.md) and
   [Documentation Rules](DOCUMENTATION_RULES.md);
2. inspect [the feature manifest](../features.yaml);
3. locate the feature's linked Proposal, RFCs, accepted ADRs, approved
   Specifications, and current conformance evidence;
4. read `docs/VISION.md`, `docs/PRINCIPLES.md`, affected architecture
   documentation, and applicable repository skills;
5. state the current lifecycle stage and any missing gate before proceeding.

If the manifest or an artifact does not yet exist, report the gap. Do not
invent a relationship to make the chain appear complete.

## Allowed actions

Without special approval, an agent may:

- inventory and classify existing material;
- draft lifecycle artifacts at non-approved statuses;
- review artifacts and distinguish blockers from suggestions;
- propose status changes for a human to approve;
- identify conflicts, missing prerequisites, and apparent consensus;
- implement work already authorized by an approved Specification;
- update traceability and evidence as part of authorized work.

## Forbidden actions

An agent MUST NOT:

- infer approval from detail, age, existing code, prior discussion, or silence;
- perform `draft → accepted`, `review → approved`, proposed ADR → `accepted`,
  or Specification → `implemented` transitions without explicit human
  authorization;
- treat a draft, proposed, review, rejected, deprecated, or superseded artifact
  as current authority;
- introduce an architecturally significant choice first in code or a
  Specification;
- silently change accepted architecture or rewrite historical reasoning;
- close open questions arbitrarily to produce a complete-looking document;
- change a Specification merely to make implementation easier;
- claim hardware validation from a build, simulator, or host test.

## Conflict and discovery handling

If implementation exposes an architectural problem, pause the affected choice
and report which RFC/ADR needs amendment or replacement. If the problem is
contractual but not architectural, route it through Specification review. If
authoritative documents conflict, do not choose one silently; provide exact
references and request human resolution.

Preserve normative versus exploratory language. A candidate in an RFC remains
a candidate until a decision is accepted and a contract approved.

## Artifact creation and updates

When creating or superseding a lifecycle artifact:

- allocate an immutable ID and use the matching template;
- preserve provenance with links to source artifacts and useful legacy text;
- update both directions of supersession references;
- add or update `docs/features.yaml` in the same change;
- check referenced IDs, statuses, and gate prerequisites;
- avoid copying substantive text into the manifest, roadmap, or agent skills.

Status changes are substantive changes: update metadata dates, references,
the feature manifest, and any affected architecture summary.

## Selecting process weight

Use the full lifecycle for major features and architectural decisions. The
lightweight path is appropriate for small bug fixes, maintenance, tests,
documentation corrections, and implementation already unambiguously governed
by an approved Specification. When the change creates a durable design choice,
route it through lifecycle triage even if the code diff is small.

## Completion reporting

For lifecycle or implementation work, report:

- the feature and lifecycle stage;
- authoritative artifacts consulted;
- artifacts or code changed;
- validation performed and evidence produced;
- open gates, conflicts, and required human approvals;
- manifest and cross-reference updates.

Do not describe a feature as complete until Specification acceptance criteria
have been reviewed and the required human transition has occurred.
