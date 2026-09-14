# SPEC-015 Milestone 6 — nRF52840 Static Preset

Evidence kind: `cross-build` plus a separately labeled host-native semantic
fixture. Connected execution and flashing are `not-collected`.

Reproduce from the repository root:

```sh
scripts/nrf52840/doctor.sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded
scripts/contracts/run-spec-001.sh --profile nrf52840-embedded
```

The pinned Swift 6.3.2, Zephyr 4.3.0, and SDK 0.17.4 build emits ELF, HEX, MAP,
Devicetree, and inspection reports under
`.build/nrf52840/signal-analyzer-static/`. The final ELF reports ARMv7E-M and
VFP-register arguments. It contains the Swift preset entry plus named,
caller-owned storage for the exact 28,016-byte generated profile workspace,
two 2,404-entry 24-byte transition stores (115,392 bytes), and one 3,840-byte
RGB565 raster/payload/in-flight staging slot. Heap and C allocation arenas are
configured to zero; the final global function table contains no malloc,
calloc, realloc, Swift task, Objective-C, or reflection entry point, and the
Zephyr configuration disables multithreading.

Final linked totals are 153,852 bytes RAM and 8,164 bytes flash, below the
approved 196,608-byte RAM and 1 MiB flash limits. The entry path uses eight
bytes of analyzed stack. The separately governed SPEC-004 capability evidence
records +252 bytes linked RAM, +4,768 bytes flash, 80 bytes conservative
resolver stack, and 72 bytes named capability storage, each within its
incremental budget. SPEC-014's reusable backend evidence supplies the exact
one-slot 480 x 4 production path without a full framebuffer.

The host-native Static semantic fixture resolves the exact 480 x 320 extent,
960-byte row, 3,840-byte bounds, one startup resolver call, and checksum
`360515885`, equal to all other presets. This build does not claim TFT, input,
watchdog, cadence, responsiveness, or other connected-board evidence.
