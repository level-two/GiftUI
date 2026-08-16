# Feature Lifecycle

This document defines the canonical lifecycle for major GiftUI feature work.
It applies to humans and AI agents. The lifecycle exists to preserve reasoning,
decisions, implementation contracts, and conformance evidence in the
repository.

Related rules:

- [MVP Scope](../MVP_SCOPE.md)
- [Documentation Rules](DOCUMENTATION_RULES.md)
- [AI Agent Rules](AI_AGENT_RULES.md)
- [Glossary](GLOSSARY.md)
- [Feature Manifest](../features.yaml)

## Canonical lifecycle

```text
Idea / problem
      ↓
Proposal (draft → proposed)
      ↓ explicit human acceptance
Accepted Proposal
      ↓
RFC (draft → review)
      ↓ engineering review and explicit human approval
Approved RFC
      ↓
ADR extraction (proposed)
      ↓ explicit human acceptance
Accepted ADR(s)
      ↓
Specification (draft → review)
      ↓ explicit human approval
Approved Specification
      ↓
Implementation (Spec status: implementing)
      ↓
Conformance review against acceptance criteria
      ↓
Implemented Specification
```

This gated path remains the only route by which an idea becomes authoritative
architecture or an implementation contract. A lightweight deferred track runs
beside it:

```text
Idea / observation
      ↓
Future Work ───────→ close / supersede
      │
      ├────────────→ Proposal → RFC → ADR → Specification → Implementation
      │
      └────────────→ Exploration ──→ re-evaluate
                              │              │
                              └─ Spike ──────┘
                                             ├─ close / pause
                                             └─ promote to Proposal or RFC
```

Future Work, Explorations, and Spikes preserve possibilities and evidence;
they do not grant approval, add work to a milestone, or create architecture.
They may be created from any lifecycle stage without advancing that stage.

The stages answer different questions:

| Artifact | Question | Effect of approval |
| --- | --- | --- |
| Proposal | Why should GiftUI invest in this? | Authorizes architectural exploration, not implementation |
| RFC | How should the accepted problem be solved? | Establishes reviewed design consensus and enables decision extraction |
| ADR | Which architecturally significant choice was made? | Becomes authoritative architecture |
| Specification | What exact contract must implementation satisfy? | Authorizes major implementation work |
| Conformance review | Does the implementation meet the approved contract? | Allows the Specification to become `implemented` |

The deferred artifacts answer different, deliberately non-authoritative
questions:

| Artifact | Question | Expected output |
| --- | --- | --- |
| Future Work | What idea, opportunity, question, or postponed decision must not be lost? | A cheap, bounded capture with provenance and a revisit trigger |
| Exploration | What do we need to understand before proposing or choosing a direction? | Findings, evidence, remaining uncertainty, and a recommendation to promote, pause, or close |
| Spike | What targeted experiment can produce missing evidence? | Reproducible results; any code is disposable unless separately adopted through the main lifecycle |

## Capture without scope expansion

While drafting or implementing any Proposal, RFC, ADR, Specification, or
implementation plan, capture a valuable out-of-scope item immediately instead
of expanding the current artifact. Use the smallest adequate form:

1. Create Future Work for a concise idea, optimization opportunity, unanswered
   question, or intentionally postponed choice.
2. Create an Exploration when the uncertainty already needs structured
   research, competing hypotheses, or an evidence plan.
3. Create a Spike only when a focused implementation or experiment is the
   efficient way to answer named questions. Link it to its parent Future Work,
   Exploration, or RFC.
4. Add the new ID to the source artifact's relationship metadata and
   `Deferred and Follow-up Work` section. State what is excluded from current
   scope and why.
5. Keep the current artifact's requirements, decisions, acceptance criteria,
   and milestone unchanged unless they pass their normal review and approval
   gates.

A sentence such as “consider later” is not durable capture. Deferred work must
have its own ID and revisit trigger before it can be removed from an RFC's
open questions or decision boundary.

## Branching and reuse

One RFC can produce multiple decisions and implementation contracts:

```text
                 ┌─ ADR-A ─ SPEC-A
RFC ─────────────┤
                 └─ ADR-B ─ SPEC-B ─ SPEC-C
```

One ADR may govern multiple Specifications, and multiple features may depend
on the same ADR. Record every relationship in document metadata and in
`docs/features.yaml`; do not duplicate the documents.

## RFC scope and decomposition

