# KMRTM24024-SPI firmware

This target compiles GiftUI's static thermostat for the KMRTM24024-SPI wiring.
It uses Zephyr's ILI9341/MIPI-DBI driver at 4 MHz and sends MSB-first RGB565 in
bounded four-row tiles. Display readback and backlight GPIO remain disabled.

The optional XPT2046 resistive-touch controller shares SCLK, MOSI, and MISO
with the display at a separate 2 MHz SPI configuration. D7/P1.08 is its
active-low chip select and D6/P1.07 is its active-low PENIRQ input. Firmware
enables the nRF52840 GPIO pull-up on PENIRQ, polls it every 10 ms outside ISR
context, and powers the XPT2046 down between conversions so PENIRQ remains
available. The KMRTM profile accepts Z1 values from 50 and a bounded integer
resistance proxy up to 30,000, based on connected-board XPT2046 measurements;
the portable ADS7846/PiScreen defaults remain unchanged.

At boot the application displays five calibration targets in top-left,
top-right, bottom-left, bottom-right, and center order. Each target has a
30-second timeout. Hold the target until a raw X/Y/Z1/Z2 sample is logged over
the 115200-baud UART, then fully release before pressing the next target. After
calibration, completed taps dispatch through GiftUI's static hit regions and
rerender only the changed thermostat region. A touch initialization or
calibration failure leaves the thermostat display available without touch.

Wiring:

| Function | DK Arduino pin | nRF52840 GPIO |
| --- | --- | --- |
| Shared MOSI / touch DIN | D11 | P1.13 |
| Shared MISO / touch DOUT | D12 | P1.14 |
| Shared SCLK / touch CLK | D13 | P1.15 |
| LCD CS | D10 | P1.12 |
| Touch CS | D7 | P1.08 |
| Touch PENIRQ | D6 | P1.07 |

Both chip selects must be inactive while the other device owns the bus. Verify
that LCD SDO and touch DOUT are high-impedance while deselected before relying
on the shared MISO wire.

Build without flashing:

```bash
scripts/nrf52840/build.sh --application kmrtm24024_spi
```

Only after the exact module and wiring have been verified, flash explicitly:

```bash
scripts/nrf52840/flash.sh --application kmrtm24024_spi
```
