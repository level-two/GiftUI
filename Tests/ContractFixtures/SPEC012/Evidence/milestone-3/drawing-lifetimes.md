# SPEC-012 Drawing Lifetime Evidence

Plan task: `SPEC-012 T3.5`

The live Path builder now becomes inactive before its caller-owned storage is
reset. Later move or line operations fail as `.invalidScope`, while point and
subpath access expose no prior values. The public facade tests independently
prove normal, throwing, and nested `withPath` cleanup.

The dynamic semantic adapter tests cover both normal and typed-throwing Canvas
invocation. Explicit release removes the eligible callable in either case and
every later invocation is `.invariantViolation`. Plan fixtures prove that a
sealed zero-stroke Canvas is visible only until discard and that discard/reset
invalidate every header, point, subpath, and Canvas lookup. Snapshot failures
retain no record. Borrowed stroke-sink tests cover accepted and refused calls
and retain only copied header/point/subpath values after the source view leaves
scope.

The nine negative declaration fixtures remain the compiler authority for
forbidden context/Path construction, Path copy/consume, synchronous and
asynchronous escape, outer-context overlapping access, and untyped or foreign
errors.

Reproduce from the repository root:

```text
swift test --filter DrawingLifetimeTests
swift test --filter PathConstructionTests
swift test --filter drawingOperationSinkRetainsOnlyDerivedValues
swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter throwingCanvasRemainsInaccessible
scripts/contracts/check-spec-012-declarations.sh --profile macos-dynamic
scripts/contracts/check-spec-012-declarations.sh --profile macos-static
scripts/contracts/check-spec-012-declarations.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-012-declarations.sh --profile nrf52840-embedded
```
