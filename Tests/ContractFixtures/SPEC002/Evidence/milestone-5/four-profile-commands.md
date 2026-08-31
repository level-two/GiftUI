# SPEC-002 T5.1 Four-Profile Command Evidence

**Task:** `T5.1`

**Recorded:** 2026-08-31

## Toolchain readiness

The project-local toolchain skills and tracked pin files were followed before
cross-profile execution.

| Target environment | Doctor/probe result |
| --- | --- |
| Raspberry Pi 1 | Swift 6.3.2 project-local compiler and Bookworm SDK passed; target is `armv6-unknown-linux-gnueabihf`; probe emitted `.build/raspberry-pi/artifacts/GiftUIToolchainProbe`, verified as ARM EABI5 hard-float |
| nRF52840-DK | Swift 6.3.2, Zephyr 4.3.0 at `3568e1b6d5cdd51a6b964a2a1d6d29200fea2056`, SDK 0.17.4, and board `nrf52840dk/nrf52840` passed; probe emitted `.build/nrf52840/probe/zephyr/zephyr.elf`, `.hex`, and `.map` with the Cortex-M4F hard-float contract |

No toolchain was installed or repaired. The probes used only ignored
project-local toolchain and build directories. Neither probe deployed,
accessed a remote target, or flashed hardware.

## Exact driver surfaces

| Profile | Compiler / target | Required mode | Result |
| --- | --- | --- | --- |
| `macos-dynamic` | Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), `arm64-apple-macosx26.0`, macOS SDK 26.5 | `-O -whole-module-optimization -DGIFTUI_DYNAMIC_PROFILE` | passed |
| `macos-static` | Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), `arm64-apple-macosx26.0`, macOS SDK 26.5 | `-O -whole-module-optimization -DGIFTUI_STATIC_PROFILE`, static library | passed |
| `raspberry-pi-armv6` | project-local Swift 6.3.2 / Bookworm, `armv6-unknown-linux-gnueabihf` | release `-O`, explicit whole-module optimization, static Swift runtime | passed |
| `nrf52840-embedded` | project-local Swift 6.3.2, `armv7em-none-none-eabi`, Zephyr 4.3.0 / SDK 0.17.4 | Embedded Swift, `-Osize`, whole-module optimization, Cortex-M4F hard-float flags | passed |

The Raspberry Pi command includes
`-Xswiftc -whole-module-optimization` explicitly, matching the metadata rather
than relying on SwiftPM's release defaults.

## Reproduction

Run from the repository root:

```sh
scripts/raspberry-pi/doctor.sh --probe
scripts/nrf52840/doctor.sh --probe
scripts/contracts/run-spec-002.sh --profile macos-dynamic
scripts/contracts/run-spec-002.sh --profile macos-static
scripts/contracts/run-spec-002.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-002.sh --profile nrf52840-embedded
```

Each profile replaces only its own generated report under
`.build/contract-reports/spec-002/<profile>/` and records compiler identity,
target, SDK or environment pins, optimization flags, commands, revision, and
exit status. This is hardware-free compilation evidence, not connected-target
conformance.
