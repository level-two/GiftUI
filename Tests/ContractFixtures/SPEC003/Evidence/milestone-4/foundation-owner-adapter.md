# SPEC-003 Milestone 4 Foundation Owner-Adapter Evidence

This record covers `SPEC-003 T4.1` and coordinates with the active SPEC-002
Milestone 4 boundary without claiming that a later production integration
owner already exists.

## Evidence seam

`GiftUIFoundationFailureAdapterTests` is a test-only producer-side adapter
target. It is the only current package target intentionally importing both
`GiftUI` and `GiftUIFailureCore`. No production target or public product was
introduced, so later execution, integration, and host Specifications retain
ownership of their first production adapters.

The exact package allow-list records both test-only edges. The SPEC-003
boundary contract separately keeps `GiftUIFailureCore` dependency-free, and
the existing source/interface/product-link audit rejects any `GiftUI` import
or re-export from that leaf.

## Frozen mapping corpus

Focused tests prove all four SPEC-002/SPEC-003 mapping rows after the local
Foundation operation rejects and without exposing a partial value:

- negative `Size` dimensions and negative present `ProposedSize` dimensions
  map to `.invalidValue`;
- checked scalar arithmetic overflow maps to `.arithmeticOverflow`;
- an unrepresentable rectangle exclusive edge maps to
  `.arithmeticOverflow`; and
- physical-to-logical conversion outside `GeometryScalar` maps to
  `.arithmeticOverflow`.

Every mapped fact uses `.foundation` origin, `.operation` affected scope, and
`.contained` containment. Positive controls prove that valid values are
returned complete and unchanged.

## Validation

- `swift test`
- `scripts/contracts/run-spec-002.sh --profile macos-dynamic`
- `scripts/contracts/run-spec-003.sh --profile macos-dynamic`
- `scripts/test.sh`

These are local macOS host checks. They do not claim cross-built or connected-
target evidence.
