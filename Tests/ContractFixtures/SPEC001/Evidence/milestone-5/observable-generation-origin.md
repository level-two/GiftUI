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

The Static profile now supplies one caller-owned inline typed model optional.
Its binding exists only for the synchronous body call, captures a direct
pointer to that storage, preserves the first initializer, discards a repeated
initializer, and routes assignment without changing the live value. The
storage layout fixture proves the helper adds no field beyond the typed
optional. Reproduce with:

```sh
swift test --filter StaticObservableModelStorage
```

The final generated analyzer storage must place this caller-owned value at an
address-stable location and prove its optimized artifact has no allocation
path; this host-native layout fixture does not claim that later evidence.

`ProductionObservableModelStorageTests` drives both mechanisms with the same
three initializer/model identities and compares one normalized transcript.
Both materialize identity 1, preserve it when initializer 2 is presented,
route assignment of identity 3 without changing live storage, and finish with
identity 1 still installed. Reproduce the comparison with:

```sh
swift test --filter productionModelStorageBindingsAreProfileEquivalent
```

`ObservableStateRegistrationBridgeTests` exercise the root-facing registration
façade. They prove one sink is issued for one pending attachment, activation
occurs only after the exact return, a mismatched generation is stale, retirement
detaches exactly once, and a report attempted during attach poisons the route
before activation. Reproduce with:

```sh
swift test --filter ObservableStateRegistrationBridge
```

`DynamicObservableModelRegistrationTests` compose the bridge with the Dynamic
typed model box in one address-stable owner. Generation zero attaches exactly,
repeated transient wrappers preserve the live model, two mutation-phase reports
return `dirtied` then `coalesced`, retirement detaches and clears storage, and
an attach-time report fails with `staleAttachment` and performs candidate
cleanup. Reproduce with:

```sh
swift test --filter DynamicObservableModelRegistration
```
