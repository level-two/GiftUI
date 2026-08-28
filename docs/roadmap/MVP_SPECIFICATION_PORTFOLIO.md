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

- approved RFC-001 through RFC-006 and RFC-008 through RFC-011;
- accepted ADR-001 and ADR-003 through ADR-012, ADR-014 through ADR-033;
- SPEC-001, the Signal Analyzer application contract, currently in `review`;
- the established [MVP Scope](../MVP_SCOPE.md), including the four supported
  configurations and the Signal Analyzer validation progression.

ADR-002 is superseded by ADR-027 and ADR-013 is superseded by ADR-033; neither
is current authority. RFC-007 remains `draft`; its delegated-service direction
and FW-009 MUST NOT become a required MVP Specification dependency.

The `canvas-drawing` feature completed its decision stage with approved RFC-009
and accepted ADR-028 through ADR-031. Wave 5 artifacts SPEC-010 through
SPEC-012 now exist; SPEC-012 is approved, while SPEC-010 and SPEC-011 are in
coordinated amendment review.

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

Wave 2 retains these immutable identities; SPEC-006 was explicitly reapproved
after ADR-033 alignment:

| Candidate key | Allocated Specification | Lifecycle status |
| --- | --- | --- |
| `TEXT` | `SPEC-005` | `approved` |
| `DECLARATIVE` | `SPEC-006` | `approved` |

SPEC-005 and SPEC-006 are parallel sibling contracts. SPEC-005 owns exact text
resource identities, compatible resource views, and resource lifetimes;
SPEC-006 owns declarative expansion, ordered modifiers, structural identity,
the bounded public action-value protocol, and action identity. Neither
Specification depends on or redefines the other.

Wave 3 has completed coordinated approval with these immutable identities:

| Candidate key | Allocated Specification | Lifecycle status |
| --- | --- | --- |
| `LAYOUT` | `SPEC-007` | `approved` |
| `RENDERING` | `SPEC-008` | `approved` |

SPEC-007 owns proposal-based measurement, placement, canonical text geometry,
and resolved occurrence bounds. SPEC-008 owns public text/color/style meaning,
shared runtime-neutral lowering, and normalized ordered render operations. The
physical semantic, layout, and backend-facing render-core modules remain
separate; `GiftUIRenderLowering` joins semantic and layout results above
`GiftUIRenderCore` without exposing either authority to backends.

Wave 4 retains this immutable identity. SPEC-009's previously approved
contract now has a focused-owner failure-carrier amendment in renewed review:

| Candidate key | Allocated Specification | Lifecycle status |
| --- | --- | --- |
| `EXECUTION` | `SPEC-009` | `review` |

SPEC-009 owns the serialized run cycle, sealed admission, publication and
dirty-recovery boundaries, execution provenance, synchronous one-shot frame
handoff, refusal convergence, and presentation-coupled input admission
machinery. It leaves observable-state storage, public interaction declarations
and action lowering, concrete runtime-profile storage, backend realization,
and host policy values to their downstream portfolio contracts.

Wave 5 retains these immutable artifacts. SPEC-010 and SPEC-011 have
coordinated candidate-target amendments in renewed review:

| Candidate key | Allocated Specification | Lifecycle status |
| --- | --- | --- |
| `OBSERVABLE` | `SPEC-010` | `review` |
| `INTERACTION` | `SPEC-011` | `review` |
| `DRAWING` | `SPEC-012` | `approved` |

SPEC-012 remains approved. The amended SPEC-009 through SPEC-011 contracts are
not authoritative again until explicit renewed human approval.

Wave 6 has produced these immutable artifacts:

| Candidate key | Allocated Specification | Lifecycle status |
| --- | --- | --- |
| `RUNTIME-PROFILES` | `SPEC-013` | `review` |
| `BACKEND-INTEGRATION` | `SPEC-014` | `draft` |

