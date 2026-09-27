# nRF52840 320×240 landscape candidate

Date: 2026-09-27. Source revision: `37b08184`.

The maintainer's photograph of the connected 240×320 attempt showed a portrait
image with horizontally reversed text and an unpainted white band. That visual
observation closes the earlier question of whether pixels reached the panel;
it does not establish correct orientation or full-frame presentation.

The approved Specifications now define the `KMRTM24024-SPI` logical surface as
320×240. The firmware uses the DCS memory-access setting `0x28` (row/column
exchange and BGR) and clears the full surface before first presentation. A
fresh `nrf52840dk/nrf52840` build linked at 195,008 bytes RAM and 241,540
bytes flash with ARMv7E-M and VFP-register arguments. Its ELF SHA-256 is
`fdb713bc4ab177b0eb30977f241adaeb32c32a61809d8f0f5fd5c916736ccf4b`;
its HEX SHA-256 is
`549e0c6458bae163961140f480077d25336495a2ea11b45525dabe6e58e990e0`.
The HEX was flashed through the repository J-Link workflow after the
maintainer's connected-test request.

The nRF host-native rehearsal and eight 320×240 raster candidates pass. The
first raster exposed a clipped time-window control row. A later shared layout
adjustment reduced outer and inner spacing; its idle PNG now shows the title,
status, ruler, four traces, and all six control labels. The short `ERR`
diagnostic is visible, while longer diagnostics are clipped by the viewport.
The candidate files are not reviewed pixel references. They remain under
`.build/contract-generated/spec-001/nrf-raster-gate/`.

The compact layout source revision `e476c138` built again for
`nrf52840dk/nrf52840` and passed the nRF host-native raster candidate gate,
108 focused host tests, the registered SPEC-015 nRF cross-build profile, and
the four-preset comparison. Its ELF SHA-256 is
`38aaa11515c992bdd1e48c0c711ccd9842269e97b4e42a5543382a670f5022c1`;
its HEX SHA-256 is
`67fef78c96844fe6530d0e25d0b765ce3c8d16b3945be20a77c79ea2000d9211`.
That HEX was flashed through `scripts/nrf52840/flash.sh --application
signal-analyzer-static --no-build` with the J-Link runner. The board reset
after flashing. The maintainer then supplied the
[connected landscape photograph](nrf52840-320x240-connected-landscape.jpg).
It shows a horizontal image with left-to-right title, ruler, channel, and
control text. The horizontal mirroring seen in the earlier portrait photograph
is absent. All four channel rows and the six `Start`, `Stop`, `Clear`, `1 s`,
`2 s`, and `5 s` control labels are visible. The earlier white strip is absent
from the visible panel area. This confirms orientation and the static idle
presentation, not touch or frame cadence.

A later read-only J-Link snapshot on probe `683833660` reported 3.300 V and
halted the Cortex-M4 in thread mode (`IPSR=0`). The display driver's
`display_initialized` byte at `0x200283ac` was `1`; five `fault_counts` words
at `0x20028210` and the CFSR/HFSR words at `0xE000ED28` were all zero. The
core was resumed with `g`. This confirms initialization and absence of
recorded faults at the snapshot, but cannot establish visual orientation,
touch behavior, or display cadence.

Physical touch alignment, all six control actions, frame cadence, failure
presentation, and stack high water remain open. The long-diagnostic clipping
also remains unresolved in the host-native candidate. No full connected
conformance claim or `implemented` transition follows from this visual check.