An RFC boundary is an independently reviewable architectural decision cluster,
not a mirror of a logical layer, package, module, protocol, or source directory.
One RFC may govern several layers and produce several ADRs or Specifications.
Conversely, one accepted Proposal may authorize several related RFCs when its
architectural concerns can be evaluated and changed independently.

Create a separate RFC when the concern:

- has multiple credible architectural alternatives requiring explicit review;
- establishes independently significant ownership, dependency, lifetime,
  synchronization, failure, resource, compatibility, or profile semantics;
- affects multiple modules or a public, backend, platform, or hardware
  integration boundary;
- requires distinct reviewers, evidence, feasibility work, or static/embedded
  analysis;
- can be approved, rejected, amended, or superseded without making the parent
  RFC incoherent; or
- would make an existing RFC too broad for reviewers to understand its
  alternatives, consequences, and approval blockers as one decision boundary.

Keep the concern in an existing RFC when it:

- is necessary for that RFC's proposed direction to be coherent;
- cannot be meaningfully approved or rejected independently;
- shares the same requirements, alternatives, evidence, and consequences;
- would create circular reliance between draft RFCs if separated; or
- elaborates an architectural choice already inside the RFC without creating
  another independently significant choice.

Route the concern to a different artifact when appropriate:

- create or revise a Proposal when the concern introduces a problem, value,
  scope, or milestone commitment not covered by an accepted Proposal;
- extract an ADR only after the architectural choice is supported by an
  approved RFC or other explicit authority;
- define exact APIs, types, bounds, behavior, errors, tests, and acceptance
  criteria in a Specification when the governing architecture is settled;
- use an Exploration or Spike when evidence is needed before architectural
  alternatives are reviewable;
- use Future Work when the concern is valuable but unnecessary for current
  coherence; and
- amend or supersede the governing RFC and ADR when the concern changes
  accepted architecture.

Neither document length nor the existence of a new layer, package, module, or
protocol is sufficient by itself to require a new RFC. Do not split inseparable
decisions merely to shorten a document, and do not bundle independently
reviewable decisions merely to reduce artifact count. An integrating RFC may
own the system-wide dependency graph and cross-layer invariants while focused
RFCs resolve independent concerns; their scopes and dependencies MUST be
explicit and MUST NOT create competing sources of authority.

## Lifecycle gates

### Before accepting an MVP Proposal

- The Proposal MUST identify the concrete reference-application or MVP
  stack-validation requirement that makes the work necessary now.
- Work without that traceability SHOULD be classified as post-MVP.
- MVP relevance does not predetermine architecture or authorize implementation.

### Before writing an RFC

- An accepted Proposal MUST exist.
- The RFC MUST link to that Proposal.
- If the Proposal is not accepted, continue refining it rather than treating
  an RFC draft as an approval shortcut.

### Before approving an RFC

- Requirements, constraints, alternatives, and trade-offs MUST be reviewable.
- Major architectural questions SHOULD be resolved.
- Remaining open questions MUST be explicit and MUST NOT invalidate the
  proposed direction.
- Every intentionally postponed decision MUST either remain an explicit
  approval blocker or be extracted into linked Future Work or Exploration with
  a clear current-scope boundary and revisit trigger.
- A deferred item MUST NOT contain a decision required for the proposed
  direction to be coherent. If it does, the RFC is not ready for approval.
- Approval MUST come from a human maintainer unless authority was explicitly
  delegated.

### Before accepting an ADR

- The decision MUST be supported by an approved RFC or another explicitly
  identified authority.
- The ADR MUST extract an agreed decision; it MUST NOT invent one.
- Consequences and rejected alternatives MUST be recorded.
- Acceptance MUST be explicit.

### Before approving a Specification

- Required architectural decisions MUST exist as accepted ADRs.
- The Specification MUST conform to those ADRs and project principles.
- Requirements MUST be implementable, testable, and unambiguous.
- Acceptance criteria and required tests MUST be present.
- Approval MUST be explicit.

### Before major implementation

- An approved Specification MUST exist.
- The implementation plan MUST follow the Specification rather than amend it.
- Mark the Specification `implementing` when implementation actually begins;
  this is a progress transition, not architectural approval.

### Before marking a Specification implemented

- Implementation MUST be checked against every acceptance criterion.
- Required tests and relevant platform checks MUST pass, or documented
  exceptions MUST receive human approval.
