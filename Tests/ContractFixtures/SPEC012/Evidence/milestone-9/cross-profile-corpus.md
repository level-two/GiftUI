# SPEC-012 T9.2 Cross-Profile Corpus

Date: 2026-09-14

All 43 focused `GiftUIDrawingTests` pass. They exercise portable declaration
values, semantic Canvas identity, layout correlation, callable invocation and
release, scoped Path mutation, immutable snapshots and plans, translation,
failure precedence, cycle recovery, combined render preflight/streaming, and
offer failure cleanup. Dedicated rows compare Dynamic and Static identity
storage and live-Path transcripts exactly; zero-Canvas output remains exactly
the SPEC-008 ordinary transcript.

The four standalone SPEC-012 reports share run ID
`a028735b8e7ba8684190df71cde1b14b61b1cec2-5b2115319d8cb4b3` and compile the
same declaration and value-layout corpus on macOS Dynamic, macOS Static,
Raspberry Pi ARMv6, and nRF52840 Embedded. SPEC-014's joined consumer evidence
adds all 17 canonical normalized-stroke vectors through full-surface RGBA8888,
full-surface RGB565, and operation-major tiled RGB565 paths with zero mask or
encoded-byte tolerance.

```sh
source scripts/lib/swiftpm.sh
giftui_swiftpm --package-path "$PWD" --cache-root "$PWD/.build/codex-cache" \
  --disable-sandbox -- test --filter GiftUIDrawingTests
for profile in macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded; do
  scripts/contracts/run-spec-012.sh --profile "$profile"
done
scripts/contracts/check-spec-012-raster-vectors.rb
```
