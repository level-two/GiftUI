# Documentation Rules

These rules define lifecycle artifact semantics, authority, identity,
metadata, traceability, and preservation for GiftUI engineering documents.

## Artifact semantics

The Proposal → RFC → ADR → Specification lifecycle is the authority-bearing
track. Future Work, Exploration, and Spike artifacts are a separate,
non-authoritative track for preserving ideas and producing evidence without
expanding committed scope.

### Future Work — cheap capture

A Future Work item records one idea, optimization opportunity, unanswered
question, or intentionally postponed decision. It MUST state the observation
or opportunity, why it is deferred, its source context, current non-goals, and
at least one concrete revisit trigger. Keep it short; it need not justify an
investment or compare designs.

Allowed statuses: `captured`, `promoted`, `closed`, `superseded`.

### Exploration — learn

An Exploration investigates an uncertain direction without requiring a
decision. It MUST define questions or hypotheses, scope, known constraints,
an evidence plan, findings as they emerge, remaining unknowns, and a
disposition. Competing approaches remain candidates. An Exploration MAY end
without a recommendation or decision.

Allowed statuses: `draft`, `active`, `paused`, `concluded`, `abandoned`,
`superseded`.

### Spike — targeted evidence

A Spike is a time- or scope-bounded implementation, prototype, benchmark, or
experiment created to answer named questions. It MUST identify its parent,
method, reproducibility conditions, results, limitations, and disposition.
Spike code is disposable and non-production by default. Reusing it in the
product requires normal review, testing, and the authority-bearing lifecycle.

Allowed statuses: `planned`, `active`, `completed`, `abandoned`, `superseded`.

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

### Implementation records — realize and prove

Implementation Plans translate approved Specifications into ordered tasks and
expected evidence. Implementation Design Notes explain selected internal
realizations for complex mechanisms. Conformance Reports map completed work
and evidence back to every acceptance criterion.

All three are derived, non-authoritative records governed by
[Implementation Documentation](IMPLEMENTATION_DOCUMENTATION.md). They MUST NOT
introduce architecture, amend a Specification, or make code divergence
authoritative.

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

Future Work, Explorations, and Spikes are evidence or navigation aids only.
Their status, detail, code, benchmarks, or conclusions MUST NOT be treated as
an accepted decision, approved contract, roadmap commitment, or implementation
authorization. When cited by an RFC, they support analysis but do not replace
review or approval.

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

Deferred-track documents use independent immutable, zero-padded IDs:

- `FW-NNN`
- `EXP-NNN`
- `SPIKE-NNN`

Allocate the next unused number within each artifact type. IDs MUST remain
unchanged after a document is published or referenced. Filenames use the
lowercase ID and a stable slug, for example:

```text
docs/rfcs/rfc-004-layout-engine.md
docs/future-work/fw-012-retained-rendering.md
docs/explorations/exp-004-hardware-scrolling.md
docs/spikes/spike-002-retained-tree-memory.md
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
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---
```

All fields are required even when their value is `[]` or `null`. Artifact
templates may add a type-specific relationship field. Dates use ISO 8601
calendar form (`YYYY-MM-DD`). `feature` MUST match a key in
`docs/features.yaml` once the document is added to the repository.

Deferred-track documents use their template's reduced metadata contract.
`feature` may be `null`, `source` MUST contain at least one artifact ID or
repository path, and `promoted_to` remains `[]` until promotion.

The metadata status and the human-readable content MUST agree. Update
`updated` for substantive edits or status changes.

All main-lifecycle templates include these deferred-track relationship fields:

```yaml
related_future_work: []
related_explorations: []
related_spikes: []
```

These fields are required for newly created main-lifecycle artifacts and when
an existing artifact first gains a deferred-track relationship. Existing
artifacts need not receive empty fields solely for mechanical migration.

Deferred-track templates use the same fields as applicable plus `source` for
the artifact or repository context that caused capture, and `promoted_to` for
the main-lifecycle artifact that takes ownership. Relationships are
bidirectional: a source RFC that creates `FW-012` lists it, and `FW-012` lists
the RFC in `source`.

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
- Every deferred item extracted from a Proposal, RFC, ADR, Specification, or
  implementation plan MUST link back to that source, and the source MUST list
  the deferred item.
- Promotion MUST preserve the original deferred artifact, update its status or
  disposition, and link the new Proposal, RFC, or Exploration. Do not rename a
  deferred item into a lifecycle artifact or reuse its ID.
- Deferred-track items do not require a `docs/features.yaml` entry merely to
  be captured. If they name an existing `feature`, use its stable key; use
  `feature: null` for untriaged cross-cutting ideas. Register or update a
  feature only when the main lifecycle requires it.

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

Future Work is not a roadmap. A roadmap records expected work; a Future Work
item records something worth remembering. Promotion into a Proposal or
roadmap requires an explicit prioritization action.

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
- `docs/future-work/`: cheap deferred idea capture
- `docs/explorations/`: structured, non-decisional investigations
- `docs/spikes/`: experiment records and evidence; disposable code belongs
  under `experiments/` and links back to its Spike
- `docs/implementation-plans/`: one ordered implementation plan per governing
  Specification
- `docs/implementation-designs/`: focused, non-authoritative explanations of
  complex internal realizations
- `docs/conformance/`: evidence-based Specification conformance reports
- `docs/templates/`: non-authoritative artifact templates
- `docs/engineering/`: canonical process and engineering-operation rules
