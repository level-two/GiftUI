# T7.7 host-native raster candidates

These PNGs were rendered from the Pi and nRF recording adapters' RGB565
output on 2026-09-27. They are **candidates**, not approved pixel
references. The source RGB565 and frame traces are regenerated under
`.build/contract-generated/spec-001/` by the host-native commands.

The canonical Pi raster is 240×240, as approved by SPEC-001. The additional
`-physical` images show the 480×320 PiScreen mapping; the Pi recorder applies
`PiScreenAspectFitTransform.physicalBounds` to each submitted region. The nRF
recorder reconstructs its approved 480×320 surface from production
`ili9486_write_rgb565` tile writes.

The `diagnostic` images show a visible `ERR` message through each production
presentation loop. The Pi images use a 7×14 bitmap derived from Terminus
8×14 by removing each selected glyph's empty rightmost column. This keeps
the clearer lowercase shapes while allowing the full `RUNNING` status to
fit beside the title. The shared 16 px Inter resource remains in use on nRF.
The raw RGB565 captures preserve identical title and control pixel regions
across all eight states on both targets. The raster command checks those
regions directly and fails if they change or are empty.
Independent review and locked RGB565 references are pending. These images must
not be used as passing oracles.

## Candidate identity for visual review

Both candidate commands in [the rehearsal record](../host-loop-rehearsal.md)
passed at clean revision `8e45792f1937c9433b9923d3398caea623cbde2e`.
The Pi host binary SHA-256 was
`1290531102d015fcec49eff301204b5c989e05f8c2c62d3fc0e4dbb12e6b0f02`;
the nRF host binary SHA-256 was
`6477fff2cc999b0567c9135db660ea66cc752d1de1e875051ee372c8136bd381`.
The Pi and nRF source identities recorded by the runner were respectively
`7e8c7de196af27300bf91d2eeff9a9e31e534194274b44edd386c03c37dae654`
and `a1dbc89d11dd078f685cafed6ab532acb16f68d559ba38c970e97343d88c8aad`.
Every committed state PNG was byte-equal to the freshly rendered candidate.

| State | Pi logical (240×240) | PiScreen mapping (480×320) | nRF (480×320) |
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
| Idle | `c2ed068bc9f3f3dc4ab45dc567c5196608b4783fe9ddcd62ae0b023578494ddb` | `2870679886374dcb4d157d3d667dabe6abcf2458acabe35ff33912f1a905b612` |
| Four traces running | `9a6b33cd8743835cf409cfaf9930cce88becc58e51894f1f67c979f036d4c574` | `94192ca8f56d5c0abd4e5f390ae4d3ed554399c5f253ab830edd00e92b6fcda0` |
| Stopped | `56a03c4d76f38cfa331fef0fcd60d139fddbcf1893b2c878e1c2de0f0e1abc91` | `fdf3485afe902b0f129da97dc1f09d833bfcfc7b0d4a2b9fddd72b74b8adecd0` |
| Cleared | `b3a4af513ad7c41f77f4ad3f545c493075346cf6dae99c0f7b36a4296c2bd7ce` | `6b242478b73c0521eeecbef6b330fb73be36e12aec0a9e71680209b978885ef6` |
| One-second window | `68f321d2dfe369fd2a5d7bdd71336d910f492ed08f81a6187c00256d875200d3` | `d5e9966f5a70e189124fd03a278b2952fc245a2c7b0402de9326bb36713a8e18` |
| Five-second window | `31310f2d26a0c2fdc08bd17f9beeec37194a7c32617009c9155d9f53cc72f4f6` | `a9b800f0f0964fba8918360e1c0ea06c6f939f39da5675d042a7d7661a827e53` |
| Two-second window | `b3a4af513ad7c41f77f4ad3f545c493075346cf6dae99c0f7b36a4296c2bd7ce` | `6b242478b73c0521eeecbef6b330fb73be36e12aec0a9e71680209b978885ef6` |
| Diagnostic | `36064f9a95d4c2d5aefa4495dcfdd15f4c1521b9977b6645dd8e8b6089f57c88` | `a4af033a54401e7410bbb7873d4d731772a3c874182034a90e5888e58549b964` |

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
