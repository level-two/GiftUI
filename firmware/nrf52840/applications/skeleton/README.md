# GiftUI nRF52840 Swift skeleton

This firmware is the first application-shaped Embedded Swift target for the
`nrf52840dk/nrf52840`. Zephyr owns startup and board drivers, a narrow C bridge
exposes those services, and Swift owns the long-running application state
machine.

When run on an nRF52840-DK, LED1 blinks while idle and stays lit while Button 1
is held. State transitions are also written to the Zephyr UART console. This
proves the Swift application entry point, persistent Swift state, calls in both
directions across the C boundary, sleeping, GPIO input, GPIO output, and the
final Cortex-M4F hard-float link.

Build without changing a connected board:

```bash
scripts/nrf52840/build.sh --application skeleton
```

Flashing remains an explicit, separate hardware operation. This skeleton does
not yet include the static GiftUI runtime, RGB565 renderer, ILI9486 display, or
ADS7846 touch support.
