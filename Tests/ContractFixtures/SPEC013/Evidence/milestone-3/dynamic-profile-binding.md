# SPEC-013 T3.5 Dynamic Profile Binding Evidence

Date: 2026-09-12

`DynamicRuntimeProfileBinding` binds `DynamicProfileStorage` and the bounded
Dynamic Canvas callable store to Runtime Core's single coordinator lifecycle.
The profile binding delegates opportunity exclusivity, execution-context
retention, active quiescence, and terminal teardown to
`RuntimeCoordinatorLifecycle`; it does not define a second Semantic, Layout,
Drawing, Observable State, Interaction, Render, or Execution algorithm.

The binding admits attempt-local reservations only during a common active
opportunity. It discards uninvoked Canvas occurrences before attempt reset and
uses scoped release around Drawing-owned invocation so success and typed throw
both end the retained closure lifetime immediately. Graphics contexts and
other focused-owner payloads are borrowed only as call parameters and are not
stored by the binding.

Validation:

- `scripts/contracts/check-spec-013-dynamic-binding.rb`
  - passed the shared-lifecycle/storage delegation checks;
  - passed the sibling Static, backend, host, and platform import negatives;
  - passed the focused-owner redefinition and borrowed-payload-field checks;
  - passed scoped Canvas success/throw release inspection.
- `swift test --disable-sandbox --scratch-path .build/spec013-swift633
  --cache-path .build --filter GiftUIRuntimeDynamicTests`
  - passed 14 focused tests, including common opportunity ownership, attempt
    cleanup, deferred active quiescence, idempotent teardown, and bounded
    callable release.
- `swift test --disable-sandbox --scratch-path
  .build/spec013-dynamic-profile --cache-path .build -Xswiftc
  -DGIFTUI_DYNAMIC_PROFILE --filter GiftUIRuntimeDynamicTests`
  - exercises the real Dynamic Canvas closure invocation path in addition to
    the default suite.

This is host-execution and source-inspection evidence. It does not claim
connected-hardware execution or completion of Milestone 5's assembled
production pipeline.
