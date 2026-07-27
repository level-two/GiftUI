---
name: giftui-nrf-build-flash
description: Build, inspect, and explicitly flash GiftUI Embedded Swift/Zephyr firmware for the Nordic nRF52840-DK. Use for nRF firmware builds, ELF architecture and resource reports, Devicetree inspection, J-Link flashing, or board bring-up diagnostics.
---

# GiftUI nRF Build and Flash

Run all commands from the repository root.

## Build and inspect

1. Run `scripts/nrf52840/doctor.sh`.
2. Build with `scripts/nrf52840/build.sh --application <name>`.
3. Require the ELF ARMv7E-M and hard-float checks to pass.
4. Use the emitted `ELF=`, `HEX=`, `MAP=`, `DEVICETREE=`, and `REPORTS=`
   paths rather than guessing paths inside the build tree.

Use `scripts/nrf52840/doctor.sh --probe` for toolchain diagnostics. The probe
must build without connected hardware and retain the Swift entry symbol.

## Flash

Flash only when the user explicitly requests a connected-board change:

```bash
scripts/nrf52840/flash.sh --application <name>
```

Use `--no-build` only after verifying the explicitly named application's ELF
and HEX. Keep the J-Link runner; do not substitute an implicit build runner.

## Constraints

- Build only for `nrf52840dk/nrf52840` using Swift's
  `armv7em-none-none-eabi` module plus Zephyr's Cortex-M4F hard-float flags.
- Never invoke `flash.sh` from setup, doctor without an explicit flash request,
  build, tests, or another host-only workflow.
- Keep generated output under `.build/nrf52840/<application>/`.
- Treat the current probe as environment validation, not completed display,
  touch, or thermostat board support.
