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

## Stable commands

- `scripts/raspberry-pi/setup-toolchain.sh`
- `scripts/raspberry-pi/doctor.sh`
- `scripts/raspberry-pi/doctor.sh --probe`
- `scripts/raspberry-pi/build.sh --product <product>`
- `scripts/raspberry-pi/deploy.sh --product <product>`

## Safety

- The supported board target is Raspberry Pi 1:
  `armv6-unknown-linux-gnueabihf`.
- Do not substitute an ARMv7 or AArch64 SDK.
- Do not deploy or restart a remote service unless the user requested a remote
  change.
- Before deploying, require the remote machine to report `armv6l`.
