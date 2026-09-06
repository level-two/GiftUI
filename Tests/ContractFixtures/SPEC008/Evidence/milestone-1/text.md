# SPEC-008 Text Evidence

Plan task: `SPEC-008 T1.3`

`Sources/GiftUI/Text.swift` implements both exact public initializers over one
typed SPEC-006 primitive payload. Admitted literals and `BoundedText` preserve
the exact admitted bytes. Oversized literals store only the closed package-SPI
invalid-declaration case; the public initializer is non-failable and does not
trap, truncate, repair, or expose that marker to clients.

Focused tests prove byte equivalence, fail-closed oversized admission, and
single primitive traversal without body evaluation or an action/modifier
visit. Public-client fixtures prove both initializers and `View` conformance,
while negative fixtures reject an unbounded `String` input and client access
to the typed payload. The source audit proves sole `GiftUI` ownership, one
primitive dispatch, one invalid marker, and no unbounded/reference storage.

Reproduce from the repository root:

```text
swift test --filter 'textStores|oversizedText|textUses'
scripts/contracts/check-spec-008-text-surface.sh
```
