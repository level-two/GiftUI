# SPEC-011 T7.2 Static Interaction Storage

Date: 2026-09-14

`GiftUIRuntimeStatic` provides caller-constructed candidate,
candidate-committed, committed, and hit-region adapters over 32 generated
inline optional slots. The common `InteractionState` receives those concrete
stores by value. No array, dictionary, unrestricted existential, reflection,
allocator API, task/thread, Objective-C runtime, string identity, handler,
model, or closure registry appears in the storage source.

Construction accepts capacities `1...32` and rejects values outside that
range. Focused tests accept the exact configured limit, reject first excess,
commit records and hit regions atomically, and resolve a down gesture directly
to the typed identity/generation pair. All 33 Runtime Static tests pass. The
whole-module optimized Static binding entry point still contains zero
forbidden allocation or closure-box instructions.

```sh
source scripts/lib/swiftpm.sh
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter GiftUIRuntimeStaticTests
scripts/contracts/check-spec-013-static-profiles.sh --profile macos-static \
  --output .build/spec-011/t7.2-macos-static
```
