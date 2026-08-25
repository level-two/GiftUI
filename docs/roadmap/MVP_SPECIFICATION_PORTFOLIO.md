# GiftUI MVP Specification Portfolio

**Status:** Proposed drafting portfolio

**Authority:** Planning only; this document does not create a Specification,
allocate a `SPEC-NNN` identity, approve a contract, or authorize implementation

## Purpose

This portfolio decomposes the accepted GiftUI MVP architecture into candidate
implementation contracts and orders their drafting so that each Specification
can name stable upstream contracts and define tests that do not require an
unfinished downstream implementation.

The portfolio follows the [MVP Milestones](MVP_MILESTONES.md), but drafting
order is a dependency graph rather than a single serial queue. A candidate
becomes a lifecycle artifact only when its draft is created from the canonical
[Specification template](../templates/spec.md), assigned the next available
immutable ID, and registered in [the feature manifest](../features.yaml).

## Lifecycle Baseline

The current authoritative inputs are:

- approved RFC-001 through RFC-006, RFC-008, and RFC-009;
- accepted ADR-001 and ADR-003 through ADR-031;
- SPEC-001, the Signal Analyzer application contract, currently in `review`;
- the established [MVP Scope](../MVP_SCOPE.md), including the four supported
  configurations and the Signal Analyzer validation progression.

ADR-002 is superseded by ADR-027 and is not current authority. RFC-007 remains
`draft`; its delegated-service direction and FW-009 MUST NOT become a required
MVP Specification dependency.

The `canvas-drawing` feature is at the decision stage with approved RFC-009 and
accepted ADR-028 through ADR-031. An approved drawing Specification is its next
missing gate.

## Boundary Rules

Each candidate Specification in this portfolio MUST:

1. own one coherent observable contract rather than mirror a source directory;
2. name all producer and consumer obligations at its boundaries;
3. define profile-neutral semantics before profile-specific realization;
4. provide a test harness that can use fakes, fixtures, or recording endpoints
   instead of requiring downstream modules or connected hardware;
5. expose explicit finite capacities, failure outcomes, and lifetime rules
   wherever static or embedded conformance depends on them;
6. distinguish contract tests from later implementation and target-integration
   evidence; and
7. return any newly discovered architectural choice to RFC/ADR work.

## Candidate Contracts

Wave 1 has completed coordinated approval with these immutable identities:

| Candidate key | Allocated Specification | Lifecycle status |
| --- | --- | --- |
| `FOUNDATION` | `SPEC-002` | `approved` |
| `FAILURE` | `SPEC-003` | `approved` |
| `CAPABILITY` | `SPEC-004` | `approved` |

The three Specifications share one ownership rule: SPEC-002 owns portable values and
import boundaries; SPEC-003 owns outcome, containment, disposition, health,
and diagnostic vocabulary; SPEC-004 owns capability contribution, resolution,
and the `rasterPresentation` catalogue while referencing the first two
contracts instead of redefining them.

Wave 2 has entered coordinated drafting and review with these immutable
identities:

| Candidate key | Allocated Specification | Lifecycle status |
| --- | --- | --- |
| `TEXT` | `SPEC-005` | `review` |
| `DECLARATIVE` | `SPEC-006` | `draft` |

SPEC-005 and SPEC-006 are parallel sibling contracts. SPEC-005 owns exact text
resource identities, compatible resource views, and resource lifetimes;
SPEC-006 owns declarative expansion, ordered modifiers, structural identity,
and action identity. Neither Specification depends on or redefines the other.

Candidate keys are planning labels, not reserved Specification IDs.

