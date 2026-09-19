# SPEC-013 T8.1 Final Package Audit

The final audit parses `swift package dump-package`, checks the exact direct
dependency set for all five SPEC-013 owner targets, scans their imports and
generated sources, rejects re-exported imports, and proves that `GiftUI`
contains no runtime-profile dependency or reference. It also rechecks the 24
retired proof-of-concept paths and the complete fixture registry.

Reproduction from the repository root:

```text
scripts/contracts/check-spec-013-module-contract.sh
ruby scripts/contracts/check-spec-013-migration.rb
ruby scripts/contracts/check-spec-013-harness.rb
```

The 2026-09-19 run passed: the profiles do not import each other or any
concrete backend, platform, driver, or host module, and focused algorithms
remain in their owning targets.
