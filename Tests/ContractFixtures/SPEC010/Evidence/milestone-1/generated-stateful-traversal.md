# SPEC-010 Generated Stateful Traversal

Plan tasks: `T1.2`, `T1.4`

Dependent plan task: `SPEC-006 T1.4`

Date: 2026-09-05

SPEC-006 exposes one exact stateful visitor operation constrained to
`View & _GiftUIObservableStateHost`. It borrows the transient declaration and
receives a body accessor that borrows that same declaration. SPEC-010's macro
emits `_giftUITraverse` inside the attached declaration and calls only this
operation, preserving access to private wrapper storage for the separately
generated lexical declaration witness.

The focused `GiftUITests` host uses `@ObservableStateHost`, declares direct
private `@State`, and contains no handwritten state-host or traversal witness.
Executing its generated `_giftUITraverse` records exactly one stateful-category
visit, zero ordinary custom visits, and one body evaluation through the
borrowed declaration. Existing ordinary-view coverage continues to select
`visitCustomView`, while fixed wrappers retain their sealed categories and
never read `Never.body`.

`check-spec-010-generated-traversal.rb` fixes the cross-owner visitor signature,
generated call shape, macro use in the executable fixture, absence of a manual
fixture witness, and absence of handwritten traversal overrides from maintained
application targets. `check-spec-006-traversal-surface.rb` continues to reject
a second traversal requirement or legacy traversal spelling.

Validation commands:

```text
swift test --filter DeclarativeViewTests
scripts/contracts/check-spec-010-generated-traversal.rb
scripts/contracts/check-spec-006-traversal-surface.rb
```

This closes the declaration/generation dependency that blocked SPEC-006 T1.4.
It does not claim pre-body runtime binding or failure suppression, which remain
SPEC-010 T3.2 work after the observable-state owner exists.
