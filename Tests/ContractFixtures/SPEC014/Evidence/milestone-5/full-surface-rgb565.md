# SPEC-014 T5.2 Hardware-Free Full-Surface RGB565 Framebuffer

Date: 2026-09-13

`FullSurfaceRGB565Framebuffer` implements the same bounded `RasterSurface`
contract as the RGBA8888 realization while preserving canonical big-endian
RGB565 bytes. Caller-owned storage represents an already-provided mapped
surface; the implementation performs no device discovery or mapping.

The focused 4 x 3 fixture uses an 11-byte stride and records mapped bytes,
workspace bytes, and their checked total separately. It verifies exact bytes,
untouched row padding, wrong-encoding and short-storage rejection, accounting
overflow, and post-transfer validation-only drain behavior.

Run from the repository root:

```sh
swift test --filter fullSurfaceRGB565Framebuffer
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

These are host tests and hardware-free cross-compiles only. No remote access,
deployment, service restart, framebuffer open, or connected-target execution
occurs.
