# Feature Lifecycle

This document defines the canonical lifecycle for major GiftUI feature work.
It applies to humans and AI agents. The lifecycle exists to preserve reasoning,
decisions, implementation contracts, and conformance evidence in the
repository.

Related rules:

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

The stages answer different questions:

| Artifact | Question | Effect of approval |
| --- | --- | --- |
| Proposal | Why should GiftUI invest in this? | Authorizes architectural exploration, not implementation |
| RFC | How should the accepted problem be solved? | Establishes reviewed design consensus and enables decision extraction |
| ADR | Which architecturally significant choice was made? | Becomes authoritative architecture |
| Specification | What exact contract must implementation satisfy? | Authorizes major implementation work |
| Conformance review | Does the implementation meet the approved contract? | Allows the Specification to become `implemented` |

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

## Lifecycle gates

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
```

Moving a document backward for revision is allowed before its approval gate.
Changing accepted architecture requires a new or superseding ADR, not a
backward status edit that erases history.

## Change routing

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

## Completion and conformance

Implementation is not lifecycle completion by itself. A conformance review
must identify the governing Specification, map evidence to acceptance
criteria, record deviations, and update the feature manifest. Open hardware
or platform gates remain open; a successful host build is not connected-board
evidence.
