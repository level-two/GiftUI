# SPEC-010 Authority and Fixture Audit

Plan task: `T0.1`

Date: 2026-09-04

## Lifecycle authority

| Artifact | Evidenced status | Relationship |
| --- | --- | --- |
| PROPOSAL-005 | accepted | authorizes observable-reference-state design |
| RFC-008 | approved | owns observable-state architecture |
| RFC-011 | approved | owns bounded model-target action integration |
| ADR-008, ADR-011 | accepted | own module direction and publication |
| ADR-014 through ADR-016 | accepted | own outcomes, disposition, diagnostics |
| ADR-024 through ADR-027 | accepted | own state, invalidation, profiles, facts |
| ADR-033 | accepted | owns bounded model-target dispatch |
| SPEC-010 | implementing approved contract | exact implementation authority |
| SPEC-010 implementation plan | active | ordered tasks and evidence |

SPEC-010 and its plan contain exactly twelve acceptance labels, `OS-001`
through `OS-012`. `docs/features.yaml` now records the feature at
`implementation`. No architecture, contract, or human approval is inferred by
this progress transition.

## MVP and dependency boundary

The Signal Analyzer requires one preserved observable root model whose Start,
Stop, Clear, acquisition, error, capture, and window changes update the same
portable Presentation across all four MVP configurations.

SPEC-006 owns traversal and structural identity; SPEC-009 owns execution
phases, wake/admission, and the opaque target-generation declaration; SPEC-011
owns Interaction consumption; SPEC-013 and SPEC-015 own production profiles,
capacities, and host assembly. Their missing implementations remain upstream
or downstream blockers, not permission for SPEC-010 substitutes.

## Spike and deferred-work boundary

SPIKE-003 and SPIKE-006 are completed feasibility evidence only. Their typed
handles, routes, storage, declarations, widths, and resource deltas are not
production authority. FW-019 remains captured and untriggered; no property-
level dependency graph or selective subtree reevaluation enters this plan.

## Fixture boundary

The checked-in compile, macro-expansion, semantic transcript, normalized
result, and required-evidence registries are intentionally empty or pending.
The harness validates exact schemas, unique IDs, exact OS-001 through OS-012
coverage, and fail-closed pending state. No production target, declaration,
macro, runtime, remote access, deployment, service restart, simulator run, or
flashing is introduced by T0.1.
