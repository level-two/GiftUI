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

## Current portfolio

- [RFC-014 coordinated amendments](../iterations/iteration-003-review/rfc-014-spec-amendment-review.md):
  SPEC-001/002/006/007/010/011/012/013/015 are **approved** under accepted ADR-035/036/037; see the
  [approval record](../iterations/iteration-003-review/rfc-014-spec-approval.md). Their prior implemented baseline is
  preserved at `53740a73`; old evidence does not establish amended conformance.
- SPEC-003/004/005/008/009/014 retain their existing implemented status and
  approval/exception records. They are unchanged by these amendments.
- SPEC-001 through SPEC-015 are allocated; each document's metadata is the current
  status source. No additional Specification ID is introduced by this package.
