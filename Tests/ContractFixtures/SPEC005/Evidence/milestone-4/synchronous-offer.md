# SPEC-005 T4.2 Synchronous Offer Evidence

T4.2 adds a contract-local, test-only synchronous offer seam whose request
contains only nominal `FontInstanceID`, nominal `GlyphID`, and explicit
`Point`. The stateless adapter resolves metrics and the raster record, enters
the nested `withPayload` borrow, calls the supplied nonescaping body, and
returns only the body's result.

Focused tests prove:

- a generated reference glyph performs nested lookup and invokes the body
  exactly once with the unchanged identities and point;
- a valid zero-byte payload invokes exactly once with an empty buffer;
- invalid and unavailable requests return `nil` with zero body and payload
  invocation; and
- the instrumented payload borrow is active only inside the body and is ended
  before the offer returns.

The adapter stores no package, payload address, request source, or callback and
defines no paint, clip, ordering, capacity, or production positioned-glyph
operation.

## Reproduction

```text
swift test --filter SynchronousOfferTests
scripts/contracts/check-spec-005-synchronous-offer.rb
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```

This is contract-local host evidence. Production positioned-glyph declarations
and integration remain owned by SPEC-008 and T4.4.
