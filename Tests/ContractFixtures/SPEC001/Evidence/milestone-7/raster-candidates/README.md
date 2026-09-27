# T7.7 host-native raster candidates

These PNGs were rendered from the Pi and nRF recording adapters' RGB565
output on 2026-09-27. They are **candidates**, not approved pixel
references. The source RGB565 and frame traces are regenerated under
`.build/contract-generated/spec-001/` by the host-native commands.

The canonical Pi raster is 240×240, as approved by SPEC-001. The additional
`-physical` images show the 480×320 PiScreen mapping; the Pi recorder applies
`PiScreenAspectFitTransform.physicalBounds` to each submitted region. The nRF
recorder reconstructs its approved 240×320 surface from production
`spi_tft_write_rgb565` row writes. The shared presentation stacks its existing
title, subtitle, and status so all three fit both 240-pixel-wide targets.

The `diagnostic` images show a visible `ERR` message through each production
presentation loop. The Pi images use a 7×14 bitmap derived from Terminus
8×14 by removing each selected glyph's empty rightmost column. This keeps
the clearer lowercase shapes. The shared 16 px Inter resource remains in use
on nRF. The raw RGB565 captures preserve identical title and background pixel
regions across all eight states on both targets. The raster command checks those
regions directly and fails if they change or are empty. It also verifies four
two-level running traces, 11 visible vertical grid lines, and the horizontal
center line from the raw pixels.
Independent review and locked RGB565 references are pending. These images must
not be used as passing oracles.

## Candidate identity for visual review

The original candidate identities and review history remain in the
[rehearsal record](../host-loop-rehearsal.md). Both candidate sets below were
regenerated after the shared header and nRF screen changes. Current source,
binary, and substituted-boundary identities are emitted by each candidate
runner under `.build/contract-generated/spec-001/`.
Each committed PNG was checked against its freshly rendered candidate.

| State | Pi logical (240×240) | PiScreen mapping (480×320) | nRF (240×320) |
| --- | --- | --- | --- |
| Idle | [view](pi-idle.png) | [view](pi-idle-physical.png) | [view](nrf-idle.png) |
| Four traces running | [view](pi-running-four-traces.png) | [view](pi-running-four-traces-physical.png) | [view](nrf-running-four-traces.png) |
| Stopped | [view](pi-stopped.png) | [view](pi-stopped-physical.png) | [view](nrf-stopped.png) |
| Cleared | [view](pi-cleared.png) | [view](pi-cleared-physical.png) | [view](nrf-cleared.png) |
| One-second window | [view](pi-window-one-second.png) | [view](pi-window-one-second-physical.png) | [view](nrf-window-one-second.png) |
| Five-second window | [view](pi-window-five-seconds.png) | [view](pi-window-five-seconds-physical.png) | [view](nrf-window-five-seconds.png) |
| Two-second window | [view](pi-window-two-seconds.png) | [view](pi-window-two-seconds-physical.png) | [view](nrf-window-two-seconds.png) |
| Diagnostic | [view](pi-diagnostic.png) | [view](pi-diagnostic-physical.png) | [view](nrf-diagnostic.png) |

The corresponding raw RGB565 SHA-256 values are:

| State | Pi logical | nRF |
| --- | --- | --- |
| Idle | `c0de51c30c24edce6927d8d20d756fc77612ff0317d7f16dd9041879d9953084` | `1da05bf58dd685022ab766363436aded9452b18841e2b8b9caeb687d54197a8b` |
| Four traces running | `80231beab57c6ad70eed345b08555b0ebb474814ded727a6347e178e8c55b9e4` | `821dd87f15399ca58a783468f3a4acba1c7c41390d4f3d14d3355867eda243dc` |
| Stopped | `755d617e0f9535570bc3eca85c17d73b814745e4e9c3be78a72aebf2d3df1fc8` | `dca694f3700fd9996bd7d5f910c7a889596b8a8fcf2adbb4f40ece62fdf8c143` |
| Cleared | `6d6b0d6921131a0260cec5d236349fd874e090faaf8735ce252d83a71ab444da` | `50ae27d91c0770509276b08405fe8e81ed2b84f957089453ead68e33928dac18` |
| One-second window | `dbea4561b3e6a606f3bcbd4c5f19bb8e80cbd70e2e1c23de76d56c4408ea2149` | `c231ff52e51146f002c83129728bda79e663886c1ad36962f214d04bc9f85f21` |
| Five-second window | `536643f8f4d2d4a7725053dd6840a3d4291a604eadfde497d301ef3388787908` | `a7f8717a2bde45e1adc8d56aeea7b1940d7d01c80854354ad16b4d4a5dc071a6` |
| Two-second window | `6d6b0d6921131a0260cec5d236349fd874e090faaf8735ce252d83a71ab444da` | `50ae27d91c0770509276b08405fe8e81ed2b84f957089453ead68e33928dac18` |
| Diagnostic | `d0ac7452a84bfabc28ce767480772433cfcd7fb4d18f79dc3033183828a84ef7` | `8da4620691ddec7488488da66194ab4044000f22784669184c2d4cd7e32fca4f` |

The cleared and two-second-window rasters match because returning to the
default two-second scale with no captured traces restores the same visible
state. Their action and model traces remain separately checked by the
behavior comparator.

Review the images at their native pixel size, including the Pi logical image
and its mapped physical view. Check the full title, subtitle, status, channel
labels, lowercase `a` and `e`, control names, selected time scale, four
running traces, and visible `ERR` diagnostic. Record the reviewer, decision,
reviewed revision, and any required correction in the rehearsal evidence
before copying the matching raw RGB565 captures into `PixelReferences`.
Each later reference change needs a new image and source-revision review.
