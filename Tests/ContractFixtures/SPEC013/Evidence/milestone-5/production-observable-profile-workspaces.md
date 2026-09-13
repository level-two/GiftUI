# Production observable profile workspaces

The SPEC-010 prerequisite for SPEC-013 T5.1 now exists in maintained runtime
targets rather than only in a recording fixture. `GiftUIRuntimeCore` owns the
profile-neutral reconciler and target-view algorithm;
`GiftUIRuntimeDynamic` supplies bounded array-backed slots and
`GiftUIRuntimeStatic` supplies one address-stable inline typed slot.

The focused conformance corpus proves value-equal begin, materialization,
publish, candidate generation, and committed lookup transcripts across both
profiles. It also proves exact first-excess rejection and verifies that the
Static store stride equals its sole typed slot. No backend or host policy is
introduced into Runtime Core.

Reproduction:

```sh
scripts/format-swift.sh
CLANG_MODULE_CACHE_PATH="$PWD/.build/module-cache" \
SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/module-cache" \
swift test --disable-sandbox --filter GiftUIRuntimeConformanceTests
```

This closes the concrete Observable workspace blocker only. SPEC-013 T5.1
still requires state-aware semantic expansion and borrowed Layout integration
before its checkbox may be completed.