Both artifacts are reconciled to approved SPEC-012. SPEC-013's completeness
review produced the coordinated SPEC-009 through SPEC-011 amendments; all four
must receive their next explicit human approval before SPEC-013 can govern
implementation. SPEC-014 remains `draft` and also observes the SPEC-009 gate.

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
| `EXECUTION`           | Sealed run-cycle admission, mutation/publication phases, frame identity and provenance, synchronous one-shot handoff, refusal recovery, pointer sequencing, identity-generation capture, and presentation-coupled input admission | ADR-010 through ADR-012, ADR-014 through ADR-016, ADR-033 | `FOUNDATION`, `FAILURE`, `DECLARATIVE`, `LAYOUT`, `RENDERING` | A scripted runtime coordinator, recording backend, and fake wake/input endpoints verify at-most-once effects, commit/refusal, dirty rederivation, stale-input cancellation, action/model-target generation mismatch, and finite retry policy |
| `DRAWING`             | Laid-out Canvas declaration and invocation, scoped graphics context and uniquely owned transient Path construction, cycle-local immutable plans, canonical straight-line stroke lowering, structural capacities, and pre-offer failure | ADR-028 through ADR-031                                                                       | `FOUNDATION`, `FAILURE`, `CAPABILITY`, `DECLARATIVE`, `LAYOUT`, `RENDERING`, `EXECUTION` | Recording plan and operation sinks verify resolved-size invocation, scoped lifetime, snapshot isolation, painter order, checked local-to-surface geometry, inherited clipping, canonical caps and joins, exhaustion, whole-plan discard, and dynamic/static source equivalence without pixels or hardware |
| `OBSERVABLE`          | Portable observable `@State`, structural ownership, registration, replacement/removal, coarse invalidation, bounded dynamic/static realization, and Signal Analyzer Presentation-fact admission      | ADR-024 through ADR-027, plus ADR-011 and ADR-014 through ADR-016                             | `FOUNDATION`, `FAILURE`, `DECLARATIVE`, `EXECUTION`                   | Shared model/location fixtures and a fake bounded admission endpoint verify identity, teardown, coalescing, phase violations, exhaustion, stale reports, and application-to-mutation-domain ordering without a backend       |
| `INTERACTION`         | Finite typed `Button` actions, `disabled`, bounded action/model-target records and generations, identity-generation capture without action/model retention, normalized-event behavior, and current-model handler dispatch | ADR-005, ADR-006, ADR-011, ADR-033 | `FOUNDATION`, `DECLARATIVE`, `LAYOUT`, `EXECUTION`, `OBSERVABLE` | Normalized pointer fixtures verify disabled behavior, exact identity-generation matching, model-replacement cancellation, final target revalidation, ordering, and dynamic/static source equivalence without a platform driver |
| `RUNTIME-PROFILES`    | Dynamic and static runtime storage/composition, semantic-to-layout-to-render coordination, declared capacities, Canvas/Path/plan workspace ownership, and shared conformance suite                    | ADR-005 through ADR-016, ADR-024 through ADR-026, ADR-028, ADR-029, ADR-031                    | `LAYOUT`, `RENDERING`, `EXECUTION`, `DRAWING`, `OBSERVABLE`, `INTERACTION` | The same small hierarchies and Canvas fixtures execute through both profiles into recording sinks; tests compare semantics, failures, operation order, bounds, snapshot behavior, allocation behavior, and omitted facilities |
| `BACKEND-INTEGRATION` | Backend SPI, raster/surface contracts, synchronous reservation and consumption, canonical pixel encoding, canonical straight-line stroke realization, payload lifetime, display-target boundary, and backend-local health | ADR-005 through ADR-007, ADR-010, ADR-014 through ADR-016, ADR-020 through ADR-023, ADR-030, ADR-031 | `FAILURE`, `CAPABILITY`, `TEXT`, `RENDERING`, `EXECUTION`, `DRAWING` | Golden operation streams run through recording, framebuffer, and bounded RGB565/tile fixtures; fake display targets verify reservation, transfer lifetime, stroke rasterization, refusal, clipping, quantization, borrowed-address isolation, and post-handoff isolation |
| `HOST-CONFIGURATION`  | Immutable target-host assembly, structural validation, action-domain/handler/root-model binding, capability resolution, Canvas producer capacities, environmental contracts, input/display coordination, finite pacing policy, and the four MVP configuration obligations | ADR-006 through ADR-008, ADR-012, ADR-015 through ADR-020, ADR-023, ADR-026, ADR-027, ADR-031, ADR-033 | `CAPABILITY`, `DRAWING`, `OBSERVABLE`, `RUNTIME-PROFILES`, `BACKEND-INTEGRATION` | Hardware-free host fixtures prove graph validation, bounded action wiring, independent conjunctive Canvas structural-capacity and `rasterPresentation` gates, policy completeness, profile selection, and dependency direction; connected-target evidence remains a later conformance gate |

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
         FOUNDATION + FAILURE + CAPABILITY
                    + DECLARATIVE + LAYOUT
                    + RENDERING + EXECUTION --------> DRAWING

