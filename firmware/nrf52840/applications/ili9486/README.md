# GiftUI ILI9486 bring-up firmware

This application targets the PiScreen ILI9486 on the nRF52840-DK Arduino
header. The tracked Devicetree uses the Phase 5 signal assignment:

| Signal | DK pin | nRF52840 GPIO |
| --- | --- | --- |
| SCLK | D13 | P1.15 |
| MISO | D12 | P1.14 |
| MOSI | D11 | P1.13 |
| LCD CS | D10 | P1.12 |
| LCD D/C | D9 | P1.11 |
| LCD reset | D8 | P1.10 |
| Touch CS | D7 | P1.08 |
| Touch PENIRQ | D6 | P1.07 |

The supported PiScreen electrical path includes the board's
SPI-to-16-bit-parallel converter. Controller commands and 8-bit parameters are
transmitted as zero-extended 16-bit values; RGB565 pixels are transmitted as
native 16-bit values. A bare ILI9486 configured for its native serial interface
requires a different transport profile.

Build without changing connected hardware:

```bash
scripts/nrf52840/build.sh --application ili9486
```

The Embedded Swift application calls a project-local C transport because the
pinned Zephyr 4.3.0 tree has no ILI9486 binding or driver. It performs hardware
reset, uses a conservative 4 MHz SPI clock, selects RGB565 MSB-first and a
fixed 480 × 320 landscape/BGR orientation, then writes eight color bars in
bounded solid 60 × 320 regions. The initialization profile deliberately uses only
standard reset, pixel-format, memory-access, sleep-out, and display-on
commands; controller-specific power and gamma values must come from the
verified working PiScreen configuration.

The tracked Phase 6 transport declares the ADS7846 as a second device on the
same SPI controller. Its independent D7 chip select starts inactive, PENIRQ is
an active-low input with a pull-up, and raw 12-bit X/Y/Z1/Z2 conversions run at
no more than 2 MHz. Zephyr's synchronous SPI API serializes each touch or
display transaction and applies the selected device's frequency and chip
select; touch reads never run from GPIO interrupt context.

The backlight pin remains unconfigured in the tracked overlay. If the optional
`backlight-gpios` property is added after hardware verification, the transport
keeps it inactive through reset and enables it only after initialization.

After the color-bar diagnostic, firmware waits two seconds and uses the real
Embedded Swift `StaticRuntime`, portable thermostat view, built-in font, and
`RGB565TileRenderer` to draw the thermostat. Each 480 × 4 tile is handed to
the same checked C rectangular writer, so the firmware cannot construct or
transfer a full-screen framebuffer. UART output reports the color-bar and
thermostat transfer times separately.

Phase 6 then presents five 16-pixel-inset calibration targets in top-left,
top-right, bottom-left, bottom-right, and center order. Each target has a
15-second timeout, records a pressure-qualified median of three X/Y/Z1/Z2
samples to UART, and requires release before advancing. After calibration,
the firmware polls PENIRQ every 10 ms, maps median samples into display
orientation, and feeds down/move/up events through the static layout's hit
regions. A typed thermostat action is dispatched once on release only when the
tap ends in the control where it began, then the updated model is rerendered.
Calibration failure is bounded and leaves the rendered thermostat available
without enabling uncalibrated input.

Phase 7 uses the ILI9486's retained GRAM after a completed action. The static
runtime compares old and new fixed layout arenas and returns the union of only
nodes whose rendered pixels changed. The initial frame and calibration screens
remain full-surface tile renders; updates clear the narrow damage rectangle and
replay clipped operations as solid RGB565 rectangles without a Swift pixel
buffer. The host-verified 21→22 update writes 324 pixels (648 payload bytes) in
23 rectangles instead of rerasterizing the 7,168-byte root region.

The tracked measurement candidate uses a four-row renderer tile and splits
pixel payloads into at most 3,840-byte SPI transactions. Both values are
reported on UART at boot and have one source of truth in `include/ili9486.h`.
They are bounded starting values, not accepted tuning results; record connected
hardware measurements before changing them or raising the 4 MHz display clock.

Stack painting and thread stack metadata are enabled for Phase 7. UART reports
the main-thread high-water mark after the first thermostat frame and after each
successful dirty update. It also reports release-to-visible latency around
action dispatch, layout, rasterization, and the final synchronous SPI write.
The 24 KiB main stack is a hardware-free candidate enabled by reducing the
inline tile from 15,360 to 3,840 bytes; accept it only after worst-case runs
retain at least 25% measured stack margin.
Use a complete connected-board run to calculate median and worst-case latency;
the instrumentation alone is not a hardware measurement.

Both the Zephyr system heap and common C allocation arena are explicitly zero.
The Embedded Swift ABI's `posix_memalign` symbol is a fail-closed shim that
always returns `ENOMEM` and never links an allocator. The build additionally
rejects real allocation entry points in the final ILI9486 ELF.

Capacity, display-controller, display-SPI, touch-controller, and touch-SPI
faults have separate fixed counters. UART preserves the first eight instances
of each category and then reports only power-of-two counts, keeping repeated
hardware failures observable without turning the polling loop into a logging
spin. Display failures return through bounded render paths; touch failures
clear pressed state, back off, and leave display updates available.

During calibrated operation, a one-minute validation heartbeat reports uptime,
successful update count, all five fault totals, and the stack high-water mark.
Use it with `docs/GiftUI_PiScreen_Phase_7_Validation_Record.md`; the heartbeat
does not replace visual inspection, power cycling, or captured timing results.

Do not power the screen or flash this firmware until the exact PiScreen
revision, supply rail, backlight polarity/transistor stage, and unpowered
continuity have been recorded. After flashing, verify the red/yellow/green/
cyan/blue/magenta/white/black bar order, landscape orientation, and sharp bar
boundaries before increasing SPI speed or changing the initialization profile.
