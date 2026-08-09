# Documentation Rules

These rules define lifecycle artifact semantics, authority, identity,
metadata, traceability, and preservation for GiftUI engineering documents.

## Artifact semantics

### Proposal — why

A Proposal establishes that a problem or opportunity deserves attention. It
MUST describe the problem, motivation, affected users, expected value, goals,
non-goals, constraints, success criteria, rough scope, risks, and open
questions. It SHOULD NOT prescribe detailed architecture.

Allowed statuses: `draft`, `proposed`, `accepted`, `rejected`, `superseded`.

### RFC — how

An RFC is the collaborative architectural exploration for an accepted
Proposal. It MUST cover context, requirements, constraints, proposed design,
module/API/backend/capability effects, static and embedded implications,
alternatives, trade-offs, costs, compatibility, testing, risks, and unresolved
questions.

Allowed statuses: `draft`, `review`, `approved`, `rejected`, `superseded`.

RFCs preserve reasoning. Architecturally significant choices from an approved
RFC MUST be extracted into ADRs before a downstream Specification is
authoritative.

### ADR — decision

An ADR records one architecturally significant decision. It MUST state
Context, Decision, Rationale, Consequences, and Rejected Alternatives.

Allowed statuses: `proposed`, `accepted`, `deprecated`, `superseded`.

An accepted ADR is authoritative architecture. A proposed ADR is not.

### Specification — what

A Specification converts accepted architecture into an implementable and
testable contract. Depending on scope it defines APIs, types, module and
ownership boundaries, behavior, state transitions, capabilities, backends,
errors, compatibility, resource requirements, required tests, and acceptance
criteria.

Allowed statuses: `draft`, `review`, `approved`, `implementing`,
`implemented`, `superseded`.

A Specification MUST NOT introduce or contradict architecture. New
architectural questions go back through RFC/ADR work.

## Authority and precedence

```text
Project vision, principles, established product scope,
and established architecture
                         ↓
                 Accepted ADRs
                         ↓
                Approved Specs
                         ↓
                 Implementation
```

Proposal and RFC documents remain important context but are not implementation
contracts.

`docs/MVP_SCOPE.md` is the established product boundary for MVP prioritization,
validation configurations, and exit decisions. MVP work MUST trace to a
reference-application or stack-validation requirement from that scope. The
scope determines whether work belongs in the MVP; it does not select an
architecture, approve a lifecycle artifact, or authorize implementation.

1. An accepted ADR overrides conflicting RFC text.
2. An approved Specification MUST conform to accepted ADRs.
3. Implementation MUST conform to approved Specifications.
4. Code divergence MUST NOT silently redefine a Specification.
5. Architecture changes require a new or superseding ADR.
6. Contract changes that preserve architecture require an amended or
   superseding Specification and renewed approval.
7. Superseded artifacts remain in history and MUST link to successors.
8. Draft, proposed, and review documents are non-authoritative.

When two authoritative artifacts conflict, stop affected downstream work,
record the conflict, and obtain human direction. Do not choose authority by
document date alone.

## Approval authority

AI agents may draft, review, propose edits, identify apparent consensus, and
prepare ADRs or Specifications. Unless a human explicitly delegates approval,
only a human maintainer may:

- accept a Proposal;
- approve an RFC;
- accept an ADR;
- approve or mark implemented a Specification.

Completeness, existing implementation, detailed legacy prose, and lack of
objections do not imply approval.

## Identity and filenames

Lifecycle documents use immutable, zero-padded IDs:

- `PROPOSAL-NNN`
- `RFC-NNN`
- `ADR-NNN`
- `SPEC-NNN`

Allocate the next unused number within each artifact type. IDs MUST remain
unchanged after a document is published or referenced. Filenames use the
lowercase ID and a stable slug, for example:

```text
docs/rfcs/rfc-004-layout-engine.md
```

Renaming a title or filename does not change the ID. References SHOULD name
the ID and use a relative Markdown link.

## Required metadata

Every lifecycle document MUST begin with YAML front matter containing:

