# SPEC-005 Adopted SPIKE-005 Input Baseline

Plan task: `T0.5`

Date: 2026-09-01

## Adopted source and license

The licensed source is official Inter release 4.1 archive member
`extras/ttf/Inter-Regular.ttf`, source SHA-256
`40d692fce188e4471e2b3cba937be967878f631ad3ebbbdcd587687c7ebe0c82`.
The upstream archive SHA-256 is
`9883fdd4a49d4fb66bd8177ba6625ef9a64aa45899767dde3d36aa425756b11e`.
The checked-in OFL 1.1 source and generated license-copy hashes are both
`262481e844521b326f5ecd053e59b98c8b2da78c8ee1bdbb6e8174305e54935a`.
The derivative name is `GiftUI Reference Sans`.

This is engineering provenance, not legal advice. The source, license,
attribution, derivative naming, and redistribution conditions remain subject
to normal human/legal review as applicable.

## Exact adopted package facts

| Fact | Frozen value |
| --- | ---: |
| Resource identity / canonical manifest SHA-256 | `bd14de9ff2baaaf464c130d5e2d0554004a4055cc57a8c16a65fe2cc39394910` |
| Canonical manifest bytes | 6,218 |
| Required mappings | 96 (`U+0020...U+007E`, `U+00B0`) |
| Glyphs | 102 |
| Replacement glyph | glyph zero / `.notdef` |
| Bitmap payload | 1,911 bytes; SHA-256 `69cf6841d1ecd25079a63f3dcc6866c119cd11ca4c62115185af99781d13af68` |
| Outline fixture payload | 13,195 bytes; SHA-256 `3d05ced8a32b17a45569b6650ea4fe88b1f2f0dc93493e79631a628d56df4c5f` |
| Canonical record JSON | 63,909 bytes; SHA-256 `717526bacb8629727f64d2bd8b01fedceaa29c7471cc72e34e5c9fa2a391ece2` |

The machine-checked inventory records every adopted byte, record-table and
provenance file, derivation pin, calibration transcript, and disposable
mechanism with exact byte count and SHA-256. The driver also checks the eleven
source/generated entries recorded by SPIKE-005's `SHA256SUMS`.

## Derivation and calibration evidence

The evidence pins CPython 3.9.6, fontTools 4.60.2, Pillow 11.3.0, and bundled
FreeType 2.13.3. SPIKE-005's reproduction command remains
`experiments/spike-005-inter-reference-font/run.sh --verify`.

The hardware-free nRF52840 calibration is frozen as:

| Metric | Baseline | Candidate | Delta | Ceiling |
| --- | ---: | ---: | ---: | ---: |
| Linked flash bytes | 22,836 | 32,060 | 9,224 | 98,304 |
| Linked RAM bytes | 4,988 | 4,988 | 0 | 512 resource-specific |
| `bss` bytes | 1,013 | 1,013 | 0 | 512 resource-specific |
| `data` bytes | 28 | 28 | 0 | 512 resource-specific |
| Conservative validation stack | 0 | 568 | 568 | 1,024 |

The evidence identifies `nrf52840dk/nrf52840`, ARMv7E-M, VFP hard-float,
Zephyr 4.3.0, and SDK 0.17.4. It is cross-built/static evidence, not a
connected-hardware stack high-water or runtime claim.

## Explicit non-adoption

`generate.py`, `run.sh`, `run-nrf.sh`, generated C tables, the C validator,
and the Spike firmware organization are classified as
`disposable-mechanism`. Their hashes preserve reproducibility and provenance;
their presence does not make them production implementation, architecture,
or a substitute for the Swift package, validator, generator, and target
composition tasks later in this plan.
