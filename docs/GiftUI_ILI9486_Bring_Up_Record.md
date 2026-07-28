# GiftUI ILI9486 Bring-Up Record

This record separates the completed hardware-free Phase 5 implementation from
claims that require the exact nRF52840-DK/PiScreen assembly. Do not replace a
`Not measured` entry with an assumption.

## Software baseline

| Item | Value |
| --- | --- |
| Firmware application | `ili9486` |
| Firmware implementation revision | `3e33c55` |
| Board target | `nrf52840dk/nrf52840` |
| Swift | 6.3.2 |
| Zephyr | 4.3.0 (`3568e1b6d5cdd51a6b964a2a1d6d29200fea2056`) |
| Zephyr SDK | 0.17.4 |
| Swift module target | `armv7em-none-none-eabi` |
| SPI bring-up clock | 4 MHz |
| Pixel format | RGB565, most-significant byte first |
| Initial orientation | 480 × 320 landscape, MADCTL `MV | BGR` |
| Swift display tile | 480 × 16 × 2 = 15,360 bytes |
| Linked flash baseline | 49,104 bytes |
| Linked RAM baseline | 38,908 bytes, including a 32 KiB main stack |
| Zephyr heap | Disabled (`CONFIG_HEAP_MEM_POOL_SIZE=0`) |

The hardware-free build produces ARMv7E-M hard-float ELF, HEX, map, resolved
Devicetree, section, symbol, and memory reports under
`.build/nrf52840/ili9486/`. It retains the Embedded Swift entry point, static
runtime, and RGB565 backend. No firmware was flashed while creating this
baseline.

## Hardware provenance gate

| Check | Recorded value | Evidence/reviewer |
| --- | --- | --- |
| PiScreen vendor | Not recorded | — |
| PiScreen model/revision | Not recorded | — |
| Front photograph | Not recorded | — |
| Back photograph | Not recorded | — |
| ILI9486 identity source | Not recorded | — |
| Working Raspberry Pi overlay/config | Not recorded | — |
| ADS7846 identity source | Not recorded | — |
| Panel supply rail | Not measured | — |
| Idle/active panel current | Not measured | — |
| Logic-high voltage at panel inputs | Not measured | — |
| Backlight transistor/enable circuit | Not verified | — |
| Backlight active polarity | Not verified | — |
| LCD/touch MISO high impedance when deselected | Not measured | — |

Do not power the screen until the supply rail is known. Do not configure D5 as
`backlight-gpios` until its polarity and load-driving circuit are verified.

## Unpowered continuity gate

Verify by signal name; Raspberry Pi and Arduino header positions do not align.

| Signal | DK header | nRF52840 | PiScreen endpoint | Result |
| --- | --- | --- | --- | --- |
| SPI MOSI | D11 | P1.13 | Pi pin 19 / LCD MOSI | Not measured |
| SPI MISO | D12 | P1.14 | Pi pin 21 / touch MISO | Not measured |
| SPI SCLK | D13 | P1.15 | Pi pin 23 / SCLK | Not measured |
| LCD CS | D10 | P1.12 | Pi pin 24 / LCD CS | Not measured |
| LCD D/C | D9 | P1.11 | Pi pin 18 / LCD D/C | Not measured |
| LCD reset | D8 | P1.10 | Pi pin 22 / LCD reset | Not measured |
| Ground | GND | GND | PiScreen ground | Not measured |
| No adjacent shorts | — | — | Every adapter conductor | Not measured |

Touch CS, PENIRQ, and backlight wiring belong in this adapter review even
though the Phase 5 tracked overlay intentionally leaves them unconfigured.

## Connected-board procedure

Only after the provenance and continuity gates have been reviewed:

1. Connect a UART console at 115200 baud.
2. Apply the one verified panel supply; never connect both 3.3 V and 5 V.
3. Build and inspect the exact image:

   ```bash
   scripts/nrf52840/build.sh --application ili9486
   ```

4. Flash only through the explicit J-Link command:

   ```bash
   scripts/nrf52840/flash.sh --application ili9486 --no-build
   ```

5. Confirm eight vertical bars in this order: red, yellow, green, cyan, blue,
   magenta, white, black. Record channel order, orientation, sharp boundaries,
   and any corruption.
6. Confirm the color bars are replaced after two seconds by the static
   thermostat showing `Target`, `21°`, `-`, and `+`.
7. Record UART-reported color-bar and thermostat transfer times.
8. Repeat at least 20 resets and 20 complete pattern/thermostat transfers at
   4 MHz before considering a higher SPI clock.

## Results

| Measurement | Result |
| --- | --- |
| Flash date/operator | Not run |
| UART initialization result | Not run |
| Color order | Not observed |
| Orientation | Not observed |
| Address-window boundaries | Not observed |
| Color-bar transfer time | Not measured |
| Thermostat transfer time | Not measured |
| Repeated transfers | 0 |
| Reset/power-cycle passes | 0 |
| Accepted SPI clock | Not established |
| Accepted controller-specific init/gamma profile | Not established |
| Measured main-stack high-water mark | Not measured |

## Phase 5 disposition

The hardware-free implementation is ready for connected-board validation. The
Phase 5 gate remains open until the exact screen passes the provenance,
continuity, color/orientation/address-window, repeated-transfer, timing, and
stack checks above without corruption, resets, or out-of-bounds writes.
