# SPEC-001 Observable Generation-Origin Evidence

The production `RuntimeObservableProfileWorkspace` uses an optional checked
`UInt32` generation cursor. Raw zero is the first valid target generation; only
`nil` represents permanent exhaustion. This preserves the shared generation
bits required for the root model's registration and action-target provenance.

The focused production-profile tests prove that Dynamic and inline Static
storage both publish generation zero for their first location. A separate
Static fixture starts with the explicit exhausted state and proves encounter
returns `registrationGenerationExhausted` before a publishable association is
staged.

Reproduce with:

```sh
swift test --filter ProductionObservableProfileWorkspace
```

This is partial SPEC-001 T5.2 evidence. Typed model preservation, attachment,
replacement, dirty/live state, removal/reinsertion, and complete profile
equivalence remain required before the task is complete.

The Dynamic profile additionally owns one bounded typed model box. Its focused
fixture proves that the first transient wrapper installs its initializer, a
later wrapper at the same storage observes the preserved model and discards its
initializer, assignment is routed without directly changing stored state, and
attempting to bind one transient wrapper twice fails as an invariant. Reproduce
that slice with:

```sh
swift test --filter DynamicObservableModelStorage
```

Static generated binding, model attachment, atomic replacement, dirty/live
state, and the complete equal-profile lifecycle remain pending.
