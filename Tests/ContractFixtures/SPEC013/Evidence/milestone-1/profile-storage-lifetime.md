# T1.4 Runtime Profile Storage Lifetime

Date: 2026-09-12

`GiftUIRuntimeCore` now declares the corrected, approved
`RuntimeProfileStorage: ~Copyable` contract with its typed structural identity,
immutable limits, audit, attempt reset, and all-storage reset requirements.

`ValidatedRuntimeProfileStorage` owns a possibly noncopyable conformer and:

- rejects any initial audit whose profile or limits disagree with the storage;
- retains the exact successful audit, limits, profile, and structural identity;
- exposes no operation that can replace or shrink the owned storage;
- checks that reset operations preserve the retained capacity audit;
- separates attempt reset from all-storage reset; and
- permits all-storage reset only before first use or after synchronous
  quiescence and teardown.

The focused `RuntimeProfileStorageTests` exercise successful retention,
rejected construction, attempt/all reset separation, both legal all-reset
boundaries, illegal active reset, post-validation capacity mutation, and the
terminal no-restart boundary.

Verification command:

```text
swift test --filter RuntimeProfileStorageTests
```

Result: five focused tests passed with the Apple Swift 6.3.3 package toolchain.
