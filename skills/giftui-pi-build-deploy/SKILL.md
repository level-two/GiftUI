---
name: giftui-pi-build-deploy
description: Cross-build GiftUI executable products as verified 32-bit ARMv6 Linux binaries, deploy them atomically to a Raspberry Pi 1 over SSH, and exercise PiScreen/GPIO hardware. Use for Raspberry Pi builds, deploys, remote runs, framebuffer or GPIO smoke tests, user-service restarts, artifact inspection, or daily Mac-to-Pi development loops.
---

# GiftUI Pi Build and Deploy

Run all commands from the repository root.

## Build

1. Run `scripts/raspberry-pi/doctor.sh`.
2. Build with:

   ```bash
   scripts/raspberry-pi/build.sh --product <executable-product>
   ```

3. Require the script's ELF, ARMv6, and hard-float attribute checks to pass.
4. Use the emitted `ARTIFACT=` path; do not guess inside SwiftPM scratch
   directories.

Use `scripts/raspberry-pi/build.sh --probe` when diagnosing the toolchain rather
than the application.

## Deploy

Only deploy when the user requested a remote change.

```bash
scripts/raspberry-pi/deploy.sh --product <executable-product>
```

Use `--run` only for a foreground remote run. Use
`--restart-service <name>` only when that user service is already configured.
Use `--dry-run` to inspect remote-changing commands.

Set machine-local defaults in `scripts/raspberry-pi/local.env`, copied from
`local.env.example`. Never put credentials or private keys in tracked files.

## Physical input

Only run hardware-changing commands when the user requested device work. Read
`docs/GiftUI_Raspberry_Pi_Platform.md` before choosing GPIO lines. Require the
Pi to provide `libgpiod.so.2`, `/dev/gpiochip0`, and unprivileged GPIO access.

Use the default active-low buttons only after verifying BCM GPIO 17, 27, and
22 do not conflict with the PiScreen overlay:

```bash
giftui/bin/GiftUIExampleThermostatRaspberryPi \
    --device /dev/fb1 \
    --gpio-buttons
```

Use `--gpio-previous`, `--gpio-next`, and `--gpio-activate` to select different
GPIO chip offsets. Do not treat physical header pin numbers as GPIO offsets.

## Constraints

- Default to the static Swift runtime destination.
- Never deploy a macOS Mach-O or an ARM64/ARMv7 binary.
- Let `deploy.sh` reject a remote host that does not report `armv6l`.
- Keep deployment unprivileged under the configured SSH user's home.
- Do not restart system services or write system directories implicitly.
