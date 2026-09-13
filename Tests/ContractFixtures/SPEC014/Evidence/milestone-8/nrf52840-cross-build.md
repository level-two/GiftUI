# SPEC-014 T8.5 nRF52840 Cross-Build Evidence

Date: 2026-09-13

The nRF52840 toolchain preflight and hardware-free probe passed with project-
local Swift 6.3.2, Zephyr 4.3.0 at revision
`3568e1b6d5cdd51a6b964a2a1d6d29200fea2056`, Zephyr SDK 0.17.4,
`nrf52840dk/nrf52840`, and `armv7em-none-none-eabi`.

The SPEC-014 collector compiled Surface, Raster, Display, and Backend
Integration modules with `-Osize`, whole-module Embedded Swift, and Zephyr's
Cortex-M4F hard-float flags, then linked baseline and candidate Zephyr ELFs.
The final ELF reports ARMv7E-M, VFPv4-D16, and VFP register arguments. The
optimized entry constructs the fixed 3,840-byte workspace, traverses and
submits a worst-case 480 x 320 fill as 80 tiles and 320 regions, and finishes
the frame. Its SIL contains zero heap-allocation instructions; maps retain no
full-surface framebuffer or recording-list symbol.

The exact selected bounds are 480 x 4, 960 bytes per row, 3,840 tile/raster/
payload/in-flight bytes, one slot, 80 tile visits and payloads, and 320 regions.
Section deltas, symbols, value layouts, maps, and explicit non-executed timing
disposition are under `.build/spec-014/t8.5/nrf52840-embedded/`.

Run from the repository root:

```sh
scripts/nrf52840/doctor.sh
scripts/nrf52840/doctor.sh --probe
scripts/contracts/collect-spec-014-nrf-evidence.sh .build/spec-014/t8.5/nrf52840-embedded
```

All commands passed. No flash or connected TFT validation was performed or
claimed.
