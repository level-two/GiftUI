# Implementation Documentation

This document defines the records used between an approved GiftUI
Specification and its implementation-completion decision. These records make
implementation work reconstructable without creating another source of
architecture or contract authority.

Related rules:

- [Feature Lifecycle](FEATURE_LIFECYCLE.md)
- [Documentation Rules](DOCUMENTATION_RULES.md)
- [AI Agent Rules](AI_AGENT_RULES.md)
- [Feature Manifest](../features.yaml)

## Authority boundary

Implementation records are derived from accepted ADRs and approved
Specifications:

```text
Accepted ADRs
      ↓
Approved Specification       normative implementation contract
      ↓
Implementation Plan          ordered work and evidence strategy
      ↓
Implementation Design Notes  selected internal realization
      ↓
Code and tests               executable realization
      ↓
Conformance Report           evidence against acceptance criteria
```

Implementation records MUST NOT introduce architecture, amend a Specification,
or make implementation divergence authoritative. Code names and internal
organization described by a design note remain replaceable unless an accepted
ADR or approved Specification requires them.

## Record types

### Implementation Plan

Major implementation under an approved Specification requires one plan. The
plan maps every acceptance criterion to ordered work and expected evidence. It
records milestones, dependencies, affected modules, tests, integration and
platform work, risks, and upstream blockers.

Store plans in `docs/implementation-plans/` and name them
`spec-NNN-implementation-plan.md`. Copy
`docs/templates/implementation-plan.md`.

Allowed statuses are `draft`, `ready`, `active`, `completed`, and `superseded`.
`ready` means the work is executable without inventing architectural or
contractual intent; it is not an approval gate. `completed` means every planned
task has a recorded disposition; it does not mean the Specification conforms
or is implemented.

### Implementation Design Note (when warranted)

A design note explains a technically significant internal realization. Create
one when a mechanism is difficult to reconstruct from local code or when
implementation review materially benefits from an explicit account of data
structures, ownership, algorithms, data flow, lifecycle, resource behavior,
profile variants, or test seams.

A design note is not required for mechanical, local, or self-explanatory work.
Prefer several focused notes over one class catalogue for an entire
Specification. Do not freeze private type or file names before they help
implementation.

Store notes in `docs/implementation-designs/` and name them
`spec-NNN-<mechanism>.md`. Copy `docs/templates/implementation-design.md`.

Allowed statuses are `draft`, `current`, and `superseded`. `current` means the
note accurately explains the present implementation direction; it does not
make that direction authoritative.

### Conformance Report

Before a Specification may become `implemented`, one conformance report must
map every acceptance criterion to evidence, record required-test and platform
results, identify deviations and approved exceptions, and distinguish
hardware-free evidence from connected-hardware evidence.

Store reports in `docs/conformance/` and name them
`spec-NNN-conformance.md`. Copy `docs/templates/conformance-report.md`.

Allowed statuses are `collecting`, `review`, `complete`, and `superseded`.
`complete` means the evidence record has a disposition for every criterion; it
does not itself authorize the Specification's `implemented` transition.

## Traceability

Each implementation record MUST identify its governing Specification and
feature in front matter. The Specification MUST link its plan, design notes,
and conformance report from `References` or a dedicated implementation section
when those records are created.

Deferred work discovered from an implementation record MUST be linked in that
record's relationship metadata and must name the record path as a source. A
required correctness or conformance item cannot be deferred.

Implementation records are not registered as lifecycle artifacts in
`docs/features.yaml`. The feature entry continues to list the governing
Specification and changes stage only as the Specification moves through
`approved`, `implementing`, conformance, and `implemented`.

Tasks, commits, source files, tests, build logs, and measurements MAY be linked
from implementation records. Evidence links MUST be stable enough for a later
reviewer to reproduce or inspect the claimed result.

When the repository provides a single top-level test/check runner, every
Implementation Plan that introduces a contract driver MUST register that
driver with the top-level runner while preserving the driver's exact
standalone invocation. Registration MUST be explicit and checked in; the
top-level runner MUST NOT silently discover, skip, weaken, or reinterpret a
required driver, profile, compiler check, failure, or evidence output. Its
default invocation SHOULD remain the fast local gate, with slower and cross-
profile checks selected explicitly. Hardware-free aggregation MUST NOT imply
connected-hardware conformance or perform deployment, remote access, or
flashing.

## Decision routing

Use this test whenever planning or implementation exposes a choice:

- A change to public behavior, cross-module contracts, ownership, dependency
  direction, lifecycle semantics, capability or backend obligations,
  deterministic behavior, compatibility, or required resource bounds belongs
  in an ADR or Specification review.
- A replaceable internal realization that satisfies the complete contract may
  be selected and explained in an Implementation Design Note.
- Work ordering, dependencies, and evidence collection belong in the
  Implementation Plan.
- Missing evidence about a candidate technique belongs in an Exploration or
  Spike; Spike code is not production implementation by default.

If implementation cannot satisfy the approved contract, pause the affected
work. Do not edit the plan or design note to conceal the mismatch.

## Pilot workflow

1. Select one approved Specification and verify its complete authority chain.
2. Create a ready Implementation Plan grounded in current source and tests.
3. Mark the Specification `implementing` when authorized implementation work
   actually begins, and set the plan to `active`.
4. Create focused Design Notes only for mechanisms meeting the criteria above.
5. Implement plan tasks and keep task dispositions, notes, and evidence links
   current in the same change that materially invalidates them.
6. Create the Conformance Report, execute required checks, and record every
   criterion's disposition.
7. Request explicit human authorization for the Specification's `implemented`
   transition after conformance review.

The pilot should evaluate whether these records reduce rediscovery, expose
upstream defects early, and remain inexpensive to maintain. Process changes
suggested by the pilot require ordinary documentation review; pilot usage does
not silently redefine these rules.
