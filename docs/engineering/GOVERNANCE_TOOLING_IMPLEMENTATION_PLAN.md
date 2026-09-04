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

Record each step's commit and validation result here as it lands. Final review
must account for all GT-001 through GT-016 criteria and any deliberately
deferred work.
