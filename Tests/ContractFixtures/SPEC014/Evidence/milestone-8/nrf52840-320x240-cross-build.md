# SPEC-014 nRF52840 320×240 landscape cross-build

**Target:** `nrf52840dk/nrf52840`, `KMRTM24024-SPI` logical landscape surface.

`scripts/contracts/check-spec-014-capability-fixtures.rb` passed for the
320×240 tiled capability and the rejected full RGBA framebuffer. The
`scripts/contracts/run-spec-014.sh --profile nrf52840-embedded` run linked the
candidate Cortex-M4F hard-float ELF and passed its nRF evidence collector.
The collector measured one 320×4 RGB565 tile at 2,560 bytes in each of the
raster, payload, and in-flight domains. The analytical full-frame bound is
60 tile visits, 240 submitted regions, and 60 payloads. It found no retained
full framebuffer or display list and zero optimized embedded-entry heap
allocation instructions.

The aggregate SPEC-014 driver reported three unrelated incomplete assertions:
legacy Raspberry Pi migration inventory, plan completion status, and the
Raspberry Pi downstream module edge set. This document records the nRF
fixture and cross-build result only. It does not claim connected execution or
measured stack high water.