```yaml
---
id: RFC-004
feature: layout-system
title: Layout Engine Architecture
status: review
authors:
  - name-or-handle
created: 2026-08-08
updated: 2026-08-08
proposal:
  - PROPOSAL-003
related_rfcs: []
related_adrs: []
related_specs: []
supersedes: []
superseded_by: []
target_milestone: MVP
---
```

All fields are required even when their value is `[]` or `null`. Artifact
templates may add a type-specific relationship field. Dates use ISO 8601
calendar form (`YYYY-MM-DD`). `feature` MUST match a key in
`docs/features.yaml` once the document is added to the repository.

The metadata status and the human-readable content MUST agree. Update
`updated` for substantive edits or status changes.

## Traceability

- Every RFC MUST reference its accepted Proposal.
- Every ADR SHOULD reference the RFC or explicit authority that produced it.
- Every Specification MUST reference all ADRs governing its scope. If none
  exist, it MUST say why; an approved major-feature Specification ordinarily
  cannot have an empty ADR set.
- Every successor MUST list what it supersedes, and every superseded document
  MUST identify its successor.
- `docs/features.yaml` MUST point to every lifecycle artifact and MUST NOT
  duplicate substantive content.
- Related legacy sources and conformance evidence belong in document
  `References`, not in authority-bearing relationship fields.
- Cross-feature dependencies MUST be explicit in the manifest or document
  metadata.

## Feature manifest schema

`docs/features.yaml` has a numeric `schema_version` and a `features` mapping.
Each feature key is an immutable lowercase kebab-case identifier. A populated
entry has this navigation-only shape:

```yaml
feature-id:
  title: Human-readable Feature Title
  status: proposal
  proposal:
    - PROPOSAL-001
  rfcs: []
  adrs: []
  specs: []
  dependencies: []
  milestone: MVP
```

Required entry fields are `title`, `status`, `proposal`, `rfcs`, `adrs`,
`specs`, `dependencies`, and `milestone`. Allowed feature statuses are
`proposal`, `rfc`, `decision`, `specification`, `implementation`,
`conformance`, `implemented`, and `deferred`. Status summarizes the furthest
valid lifecycle stage; it does not grant artifact approval. Artifact lists use
IDs, dependencies use feature keys, and `milestone` may be `null`.

The manifest remains empty until feature registration or migration is
authorized. Comments may explain repository-wide state, but feature entries
MUST NOT contain design summaries, decisions, contracts, or open-question
prose.

## Normative language

Use `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, and `MAY` for contractual
requirements. Use `could`, `candidate`, `explore`, or `open question` for
non-normative possibilities. Do not make unresolved choices look normative.

Specification `Implementation Notes` are non-authoritative guidance unless a
specific statement explicitly says otherwise and is supported by the
normative contract.

## Architecture and roadmap documents

`docs/architecture/` explains the current accepted system. It is derived from
accepted ADRs and MUST NOT become an alternative decision-making channel:

```text
RFC decides → ADR records → architecture documentation explains
```

Roadmaps answer when and in what order. They SHOULD reference feature IDs and
MUST NOT duplicate lifecycle contracts.

Project scope documents answer what product outcome and validation boundary a
milestone must satisfy. They constrain Proposals, RFCs, ADRs, Specifications,
roadmaps, and implementation plans without replacing their distinct roles.

## Legacy and historical documents

Preserve mixed legacy documents as source material. Do not silently rewrite
their reasoning or assign modern approval states by inference. New lifecycle
artifacts SHOULD link to useful legacy sources and state what was reused.

Rejected, deprecated, and superseded artifacts remain available. A successor
changes current authority; it does not erase history.

## Directory ownership

- `docs/proposals/`: Proposal artifacts only
- `docs/rfcs/`: RFC artifacts only
- `docs/adrs/`: ADR artifacts only
- `docs/specs/`: Specification artifacts only
- `docs/architecture/`: explanations of accepted current architecture
- `docs/roadmap/`: milestones and ordering
- `docs/templates/`: non-authoritative artifact templates
- `docs/engineering/`: canonical process and engineering-operation rules
