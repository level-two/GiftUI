# SPEC-002 T4.2 Foundation Failure-Mapping Evidence

This record closes SPEC-002 implementation-plan task `T4.2` through the shared
SPEC-002/SPEC-003 owner-adapter seam. It does not claim that a later production
integration owner exists.

## Boundary and ownership

`GiftUIFoundationFailureAdapterTests` is the test-only target at the first
package boundary that knows both `GiftUI` Foundation values and
`GiftUIFailureCore` facts. The package graph gives that target one-way edges to
both leaves. Neither leaf imports or re-exports the other, and the adapter is
not a public product.

The shared implementation and its SPEC-003 disposition are recorded in the
[SPEC-003 Foundation owner-adapter evidence](../../../SPEC003/Evidence/milestone-4/foundation-owner-adapter.md).

## Exact rejection mappings

Focused tests prove that Foundation rejects before mapping and returns no
partial value:

| Foundation rejection | Condition |
| --- | --- |
| Negative `Size` dimension or negative present `ProposedSize` dimension | `.invalidValue` |
| Checked scalar addition overflow | `.arithmeticOverflow` |
| Unrepresentable rectangle exclusive edge | `.arithmeticOverflow` |
| Physical-to-logical conversion outside `GeometryScalar` | `.arithmeticOverflow` |

Every fact also proves `.foundation` origin, `.operation` affected scope, and
`.contained` containment. Positive controls preserve complete valid sizes,
proposals, scalar results, coordinates, and rectangles.

## Validation

Validated on 2026-08-31 from the repository root:

- `swift test --filter GiftUIFoundationFailureAdapterTests`
- `scripts/contracts/run-spec-002.sh --profile macos-dynamic`
- `scripts/contracts/run-spec-003.sh --profile macos-dynamic`
- `scripts/test.sh`

These are local macOS host checks. They do not claim cross-built or connected-
target evidence.
