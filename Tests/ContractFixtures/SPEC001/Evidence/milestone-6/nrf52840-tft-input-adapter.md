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

## Finite device-validation entry

A separately committed follow-up replaces the firmware's immediate
preset-check exit with a finite target-owned validation entry. After confirming
the exact generated preset, storage total, 4-row tile, and 3,840-byte segment,
it will, when deliberately flashed:

1. initialize ADS7846 and ILI9486 through their safe states;
2. transfer bounded color bars without a full framebuffer;
3. poll PENIRQ and raw samples every 10 ms for ten seconds;
4. print saturating fault counts and main-stack high-water over UART; and
5. return instead of running an unbounded loop.

The exact pristine build passed again. The follow-up artifacts are:

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `762373bed14562ffbc4c9d6421f003ca9543c49be58f3cfe9520912b7b57a0f8` |
| `zephyr.hex` | `3382b495777a3e9161c247bdb5675e7d6595da143761171a0abd7896b03ded58` |
| `zephyr.map` | `95b45a845a34b213bf97e4c2a001b213f51781cbd51d9ec2f62c7666797a29ea` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The load-segment report records 35,988 flash bytes and 176,508 RAM bytes;
hard-float, zero-heap, required-symbol, and ceiling checks pass. This is still
hardware-free evidence: the repository's `doctor.sh --probe` validates the
probe build, not a connected DK. No board was detected or flashed, and no
connected output or stack result is claimed.

## Explicit device cleanup

The next hardware-free slice adds target-owned shutdown entry points for both
controllers. ADS7846 shutdown leaves chip select inactive and PENIRQ as a
pulled-up input. ILI9486 shutdown turns the display and backlight off when
available, asserts reset, leaves data/command and chip select inactive, and
clears its initialized state. Display initialization rolls partial progress
back to that safe state.

The finite validation entry now tracks successful initialization separately
for touch and display. Every later display, input, or normal-completion path
runs reverse-order cleanup, preserves the original operational failure, and
records a cleanup failure without replacing an earlier one. This makes the
previously implicit finite-return behavior an explicit device-lifecycle
contract for the future Static host owner.

A pristine hardware-free build retains `ads7846_shutdown` and
`ili9486_shutdown` and again passes ARMv7E-M, VFP hard-float, zero-heap,
required-symbol, RAM, and flash gates:

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `f6fe865c298c3b52bdeda9c4dcb0d6361ed196d663f6dc8bfb7cb9ea71a2ec47` |
| `zephyr.hex` | `dfbcda4af14bb61866cc61bf1f3e4ca9fe99da87da975833bb76d1c0ea4fc2fe` |
| `zephyr.map` | `1b2b5f186403558049d3610400351cff42a7f1893fa7ce54dcf45e15d8666288` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The inspected load segments use 32,168 flash bytes and 175,296 RAM bytes.
No full framebuffer or heap entry point is present. No board was flashed.

## Target-local touch normalization

The ADS7846 boundary now includes an allocation-free normalizer configured by
explicit raw horizontal/vertical ranges, logical extent, axis swap, and axis
inversion. It maps accepted samples into bounded logical coordinates and emits
the same numeric down/move/up phases as GiftUI's portable pointer contract.
Leaving the calibrated range closes an active contact at its last valid point;
an input transport failure can reset local contact state without synthesizing
an action-producing up event. Source, sequence, ordinal, and physical-
presentation provenance remain owned by the future Static host admission
adapter, not by this device decoder.

`check-spec-001-nrf-touch-input.sh` compiles the exact firmware source as C99
with warnings treated as errors. Its fixture covers invalid calibration,
fail-closed reinitialization, minimum/midpoint/maximum mapping, swapped and
inverted axes, ordered down/move/up emission, out-of-range closure, and
transport reset. The check is also part of the SPEC-001 nRF profile driver.

The pristine firmware retains the initializer, update, and reset entry points
and passes ARMv7E-M, VFP hard-float, zero-heap, symbol, RAM, and flash gates.
The inspected artifacts are:

| Artifact | SHA-256 |
| --- | --- |
| `zephyr.elf` | `269d09fa033546d0e1332785edc1727fc1452ba1451cc0f0ff34eb55fcaa63cb` |
| `zephyr.hex` | `cb528626b32dd8343f88b9c1c4de384e586ff01ced990287fae906526a3243bf` |
| `zephyr.map` | `28145b1e6dd81fac8325a4a99beda5d3448ab3f63350154c1eb673adc5906a37` |
| `zephyr.dts` | `042dd0ead8283db2cb12d0ff36caad849f8c88787859202809cd03bf17aef6d7` |

The load segments use 32,456 flash bytes and 175,296 RAM bytes. Physical
calibration values and orientation are deliberately not claimed by this
hardware-free fixture and remain connected-target evidence.
