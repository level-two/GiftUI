# SPEC-008 BoundedText Evidence

Plan task: `SPEC-008 T1.2`

`Sources/GiftUI/BoundedText.swift` owns a 96-byte inline value payload and a
16-bit admitted byte count. The storage uses only fixed-width integer fields,
remaining available below macOS 26 and on the two embedded profiles. Focused
tests prove the 100-byte stride ceiling, exact 96-byte admission boundary,
well-formed UTF-8 validation, trailing C NUL treatment, complete `Int32`
formatting, value equality, and one-call throwing `withUTF8` behavior.

The registered public-client fixtures compile the required initializers,
conformances, byte count, and borrow surface. Negative fixtures reject an
unbounded `String` input, byte-count mutation, and storage access. The source
audit proves sole `GiftUI` ownership and permits only the two expected stored
properties backed by 24 fixed-width words; it rejects string, reference, and
dynamic-array storage.

Reproduce from the repository root:

```text
swift test --filter BoundedText
scripts/contracts/check-spec-008-bounded-text-surface.sh
```
