# GiftUI ADS7846 Bring-Up Record

This record separates the completed hardware-free Phase 6 implementation from
claims that require the exact nRF52840-DK/PiScreen assembly. Do not replace a
`Not measured` entry with an assumption.

## Software baseline

| Item | Value |
| --- | --- |
| Firmware application | `ili9486` |
| Phase 6 implementation revision | `e0a4a12` |
| Board target | `nrf52840dk/nrf52840` |
| Touch controller | ADS7846-compatible; exact fitted part not yet verified |
| Shared SPI touch clock | 2 MHz maximum |
| Touch CS | DK D7 / P1.08, active low |
| PENIRQ | DK D6 / P1.07, active low with pull-up |
| Poll interval | 10 ms, outside GPIO interrupt context |
| Sample filter | Median of three X/Y/Z1/Z2 samples |
| Pressure gate | Z1 at least 100; integer resistance proxy at most 4,000 |
| Calibration | Five points, 16-pixel inset, 15-second timeout per point |
| Release timeout during calibration | 5 seconds |
| Linked flash | 54,968 bytes |
| Linked RAM | 38,908 bytes, including a 32 KiB main stack |
| Zephyr heap | Disabled (`CONFIG_HEAP_MEM_POOL_SIZE=0`) |

The hardware-free build produces an ARMv7E-M hard-float ELF and retains the
ADS7846 processing module, static runtime, RGB565 backend, and Embedded Swift
entry point. Host tests cover calibration span and center validation, inverted
axes, inset extrapolation, pressure rejection, median filtering, all four
orientations, release deduplication, and filtered tap dispatch into the typed
thermostat model. No firmware was flashed while creating this baseline.

## Hardware provenance and continuity gate

Complete the Phase 5 provenance and power gates first. Verify these additional
touch paths unpowered and by signal name; Raspberry Pi and Arduino header
positions do not align.

| Check | Expected path/state | Result | Evidence/reviewer |
| --- | --- | --- | --- |
| Touch controller identity | ADS7846 or electrically compatible | Not verified | — |
| Touch CS continuity | DK D7 / P1.08 to PiScreen touch CS | Not measured | — |
| PENIRQ continuity | DK D6 / P1.07 to PiScreen PENIRQ | Not measured | — |
| Shared SCLK continuity | DK D13 / P1.15 to LCD and touch SCLK | Not measured | — |
| Shared MOSI continuity | DK D11 / P1.13 to LCD and touch DIN | Not measured | — |
| Touch MISO continuity | DK D12 / P1.14 to touch DOUT | Not measured | — |
| LCD/touch MISO isolation | High impedance when each device is deselected | Not measured | — |
| Adjacent shorts | None across adapter conductors | Not measured | — |

Do not power or flash until the exact PiScreen supply rail, backlight circuit,
controller identities, continuity, and MISO isolation have been reviewed.

## PENIRQ and shared-bus gate

After the provenance gate passes, verify each condition independently of
GiftUI action dispatch.

| Check | Acceptance criterion | Result |
| --- | --- | --- |
| Boot chip selects | LCD CS and touch CS remain inactive except during their transactions | Not run |
| Idle PENIRQ | Stable inactive/high with no touch | Not run |
| Active PENIRQ | Low for a held press and high after release | Not run |
| Touch transaction | Touch CS active; LCD CS inactive; clock no faster than 2 MHz | Not run |
| Display transaction | LCD CS active; touch CS inactive; clock 4 MHz | Not run |
| Arbitration | Alternating display/touch operations show no overlapping chip selects | Not run |
| Display integrity | Touch polling produces no visible display corruption | Not run |
| Touch integrity | Full-screen transfers do not create missed or stuck touches | Not run |

Use a logic analyzer or oscilloscope capture as evidence for frequency,
chip-select exclusion, and PENIRQ timing. The synchronous Zephyr SPI calls are
the software arbitration mechanism; that implementation fact is not hardware
evidence.

## Five-point calibration capture

On boot, the firmware shows white targets in this order and logs the
pressure-qualified median raw sample to UART. Record the actual values rather
than typical ADS7846 ranges.

| Target | Display coordinate | Raw X | Raw Y | Z1 | Z2 | Accepted |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Top left | (16, 16) | Not measured | Not measured | Not measured | Not measured | Not run |
| Top right | (463, 16) | Not measured | Not measured | Not measured | Not measured | Not run |
| Bottom left | (16, 303) | Not measured | Not measured | Not measured | Not measured | Not run |
| Bottom right | (463, 303) | Not measured | Not measured | Not measured | Not measured | Not run |
| Center | (240, 160) | Not measured | Not measured | Not measured | Not measured | Not run |

Confirm the horizontal and vertical raw spans are each at least 256 counts and
the center is within one quarter-span of the derived midpoint. If pressure
values reject deliberate presses or accept hover/noise, record the observed
range and change the tracked threshold with host tests; do not silently tune a
local binary.

## Connected-board procedure

Only after the provenance, continuity, and shared-bus gates have been
reviewed:

1. Connect a UART console at 115200 baud and the logic analyzer channels.
2. Build and inspect the exact image:

   ```bash
   scripts/nrf52840/build.sh --application ili9486
   ```

3. Flash only through the explicit J-Link command:

   ```bash
   scripts/nrf52840/flash.sh --application ili9486 --no-build
   ```

4. Complete all five displayed targets, fully releasing after each press, and
   copy the UART samples into this record.
5. Confirm the thermostat appears after calibration and reports each target
   change once per completed tap.
6. Exercise display updates while watching both chip selects and PENIRQ.
7. Run the classification matrix below without rebooting between presses.
8. Hold, drag out of a control, release outside, alternate controls rapidly,
   and disconnect or fault the touch path where safe. Confirm there is no
   repeated action and no stuck pressed state.

## Classification and release results

Each row requires 100 completed presses. “Near edge” presses must cover all
four inside edges without intentionally crossing outside the hit region.

| Control/location | Required | Correct | Wrong action | Missed | Repeated | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Decrement, center | 100 | 0 | 0 | 0 | 0 | Not run |
| Decrement, near edges | 100 | 0 | 0 | 0 | 0 | Not run |
| Increment, center | 100 | 0 | 0 | 0 | 0 | Not run |
| Increment, near edges | 100 | 0 | 0 | 0 | 0 | Not run |

| Additional check | Result |
| --- | --- |
| Drag outside cancels action | Not run |
| Held touch dispatches no repeated action | Not run |
| Release emits exactly once | Not run |
| Alternating controls leaves no stuck state | Not run |
| Median filtering rejects injected/sampled outliers | Not measured |
| Median touch-to-visible-update latency | Not measured |
| Worst-case touch-to-visible-update latency | Not measured |
| Longest continuous touch/render run | Not run |

## Phase 6 disposition

The hardware-free implementation is ready for connected-board validation. The
Phase 6 gate remains open until the exact assembly passes provenance,
continuity, PENIRQ, shared-bus, calibration, classification, release, and
stuck-state checks. A successful build alone is not completed touch support.
