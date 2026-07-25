---
name: giftui-pi-toolchain
description: Set up, activate, inspect, repair, and verify GiftUI's project-local Swift cross-compilation environment for Raspberry Pi 1 ARMv6 and Raspberry Pi OS Bookworm. Use for toolchain installation, SDK diagnostics, compiler-version mismatches, environment checks, or ARMv6 probe builds.
---

# GiftUI Pi Toolchain

Run all commands from the repository root.

## Workflow

1. Read `scripts/raspberry-pi/toolchain.env` before changing the paired macOS
   compiler and ARMv6 SDK pins.
2. Run `scripts/raspberry-pi/doctor.sh`.
3. If the SDK is absent, run `scripts/raspberry-pi/setup-toolchain.sh`.
4. Run `scripts/raspberry-pi/doctor.sh --probe` after setup or repair.
5. Report the host Swift version, target triple, and probe artifact path.

Use `source scripts/raspberry-pi/env.sh` only when an interactive shell needs
the exported paths. The build scripts source the same configuration
automatically.

## Constraints

- Keep downloads, the unpacked macOS compiler, and the SDK under
  `.toolchains/`.
- Do not install under `/opt`.
- Do not run the downloaded `.pkg` installer or change Xcode's selected
  toolchain.
- Require host Swift `6.3.2`; do not wave through a version mismatch.
- Keep the target `armv6-unknown-linux-gnueabihf`.
- Do not replace the SDK with ARMv7 or AArch64 artifacts.
- Treat `setup-toolchain.sh --force` as a repair of generated local state only.
- Do not commit `scripts/raspberry-pi/local.env`.
