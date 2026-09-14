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

This is partial SPEC-001 T5.4 evidence. The application-specific Dynamic
composition now installs `SignalAnalyzerActionHandler` with the production
Dynamic root target access and dispatcher. Its focused corpus decodes all six
exact action codes, rejects invalid codes without mutation, cancels stale
action and target generations, and cancels a captured former action after the
real root commits a replacement. Reproduce with:

```sh
swift test --filter SignalAnalyzerHostActionDispatchTests
```

The Static analyzer composition installs the same exact handler through
the generated-root-compatible typed pointer path. Its six-case corpus reaches
the same repository intents and visible-window mutations while preserving the
address-stable root as the lifetime owner.

The final normalized interleaving corpus captures an action at pointer down
and at activation admission, then commits model replacement before dispatch.
Both captures cancel and invoke neither former nor replacement model. Published
removal also cancels. A replacement-staging failure preserves generation zero
and permits exactly one later dispatch to the former model, while disabled
state cancels without another invocation. Dynamic and Static transcripts are
equal, and the replacement model records no call.

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
2, and cancel again after published structural removal. Before successful
replacement, an incompatible candidate is rejected and generation 0 still
dispatches to the former model; the failed identity 9 candidate is never
invoked. The final invocation total is exactly four in both profiles.
Reproduce with:

```sh
swift test --filter rootTargetAdaptersProduceEqualDispatchAndCancellation
swift test --filter actionReplacementInterleavingsAreEqualAcrossProfiles
```
