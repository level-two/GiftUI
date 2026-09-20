# SPEC-015 Milestone 6 — Raspberry Pi 1 ARMv6 Dynamic Preset

Evidence kind: `cross-build` plus a separately labeled host-native semantic
fixture. Connected execution is `not-collected`.

Reproduce from the repository root:

```sh
scripts/raspberry-pi/doctor.sh
scripts/contracts/run-spec-015.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-001.sh --profile raspberry-pi-armv6
```

The pinned Swift 6.3.2 cross-build emits
`.build/raspberry-pi/artifacts/SignalAnalyzerRaspberryPiARMv6`. The build
workflow verifies a 32-bit ARMv6 EABI5 ELF and the hard-float attributes. The
recorded artifact is 8,066,444 bytes after stripping and has SHA-256
`3ce04bde5b24b1af404c101b0db89035a045b174c7f477ce68ef898dc9e20dfc`.
Its dynamic imports are limited to `libstdc++`, `libm`, `libatomic`,
`libgcc_s`, `libc`, and the ARM hard-float loader.

The exact physical projection is 240 x 240 with a 240 x 16 RGB565 tile,
480-byte rows, and 7,680-byte raster/payload/in-flight bounds. The host-native
semantic fixture reports checksum `360515885`, equal to both macOS presets,
with the Dynamic 31,632-byte profile storage audit. The report explicitly
does not claim framebuffer, PiScreen, input, timing, process-memory, or other
connected-target evidence.
