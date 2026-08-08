# GiftUI Engineering Governance Bootstrap Specification

**Status:** Bootstrap Specification  
**Scope:** Repository engineering process, documentation model, and AI-agent workflows  
**Target:** GiftUI repository  
**Audience:** Human maintainers and AI engineering agents

---

## 1. Purpose

GiftUI is evolving from a proof of concept into a framework with multiple interacting architectural concerns, including:

- public SwiftUI-like API evolution;
- view graph and state management;
- layout;
- rendering;
- capability negotiation;
- backend abstraction;
- static and dynamic deployment models;
- Linux, framebuffer, and embedded targets.

Design knowledge already exists in proposals, discussions, experiments, and specifications.

The repository MUST establish a formal engineering lifecycle that converts this knowledge into durable, traceable engineering artifacts.

The lifecycle for a major feature is:

```text
Proposal
   ↓
RFC
   ↓
ADR(s)
   ↓
Specification(s)
   ↓
Implementation
   ↓
Conformance / completion
```

The governance system MUST be usable by both humans and AI agents.

The repository itself SHOULD become the canonical long-term memory of the project.

---

# 2. Goals

The bootstrap work MUST establish:

1. a canonical feature-engineering lifecycle;
2. clear semantics for Proposal, RFC, ADR, and Specification documents;
3. document status transitions;
4. authority and precedence rules between documents;
5. traceability between artifacts;
6. reusable document templates;
7. a machine-readable feature index;
8. repository-local AI-agent instructions;
9. role-specific AI-agent skills;
10. rules for migrating existing GiftUI design documents;
11. lightweight validation of the resulting documentation system.

After completion, an AI agent entering the repository MUST be able to answer:

- What feature is being worked on?
- At what lifecycle stage is it?
- What documents are authoritative?
- What architectural decisions already exist?
- What decisions are still open?
- What specification governs implementation?
- What may the agent change?
- What requires explicit human approval?

---

# 3. Non-goals

This bootstrap task MUST NOT:

- redesign GiftUI architecture;
- choose between unresolved architectural alternatives;
- implement framework features;
- refactor production source code;
- convert speculative ideas into accepted decisions;
- infer human approval from old discussions;
- silently rewrite historical reasoning;
- create ADRs for decisions that have not actually been made.

Existing material may expose architectural gaps. Those gaps MUST be recorded rather than resolved implicitly.

---

# 4. Repository Structure

The agent MUST establish the following logical structure unless an equivalent structure already exists.

```text
docs/
├── engineering/
│   ├── FEATURE_LIFECYCLE.md
│   ├── DOCUMENTATION_RULES.md
│   ├── AI_AGENT_RULES.md
│   └── GLOSSARY.md
│
├── architecture/
│   └── README.md
│
├── proposals/
│   └── README.md
│
├── rfcs/
│   └── README.md
│
├── adrs/
│   └── README.md
│
├── specs/
│   └── README.md
│
├── roadmap/
│
├── templates/
│   ├── proposal.md
│   ├── rfc.md
│   ├── adr.md
│   └── spec.md
│
└── features.yaml

.agents/
└── skills/
    ├── feature-triage/
    │   └── SKILL.md
    ├── proposal-author/
    │   └── SKILL.md
    ├── rfc-author/
    │   └── SKILL.md
    ├── rfc-reviewer/
    │   └── SKILL.md
    ├── adr-author/
    │   └── SKILL.md
    ├── spec-author/
    │   └── SKILL.md
    ├── spec-reviewer/
    │   └── SKILL.md
    ├── lifecycle-reviewer/
    │   └── SKILL.md
    └── implementation-planner/
        └── SKILL.md

AGENTS.md
```

Naming MAY be adapted to existing repository conventions, but the conceptual separation MUST remain.

---

# 5. Artifact Model

## 5.1 Proposal — Why

A Proposal establishes that a problem or opportunity deserves engineering attention.

It MUST describe:

- problem;
- motivation;
- affected users;
- expected value;
- goals;
- non-goals;
- constraints;
- success criteria;
- rough scope.

A Proposal SHOULD NOT prescribe detailed architecture.

Allowed statuses:

```text
draft
proposed
accepted
rejected
superseded
```

An accepted Proposal authorizes architectural exploration.

It does not authorize implementation.

---

## 5.2 RFC — How

An RFC explores how the accepted problem SHOULD be solved.

It is the primary collaborative design artifact.

It MUST normally contain:

- context;
- requirements;
- constraints;
- proposed architecture;
- affected modules;
- API implications;
- backend implications;
- capability implications;
- static/embedded implications where relevant;
- alternatives;
- trade-offs;
- performance considerations;
- memory/code-size considerations;
- compatibility;
- testing implications;
- unresolved questions.

