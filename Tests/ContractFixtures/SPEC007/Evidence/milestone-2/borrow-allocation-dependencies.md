# SPEC-007 T2.5 Borrow, Allocation, and Dependency Evidence

The focused lifetime test passes a semantic view carrying the sole strong
reference to a source token through the generic layout entry. Pre-publication
cleanup resets the caller-owned workspace, and the token is released when the
caller's local view ends, proving layout retained neither the view nor its
source.

`check-spec-007-static-exposure.sh` compiles the fixed static semantic-view
probe with optimization and scans the borrowed generic accessor body. It
contains zero `alloc_ref`, `alloc_box`, or `swift_allocObject` instructions.

`check-spec-007-semantic-boundary.rb` verifies the exact package view surface,
the absence of forbidden action, generation, model/state, runtime, render,
backend, platform, and unrestricted-existential fields, and the absence of
adapter-owned array/dictionary/set storage. It also verifies that
`GiftUISemanticCore` imports and depends only on `GiftUI`, never
`GiftUILayout`, and that layout source stores no borrowed semantic view or
payload vocabulary.

Reproduce with:

```text
swift test --filter layoutEntryRetainsNeitherTheSemanticViewNorItsSourceLifetime
scripts/contracts/check-spec-007-static-exposure.sh
```

The SPEC-007 driver runs the dependency audit for every profile and the
optimized allocation probe for `macos-static`. Its nRF path compiles the same
probe for `armv7em-none-none-eabi`, verifies ARMv7E-M and hard-float ELF
attributes, and inspects the object symbol closure for allocation calls and
prohibited layout, render, runtime, backend, platform, Zephyr, or J-Link
references. This is hardware-free compile and inspection evidence; it makes
no connected-board or execution claim.
