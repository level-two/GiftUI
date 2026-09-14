# SPEC-001 Action Model-Target Access Evidence

The production Dynamic and Static observable root adapters expose one
generation-matching model borrow. The operation compares the requested target
generation with the root's current published generation and invokes the body
only while the corresponding live model remains available.

Focused fixtures prove that generation 1 cannot borrow the initial generation
0 model, generation 0 borrows it exactly once, replacement invalidates the
former generation, and only generation 1 can borrow the replacement. The body
records no invocation for either stale request.

Reproduce with:

```sh
swift test --filter dynamicRootAdapterBorrowsOnlyTheMatchingTargetGeneration
swift test --filter staticRootAdapterBorrowsOnlyTheMatchingTargetGeneration
```

This is partial SPEC-001 T5.4 evidence. The concrete target composition must
still install `SignalAnalyzerActionHandler`, adapt each root to
`ActionModelTargetAccess`, and prove pointer-down and admitted-action
replacement/removal interleavings through `RuntimeInteractionDispatcher`.
