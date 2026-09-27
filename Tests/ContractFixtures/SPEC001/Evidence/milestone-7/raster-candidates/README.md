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
regions directly and fails if they change or are empty. It also verifies four
two-level running traces, 11 visible vertical grid lines, and the horizontal
center line from the raw pixels.
Independent review and locked RGB565 references are pending. These images must
not be used as passing oracles.

## Candidate identity for visual review

Both candidate commands in [the rehearsal record](../host-loop-rehearsal.md)
passed with the rendering sources committed in `5cd97720`. Their images were
captured before this evidence update was committed.
The Pi host binary SHA-256 was
`a24d1e1fcb52f51bb8c798f93ce8ae187a5867ed35460ede6f1e04b1b5cecb1d`;
the nRF host binary SHA-256 was
`0038a392cd2cc89f80d9f89ad4c42ad2f0faca49eece4a7ea48aff8ecb468ad2`.
The Pi and nRF source identities recorded by the runner were respectively
`34efe2c4526129e2ee0e1dd92582dac7b3e8281e70774a81f5aceaf0ff176ed1`
and `9723c47f132a32dca3b37696c0cbb0211e121ae221e73e708087ee07cee07213`.
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
| Idle | `cf8eb7ca9ae49b36ca31c85223d01ffb61e5cb6b8e711c33b15befc9358129be` | `8438ae379b845a253087043e0f04f2f493bcf0b1762d3cd62e2c6114825b85ed` |
| Four traces running | `ed9f3db3ca0cc56e126689989d7cd477dda985f9395a624e1fd732f0277e9487` | `c66b1b181f7d54e05d46f4956494e3f537cea4d2a6ead94b9065ecfd86e471dc` |
| Stopped | `747916b59f984d4d2eea57b34ac3a31970f06c915d316ae120cf3da91f47952a` | `823326c348d126ed383fcb8be664de70ee1920b66d797ed0fdfff54f53561dc0` |
| Cleared | `382c5791568decc349e3e8cc9230bafe209855326da6e6264e1fcdbc370b1c25` | `784c314bbb4f62c2b61514db8c40dd7bce738615e320bbdad011a43ca4c8536c` |
| One-second window | `b2b52ea32748e6cf147c090f5a8d3704ed94faf5bbc9c8b7108529d9de3364d7` | `71baeffffa9b61041962a806f5ca28977a9b21b85faef5aba9e1c55393324c9b` |
| Five-second window | `783c525168c38f116b0f9a6a5140a2abfa13bfe5277aa3d8914aadb1837ce3c4` | `57f8ede130aed5b7e35c5177ab6710ad4737bea65ccd4983b3060508a5e485b9` |
| Two-second window | `382c5791568decc349e3e8cc9230bafe209855326da6e6264e1fcdbc370b1c25` | `784c314bbb4f62c2b61514db8c40dd7bce738615e320bbdad011a43ca4c8536c` |
| Diagnostic | `16771dde9ecae28aa97f45136fdf4257f9e0c4bfbb5cd80eaa0756b7978e48da` | `86947390c91f9cf960abb0eda8629e72c34013f175a4a0384d86562e8a27ffc6` |

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
