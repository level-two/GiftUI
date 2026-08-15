# Specifications

Specifications define precise, implementable, and testable contracts derived
from accepted ADRs. Only approved, implementing, or implemented
Specifications govern implementation.

- Canonical semantics and statuses: [Documentation Rules](../engineering/DOCUMENTATION_RULES.md)
- Lifecycle gates: [Feature Lifecycle](../engineering/FEATURE_LIFECYCLE.md)
- Starting point: [Specification template](../templates/spec.md)

Use filenames of the form `spec-NNN-short-slug.md`. Link every governing ADR,
define acceptance criteria, and update `docs/features.yaml`.

Optional optimizations or extensions discovered during authoring belong in
linked [Future Work](../future-work/README.md), not in the approved contract or
its required acceptance criteria.
