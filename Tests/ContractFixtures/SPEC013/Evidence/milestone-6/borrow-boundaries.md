# SPEC-013 T6.5 Borrow and Typed-Source Boundary Evidence

Evidence kind: host execution and inspection. No simulator, connected target,
deployment, service restart, or flashing was used.

## Result

The twelve-case corpus aggregates the authoritative focused-owner lifetime
proofs. Canvas callables and Static captures release exactly once, failed plans
discard, render views retain neither Semantic nor Layout storage, borrowed
operations and glyph/resource payloads are poisoned after their synchronous
scope, action dispatch borrows only the revalidated current model, and endpoint
handoff retains only target-owned payload bytes.

SPEC-012 compiler negatives reject copying, consuming, escaping, or
asynchronously escaping Path storage and reject missing or incorrect typed
throws. Static source and optimized-path checks reject closure boxes,
existentials, allocation, reflection, Objective-C, tasks, and threads. The
generated fixture checker reconstructs both canonical inputs and verifies
every observable slot and Canvas callable ID exactly. The module-contract audit
retains all prohibited sibling, reverse, backend, platform, driver, and host
edges as failures.

## Reproduction

```sh
scripts/format-swift.sh
scripts/contracts/check-spec-012-declarations.sh
scripts/contracts/check-spec-013-static-generated-fixture.rb
scripts/contracts/check-spec-013-static-storage.rb
swift test --filter canvasPlanProducerReleasesEachCallableOnceOnLaterThrowAndInvokesNoSuffix
swift test --filter renderViewBorrowRetainsNeitherAuthoritativeResult
swift test --filter oneShotProducerAndBorrowedOperationLeaveOnlyOwnedPayloadBytes
swift test --filter dispatcherRevalidatesDecodesAndBorrowsCurrentModelExactlyOnce
scripts/contracts/check-spec-013-borrow-boundaries.rb
scripts/contracts/check-spec-013-harness.rb
```
