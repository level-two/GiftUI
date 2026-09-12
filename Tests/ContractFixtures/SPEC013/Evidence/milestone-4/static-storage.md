# T4.2 Fixed Static Storage

Date: 2026-09-12

`StaticProfileStorage` owns one generated, fixed-layout region for every one of
the sixteen audit families. Construction validates the exact region byte
counts and all focused capacities through the shared Runtime Core audit. A
nonzero typed structural identity and the successful audit are retained.

The logical-use ledger is a 51-element tuple-backed value. It records current
and high-water counts without a dynamically growing collection. Exact-limit
reservations succeed, the first excess and arithmetic overflow reject without
mutation, and the common storage registry determines attempt-local versus
committed lifetime. Attempt reset is idempotent; quiescent teardown clears all
regions and counters once and prevents later attempt acquisition.

Swift's standard `InlineArray` was deliberately not used because it requires
macOS 26 while GiftUI targets macOS 15. The repository-owned tuple-backed value
preserves inline, allocation-free storage without changing deployment support.

Verification commands:

```text
swift test --filter GiftUIRuntimeStaticTests
scripts/contracts/check-spec-013-static-storage.rb
scripts/contracts/check-spec-013-storage-registry.rb
scripts/contracts/check-spec-013-harness.rb
```

Result: six focused Static tests passed under Apple Swift 6.3.3. The structural
checker confirmed sixteen distinct generated regions, 51 fixed counters,
shared ownership/reset classification, and no dynamic storage facility in the
production Static storage source.
