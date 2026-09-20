# SPEC-015 Milestone 6 — nRF52840 Static Preset

Evidence kind: `cross-build` plus a separately labeled host-native semantic
fixture. Connected execution and flashing are `not-collected`.

Reproduce from the repository root:

```sh
scripts/nrf52840/doctor.sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded
scripts/contracts/run-spec-001.sh --profile nrf52840-embedded
```

The immutable report is bound to repository revision
`4035e46ed44e36fccf0fa160185f28a442257826`, run
`4035e46ed44e36fccf0fa160185f28a442257826-e5b156c796a8714d`, and ELF
SHA-256 `005fe1697a256bc273a9cb4f3f2bdd8d5314cae938472f7d40cca8b11a786698`.
The pinned Swift 6.3.2, Zephyr 4.3.0, and SDK 0.17.4 build emits ELF, HEX, MAP,
Devicetree, and inspection reports under
`.build/nrf52840/signal-analyzer-static/`. The final ELF reports ARMv7E-M and
VFP-register arguments. It contains the Swift preset entry plus named,
caller-owned storage for the exact 36,368-byte generated profile workspace,
two 2,404-entry 24-byte transition stores (115,392 bytes), and one 3,840-byte
RGB565 raster/payload/in-flight staging slot. Heap and C allocation arenas are
configured to zero; the final global function table contains no malloc,
calloc, realloc, Swift task, Objective-C, or reflection entry point, and the
Zephyr configuration disables multithreading. The retained two-byte protected
Swift personality leaf is toolchain support and is not reachable from the
preset entry; the entry path contains no throw or exception operation.

Final linked totals are 175,296 bytes RAM and 31,928 bytes flash, below the
approved 196,608-byte RAM and 1 MiB flash limits. The entry path uses eight
bytes of analyzed stack. The separately governed SPEC-004 capability evidence
records +252 bytes linked RAM, +4,768 bytes flash, 80 bytes conservative
resolver stack, and 202 bytes named capability storage, each within its
incremental budget. SPEC-014's reusable backend evidence supplies the exact
one-slot 480 x 4 production path without a full framebuffer.

The host-native Static semantic fixture resolves the exact 480 x 320 extent,
960-byte row, 3,840-byte bounds, one startup resolver call, and checksum
`360515885`, equal to all other presets. This build does not claim TFT, input,
watchdog, cadence, responsiveness, or other connected-board evidence.

## Amended-profile firmware reconciliation

The later SPEC-001 T6.8 composition audit found that the firmware reservation
still used the earlier 28,016-byte profile total while the current generated
audit and normalized report required 36,368 bytes. The corrected pristine
cross-build now retains an exact 36,368-byte profile symbol and checks its size
alongside the 115,392-byte capture and 3,840-byte staging symbols. Report
generation derives these values from the inspected ELF.

The corrected artifact has ELF SHA-256
`2ce8059e501e4903016339df28829c587f847c2c06b1275cf01b5a8591b27cc7`
and linked totals of 183,872 bytes RAM and 34,384 bytes flash. The immutable
report records the three measured symbol sizes. The artifact remains below the
approved ceilings with both heaps disabled. This remains cross-build-only
evidence; no connected execution or flashing occurred.
