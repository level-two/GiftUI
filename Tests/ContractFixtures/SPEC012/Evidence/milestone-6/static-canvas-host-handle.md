# SPEC-012 T6.4 Static Canvas Host-Handle Evidence

`StaticCanvasHostValidation` compares the generated callable table with the
independent `StaticCanvasLimits` before profile storage construction or any
callable invocation. The focused matrix accepts exact equality and rejects a
missing limit, insufficient callable-case capacity, and insufficient greatest
capture capacity.

`StaticCanvasHostModelLocation` owns one inline model value. Its nonescaping
`withHandle` scope supplies the only `StaticCanvasObservableModelHandle`
construction seam and is the host's explicit proof that the storage address
outlives generated Canvas use in that scope. The handle stores only an unsafe
pointer, is copyable for generated capture records, and owns no model reference.
Two copies borrow the same exact model address and value.

Reproduce the focused host evidence with:

```sh
swift test --filter staticCanvasHostValidationIsIndependentAndExact
swift test --filter staticCanvasObservableHandleBorrowsOneAddressStableHostLocation
```

This is host-execution lifetime evidence. It does not claim a connected board,
cross-target allocator result, or final static image cost.