Allowed statuses:

```text
draft
review
approved
rejected
superseded
```

An RFC MAY contain multiple decisions.

Architecturally significant decisions MUST be extracted into ADRs before downstream Specifications become authoritative.

---

# 6. ADR — Decision Record

An ADR records a decision, not the entire design discussion.

Each ADR MUST answer:

```text
Context
Decision
Rationale
Consequences
Rejected alternatives
```

Allowed statuses:

```text
proposed
accepted
deprecated
superseded
```

An accepted ADR is authoritative architecture.

RFC discussion is historical context; the accepted ADR represents the actual decision.

One RFC MAY generate multiple ADRs.

One ADR MAY affect multiple Specifications.

---

# 7. Specification — What

A Specification converts approved architectural decisions into an implementation contract.

It MUST be sufficiently precise that implementation work does not need to rediscover architectural intent.

Depending on scope it SHOULD define:

- public APIs;
- protocols;
- types;
- ownership;
- module boundaries;
- lifecycle behavior;
- state transitions;
- algorithms where behavior is contractual;
- capability behavior;
- backend behavior;
- error handling;
- compatibility requirements;
- performance requirements;
- static/embedded constraints;
- acceptance criteria;
- required tests.

Allowed statuses:

```text
draft
review
approved
implementing
implemented
superseded
```

A Specification MUST NOT introduce an architectural decision that contradicts or bypasses accepted ADRs.

If specification work reveals a new architectural decision, specification work MUST pause on that question and an RFC/ADR amendment MUST be created.

---

# 8. Authority Model

The following precedence MUST be documented:

```text
Project principles / established architecture
                ↓
        Accepted ADRs
                ↓
       Approved Specs
                ↓
        Implementation
```

Proposal and RFC documents are important historical and reasoning artifacts but are not implementation contracts.

Rules:

1. Accepted ADR overrides conflicting RFC text.
2. Approved Specification MUST conform to accepted ADRs.
3. Implementation MUST conform to approved Specification.
4. Implementation divergence MUST NOT silently redefine the Specification.
5. If architecture changes, create or supersede an ADR.
6. If contractual implementation behavior changes without changing architecture, amend or supersede the Specification.
7. Superseded documents remain in history and MUST reference their successors.

---

# 9. Approval Authority

AI agents MUST NOT infer approval.

Unless explicitly authorized otherwise:

```text
AI agent:
    may draft
    may review
    may propose changes
    may identify consensus
    may prepare an ADR
    may prepare a Spec

Human maintainer:
    accepts Proposal
    approves RFC
    accepts ADR
    approves Spec
```

An AI agent MUST NOT change:

```text
draft → accepted
review → approved
proposed ADR → accepted
```

merely because the document appears complete.

Explicit human instruction is required.

---

# 10. Metadata

Every lifecycle document MUST contain structured metadata.

Recommended Markdown front matter:

```yaml
---
id: RFC-004
feature: layout-system
title: Layout Engine Architecture
status: review
authors:
  - yauheni
created: 2026-08-08
updated: 2026-08-08

proposal:
  - PROPOSAL-003

related_adrs: []

related_specs: []

supersedes: []
superseded_by: []

target_milestone: MVP-2
---
```

Fields MAY vary slightly by artifact type.

IDs MUST be immutable after publication.

References SHOULD use IDs rather than filenames alone.

---

# 11. Feature Manifest

Create:

```text
docs/features.yaml
```

This is the machine-readable entry point for humans and agents.

Example:

```yaml
features:

  capability-system:
    title: Capability System
    status: rfc
    proposal:
      - PROPOSAL-002
    rfcs:
      - RFC-002
    adrs: []
    specs: []
    milestone: MVP

  layout-system:
    title: Layout System
    status: proposed
    proposal:
      - PROPOSAL-003
    rfcs: []
    adrs: []
    specs: []
    milestone: MVP
```

The manifest MUST point to lifecycle artifacts.

It MUST NOT duplicate their substantive content.

Its purpose is navigation and lifecycle state discovery.

---

# 12. Feature Lifecycle

`docs/engineering/FEATURE_LIFECYCLE.md` MUST define the canonical lifecycle.

Minimum lifecycle:

```text
Idea / problem
      ↓
Proposal
      ↓ human acceptance
RFC
      ↓ engineering review
RFC approved
      ↓
ADR extraction
      ↓ human acceptance
Specification
      ↓ human approval
Implementation
      ↓
Conformance review
      ↓
Implemented
```

