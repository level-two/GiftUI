---
name: giftui-nrf-toolchain
description: Set up, activate, inspect, repair, and verify GiftUI's project-local Embedded Swift and Zephyr environment for the Nordic nRF52840-DK. Use for nRF52840 toolchain installation, version or checksum diagnostics, Zephyr workspace repair, environment activation, or the hardware-free Swift-to-Zephyr probe.
---

# GiftUI nRF Toolchain

Run all commands from the repository root.

## Workflow

1. Read `scripts/nrf52840/toolchain.env` before changing any pin.
2. Run `scripts/nrf52840/doctor.sh`.
3. If generated state is absent, run `scripts/nrf52840/setup-toolchain.sh`.
4. Run `scripts/nrf52840/doctor.sh --probe` after setup or repair.
5. Report the resolved version set and emitted probe artifact paths.

Source `scripts/nrf52840/env.sh` only for an interactive shell. Build scripts
activate the same environment automatically.

## Constraints

- Keep every download and checkout under `.toolchains/nrf52840/`.
- Keep firmware and reports under `.build/nrf52840/`.
- Do not install Swift, Zephyr, or the SDK globally or change Xcode selection.
- Keep board `nrf52840dk/nrf52840` and Swift's supported module target
  `armv7em-none-none-eabi`; take Cortex-M4F and hard-float flags from Zephyr
  and verify the final ELF's VFP calling convention.
- Require all archive checksums and Git revisions to match tracked pins.
- Treat `setup-toolchain.sh --force` as repair of ignored generated state only.
- Do not commit `scripts/nrf52840/local.env`.
- Never flash as part of setup, doctor, build, or host tests.
