# KMRTM24024-SPI firmware

This hardware-free target compiles GiftUI's static thermostat for the proposed
KMRTM24024-SPI wiring. It uses Zephyr's ILI9341/MIPI-DBI driver at 4 MHz, sends
MSB-first RGB565 in bounded four-row tiles, and keeps display readback, touch,
and backlight GPIO disabled until the hardware gates in the support
specification are complete.

Build without flashing:

```bash
scripts/nrf52840/build.sh --application kmrtm24024_spi
```

Only after the exact module and wiring have been verified, flash explicitly:

```bash
scripts/nrf52840/flash.sh --application kmrtm24024_spi
```
