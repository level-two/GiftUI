# T4.4 Static Canvas Capture Lifetime

Date: 2026-09-12

`StaticCanvasOccurrence` is a noncopyable, fixed-layout owner of one structural
identity, one nonzero generated `UInt16` callable ID, one declared byte count,
one live/released state, and one inline optional capture record. Construction
checks the ID range and exact generated capture size without a closure,
existential, collection, or fallback box.

Invocation borrows the stored capture directly into the generated
`StaticCanvasCallableTable` and uses a scoped cleanup to nil the sole stored
record immediately after either normal return or a typed `DrawingError`.
Discard performs the same transition for an uninvoked record. Both paths are
idempotent; a released record cannot invoke again and never increments its
release count twice.

Verification commands:

```text
swift test --filter GiftUIRuntimeStaticTests
scripts/contracts/check-spec-013-static-storage.rb
scripts/contracts/check-spec-013-static-generated-fixture.rb
scripts/contracts/check-spec-013-module-contract.sh
```

Result: eleven focused Static tests passed under Apple Swift 6.3.3. Lifetime
tokens proved destruction once after success, once after typed throw, and once
after discard, with no replay after release. The source gate confirmed direct
borrowed dispatch, scoped release, inline capture destruction, and absence of
dynamic storage and closure fallback facilities.
