# SPEC-008 Declaration Profile Compilation Evidence

Plan task: `SPEC-008 T1.5`

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

For both optimized macOS profiles, the same checker also builds and runs the
declaration probe with the shared allocation interposer. After an unmeasured
runtime warmup, its measured pass verifies 14 admission cases byte-for-byte:
empty, 96-byte, rejected 97-byte, rejected malformed UTF-8, embedded and
trailing NUL, ASCII, degree, replacement scalar, and all five required Int32
values. The recorded result is zero byte mismatches and zero measured heap
allocations. Successful process completion records zero observed traps.

The measured traversal includes an invalid Text declaration and a three-level
style chain. It records two primitive visits, three modifier visits, and zero
body evaluations. Package tests independently verify exact stored bytes,
malformed input coverage, the one-call `withUTF8` contract, closed invalid
Text storage, and exact style source order. Raspberry Pi and nRF52840 evidence
remains hardware-free compile evidence; runtime counters are host-profile
measurements and make no connected-target claim.

Reproduce from the repository root:

```text
scripts/contracts/check-spec-008-declaration-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-008-declaration-profiles.sh --profile macos-static
scripts/contracts/check-spec-008-declaration-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-008-declaration-profiles.sh --profile nrf52840-embedded
swift test --filter BoundedTextTests
swift test --filter TextTests
swift test --filter StyleModifierTests
```
