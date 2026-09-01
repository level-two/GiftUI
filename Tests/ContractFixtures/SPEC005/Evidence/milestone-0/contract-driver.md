# SPEC-005 Contract Driver

Plan task: `T0.3`

Date: 2026-09-01

## Command surface

The explicit registry preserves exactly these standalone hardware-free
commands:

- `scripts/contracts/run-spec-005.sh --profile macos-dynamic`
- `scripts/contracts/run-spec-005.sh --profile macos-static`
- `scripts/contracts/run-spec-005.sh --profile raspberry-pi-armv6`
- `scripts/contracts/run-spec-005.sh --profile nrf52840-embedded`

Missing and unknown profiles fail. Each accepted run replaces only its own
deterministic generated/report roots, verifies the exact text-resource source
list and package graph, validates the ordered fixture/corpus registries and
generated-asset hashes, records all input/output hashes and compiler commands,
and rejects an incomplete report.

## Pinned profiles

- macOS dynamic/static require Apple Swift 6.3.3 build
  `swiftlang-6.3.3.1.3`, target `arm64-apple-macosx26.0`, release `-O`, and
  whole-module optimization.
- Raspberry Pi requires project-local Swift 6.3.2 and the exact
  `armv6-unknown-linux-gnueabihf` Bookworm destination.
- nRF52840 requires project-local Swift 6.3.2, Embedded Swift, `-Osize`, WMO,
  `armv7em-none-none-eabi`, board `nrf52840dk/nrf52840`, Zephyr 4.3.0, SDK
  0.17.4, and Cortex-M4F hard-float flags.

Every report labels itself hardware-free and records remote access,
deployment, service restart, simulator execution, connected-target execution,
and flashing as false. The driver runs only doctor checks, compilers, package
inspection, and artifact hashing.

## Validation boundary

All four standalone commands passed against the pinned project-local
toolchains. The ARMv6 and nRF52840 results prove compilation, target identity,
and emitted module evidence only; they make no target-runtime, simulator, or
connected-hardware claim. The registry checker and top-level default gate also
pass with SPEC-005 registered explicitly.

Semantic declarations, positive/negative import fixtures, production generated
assets, resource measurements, deployment, connected execution, and flashing
remain outside this task.
