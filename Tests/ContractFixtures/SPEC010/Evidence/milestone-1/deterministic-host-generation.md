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

## P10 implementation-evidence reconciliation — 2026-11-09

The T1.2 account above describes the original macro implementation. The current
`GiftUIMacros-tool` also has a `--lower-source` host CLI mode used by
SPEC-006/010/012/013/015 contract fixtures; it is a mode in the same executable,
not a separate target. `GiftUIMacros.swift` uses Foundation for command-line
error output, and `FiniteSourceLowering.swift` uses Foundation to read the
host-side JSON schema. Neither Foundation import is in
`ObservableStateHostMacro.swift`, and the CLI/lowerer are host build tooling;
the macro target remains unproductized and outside every target dependency
closure. `CanvasWitnessLowering.swift` has no Foundation use. The P10 checker
now limits Foundation imports to those two source files while continuing to
reject runtime, application, platform, and product-target dependencies. This
records the implementation detail without changing SPEC-010's host-only macro
contract or the exact target dependency graph.
