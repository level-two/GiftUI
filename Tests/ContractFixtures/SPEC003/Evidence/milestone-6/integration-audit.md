# SPEC-003 Milestone 6 Integration Audit

The completed execution-correlation, capability-adapter, and production-host
integrations are audited by
`scripts/contracts/check-spec-003-integration-audit.rb`.

The audit requires exact agreement between the SPEC-002 package registry and
the SPEC-003/SPEC-004 owner registries, preserves the one-way Execution and
Capabilities dependencies, verifies the production host's Core-only residual
routing surface, rejects production imports of Failure Diagnostics, and keeps
FW-009 and FW-012 in the captured deferred-work track.

Reproduction:

```sh
scripts/contracts/check-spec-003-integration-audit.rb
CLANG_MODULE_CACHE_PATH=.build/contract-cache \
  SWIFTPM_MODULECACHE_OVERRIDE=.build/contract-cache \
  swift package --disable-sandbox dump-package | \
  scripts/contracts/check-spec-003-dependencies.rb
scripts/contracts/check-spec-003-execution-correlation.rb
```

These commands are hardware-free and make no connected-target claim.
