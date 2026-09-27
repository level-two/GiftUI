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
first raster exposed a clipped time-window control row. A later shared root
layout adjustment reduced outer spacing and padding; its idle PNG now shows
the title, status, ruler, four traces, and all six control labels. The
diagnostic text is still below the visible surface in the failure state. This
is an outstanding landscape layout defect, and the candidates are not reviewed
pixel references. The candidate files remain under
`.build/contract-generated/spec-001/nrf-raster-gate/`.

Physical verification of the new orientation, readable text, full-panel clear,
touch alignment, all six controls, frame cadence, and stack high water remains
open pending a new connected observation. No connected conformance claim or
`implemented` transition follows from this candidate.
