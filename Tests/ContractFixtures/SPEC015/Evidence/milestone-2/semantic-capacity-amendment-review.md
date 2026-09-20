# SPEC-013 / SPEC-015 Semantic-Capacity Amendment Review

**ready for human approval consideration** — no architecture change is
introduced. The amendment separates profile-owned retained semantic structure
from SPEC-006 semantic-node counting and uses direct production traversal of
the already approved SPEC-001 hierarchy.

## Evidence reviewed

- The diagnostic-absent hierarchy measures 47 semantic nodes, 14 body
  evaluations, 5 modifiers, 6 actions, depth 26, 80 retained structural
  identities, and 5 Canvas occurrences.
- The diagnostic-present hierarchy measures 48 semantic nodes with the same
  body/modifier/action/depth/Canvas values and 81 retained structural
  identities.
- The formerly approved limit of depth 12 deterministically returns
  `capacityExhausted` before publication.
- Existing SPEC-013 semantic byte projections encode 32 bytes per Dynamic
  structural record and 24 bytes per Static structural record. Applying those
  established projections to 81 records yields 2,592 and 1,944 bytes.

## Review findings

No accepted ADR is contradicted. ADR-006 profile equivalence is strengthened
because both profiles receive the same explicit structural count. ADR-008
ownership remains in Runtime Core and the target host. SPEC-006 semantic-node
meaning is unchanged. SPEC-008 render structure remains separately bounded.

The amendment is source-breaking package SPI: schema 3 and every
`RuntimeProfileLimits`/`RuntimeStorageCapacities` construction must supply the
new value. Exact-limit, first-excess, freshness, four-preset comparison, and
resource-audit tests are required before the implementation can claim the
amendment complete.

## Approval record

The maintainer explicitly requested on 2026-09-20 that SPEC-015 and SPEC-013
be made approved and that implementation proceed. The amended Specifications
therefore remain authoritative at `implementing` status under that explicit
reapproval; this review does not claim either Specification is implemented.
