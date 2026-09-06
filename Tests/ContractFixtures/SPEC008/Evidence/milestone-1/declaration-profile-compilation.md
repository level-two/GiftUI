# SPEC-008 Declaration Profile Compilation Evidence

Plan task: `SPEC-008 T1.5` (cross-profile compilation slice)

The profile-aware declaration checker compiles the exact maintained `GiftUI`
declaration sources and 17 registered positive/negative client fixtures with
the pinned compiler, target, SDK, optimization, and dynamic/static condition
for macOS dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840 Embedded
Swift. It records a per-fixture result table and the compiled `GiftUI` module
inside each immutable SPEC-008 report.

The consolidated positive boundary covers every named color; empty, 96-byte,
97-byte, malformed, embedded-NUL, trailing-NUL, ASCII, degree, and replacement
text inputs; the five required `Int32` boundary/control values; modifier
chaining; and a custom view. Negative fixtures exclude `clear`, alpha,
backend hooks, unbounded `String`, interpolation, payload construction/access,
mutable byte count, private storage, and wrapper storage.

This slice makes only hardware-free compilation claims. Exact admitted bytes
and allocation/trap/body-evaluation counters remain required before T1.5 is
complete.

Reproduce from the repository root:

```text
scripts/contracts/check-spec-008-declaration-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-008-declaration-profiles.sh --profile macos-static
scripts/contracts/check-spec-008-declaration-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-008-declaration-profiles.sh --profile nrf52840-embedded
```
