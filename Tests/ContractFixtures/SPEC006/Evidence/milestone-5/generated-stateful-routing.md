# SPEC-006 T5.1 Generated Stateful Routing

Plan task: `T5.1`

Date: 2026-09-05

`GiftUITests` is a separate client module that imports only `GiftUI`. Its
declaration fixture compiles an ordinary custom `View` and an
`@ObservableStateHost` view side by side. The ordinary declaration relies on
the default `View._giftUITraverse` witness, while the annotated declaration
contains one direct private `@State` and relies on the host-only macro to
generate both state-host members.

Focused execution proves the ordinary declaration selects
`visitCustomView` exactly once. The annotated declaration selects
`visitStatefulCustomView` exactly once, never selects `visitCustomView`, and
passes its body accessor the borrowed declaration. The fixture contains no
handwritten `_giftUITraverse` or state-declaration visitor witness.

SPEC-010's registered generated-traversal audit fixes the macro-generated call
shape and rejects handwritten application witnesses. SPEC-006's registered
traversal audit independently fixes the visitor signature and rejects a second
traversal requirement or legacy traversal spelling.

Validation commands:

```text
swift test --filter DeclarativeViewTests
scripts/contracts/check-spec-010-generated-traversal.rb
scripts/contracts/check-spec-006-traversal-surface.rb
```

This evidence establishes only generated-versus-ordinary routing. Pre-body
state binding, successful semantic equivalence, and binding-failure atomicity
remain assigned to `T5.2` and `T5.3` after the SPEC-010 state-aware decorator
exists.
