# SPEC-015 240×320 four-preset comparison

Date: 2026-09-27

The four immutable profile drivers completed at implementation revision
`1433d97c` with shared run ID
`1433d97ce82e336b44ead897f8c0d38fe6e6b3c4-de43777e100e4638`.
The updated comparison checker passed against those reports. The normalized
semantic checksum was `360515885` for all four profiles, with one capability
resolution at startup and none afterward.

| Profile | Logical surface | Raster staging | Profile storage |
| --- | --- | ---: | ---: |
| macOS Dynamic | 320×240 | 307,200 B | 41,376 B |
| macOS Static | 320×240 | 307,200 B | 39,696 B |
| Raspberry Pi ARMv6 | 240×240 | 7,680 B | 41,376 B |
| nRF52840 Static | 240×320 | 1,920 B | 39,696 B |

The nRF firmware cross-build reported 194,236 B linked RAM and 241,460 B
flash, below the approved 196,608 B RAM and 1 MiB flash ceilings. Its ELF
reported ARMv7E-M with VFP register arguments, and linked symbol inspection
found no prohibited heap or concurrency runtime symbol. The named application
storage is 39,696 B profile, 115,392 B capture, and 1,920 B raster staging,
for 157,008 B total; raster coverage is a separate 120 B symbol. No nRF board
was flashed or executed.

Reproduce from the repository root with
`scripts/contracts/run-spec-015-milestone-6.sh`. The four profile reports and
their source/artifact identities are under `.build/contract-reports/spec-015/`;
the normalized comparison is under `.build/spec-015/comparison/report.tsv`.
The original 480×320 milestone report remains historical evidence.
