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

Build without changing connected hardware:

```bash
scripts/nrf52840/build.sh --application ili9486
```

The Embedded Swift application calls a project-local C transport because the
pinned Zephyr 4.3.0 tree has no ILI9486 binding or driver. It performs hardware
reset, uses a conservative 4 MHz SPI clock, selects RGB565 MSB-first and a
fixed 480 × 320 landscape/BGR orientation, then writes eight color bars in
bounded 60 × 16 tiles. The initialization profile deliberately uses only
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
`RGB565TileRenderer` to draw the thermostat. Each 480 × 16 tile is handed to
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

Phase 7 redraws only the union of the previous and updated thermostat layout
bounds after a completed action. The initial frame and calibration screens
remain full-surface renders; update tiles are packed to the dirty rectangle so
the SPI transport does not send unchanged columns or rows.

The tracked Phase 7 measurement candidate keeps the 16-row renderer tile and
splits pixel payloads into at most 3,840-byte SPI transactions. Both values are
reported on UART at boot and have one source of truth in `include/ili9486.h`.
They are bounded starting values, not accepted tuning results; record connected
hardware measurements before changing them or raising the 4 MHz display clock.

Stack painting and thread stack metadata are enabled for Phase 7. UART reports
the main-thread high-water mark after the first thermostat frame and after each
successful dirty update. It also reports release-to-visible latency around
action dispatch, layout, rasterization, and the final synchronous SPI write.
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

Do not power the screen or flash this firmware until the exact PiScreen
revision, supply rail, backlight polarity/transistor stage, and unpowered
continuity have been recorded. After flashing, verify the red/yellow/green/
cyan/blue/magenta/white/black bar order, landscape orientation, and sharp bar
boundaries before increasing SPI speed or changing the initialization profile.