The document MUST also describe branching.

Example:

```text
                 ┌─ ADR-A ─ SPEC-A
RFC ─────────────┤
                 └─ ADR-B ─ SPEC-B
```

Multiple Specifications MAY implement parts of one architecture.

Multiple features MAY depend on the same ADR.

---

# 13. Lifecycle Gate Rules

Before writing an RFC:

```text
Accepted Proposal MUST exist.
```

Before approving an RFC:

```text
major open architectural questions SHOULD be resolved.
```

Before approving a Spec:

```text
required architectural decisions MUST exist as accepted ADRs.
```

Before implementation:

```text
an approved Specification MUST exist for major feature work.
```

Before marking implemented:

```text
implementation MUST be checked against Specification acceptance criteria.
```

For trivial bug fixes, maintenance, documentation changes, or obvious implementation work, maintainers MAY use a lighter process.

The governance system MUST NOT force every code change through a full RFC lifecycle.

---

# 14. Templates

The bootstrap agent MUST create templates.

## Proposal template

Required sections:

```text
Summary
Problem
Motivation
Users / Use Cases
Goals
Non-goals
Constraints
Success Criteria
Scope
Risks
Open Questions
```

## RFC template

Required sections:

```text
Summary
Context
Requirements
Constraints
Proposed Design
Module Responsibilities
Public API Impact
Capabilities Impact
Backend Impact
Static / Embedded Impact
Performance
Memory / Binary Size
Alternatives
Rejected Approaches
Compatibility
Testing Strategy
Risks
Open Questions
Decision Summary
```

## ADR template

Required sections:

```text
Title
Status
Context
Decision
Rationale
Consequences
Rejected Alternatives
References
```

## Spec template

Required sections:

```text
Summary
Scope
Goals
Non-goals
Dependencies
Related ADRs
Terminology
Public Contract
Module Contract
Types / APIs
Behavior
State / Lifecycle
Capability Requirements
Backend Requirements
Error Handling
Performance Requirements
Compatibility
Testing Requirements
Acceptance Criteria
Implementation Notes
Open Issues
```

`Implementation Notes` MUST explicitly be non-authoritative unless stated otherwise.

---

# 15. AI Agent Skills

Each skill MUST be small, role-specific, and reference the canonical lifecycle documents.

A skill MUST NOT copy the entire governance model.

Each `SKILL.md` SHOULD contain:

```text
Role
Purpose
Required Inputs
Documents To Read
Allowed Decisions
Forbidden Decisions
Required Output
Review Checklist
Completion Criteria
```

---

## 15.1 feature-triage

Purpose:

Determine the lifecycle state of a requested feature.

It MUST:

- locate the feature in `features.yaml`;
- locate related documents;
- determine current lifecycle stage;
- identify missing prerequisites;
- recommend the next artifact.

It MUST NOT design the feature unless subsequently operating under another role.

---

## 15.2 proposal-author

Purpose:

Convert a problem/opportunity into a Proposal.

It MUST emphasize:

```text
Why?
Who benefits?
What outcome is desired?
What is explicitly outside scope?
```

It MUST avoid premature API and class design.

---

## 15.3 rfc-author

Purpose:

Turn an accepted Proposal into an architectural exploration.

It MAY:

- compare alternatives;
- propose interfaces;
- examine module boundaries;
- analyze embedded constraints;
- explore performance and memory trade-offs.

It MUST preserve unresolved issues as explicit open questions.

---

## 15.4 rfc-reviewer

Purpose:

Challenge an RFC.

The reviewer MUST look for:

- hidden assumptions;
- inconsistent module ownership;
- capability-model conflicts;
- backend coupling;
- dynamic/static incompatibility;
- embedded constraints;
- memory/code-size consequences;
- performance risks;
- missing alternatives;
- API compatibility;
- testing difficulty.

It MUST distinguish blockers from suggestions.

---

## 15.5 adr-author

Purpose:

Extract agreed architectural decisions from an approved RFC.

It MUST NOT introduce a new decision.

If consensus is insufficient, the ADR remains `proposed`.

---

## 15.6 spec-author

Purpose:

Convert accepted decisions into an implementable contract.

It MUST read:

- relevant Proposal;
- approved RFC;
- all relevant accepted ADRs;
- related existing Specifications;
- affected architecture documents.

It MUST NOT silently modify architecture.

---

## 15.7 spec-reviewer

Purpose:

Verify that a Specification is:

- complete;
- internally consistent;
- implementable;
- testable;
- compatible with ADRs;
- unambiguous enough for an implementation agent.

The reviewer MUST identify architectural decisions accidentally introduced by the Spec.

