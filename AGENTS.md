# GiftUI Agent Contract

## Repository workflow

- Run commands from the repository root.
- Keep the downloaded macOS compiler and cross-compilation SDK under
  `.toolchains/`.
- Keep generated Raspberry Pi builds and deployable artifacts under
  `.build/raspberry-pi/`.
- Do not run the Swift.org installer, install the ARMv6 SDK under `/opt`, or
  mutate Xcode/global Swift selection.

## Raspberry Pi skills

- Use `skills/giftui-pi-toolchain/SKILL.md` for toolchain setup, environment
  activation, diagnostics, and the ARMv6 probe.
- Use `skills/giftui-pi-build-deploy/SKILL.md` for Raspberry Pi builds and
  deployment.

## nRF52840 skills

- Use `skills/giftui-nrf-toolchain/SKILL.md` for Embedded Swift/Zephyr setup,
  activation, diagnostics, and the hardware-free board probe.
- Use `skills/giftui-nrf-build-flash/SKILL.md` for nRF52840 firmware builds,
  artifact inspection, and explicit J-Link flashing.

## Stable commands

- `scripts/raspberry-pi/setup-toolchain.sh`
- `scripts/raspberry-pi/doctor.sh`
- `scripts/raspberry-pi/doctor.sh --probe`
- `scripts/raspberry-pi/build.sh --product <product>`
- `scripts/raspberry-pi/deploy.sh --product <product>`
- `scripts/nrf52840/setup-toolchain.sh`
- `scripts/nrf52840/doctor.sh`
- `scripts/nrf52840/doctor.sh --probe`
- `scripts/nrf52840/build.sh --application <application>`
- `scripts/nrf52840/flash.sh --application <application>`

## Safety

- The supported board target is Raspberry Pi 1:
  `armv6-unknown-linux-gnueabihf`.
- Do not substitute an ARMv7 or AArch64 SDK.
- Do not deploy or restart a remote service unless the user requested a remote
  change.
- Before deploying, require the remote machine to report `armv6l`.
- The supported Nordic board is `nrf52840dk/nrf52840`. Swift uses its bundled
  `armv7em-none-none-eabi` module with Zephyr's Cortex-M4F hard-float flags;
  require ELF verification of the VFP calling convention.
- Keep nRF52840 toolchains under `.toolchains/nrf52840/` and generated firmware
  under `.build/nrf52840/`.
- Never flash an nRF52840-DK unless the user requested a connected-board
  change.
