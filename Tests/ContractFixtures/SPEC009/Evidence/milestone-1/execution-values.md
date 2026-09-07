# SPEC-009 Execution Value Evidence

Plan tasks: `SPEC-009 T0.2` (incremental boundary slice), `SPEC-009 T1.1`

The first `GiftUIExecution` source lands atomically with the exact approved
`GiftUI` plus `GiftUIRenderCore` dependency edge and its focused test target.
The eight obsolete `GiftUIExecutionContract` placeholder references are
retired from SPEC-002 through SPEC-005 boundary fixtures and checks; no alias
target or compatibility shim exists. `GiftUIFailureExecution` and fixture
adapter rows remain deferred until their first compiling sources, so T0.2
remains active.

Focused tests prove all five identity constructors preserve zero, an ordinary
value, and `UInt32.max` without a sentinel; each identity occupies four bytes.
They prove the exact seven-case phase raw order and one-byte layout, exact
limits admission including zero completion capacity, the 12-byte limits
layout, and exact optional context correlation within its 24-byte ceiling.
The source audit fixes sole ownership, exact imports, conformances, and the
absence of validation/sentinel logic, dynamic storage, public API, or upward
owner coupling.

Reproduce from the repository root:

```text
swift test --filter ExecutionValueTests
scripts/contracts/check-spec-009-execution-values.rb
scripts/contracts/check-spec-009-migration.rb
swift package dump-package | scripts/contracts/check-target-dependencies.rb
```
