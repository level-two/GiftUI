# SPEC-006 Authority and Fixture Audit

Plan task: `T0.1`

Date: 2026-09-04

## Lifecycle authority

The complete implementation gate is present and authoritative:

| Artifact | Evidenced status | Relationship |
| --- | --- | --- |
| PROPOSAL-003 | accepted | lists SPEC-006 |
| RFC-002 | approved | lists SPEC-006 |
| RFC-004 | approved | lists SPEC-006 |
| RFC-010 | approved | lists SPEC-006 |
| RFC-011 | approved | lists SPEC-006 |
| ADR-005 | accepted | lists SPEC-006 |
| ADR-006 | accepted | lists SPEC-006 |
| ADR-008 | accepted | lists SPEC-006 |
| ADR-032 | accepted | lists SPEC-006 |
| ADR-033 | accepted | lists SPEC-006 |
| SPEC-002 | implementing approved contract | lists SPEC-006 |
| SPEC-003 | implementing approved contract | lists SPEC-006 |
| SPEC-010 | approved | lists SPEC-006 |
| SPEC-006 | implementing approved contract | links the chain above |
| SPEC-006 implementation plan | active | points to SPEC-006 |

`docs/features.yaml` registers SPEC-006 under `giftui-mvp-architecture`, whose
stage is already `implementation`. Starting this sibling contract therefore
requires no manifest-stage change. SPEC-007 through SPEC-013 retain their
separate downstream ownership; this audit grants no authority to implement
their contracts through SPEC-006.

## Acceptance and scope audit

SPEC-006 and its plan contain exactly fifteen ordered acceptance labels,
`DV-001` through `DV-015`. The implementation boundary is Rank 0 declaration
composition and deterministic bounded semantic expansion. It excludes layout,
rendering, concrete controls or modifiers, state ownership and invalidation,
activation and input, capability resolution, backends, frame coordination,
runtime-profile budgets, host policy, deployment, and connected hardware.

The Signal Analyzer MVP requires one non-trivial portable Presentation with
reusable custom views, fixed child composition, conditional and optional
content, and modifier chaining across the four exact MVP configurations.
SPEC-006 is the approved semantic foundation for that scope requirement.

## Deferred-work audit

FW-017 and FW-020 are both `captured`, name SPEC-006 as a source, remain
post-MVP, and have concrete revisit triggers. SPEC-006 reciprocally lists both
items. Neither is triggered by implementation start: no public binding,
dynamic collection, keyed identity, public type erasure, public custom
modifier, or client-visible identity is required or introduced.

## Fixture boundary

The fixture README, empty ordered compile registry, ordered input registry,
canonical transcript schema, normalized result schema, deterministic generated
and report roots, and separate host, cross-built, simulator, and connected-
target labels are checked in. Empty registries are intentional fail-closed
baselines and will gain rows only with their owning implementation tasks.

No production target, declaration API, semantic implementation, driver,
remote access, deployment, service restart, simulator execution, or flashing
was introduced by this audit.
