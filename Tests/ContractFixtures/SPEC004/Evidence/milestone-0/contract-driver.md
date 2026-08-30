# SPEC-004 Contract Driver Evidence

Plan task: `T0.3`

Date: 2026-08-30

## Command surface

The registered standalone driver accepts exactly these hardware-free profiles:

- `scripts/contracts/run-spec-004.sh --profile macos-dynamic`
- `scripts/contracts/run-spec-004.sh --profile macos-static`
- `scripts/contracts/run-spec-004.sh --profile raspberry-pi-armv6`
- `scripts/contracts/run-spec-004.sh --profile nrf52840-embedded`

Unknown or missing profiles fail. Each run replaces only its deterministic
generated and report roots, verifies the exact capability source list and
package graph, records repository revision/dirty state, hashes every checked-
in input and emitted image, preserves the complete commands and compiler
identity, and records a deterministic exit.

## Pinned profiles

- macOS dynamic/static use Apple Swift 6.3.3 build
  `swiftlang-6.3.3.1.3`, target `arm64-apple-macosx26.0`, release `-O`, and
  whole-module optimization.
- Raspberry Pi uses the project-local Swift 6.3.2 Bookworm SDK and exact
  `armv6-unknown-linux-gnueabihf` destination.
- nRF52840 uses project-local Swift 6.3.2, Embedded Swift, `-Osize`, WMO,
  target `armv7em-none-none-eabi`, board `nrf52840dk/nrf52840`, Zephyr 4.3.0,
  SDK 0.17.4, and Cortex-M4F hard-float flags.

The cross-profile commands invoke only doctors, compilers, and artifact
inspection. Metadata records `remote_access=false`, `deployment=false`,
`service_restart=false`, and `flashing=false`.

## Validation

All four standalone commands passed using the pinned project-local toolchains.
`scripts/contracts/check-driver-registry.rb` and the no-argument
`scripts/test.sh` gate also passed with SPEC-004 registered explicitly.

This is harness evidence only. Semantic capability declarations and compile-
boundary fixtures begin in later tasks.
