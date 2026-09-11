# SPEC-008 T2.5 Render View Boundary Evidence

The focused runtime lifetime test passes semantic and resolved-layout views
that carry the only strong references to distinct source tokens through one
generic shared-identity borrow. Both tokens are released when the caller's
views leave scope, proving the consumer retained neither authoritative result.

`check-spec-008-render-view-static-exposure.sh` compiles fixed semantic and
resolved-layout views with optimization and scans the shared-identity borrowed
accessor. It contains zero `alloc_ref`, `alloc_box`, or `swift_allocObject`
instructions.

`check-spec-008-render-view-boundaries.rb` verifies that Semantic Core, Layout,
and Render Core retain their exact package dependencies; both result adapters
forward their owners' views without collection or reference materialization;
Layout owns no normalized rendering operation; and Render Core owns no layout
algorithm or semantic/result dependency.

Reproduce with:

```text
swift test --filter renderViewBorrowRetainsNeitherAuthoritativeResult
scripts/contracts/check-spec-008-render-view-static-exposure.sh
```

This is host compilation, optimized SIL inspection, source inspection, and
runtime lifetime evidence. Cross-compiler value layouts and complete static
render-production allocation evidence remain assigned to T3.5 and T6.4.
