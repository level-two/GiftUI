# SPEC-011 T7.1 Dynamic Interaction Storage

Date: 2026-09-14

`GiftUIRuntimeDynamic` provides three bounded heap-backed storage adapters for
the common `InteractionState`: candidate records, candidate/committed records,
and hit regions. Construction reserves the configured capacity, append checks
the finite `UInt16` limit before mutation, replacement requires an existing
slot, and reset retains capacity. Committed record and hit-region exchanges
swap both contents and capacity, keeping the bound attached to its allocation.

Focused tests accept exactly two actions/hit regions, reject the first excess
as `capacityExhausted`, commit the exact record and region, and prove a later
discard preserves committed state. All 30 Runtime Dynamic tests pass.

```sh
source scripts/lib/swiftpm.sh
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter GiftUIRuntimeDynamicTests
```
