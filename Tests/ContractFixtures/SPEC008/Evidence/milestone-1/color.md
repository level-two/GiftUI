# SPEC-008 Color Evidence

Plan task: `SPEC-008 T1.1`

`Sources/GiftUI/Color.swift` implements the exact public three-channel
`Equatable`, `Hashable`, and `Sendable` value. Focused tests prove size 3,
stride 3, alignment 1, stored channel equality, and the six exact named RGB
values.

The registered public-client fixtures compile the required initializer and
conformances and reject `clear`, an alpha argument, an alpha member, and a
backend reinterpretation hook. The source audit permits the sole `Color`
declaration only in `GiftUI` and rejects a second maintained declaration.
Cross-profile fixture compilation and layout reports remain assigned to T1.5,
T3.5, and T8.2; this focused host evidence makes no cross-target claim.

Reproduce from the repository root:

```text
swift test --filter Color
scripts/contracts/check-spec-008-color-surface.sh
```
