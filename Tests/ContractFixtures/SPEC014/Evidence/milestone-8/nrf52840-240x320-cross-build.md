# SPEC-014 240×320 nRF cross-build evidence

Date: 2026-09-27

The amended `spec014-nrf52840-rgb565-tiled` capability fixture passed its
normalized comparison with SPEC-004. The negative full-surface RGBA case
requires 307,200 bytes and is rejected against the 1,920-byte raster ceiling.

Run from the repository root:

```sh
scripts/contracts/check-spec-014-capability-fixtures.rb
scripts/contracts/collect-spec-014-nrf-evidence.sh .build/contract-generated/spec-014/nrf-240x320
```

Both commands passed. The collector compiled the optimized Embedded Swift
backend entry for `armv7em-none-none-eabi`, linked baseline and candidate
Zephyr ELFs, and verified Cortex-M4F VFP register arguments. The entry uses
one 240×4 RGB565 tile with 480-byte rows and 1,920-byte raster, payload, and
in-flight bounds. Its worst-case 240×320 fill visits 80 tiles and submits 320
regions. The optimized entry contains no heap allocation instruction, and the
linked map contains no retained full framebuffer or display list.

Generated commands, normalized fixtures, symbols, maps, section deltas,
allocation inspection, ARM attributes, and resource reports are under
`.build/contract-generated/spec-014/nrf-240x320/`. The 1,920-byte stack entry
in that report is the caller-owned tile workspace bound; connected stack high
water and display behavior remain unmeasured.
