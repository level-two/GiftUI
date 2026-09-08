# SPEC-010 T4.3 Borrowed Target Lookup Evidence

The internal finite lookup slot conforms to `ObservableStateTargetView` and
retains only the complete structural identity/ordinal key and opaque target
generation. Both lookup operations are `borrowing`; neither exposes a model,
attachment, sink, handler, or storage owner.

Live lookup returns only an exact published key. Publishable lookup is `nil`
before candidate entry and remains `nil` until a successful encounter. A
preserved encounter exposes the existing live generation to candidate
construction, while a candidate-only encounter exposes only its already
reserved fresh generation. Publishing promotes that staged generation to
live; discarding exposes it nowhere and leaves the slot reusable. Wrong
identities and ordinals always return `nil` without lazy materialization.

```sh
swift test --filter ObservableStateTargetLookupSlotTests
ruby scripts/contracts/check-spec-010-target-lookup.rb
```

Removal retirement and cross-lifetime discard behavior remain T4.4.