| Key                   | Candidate contract                                                                                                                                                                                   | Governing decisions                                                                           | Draft prerequisites                                                   | Independent acceptance seam                                                                                                                                                                                                  |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `FOUNDATION`          | Portable values, checked geometry, normalized input values, package topology, visibility, and import boundaries                                                                                      | ADR-005 through ADR-009                                                                       | None beyond accepted decisions                                        | Compile fixtures and dependency-graph tests; checked-arithmetic and value-semantic unit tests require no runtime or backend                                                                                                  |
| `FAILURE`             | Bounded cross-layer outcomes, containment, layered disposition, operational health projection, and diagnostics                                                                                       | ADR-014 through ADR-016                                                                       | None beyond accepted decisions                                        | Pure outcome mapping, policy-totality, containment, and diagnostic-isolation fixtures with no renderer or runtime implementation                                                                                             |
| `CAPABILITY`          | Typed capability contribution, bounded host resolution, immutable effective results, and the `rasterPresentation` catalogue                                                                          | ADR-017 through ADR-020                                                                       | None beyond accepted decisions; use accepted normalized fixtures      | Pure order-independent resolution fixtures, absence/failure cases, and static zero-allocation/resource evidence                                                                                                              |
| `TEXT`                | Exact font-resource identities, canonical metrics/shaping and raster-resource views, compatible concrete resource sets, and positioned-glyph resource lifetime                                       | ADR-021 through ADR-023                                                                       | `FOUNDATION`                                                          | Licensed-resource fixture validation, deterministic geometry data, mismatch rejection, and bounded static-resource tests without a concrete backend                                                                          |
| `DECLARATIVE`         | Rank 0 client declarations, fixed builder composition, custom views, ordered modifier semantics, semantic identity, action identity, and structural expansion                                        | ADR-005, ADR-006, ADR-008                                                                     | `FOUNDATION`, `FAILURE`                                               | Recording semantic-tree fixtures compare identity, expansion, modifier order, capacity failure, and dynamic/static source equivalence without layout                                                                         |
| `LAYOUT`              | Proposal-based stacks, spacer, spacing, alignment, padding, frame constraints, checked placement, hit geometry, and canonical text layout                                                            | ADR-005, ADR-006, ADR-009, ADR-021, ADR-023                                                   | `FOUNDATION`, `TEXT`, `DECLARATIVE`                                   | Table-driven measurement and placement fixtures use a semantic-child adapter and canonical metric provider; no pixel backend is needed                                                                                       |
| `RENDERING`           | Rank 2 text/color/foreground/background semantics, normalized ordered render operations, positioned glyphs, clipping/damage, line operations, streamability, and semantic-to-render lowering         | ADR-005, ADR-006, ADR-021 through ADR-023                                                     | `FOUNDATION`, `TEXT`, `DECLARATIVE`, `LAYOUT`, `FAILURE`              | A recording operation sink verifies golden ordered operations, bounds, clips, exact resource identities, overflow, and profile equivalence without rasterization                                                             |
| `EXECUTION`           | Sealed run-cycle admission, mutation/publication phases, frame identity and provenance, synchronous one-shot handoff, refusal recovery, pointer sequencing, and presentation-coupled input admission | ADR-010 through ADR-016                                                                       | `FOUNDATION`, `FAILURE`, `DECLARATIVE`, `LAYOUT`, `RENDERING`         | A scripted runtime coordinator, recording backend, and fake wake/input endpoints verify at-most-once effects, commit/refusal, dirty rederivation, stale-input cancellation, and finite retry policy                          |
| `OBSERVABLE`          | Portable observable `@State`, structural ownership, registration, replacement/removal, coarse invalidation, bounded dynamic/static realization, and Signal Analyzer Presentation-fact admission      | ADR-024 through ADR-027, plus ADR-011 and ADR-014 through ADR-016                             | `FOUNDATION`, `FAILURE`, `DECLARATIVE`, `EXECUTION`                   | Shared model/location fixtures and a fake bounded admission endpoint verify identity, teardown, coalescing, phase violations, exhaustion, stale reports, and application-to-mutation-domain ordering without a backend       |
| `INTERACTION`         | Public `Button` and `disabled` declarations, enabled-state lowering, stable action capture, normalized-event behavior, and activation semantics                                                      | ADR-005, ADR-006, ADR-011, ADR-013                                                            | `FOUNDATION`, `DECLARATIVE`, `LAYOUT`, `EXECUTION`                    | Normalized pointer fixtures drive recording hit maps and action sinks to verify disabled behavior, down/up identity, stale or cancelled sequences, ordering, and dynamic/static source equivalence without a platform driver |
| `RUNTIME-PROFILES`    | Dynamic and static runtime storage/composition, semantic-to-layout-to-render coordination, declared capacities, workspace ownership, and shared conformance suite                                    | ADR-005 through ADR-016 and ADR-024 through ADR-026                                           | `LAYOUT`, `RENDERING`, `EXECUTION`, `OBSERVABLE`, `INTERACTION`       | The same small hierarchies execute through both profiles into recording sinks; tests compare semantics, failures, operation order, bounds, allocation behavior, and omitted facilities                                       |
| `BACKEND-INTEGRATION` | Backend SPI, raster/surface contracts, synchronous reservation and consumption, canonical pixel encoding, payload lifetime, display-target boundary, and backend-local health                        | ADR-005 through ADR-007, ADR-010, ADR-014 through ADR-016, ADR-020 through ADR-023            | `FAILURE`, `CAPABILITY`, `TEXT`, `RENDERING`, `EXECUTION`             | Golden operation streams run through recording, framebuffer, and bounded RGB565/tile fixtures; fake display targets verify reservation, transfer lifetime, refusal, clipping, quantization, and post-handoff isolation       |
| `HOST-CONFIGURATION`  | Immutable target-host assembly, structural validation, capability resolution, environmental contracts, input/display coordination, finite pacing policy, and the four MVP configuration obligations  | ADR-006 through ADR-008, ADR-012, ADR-013, ADR-015 through ADR-020, ADR-023, ADR-026, ADR-027 | `CAPABILITY`, `OBSERVABLE`, `RUNTIME-PROFILES`, `BACKEND-INTEGRATION` | Hardware-free host fixtures prove graph validation, policy completeness, capability compatibility, profile selection, and dependency direction; connected-target evidence remains a later conformance gate                   |

