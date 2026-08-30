# SPEC-004 T2.5 Bounded Resolver Work Evidence

The resolver records fixed-width `UInt16` counters at its actual decision
points when `GIFTUI_CAPABILITY_INSTRUMENTATION` is enabled. The counters cover
resolver invocation, four role visits, operation-set and stream comparisons,
set intersections, checked byte arithmetic, candidate checks, and exactly one
validation-result construction.

The normalized semantic probe proves:

- a widest two-candidate, two-encoding path performs 44 primitive operations;
- that maximum traverses both candidates and both encoding arithmetic paths;
- an early producer-stream negative performs 8 primitive operations;
- every later failure is a prefix of, or omits work from, the measured widest
  path, so every success and negative path remains below the ceiling of 96;
- 10,000 repeated reads of an already-built snapshot perform zero resolver
  invocations and zero counted primitive operations; and
- all counters use fixed-width storage and are absent unless the dedicated
  instrumentation compilation condition is enabled.

The macOS contract driver compiles the semantic probe with instrumentation,
compiles production dynamic/static resource images without it, and rejects any
instrumentation symbol in those images. The ARMv6 and nRF52840 production
module commands likewise omit the instrumentation condition.

Validated commands on 2026-08-30:

```text
swift test --filter GiftUICapabilitiesTests
scripts/contracts/run-spec-004.sh --profile macos-dynamic
scripts/contracts/run-spec-004.sh --profile macos-static
scripts/contracts/run-spec-004.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-004.sh --profile nrf52840-embedded
```

All commands passed. The profile results are hardware-free evidence only.