---

## 15.8 lifecycle-reviewer

Purpose:

Act as the architecture/process consistency checker.

It MUST answer:

```text
What stage is this feature in?
Are lifecycle prerequisites satisfied?
Which artifacts are authoritative?
Are there conflicts?
Are decisions hidden in the wrong artifact?
Which existing documents become stale?
Does this change require an ADR?
Does this change require a Spec update?
```

This role SHOULD be usable before merging major feature changes.

---

## 15.9 implementation-planner

Purpose:

Convert an approved Specification into implementation tasks.

It MAY produce:

- milestones;
- dependency ordering;
- source-module changes;
- test tasks;
- integration tasks.

It MUST NOT change the Specification to make implementation easier.

Discovered specification problems MUST be reported upstream.

---

# 16. Root Agent Instructions

Create or update:

```text
AGENTS.md
```

It MUST direct repository-aware agents to:

1. read `docs/engineering/FEATURE_LIFECYCLE.md`;
2. inspect `docs/features.yaml`;
3. locate authoritative ADRs and Specs before major implementation;
4. determine lifecycle stage before producing new feature artifacts;
5. avoid treating draft documents as decisions;
6. avoid changing accepted architecture implicitly;
7. preserve traceability between artifacts;
8. update references when creating or superseding lifecycle documents.

The root file SHOULD remain short.

Detailed role behavior belongs in skills.

---

# 17. Existing GiftUI Knowledge Migration

The repository already contains design work concerning areas such as:

- backend abstraction;
- framebuffer rendering;
- embedded/TFT backends;
- static versus dynamic configurations;
- capability propagation;
- public View API;
- layout;
- state;
- `ObservedObject` / `StateObject`-like behavior;
- graphical primitives;
- interaction;
- scrolling;
- Raspberry Pi and embedded PoCs.

The bootstrap agent MUST inventory existing documents before restructuring them.

Produce an inventory containing:

```text
Existing document
Likely feature
Current document nature
    Proposal
    RFC-like
    ADR-like
    Spec-like
    Mixed
    Experiment
    Historical notes

Known status
Relevant existing decisions
Unresolved questions
Recommended destination
```

The agent MUST NOT assume that a previous design proposal was approved merely because it is detailed.

---

# 18. Handling Mixed Legacy Documents

Existing documents may combine:

```text
motivation
architecture
decision
specification
implementation notes
```

The bootstrap agent SHOULD NOT destroy these documents.

Preferred migration:

```text
legacy source document
       ↓ references
new Proposal
new RFC
new ADR(s)
new Spec(s)
```

The original document MAY remain as historical source material.

New artifacts MUST link back to it when useful.

If approval state cannot be established, use conservative states such as:

```text
draft
review
proposed
```

Never use `accepted` merely by inference.

---

# 19. Architecture Documentation

`docs/architecture/` represents current architectural knowledge rather than lifecycle discussion.

Architecture documentation SHOULD summarize the currently accepted system.

It MUST be derived from accepted decisions rather than becoming an alternative decision-making mechanism.

Rule:

```text
RFC decides.
ADR records.
Architecture docs explain the resulting current system.
```

When an ADR changes architecture, affected architecture documents SHOULD be updated.

---

# 20. Roadmap Relationship

Roadmaps and milestones answer:

```text
When?
In what order?
Toward what product state?
```

Lifecycle artifacts answer:

```text
Why?
How?
What exactly?
```

Roadmap entries SHOULD reference feature IDs rather than duplicate Specs.

Example:

```text
MVP-2:
  - layout-system
  - capability-system
  - basic-input
```

---

# 21. Bootstrap Execution Plan

The AI agent MUST execute the governance bootstrap in phases.

## Phase 1 — Inventory

Inspect the repository.

Identify:

- existing documentation;
- existing proposals/specs;
- architectural documents;
- agent instructions;
- naming conventions;
- roadmap artifacts.

Do not modify architecture in this phase.

Output a concise inventory.

---

## Phase 2 — Governance Core

Create:

```text
FEATURE_LIFECYCLE.md
DOCUMENTATION_RULES.md
AI_AGENT_RULES.md
GLOSSARY.md
```

Establish artifact authority and lifecycle rules.

---

## Phase 3 — Templates

Create Proposal, RFC, ADR, and Spec templates.

Ensure templates conform to governance rules.

---

## Phase 4 — Feature Manifest

Create `features.yaml`.

Populate it initially only with features that can be identified confidently.

Unknown relationships MUST be marked rather than invented.

---

## Phase 5 — Agent Skills

Create role-specific skills.

Skills MUST refer to canonical governance documents instead of duplicating policy.