`FOUNDATION` defines only portable values and ownership boundaries. It MUST NOT
absorb declarative semantics merely because those declarations reside in the
same stable `GiftUI` module. Likewise, `BACKEND-INTEGRATION` specifies reusable
backend and integration contracts, not the behavior of a particular board or
operating system.

## Drafting Graph

```text
Wave 1:  FOUNDATION            FAILURE              CAPABILITY

Wave 2:  FOUNDATION ------------------------------> TEXT
         FOUNDATION + FAILURE --------------------> DECLARATIVE

Wave 3:  FOUNDATION + TEXT + DECLARATIVE ---------> LAYOUT
         FOUNDATION + TEXT + DECLARATIVE
                    + LAYOUT + FAILURE ------------> RENDERING

Wave 4:  FOUNDATION + FAILURE + DECLARATIVE
                    + LAYOUT + RENDERING ----------> EXECUTION

Wave 5:  FOUNDATION + FAILURE + DECLARATIVE
                    + EXECUTION -------------------> OBSERVABLE
         FOUNDATION + DECLARATIVE + LAYOUT
                    + EXECUTION -------------------> INTERACTION
         FAILURE + CAPABILITY + TEXT + RENDERING
                    + EXECUTION -------------------> BACKEND-INTEGRATION

Wave 6:  LAYOUT + RENDERING + EXECUTION
                    + OBSERVABLE + INTERACTION ----> RUNTIME-PROFILES

Wave 7:  CAPABILITY + OBSERVABLE + RUNTIME-PROFILES
                    + BACKEND-INTEGRATION ---------> HOST-CONFIGURATION
```

The wave labels indicate the earliest safe drafting start. Specifications in
one wave may be drafted in parallel only when every incoming prerequisite has
at least a complete review-ready draft whose referenced declarations and
semantics are stable enough for downstream use. Approval remains independent:
a downstream draft may explore integration, but it MUST NOT be approved before
all of its authoritative prerequisite Specifications are approved.

## Drawing and Application Branch

The Canvas branch cannot yet enter Specification drafting:

```text
PROPOSAL-006 accepted
        |
        v
Canvas RFC -> accepted Canvas ADRs -> `DRAWING` Specification
                                      |
FOUNDATION + LAYOUT + RENDERING -------'
                                      |
OBSERVABLE + HOST-CONFIGURATION -------+--> SPEC-001 approval and full MVP
```

The future `DRAWING` Specification should define only the MVP Canvas, graphics
context, path, stroke, solid shading, and drawing-geometry contract required by
the Signal Analyzer. Its tests should lower deterministic paths into recording
render-operation sinks and validate geometry, clipping, stroke semantics,
capacity errors, and static bounds without requiring pixels or hardware.

SPEC-001 remains the application-level integration contract. Its Domain, Data,
capture, and portable Presentation behavior can be reviewed independently,
but its framework-facing acceptance criteria cannot be closed until the
approved reusable contracts for declarative composition, layout, rendering,
execution, observable state, interaction, drawing, runtime profiles, backend
integration, and host configuration exist.

## Recommended Drafting Sequence

1. Draft `FOUNDATION`, `FAILURE`, and `CAPABILITY` in parallel.
2. Draft `TEXT` and `DECLARATIVE` as soon as their Wave 1 inputs are stable.
3. Draft `LAYOUT`, then `RENDERING`; keep their recording fixtures reusable by
   later runtime and backend conformance suites.
4. Draft `EXECUTION` after the layout and rendering contracts stabilize.
5. Draft `OBSERVABLE`, `INTERACTION`, and `BACKEND-INTEGRATION` in parallel
   once their distinct prerequisites are stable.
6. Draft `RUNTIME-PROFILES`, followed by `HOST-CONFIGURATION`.
7. In parallel with Steps 1 through 6, complete the Canvas RFC and ADR gates;
   draft `DRAWING` only after those decisions are accepted and its framework
   prerequisites are stable.
8. Reconcile SPEC-001 against the approved reusable contracts, then request
   human approval. Implementation planning starts only from approved Specs.

## Portfolio-Level Verification

Before the first portfolio Specification is submitted for approval, reviewers
should verify that:

- every active accepted ADR is governed by at least one candidate contract or
  by SPEC-001;
- every candidate has a non-hardware test seam and measurable capacity and
  failure criteria where applicable;
- producer/consumer terminology is identical across prerequisite and dependent
  drafts;
- no candidate imports a downstream implementation merely to make its tests
  executable;
- shared conformance fixtures are owned once and consumed by both profile or
  backend implementations;
- connected Raspberry Pi and nRF52840 checks appear only as downstream
  conformance evidence and are not confused with independent contract tests;
  and
- RFC-007, deferred work, legacy documents, and proof-of-concept code remain
  non-authoritative inputs.

## References

- [Feature Lifecycle](../engineering/FEATURE_LIFECYCLE.md)
- [Documentation Rules](../engineering/DOCUMENTATION_RULES.md)
- [AI Agent Rules](../engineering/AI_AGENT_RULES.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [MVP Milestones](MVP_MILESTONES.md)
- [Feature Manifest](../features.yaml)
- [Specification Template](../templates/spec.md)
