# nRF52840 Connected Campaign Attempt

**Recorded:** 2026-09-25

The maintainer authorized connected tests and confirmed the shield orientation,
pin alignment, and power setup before flashing. The connected J-Link is serial
`683833660` with target voltage 3.30 V. The target is
`nrf52840dk/nrf52840`; the project-local board probe passed. The ELF reports
ARMv7E-M, VFPv4-D16, and `Tag_ABI_VFP_args: VFP registers`.

The first connected image stopped in `swift_allocObject` while evaluating the
deterministic source's next delay. The static schedule now uses integer
milliseconds and explicit comparisons instead of a variadic `min` call or
dynamic `Duration` arithmetic. Seven focused host source/repository tests
passed, and the connected source/capture startup checks advanced past the
former fault.

The subsequent connected run exposed main-stack exhaustion during canvas
rendering. The main stack was increased from 24,576 to 27,648 bytes, and the
validator now borrows the existing static model/interaction/gesture instances
and resets them in a separate function. The validator wrapper's generated
stack frame fell from 10,628 bytes to 56 bytes. The first-frame input probe
was likewise moved out of the render frame. The build remains within the
192 KiB firmware RAM ceiling: 196,416 bytes, with 242,076 bytes of flash.
The flashed ELF SHA-256 is
`2b203f3c29e906081eb38547ceec98049f3b78fa9588503901de1aa67ab7e6a6`;
the HEX SHA-256 is
`2d74201c5043f3999e95be187d7b7df233fbc718768fdf9342fd058d96aef5c1`.
The hardware-free SPEC-001 nRF profile gate passed 251 host tests and
published its cross-build report at
`.build/contract-reports/spec-001/20260925T173857Z-66640/nrf52840-embedded/`.

The board still raises a Zephyr MPU data-access fault at the main-stack guard
(`0x20029320`) during raster validation. A debugger snapshot before the fault
showed live raster work and a main-stack pointer at `z_main_stack + 13,792`;
the later fault demonstrates that this is not the peak. No successful initial
frame, 30-second run, six-control input sequence, or resource high-water mark
can be claimed. T8.2 remains blocked on reducing peak render stack use within
the approved 192 KiB RAM ceiling, then repeating the connected campaign.
