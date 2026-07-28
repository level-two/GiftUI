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

The initial Embedded Swift application only verifies the resolved bus and control GPIOs. It
drives chip-select and D/C inactive, holds reset asserted, and leaves the
backlight pin unconfigured. Do not add `backlight-gpios`, power the screen, or
flash this firmware until the exact PiScreen revision, supply rail, backlight
polarity/transistor stage, and unpowered continuity have been recorded.
