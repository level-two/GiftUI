# SPEC-001 Fact Mutation and Publication Evidence

This partial T5.3 slice composes the application-owned Dynamic fact endpoint,
the fixed host sequencer, host wake pacing, the real Signal Analyzer model,
the Dynamic observable root, and `RuntimeCompletePipeline`.

The focused burst admits 20 transition-category facts with consecutive
sequences. The first admission requests one wake and the other 19 coalesce.
No model mutation occurs before the paced 250,000-microsecond opportunity.
Inside that opportunity every accepted fact applies once, the real model emits
20 change reports, and the observable owner records one clean-to-dirty
transition. Derivation sees only the final stopped state and publishes one
complete semantic revision. Successful joint publication clears dirty state.

The cross-profile root transcript separately proves that a successful repeated
publication clears Dynamic and Static dirty state equally. The registration
bridge test then proves a later mutation begins a fresh dirtied/coalesced epoch.

Reproduce with:

```sh
swift test --filter SignalAnalyzerHostFactAdmissionTests
swift test --filter ObservableStateRegistrationBridgeTests
swift test --filter ProductionObservableRootAdapterTests
```

The concrete semantic-action join, retry/failure wake disposition, generated
Static fact endpoint, and executable profile roots remain assigned to later
T5.3/T5.4/T6 slices. This evidence does not claim T5.3 complete.
