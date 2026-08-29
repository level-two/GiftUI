# SPEC-002 Clean-Baseline Cut Record

Implementation-plan tasks `T0.5` and `T0.7` land atomically in one commit so
the active branch never records an unbuildable root package.

## Removal evidence

- The maintainer confirmed the exact 175-path removal manifest on 2026-08-29.
- All old contents are recoverable from annotated tag `PoC`, tag object
  `2b2837a66b94df38c7b74ead33ebbb54aa08a06d`, dereferenced commit
  `d5d6330432caa7c983d8dba35cf9f23c3800860b`.
- 173 confirmed paths are absent from the active tree.
- `Sources/GiftUI/GiftUI.swift` and `Tests/GiftUITests/GiftUITests.swift` were
  removed and recreated in the same change with clean SPEC-002 bootstrap
  contents; no PoC declaration, assertion, or helper survives in either file.
- The old root manifest was replaced rather than retained. It now declares
  only the stable `GiftUI` library product, `GiftUI` target, and
  `GiftUITests` test target.
- No source, test, firmware, removed legacy document, package-workspace file,
  or hard-coded layer-compilation script was copied to an active archive.

The complete removal inputs remain in
[`clean-baseline-remove-paths.txt`](clean-baseline-remove-paths.txt), and each
path's disposition remains in
[`clean-baseline-removal-ownership.md`](clean-baseline-removal-ownership.md).

## Package bootstrap

The initial exact target allow-list is
[`initial-target-allow-list.txt`](initial-target-allow-list.txt):

```text
GiftUI
GiftUITests
```

New targets must fail closed until the owning ready plan updates the checked-in
dependency allow-list established by `T1.3`. This bootstrap does not create a
target or declaration owned by a later Specification.

## Verification commands

Run from the repository root:

```sh
swift package dump-package
swift build --product GiftUI
swift test
scripts/validate-governance.rb
git diff --check
```

The expected package target-name set is exactly the two-line initial allow-list.
The build and tests require no runtime, backend, platform, driver, firmware,
remote host, or connected board.
