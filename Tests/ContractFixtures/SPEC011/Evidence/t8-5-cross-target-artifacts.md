# SPEC-011 T8.5 ARMv6 and nRF52840 Artifact Inspection

The Raspberry Pi driver builds the final Signal Analyzer preset with the
project-local Swift 6.3.2 toolchain and exact
`armv6-unknown-linux-gnueabihf` destination. The emitted artifact is ELF32
little-endian ARM EABI5 and the composed optimized IR/object audit rejects
ARMv7 or AArch64 substitution.

The Nordic driver builds `signal-analyzer-static` for
`nrf52840dk/nrf52840`, using Swift's `armv7em-none-none-eabi` module and
Zephyr's Cortex-M4F hard-float flags. Final ELF attributes report ARMv7E-M,
Thumb-2, VFPv4-D16, SP hard-float use, and `Tag_ABI_VFP_args: VFP registers`.
The linked memory, map, symbol, Static SIL/IR, fixed profile/capture/raster
storage, zero-heap, and direct typed-dispatch reports are verified before the
SPEC-011 report is published.

The toolchains remain below `.toolchains/`; Pi and Nordic artifacts remain
below `.build/raspberry-pi/` and `.build/nrf52840/`. The driver records
`connected_target_execution=false` and `flashing=false`. No hardware claim is
made from these artifacts.
