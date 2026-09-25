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

A temporary diagnostic image skipped only the startup full-canvas self-check.
It reached the same main-stack guard fault (`0x20029320`) in the production
path, so skipping the self-check cannot resolve the connected failure. The
source was restored, and the committed HEX with SHA-256
`2d74201c5043f3999e95be187d7b7df233fbc718768fdf9342fd058d96aef5c1`
was reflashed successfully. The repository working tree is clean.

The final 192-byte RAM headroom was also tested as main stack: 27,840 bytes
made the linked image exactly 196,608 bytes (192 KiB). The connected run still
faulted at the main-stack guard (`0x20029338`). The build was returned to its
committed 27,648-byte stack and the committed HEX was reflashed. Increasing
the stack within the approved RAM limit is insufficient.

## Follow-up stack-lifetime repair and connected run

The subsequent repair kept the canvas renderer, validation probe, and
production presentation in separate non-inlined stack frames. It moved the
first-frame input probe after the render traversal, split its raw gesture,
sequence, and input-drain checks into separate calls, and kept the temporary
gesture session in static storage. The generated first-frame probe entry frame
fell from 10,404 bytes to 80 bytes. Its checks and the production input path
remain enabled.

The exact final ELF SHA-256 is
`e8d4d31aa01b66196c85b9030608b712cf13b5952191ce92d1bd644217a8ab40`;
the flashed HEX SHA-256 is
`b3394cd967200621e841166564e4a0d8df4224f0e4cf320366a4e8c65d7938ce`.
The linked image uses 196,480 bytes of RAM and 241,284 bytes of flash. ELF
attributes retain ARMv7E-M, VFPv4-D16, and the VFP-register calling
convention. The project-local doctor and build passed. The SPEC-001 nRF
profile gate passed 251 host tests and published its cross-build report at
`.build/contract-reports/spec-001/20260925T183048Z-79559/nrf52840-embedded/`.

The final HEX was flashed through the repository J-Link workflow to serial
`683833660`. After more than 30 continuous seconds without a serial fault,
J-Link found the target in `giftui_static_host_wait_until` under
`giftui_production_host_run`, with the main-stack pointer at
`z_main_stack + 27,456` while idle. This confirms startup validation,
first-frame presentation, and the input probe returned to the production
scheduler. It does not establish peak stack use; the inspected stack image did
not contain a reliable untouched fill interval. The maintainer's earlier
photo showed a partial image from the previous firmware. A fresh visual
inspection, six physical controls, frame cadence, and touch behavior are
still needed before T8.2 can pass.

## Physical display identification and blocked gate

The maintainer's follow-up front photo showed a mostly white panel with a few
colored lines at the top. While the firmware was in its production scheduler,
the built-in `ili9486_render_color_bars()` diagnostic returned zero through
J-Link, but the maintainer observed no eight-bar pattern: only top lines and
green dots at the bottom left. SPI API success therefore does not establish
correct display output.

The maintainer then supplied a back photo. Its silkscreen reads
`KMRTM24024-SPI` and `2.4 TFT SPI 240*320`. The display pins are marked
`CS`, `RESET`, `D/C`, `SDI(MOSI)`, `SCK`, `LED`, and `SDO(MISO)`; separate
`T_CLK`, `T_CS`, `T_DIN`, `T_OUT`, and `T_IRQ` pins serve touch. This is a
240 x 320 direct-SPI module, commonly documented as ILI9341-class, rather
than the approved 480 x 320 ILI9486 PiScreen serial-to-parallel target. The
flashed firmware's extent, address windows, command framing, and controller
initialization therefore do not match the physical panel. The visible failure
is consistent with this mismatch; no display, touch, or 30-second connected
scenario pass is claimed.

An ILI9486 initialization candidate was briefly cross-built and flashed
before the back photo arrived. It added the Linux ILI9486 power, VCOM, and
gamma sequence, but cannot make this 240 x 320 direct-SPI module conform.
That source change was removed after identification. T8.2 remains open until
a supported 480 x 320 ILI9486/ADS7846 display is connected or the approved
contracts are explicitly revised through the lifecycle. An optional
240 x 320 target variant is preserved separately in
[FW-023](../../../../docs/future-work/fw-023-ili9341-240x320-target-variant.md).
The previously tested commit `c73ed22c` was rebuilt from an isolated clean
checkout and its HEX SHA-256
`b3394cd967200621e841166564e4a0d8df4224f0e4cf320366a4e8c65d7938ce`
was flashed back to J-Link serial `683833660`. The display remains physically
incompatible with that restored firmware.
