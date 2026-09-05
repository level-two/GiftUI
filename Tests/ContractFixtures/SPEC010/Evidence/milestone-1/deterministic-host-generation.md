# SPEC-010 Deterministic Host Generation

Plan task: `T1.2`

Date: 2026-09-05

`GiftUIMacros` is a host-only SwiftPM macro target backed by the exact pinned
`swift-syntax` 603.0.2 dependency. `GiftUI` names it only as a macro build edge;
the package publishes no macro product. The target imports compiler-plugin,
diagnostic, syntax, builder, and macro modules only. The registered package
graph and `check-spec-010-macro-boundary.rb` reject runtime, platform,
application, backend, task-local, reflection, `Any`, Foundation, and
Observation mechanisms in the macro owner.

`ObservableStateHostMacro` emits exactly the two named members and the
`_GiftUIObservableStateHost` conformance. It enumerates only direct stored
`@State` declarations, including qualified `@GiftUI.State`, in lexical source
order and assigns ordinals from zero. Nested, inherited, static, and class
members outside the attached declaration are not enumerated. Generated member
access follows the host's access boundary; a private host receives fileprivate
witnesses so its public-protocol conformances remain compiler-valid.

Checked-in sources and byte-stable expected expansions cover zero, one,
several, private, nested/non-direct, inherited/non-direct, and malformed
declarations. The overflow-shaped boundary fixture verifies that 65,535 is
accepted and 65,536 is rejected before ordinal generation. The malformed
fixture verifies deterministic diagnostic routing. Host tests expand every
snapshot, and a `GiftUI` integration test compiles a real annotated view with
private wrappers and executes its generated declaration visitor to observe
ordinals `[0, 1]`.

Validation commands:

```text
swift test --filter ObservableStateHostMacroTests
swift test --filter ObservableStateHostIntegrationTests
scripts/contracts/check-spec-010-harness.rb
scripts/contracts/check-spec-010-macro-boundary.rb
swift package dump-package | scripts/contracts/check-target-dependencies.rb
```

The macro emits the SPEC-006 stateful traversal member because its approved
visitor signature is already present. This task proves deterministic emission
and compilation; dependent T1.4 remains responsible for category behavior and
the absence of handwritten application overrides.
