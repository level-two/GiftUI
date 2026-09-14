# SPEC-015 Action Generation Dispatch Evidence

The focused Signal Analyzer host fixture composes SPEC-011's production
`RuntimeInteractionDispatcher` with the exact immutable
`SignalAnalyzerActionHandler`, a weak current-model target access, and scalar
committed action records.

The fixture proves:

- all six action codes `0...5` decode and dispatch exactly once to the current
  model;
- codes `6` and `UInt16.max` fail closed as invariant violations;
- stale action and target generations cancel before borrowing the model;
- replacement between capture and dispatch cancels the former action; and
- neither the action record, handler, dispatcher, nor target access retains
  the former model after the host-owned target releases it.

Reproduce with:

```sh
swift test --filter SignalAnalyzerHostActionDispatchTests
```

This is hardware-free host-execution evidence. Target-local normalized input,
pointer sequence limits, action/input first-excess handling, and concrete root
ownership remain later T5/T6 work.
