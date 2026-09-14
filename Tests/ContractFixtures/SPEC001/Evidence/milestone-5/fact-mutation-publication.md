# SPEC-001 Fact Mutation and Publication Evidence

This T5.3 evidence composes the application-owned Dynamic fact endpoint,
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

The production Dynamic action composition also dispatches Start through
same-thread and deferred application executors. Both callbacks leave the model
at its initial state, admit the same sequenced running-state fact, and change
the model only when that fact is applied later. The deferred executor has no
admission outcome until drained; the same-thread executor returns from
admission without entering observable mutation.

Reproduce with:

```sh
swift test --filter SignalAnalyzerHostFactAdmissionTests
swift test --filter ObservableStateRegistrationBridgeTests
swift test --filter ProductionObservableRootAdapterTests
swift test --filter sameThreadAndDistinctActionCallbacksStopAtLaterFactAdmission
swift test --filter integratedAnalyzerCycleIsProfileEquivalent
```

The normalized integrated-cycle evidence completes the semantic-action,
Static direct endpoint/reporting, accepted-frame, and retryable-refusal wake
joins. Concrete executable profile roots remain Milestone 6 work and are not
claimed by this completed Milestone 5 task.
