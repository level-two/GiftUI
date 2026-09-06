# SPEC-008 Style Modifier Evidence

Plan task: `SPEC-008 T1.4`

`Sources/GiftUI/StyleModifiers.swift` implements the exact opaque
`foregroundStyle` and rectangular `background` modifiers over two typed
SPEC-006 payloads. One generic framework wrapper dispatches each payload
through the sole modifier visitor operation and contains no rendering,
backend, layout, reference, or dynamic storage.

Focused declaration tests prove exact colors and source-call order. The
SPEC-006 semantic corpus records `Text` followed by inner-to-outer modifier
applications with chain indices zero and one, consumes both typed colors, and
proves changing only color payloads preserves descendant semantic identity.
Public-client fixtures cover chained modifiers and custom views; negative
fixtures reject direct payload construction and wrapper-storage access.

Reproduce from the repository root:

```text
swift test --filter StyleModifier
swift test --filter testSpec008TextAndStylePayloadsPreserveModifierOrderAndIdentity
scripts/contracts/check-spec-008-style-surface.sh
```
