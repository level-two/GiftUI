# Governance Tooling Implementation Plan

**Status:** Active repository-engineering plan

**Source:** [Governance Tooling Improvements](GOVERNANCE_TOOLING_IMPROVEMENTS.md)

**Created:** 2026-09-04

**Lifecycle classification:** Lightweight repository maintenance; this plan is
operational and does not create product architecture or contract authority

## Delivery Strategy

Implementation follows the seven migration steps in the source specification.
Each step is independently reviewable, tested at its narrowest useful gate,
and committed before the next step begins.

| Step | Deliverable | Primary criteria | Commit gate |
| --- | --- | --- | --- |
| 1 | Authority graph generator, schema validation, and graph fixtures | GT-001–GT-003 | Governance-tooling graph tests and governance validation |
| 2 | SPEC-005 task-evidence schema, manifest, and validator | GT-006–GT-007 | Task-evidence tests and SPEC-005 manifest validation |
| 3 | Deterministic Markdown/JSON task context packs | GT-004–GT-005 | Context-pack tests for T5.1 and blocked T4.4 |
| 4 | Immutable SPEC-005 report identities and publication | GT-008–GT-010 | Report-identity tests and migrated host profile |
| 5 | Compiler-fixture module isolation | GT-011 | Fixture-isolation tests in forward and reverse order |
| 6 | Focused/profile/Specification/repository gates and SwiftPM wrapper | GT-012–GT-014 | Wrapper tests, focused gate, and fast repository gate |
| 7 | Remaining registered Specification migration and documentation | GT-015–GT-016 | Governance, formatter, tooling, registered profile, and repository gates |

## Constraints

- Product modules, public APIs, runtime behavior, lifecycle statuses, and
  accepted architecture remain unchanged.
- Generated graph, context, and report artifacts stay under `.build/` and are
  navigation or evidence aids only.
- Existing standalone contract-driver commands remain valid throughout the
  migration.
- Hardware-free validation does not claim connected-hardware evidence and does
  not deploy, restart, or flash anything.
- A failed step remains uncommitted until its focused gate passes.

## Completion Record

| Step | Commit(s) | Validation result |
| --- | --- | --- |
| Plan | `b788af7` | Seven independently reviewable migrations recorded before implementation |
| 1 | `6286a08` | Authority graph fixtures and integrated governance validation pass |
| 2 | `106d2eb` | SPEC-005 manifest and task-evidence validator pass |
| 3 | `ee00227` | Deterministic Markdown/JSON context-pack tests pass for completed and blocked tasks |
| 4 | `67c9d1c` | SPEC-005 immutable publication and mixed-identity tests pass across four profiles |
| 5 | `c2d858d` | Fixture-local module allowlists pass in forward and reverse build order |
| 6 | `b80520d` | Focused/profile/Specification/repository gates and SwiftPM wrapper tests pass |
| 7 | `b110793`, `ccb28b9`, `47e9f2b`, plus the final transition-removal change | SPEC-002, SPEC-003, and SPEC-004 manifests validate and stable macOS profile commands publish immutable reports |

Final validation must account for GT-001 through GT-016 from a clean checkout.
Connected-target execution remains governed by the relevant product
Specifications and is not part of this tooling initiative.
