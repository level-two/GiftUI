# SPEC-004 Replacement nRF Fixture Evidence

**Scope:** approved `KMRTM24024-SPI` 240 x 320 logical target; hardware-free
capability arithmetic, normalization, and resource harness only.

The exact nRF fixture resolves a 240 x 4 RGB565 region at 480 bytes per row.
Raster, payload, and in-flight usage are each 1,920 bytes. A 240 x 320
full-surface RGBA8888 control requires 307,200 bytes and is unavailable under
the 1,920-byte raster ceiling. The separate 3,840-byte fact-admission storage
is unchanged.

`swift test --filter GiftUICapabilitiesTests` passed 37 tests.
`scripts/contracts/check-spec-004-profile-corpus.rb` passed five ordered
normalized cases with checksum 12. The four `run-spec-004.sh --profile`
commands passed for `macos-dynamic`, `macos-static`, `nrf52840-embedded`, and
`raspberry-pi-armv6`, publishing immutable reports under
`.build/contract-reports/spec-004/543a8573adedb99111f6e0cb11b986d0d3dd92ce-1f91c6629d049ebf/`.
These reports were generated from parent revision `543a8573` with the working
tree changes in this implementation step.

The nRF matched resource pair reports 7,936 baseline and 8,188 candidate
linked RAM bytes (+252); 25,732 baseline and 30,500 candidate linked flash
bytes (+4,768); 202 bytes named capability storage; 1,920 bytes display
staging; 80 bytes conservative resolver stack; and 44 initialization
operations. All configured bounds passed. This is a capability fixture probe,
not a linked Signal Analyzer firmware measurement or a connected-board result.
