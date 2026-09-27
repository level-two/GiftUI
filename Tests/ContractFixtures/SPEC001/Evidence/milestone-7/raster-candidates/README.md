# T7.7 host-native raster candidates

These PNGs were rendered from the Pi and nRF recording adapters' RGB565
output on 2026-09-27. They are **candidates**, not approved pixel
references. The source RGB565 and frame traces are regenerated under
`.build/contract-generated/spec-001/` by the host-native commands.

The canonical Pi raster is 240×240, as approved by SPEC-001. The additional
`-physical` images show the 480×320 PiScreen mapping; the Pi recorder applies
`PiScreenAspectFitTransform.physicalBounds` to each submitted region. The nRF
recorder reconstructs its approved 240×320 surface from production
`spi_tft_write_rgb565` row writes. The static header stacks its existing title,
subtitle, and status so all three fit the narrower display.

The `diagnostic` images show a visible `ERR` message through each production
presentation loop. The Pi images use a 7×14 bitmap derived from Terminus
8×14 by removing each selected glyph's empty rightmost column. This keeps
the clearer lowercase shapes while allowing the full `RUNNING` status to
fit beside the title. The shared 16 px Inter resource remains in use on nRF.
The raw RGB565 captures preserve identical title and background pixel regions
across all eight nRF states. The raster command checks those
regions directly and fails if they change or are empty. It also verifies four
two-level running traces, 11 visible vertical grid lines, and the horizontal
center line from the raw pixels.
Independent review and locked RGB565 references are pending. These images must
not be used as passing oracles.

## Candidate identity for visual review

The Pi candidate in [the rehearsal record](../host-loop-rehearsal.md)
passed with the rendering sources committed in `5cd97720`.
The Pi host binary SHA-256 was
`a24d1e1fcb52f51bb8c798f93ce8ae187a5867ed35460ede6f1e04b1b5cecb1d`;
the nRF 240×320 candidate was regenerated after the screen migration.
The Pi source identity recorded by the runner was
`34efe2c4526129e2ee0e1dd92582dac7b3e8281e70774a81f5aceaf0ff176ed1`.
The nRF candidate below replaces the former 480×320 images and hashes; its
source and binary identities are recorded in the generated raster-gate report.
Each committed nRF PNG was checked against the freshly rendered candidate.

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
| Idle | `cf8eb7ca9ae49b36ca31c85223d01ffb61e5cb6b8e711c33b15befc9358129be` | `1da05bf58dd685022ab766363436aded9452b18841e2b8b9caeb687d54197a8b` |
| Four traces running | `ed9f3db3ca0cc56e126689989d7cd477dda985f9395a624e1fd732f0277e9487` | `821dd87f15399ca58a783468f3a4acba1c7c41390d4f3d14d3355867eda243dc` |
| Stopped | `747916b59f984d4d2eea57b34ac3a31970f06c915d316ae120cf3da91f47952a` | `dca694f3700fd9996bd7d5f910c7a889596b8a8fcf2adbb4f40ece62fdf8c143` |
| Cleared | `382c5791568decc349e3e8cc9230bafe209855326da6e6264e1fcdbc370b1c25` | `50ae27d91c0770509276b08405fe8e81ed2b84f957089453ead68e33928dac18` |
| One-second window | `b2b52ea32748e6cf147c090f5a8d3704ed94faf5bbc9c8b7108529d9de3364d7` | `c231ff52e51146f002c83129728bda79e663886c1ad36962f214d04bc9f85f21` |
| Five-second window | `783c525168c38f116b0f9a6a5140a2abfa13bfe5277aa3d8914aadb1837ce3c4` | `a7f8717a2bde45e1adc8d56aeea7b1940d7d01c80854354ad16b4d4a5dc071a6` |
| Two-second window | `382c5791568decc349e3e8cc9230bafe209855326da6e6264e1fcdbc370b1c25` | `50ae27d91c0770509276b08405fe8e81ed2b84f957089453ead68e33928dac18` |
| Diagnostic | `16771dde9ecae28aa97f45136fdf4257f9e0c4bfbb5cd80eaa0756b7978e48da` | `8da4620691ddec7488488da66194ab4044000f22784669184c2d4cd7e32fca4f` |

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