Wave 6:  LAYOUT + RENDERING + EXECUTION + DRAWING
                    + OBSERVABLE + INTERACTION ----> RUNTIME-PROFILES
         FAILURE + CAPABILITY + TEXT + RENDERING
                    + EXECUTION + DRAWING ----------> BACKEND-INTEGRATION

Wave 7:  CAPABILITY + DRAWING + OBSERVABLE + RUNTIME-PROFILES
                    + BACKEND-INTEGRATION ---------> HOST-CONFIGURATION
```

The wave labels indicate the earliest safe drafting start. Specifications in
one wave may be drafted in parallel only when every incoming prerequisite has
at least a complete review-ready draft whose referenced declarations and
semantics are stable enough for downstream use. Approval remains independent:
a downstream draft may explore integration, but it MUST NOT be approved before
all of its authoritative prerequisite Specifications are approved.

## Drawing and Application Integration

The Canvas branch has completed its architecture gates and is now part of the
main drafting graph. It may enter Specification drafting in Wave 5 once the
contracts it extends are stable:

```text
PROPOSAL-006 accepted
        |
        v
RFC-009 approved -> ADR-028...ADR-031 accepted -> `DRAWING` Specification
                                      ^                 |
FOUNDATION + FAILURE + CAPABILITY -----|                 v
DECLARATIVE + LAYOUT + RENDERING ------|        RUNTIME-PROFILES
EXECUTION -----------------------------'        BACKEND-INTEGRATION
                                                       |
CAPABILITY + DRAWING + OBSERVABLE ---------------------|
RUNTIME-PROFILES + BACKEND-INTEGRATION ----------------+--> HOST-CONFIGURATION
                                                              |
DRAWING + OBSERVABLE + INTERACTION + HOST-CONFIGURATION ------+--> SPEC-001 approval
```

The future `DRAWING` Specification should define only the MVP Canvas, graphics
context, path, stroke, solid shading, cycle-local plan, normalized stroke, and
drawing-geometry contract required by the Signal Analyzer. It must also define
the producer side of the independent B2 structural-capacity gate without
adding Canvas construction capacity to SPEC-004's closed capability
vocabulary. Its tests should lower deterministic paths into recording plans
and render-operation sinks and validate geometry, clipping, stroke semantics,
scoped lifetimes, capacity errors, whole-plan discard, and profile-equivalent
bounds without requiring pixels or hardware.

`DRAWING` owns portable drawing meaning, plan construction, normalized stroke
payload, and producer obligations. `RUNTIME-PROFILES` owns concrete dynamic
and static storage realization; `BACKEND-INTEGRATION` owns raster realization
and synchronous consumption; `HOST-CONFIGURATION` owns assembled startup
validation. Those downstream contracts reference `DRAWING` rather than
redefining it.

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
5. Draft `OBSERVABLE`, `INTERACTION`, and `DRAWING` in parallel once their
   distinct prerequisites are stable. `DRAWING` must use approved RFC-009 and
   accepted ADR-028 through ADR-031 without allocating an implementation plan
   before its Specification is approved.
6. Reconcile and review `RUNTIME-PROFILES` (SPEC-013) and
   `BACKEND-INTEGRATION` (SPEC-014) against approved SPEC-012's plan,
   operation, capacity, and lifetime contracts before advancing either draft.
7. Draft `HOST-CONFIGURATION`, including the independent conjunctive Canvas
   structural-capacity and `rasterPresentation` capability startup gates.
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
