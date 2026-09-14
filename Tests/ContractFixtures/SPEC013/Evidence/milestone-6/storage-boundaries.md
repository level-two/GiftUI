# SPEC-013 T6.1 Storage Boundary Corpus

Date: 2026-09-14

The frozen `storage.yaml` corpus names the Dynamic and Static exact-limit and
first-excess rows, the complete physical-family audit, and Dynamic allocator
bookkeeping as four globally unique cases. The registered checker fixes 51
logical dimensions and 16 physical families and verifies that both profile
suites reserve each exact limit, report its exact high-water value, reject the
first excess without mutation, and use the same deterministic
`limitExceeded` identity.

The Core audit suite preserves all sixteen artificial byte fields `1...16`,
their exclusive zero-overlap meaning, and the checked total of 136 bytes.
Dynamic storage reports 136 owned payload bytes, at least 136 reserved payload
bytes, and sixteen allocations separately from `totalProfileBytes`. Static
storage uses its fixed tuple-backed ledger and contributes no Dynamic allocator
bookkeeping.

Reproduction:

```sh
scripts/contracts/check-spec-013-storage-boundaries.rb
source scripts/lib/swiftpm.sh
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter everyDynamicLogicalDimensionAcceptsExactLimitAndRejectsFirstExcess
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter GiftUIRuntimeStaticTests
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter checkedAuditPreservesEveryExclusiveFieldAndExactTotal
```

This is host execution and source/fixture inspection evidence. It makes no
production-capacity, cross-build, timing, connected-target, or hardware claim.
