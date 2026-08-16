# AI Agent Rules

These rules apply to repository-aware AI agents working on GiftUI. Root
instructions route agents here; role-specific procedures live in
`.agents/skills/`.

## Required orientation

Before drafting or implementing major feature work:

1. read [Feature Lifecycle](FEATURE_LIFECYCLE.md) and
   [Documentation Rules](DOCUMENTATION_RULES.md);
2. read [GiftUI MVP Scope](../MVP_SCOPE.md), `docs/VISION.md`, and
   `docs/PRINCIPLES.md`;
3. inspect [the feature manifest](../features.yaml);
4. locate the feature's linked Proposal, RFCs, accepted ADRs, approved
   Specifications, deferred-track items, and current conformance evidence;
5. read affected architecture documentation and applicable repository skills;
6. state the current lifecycle stage, MVP justification, and any missing gate
   before proceeding.

If the manifest or an artifact does not yet exist, report the gap. Do not
invent a relationship to make the chain appear complete.

## Allowed actions

Without special approval, an agent may:

- inventory and classify existing material;
- draft lifecycle artifacts at non-approved statuses;
- review artifacts and distinguish blockers from suggestions;
- propose status changes for a human to approve;
- identify conflicts, missing prerequisites, and apparent consensus;
- create or update Future Work, Exploration, and Spike artifacts without human
  approval when doing so preserves supplied observations and does not expand
  current scope;
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
- treat a Future Work item, Exploration finding, Spike result, or experimental
  code as a decision, contract, roadmap commitment, or implementation
  authorization;
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

## Deferred discovery behavior

During Proposal, RFC, ADR, Specification, planning, implementation, or review
work, actively notice valuable ideas, optimization opportunities, unanswered
questions, and intentionally postponed choices. For each item:

1. Determine whether it blocks the current artifact's coherence, correctness,
   or approval gate. If yes, keep it visible as a blocker and do not defer it.
2. Otherwise create the smallest adequate artifact: Future Work for capture,
   Exploration for structured uncertainty, or Spike for a bounded experiment.
3. Preserve provenance, why it is outside current scope, concrete revisit
   triggers, and bidirectional links to the source artifact.
4. Do not add the item to MVP scope, a roadmap, requirements, acceptance
   criteria, or implementation tasks unless separately authorized.
5. When a trigger is observed, report it and recommend re-evaluation; do not
   silently promote or decide the item.

An agent may create a deferred artifact as part of authorized documentation or
implementation work. It MUST NOT launch a Spike that changes connected
hardware, external systems, or other scoped resources without the same user
authorization that experiment would normally require.

## Artifact creation and updates

When creating or superseding a lifecycle artifact:

- allocate an immutable ID and use the matching template;
- preserve provenance with links to source artifacts and useful legacy text;
- update both directions of supersession references;
- update both sides of deferred-track source, parent, and promotion links;
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

When routing architecture work, apply the RFC scope and decomposition criteria
in [Feature Lifecycle](FEATURE_LIFECYCLE.md). Do not infer that a new layer,
package, module, protocol, or long document automatically requires a separate
RFC. Recommend the smallest coherent, independently reviewable decision
boundary and route settled contract detail to Specifications.

## Completion reporting

For lifecycle or implementation work, report:

- the feature and lifecycle stage;
- the reference-application or stack-validation requirement that justifies MVP
  inclusion, or that the work is post-MVP;
- authoritative artifacts consulted;
- artifacts or code changed;
- validation performed and evidence produced;
- open gates, conflicts, and required human approvals;
- manifest and cross-reference updates.

Do not describe a feature as complete until Specification acceptance criteria
have been reviewed and the required human transition has occurred.
