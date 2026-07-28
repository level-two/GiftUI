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

The backlight pin remains unconfigured in the tracked overlay. If the optional
`backlight-gpios` property is added after hardware verification, the transport
keeps it inactive through reset and enables it only after initialization.

After the color-bar diagnostic, firmware waits two seconds and uses the real
Embedded Swift `StaticRuntime`, portable thermostat view, built-in font, and
`RGB565TileRenderer` to draw the thermostat. Each 480 × 16 tile is handed to
the same checked C rectangular writer, so the firmware cannot construct or
transfer a full-screen framebuffer. UART output reports the color-bar and
thermostat transfer times separately.

Do not power the screen or flash this firmware until the exact PiScreen
revision, supply rail, backlight polarity/transistor stage, and unpowered
continuity have been recorded. After flashing, verify the red/yellow/green/
cyan/blue/magenta/white/black bar order, landscape orientation, and sharp bar
boundaries before increasing SPI speed or changing the initialization profile.
