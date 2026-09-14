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
still install `SignalAnalyzerActionHandler` and prove pointer-down and
admitted-action replacement/removal interleavings through
`RuntimeInteractionDispatcher`.

The profile-specific adapters now conform to `ActionModelTargetAccess`.
Dynamic stores a weak root reference: releasing the composition root clears
the reported generation and later borrow attempts invoke no body. Static stores
only a typed mutable pointer whose lifetime is bounded by the generated
address-stable root; copying the handle preserves that storage identity and
both copies borrow the same generation-0 model. Reproduce with:

```sh
swift test --filter ObservableRootTargetAccess
```

`ProductionObservableRootActionDispatchTests` install each profile adapter in
the production `RuntimeInteractionDispatcher`. Both normalized transcripts
dispatch generation 0 to model identity 1 exactly once, cancel that captured
action after replacement, dispatch generation 1 only to replacement identity
2, and cancel again after published structural removal. The final invocation
total is exactly three in both profiles. Reproduce with:

```sh
swift test --filter rootTargetAdaptersProduceEqualDispatchAndCancellation
```