---

## Phase 6 — Root Agent Routing

Create/update `AGENTS.md`.

Ensure a newly started coding agent can discover the governance process immediately.

---

## Phase 7 — Existing Knowledge Migration

Classify existing GiftUI documents.

Create new lifecycle artifacts only where classification is sufficiently clear.

Preserve provenance.

Do not grant implicit approval.

---

## Phase 8 — Consistency Review

Run the lifecycle-reviewer rules over the resulting structure.

Verify:

- links;
- statuses;
- IDs;
- references;
- ADR relationships;
- Specification dependencies;
- feature manifest consistency.

---

# 22. Validation

The system SHOULD support lightweight automated validation.

Validation MAY initially be simple.

Possible checks:

```text
Every lifecycle document has an ID.
Every ID is unique.
Every document has a valid status.
Every Spec references relevant ADRs.
Referenced document IDs exist.
features.yaml references valid artifacts.
superseded documents identify successors.
```

The bootstrap MUST NOT introduce substantial external tooling solely for documentation validation unless already justified by the repository.

Start with low-maintenance validation.

Automation can evolve later.

---

# 23. Change Rules

Once governance has been bootstrapped:

### New major feature

```text
feature-triage
    ↓
Proposal
    ↓
RFC
    ↓
ADR
    ↓
Spec
    ↓
implementation-plan
    ↓
code
    ↓
lifecycle/conformance review
```

### Architecture change during implementation

Do NOT silently modify code and update Spec afterward.

Instead:

```text
implementation discovers issue
        ↓
RFC amendment/new RFC
        ↓
new/superseding ADR
        ↓
Spec update
        ↓
implementation continues
```

### Specification clarification

If architecture remains unchanged:

```text
Spec amendment
        ↓
review
        ↓
approval
```

---

# 24. Agent Behaviour Rules

All repository AI agents MUST follow these principles.

### Do not invent consensus

Detailed prior discussion is not equivalent to approval.

### Do not hide decisions

A significant architecture choice must not appear for the first time inside implementation code.

### Preserve open questions

Unresolved questions are legitimate engineering output.

Do not make arbitrary choices merely to produce a complete-looking document.

### Prefer references over duplication

ADR, Spec, roadmap, and architecture documents SHOULD cross-reference rather than repeat substantial content.

### Separate normative and exploratory text

Agents must distinguish:

```text
must / shall
```

from:

```text
could / might / candidate / open question
```

### Preserve history

Rejected and superseded reasoning is valuable.

Do not delete it merely because a newer decision exists.

### Avoid process theatre

The lifecycle exists to improve engineering quality.

Small changes SHOULD remain lightweight.

---

# 25. Acceptance Criteria

The bootstrap is complete when all of the following are true:

- [ ] Canonical lifecycle documentation exists.
- [ ] Proposal, RFC, ADR, and Spec semantics are clearly separated.
- [ ] Status models are defined.
- [ ] Approval authority is defined.
- [ ] Document precedence rules are defined.
- [ ] Templates exist for all lifecycle artifacts.
- [ ] A machine-readable feature manifest exists.
- [ ] Root AI-agent instructions exist.
- [ ] Role-specific agent skills exist.
- [ ] Existing GiftUI documentation has been inventoried.
- [ ] Existing documents have not been assigned fictitious approval states.
- [ ] At least one existing GiftUI feature is represented end-to-end as an example or initial migration.
- [ ] Cross-document references are consistent.
- [ ] A lifecycle reviewer can determine the authoritative state of a feature without relying on chat history.
- [ ] No GiftUI production architecture has been silently changed as part of the governance bootstrap.

---

# 26. Recommended Initial Pilot

After installing the governance system, use one real GiftUI topic to validate it end-to-end.

Recommended candidates:

```text
Capability System
```

or:

```text
Layout System
```

The pilot SHOULD exercise:

```text
Proposal
    ↓
RFC
    ↓
ADR(s)
    ↓
Spec
    ↓
Implementation Plan
```

Do not migrate every existing idea immediately.

Use the pilot to discover weaknesses in the lifecycle before performing broad migration.

---

# 27. Definition of Success

The governance system is successful if a fresh human or AI engineer can enter the GiftUI repository and, without access to historical conversations:

1. understand why a major feature exists;
2. reconstruct the architectural reasoning;
3. identify the decisions actually accepted;
4. locate the exact implementation contract;
5. understand which questions remain open;
6. know what may safely be changed;
7. know which lifecycle artifact must be updated when a new issue appears.

The repository then acts not merely as source-code storage but as the durable engineering memory of GiftUI.
