# T1.1 Runtime Profile Limits

`Sources/GiftUIRuntimeCore/RuntimeProfileValues.swift` implements the exact
SPEC-013 package value surface for `RuntimeProfileKind`,
`RuntimeProfileLimits`, `RuntimeProfileValidationError`, and
`RuntimeProfileValidationResult`.

`Tests/GiftUIRuntimeCoreTests/RuntimeProfileLimitsTests.swift` exercises both
valid profiles, the static-Canvas presence rule, zero ordinary operations for
a drawing-only fixture, every aggregate cross-relation, checked combined
operation overflow, exact enum raw values, and preservation of explicit
render-workspace semantic-scope and traversal-depth values that are not
derived from SPEC-006 limits.

Reproduce on the pinned macOS toolchain from the repository root:

```sh
swift test --filter RuntimeProfileLimitsTests
scripts/contracts/check-spec-013-module-contract.sh
scripts/format-swift.sh --lint
```

This host execution is focused T1.1 evidence. It does not claim storage audit,
profile behavior, static allocation, cross-build, or connected-hardware
conformance.
