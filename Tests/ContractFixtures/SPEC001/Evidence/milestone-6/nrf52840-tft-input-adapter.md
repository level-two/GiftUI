# SPEC-001 T6.8 nRF52840 TFT/Input Adapter Slice

The selected connected assembly is the `nrf52840dk/nrf52840` with the
480 x 320 ILI9486 PiScreen display bridge and its ADS7846 resistive-touch
controller. This is the concrete assembly whose dimensions match the approved
480 x 320 Static preset and 480 x 4 RGB565 region contract.

The application-local Devicetree overlay fixes the display at 4 MHz and touch
at 2 MHz. It assigns the Arduino-header SPI bus, display chip select/DC/reset,
touch chip select, and active-low PENIRQ. Project-local bindings keep those
requirements explicit rather than depending on an unrelated generic panel.

The first hardware-free T6.8 slice restores the previously proven device
drivers at the current `signal-analyzer-static` firmware boundary. It provides:

- safe-state GPIO and SPI initialization for ILI9486 and ADS7846;
- the PiScreen serial-to-16-bit-parallel command framing;
- bounded RGB565 writes with an exact 480 x 4 / 3,840-byte maximum transfer;
- raw 12-bit touch sampling and active-low pen-state observation; and
- saturating, rate-limited display/input/capacity fault accounting.

The checked firmware retains each public driver entry point even before the
remaining Static host loop consumes it. `main` also validates the compiled
4-row and 3,840-byte values alongside the exact generated preset and storage
total.

## Exact build result

The project-local doctor passed with Swift 6.3.2, Zephyr 4.3.0, Zephyr SDK
0.17.4, target `armv7em-none-none-eabi`, and board
`nrf52840dk/nrf52840`. The command

```text
scripts/nrf52840/build.sh --application signal-analyzer-static --pristine
```

loaded `app.overlay`, compiled the ILI9486 and ADS7846 drivers, and passed the
ELF, hard-float, required-symbol, zero-heap, RAM, and flash gates. The emitted
ELF declares ARMv7E-M and `Tag_ABI_VFP_args: VFP registers`.

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `5217a55b094a3179dfa39e78a9d1b4ffe56933bacd49cef42b8206ccda84d8aa` |
| `zephyr.hex` | `11f6d71eac0f9f1f627858171d38733160490bbb68f53ab5c5a365fb4826b91e` |
| `zephyr.map` | `06b787854eb6574eeb458fed7c5f3937e3b69ea1cfd801f41aa6e7e864199c31` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The load-segment report records 35,192 flash bytes and 176,508 RAM bytes,
within the checked 1,048,576-byte flash and 196,608-byte RAM ceilings. Both
the Zephyr heap and C allocation arena remain zero. The display driver owns
only a bounded scratch segment; it does not introduce a 480 x 320 full-frame
buffer.

This slice is compile/link/inspection evidence only. It does not yet compose
the generated Static host loop, submit analyzer regions, normalize actions, or
measure connected stack high-water behavior. No board was flashed. The
documented physical-board provenance, shield continuity/orientation, and
power checks remain mandatory before the authorized connected campaign can
begin.