- Conformance evidence MUST be linked from the Specification.
- A human maintainer MUST explicitly authorize the `implemented` transition.

## Status transitions

Only the transitions shown below are valid. `superseded` transitions require a
successor reference.

```text
Proposal:      draft → proposed → accepted
                              └→ rejected
               draft/proposed/accepted → superseded

RFC:           draft → review → approved
                           └→ rejected
               draft/review/approved → superseded

ADR:           proposed → accepted → deprecated
                    └───────────────→ superseded

Specification: draft → review → approved → implementing → implemented
               draft/review/approved/implementing/implemented → superseded

Future Work:   captured → promoted
                    └──→ closed
               captured/promoted/closed → superseded

Exploration:   draft → active → concluded
                         ├────→ paused → active
                         └────→ abandoned
               draft/active/paused/concluded/abandoned → superseded

Spike:         planned → active → completed
                         └────→ abandoned
               planned/active/completed/abandoned → superseded
```

`promoted` identifies the Proposal, RFC, or Exploration that took ownership of
a Future Work item; it is not an approval. `concluded` means an Exploration
recorded its findings and disposition, not that GiftUI accepted a design.
`completed` means a Spike answered or attempted its target questions and
recorded evidence, not that its code is production-ready.

Moving a document backward for revision is allowed before its approval gate.
Changing accepted architecture requires a new or superseding ADR, not a
backward status edit that erases history.

## Change routing

### Deferred decision or idea discovered in an active artifact

Do not solve it merely because it was noticed. Determine whether it blocks the
current artifact:

```text
new question / opportunity
        ↓
required for current scope or approval coherence?
        ├─ yes → keep as an explicit blocker in the current lifecycle
        └─ no  → capture as FW or EXP, cross-link, preserve scope
```

If an RFC already contains useful analysis for a postponed topic, move or
summarize that material in the new Exploration and leave a concise boundary
and link in the RFC. Do not duplicate normative text or imply that an RFC
candidate became a decision. If the whole RFC is intentionally postponed,
leave it at `draft` or `review`, record `target_milestone: null` and its linked
revisit item; GiftUI does not use an approval-like `deferred` RFC status.

### Architecture issue discovered during implementation

Pause the affected work and route the issue upstream:

```text
implementation finding
        ↓
RFC amendment or new RFC
        ↓
new or superseding ADR
        ↓
Specification update or successor
        ↓
implementation resumes
```

### Contract clarification without architecture change

Amend or supersede the Specification, return it to review, and obtain approval
before relying on the changed contract.

### Implementation divergence

Do not silently update documentation to match code. Determine whether code is
wrong, the Specification needs a reviewed change, or architecture needs a new
decision.

## Lightweight path

The full lifecycle is expected for major features and architectural changes.
Trivial bug fixes, maintenance, tests, documentation corrections, mechanical
refactors, and obvious implementation within an approved Specification MAY use
a lighter process.

Use the full lifecycle when a change does one or more of the following:

- changes public or cross-module contracts;
- chooses ownership or module boundaries;
- changes runtime-profile or capability semantics;
- introduces backend or platform coupling;
- materially affects memory, binary size, performance, or compatibility;
- creates a choice future work must treat as authoritative.

When uncertain, use feature triage or lifecycle review. Process weight should
match decision risk, not diff size.

The deferred track is also lightweight, but it is not a shortcut around the
main lifecycle. Promotion rules are:

- Future Work → Exploration when research or evidence is needed to judge the
  idea.
- Future Work → Proposal when GiftUI is ready to evaluate investment in a
  substantial problem or opportunity.
- Exploration → Proposal when the problem is credible but investment has not
  been accepted.
- Exploration → RFC only when an accepted Proposal already covers the problem
  and the findings make architectural alternatives reviewable.
- Spike → parent Exploration or RFC as evidence; a Spike never promotes
  directly to an ADR, Specification, or production implementation.
- RFC → ADR, and ADR → Specification, only through the existing approval
  gates.

Re-evaluate an item when its explicit trigger occurs, when an upcoming
milestone depends on it, when new evidence changes its value or feasibility,
or when an authoritative artifact would otherwise foreclose it. A calendar
date alone may be a trigger, but “later” is not.

## Completion and conformance

Implementation is not lifecycle completion by itself. A conformance review
must identify the governing Specification, map evidence to acceptance
criteria, record deviations, and update the feature manifest. Open hardware
or platform gates remain open; a successful host build is not connected-board
evidence.
