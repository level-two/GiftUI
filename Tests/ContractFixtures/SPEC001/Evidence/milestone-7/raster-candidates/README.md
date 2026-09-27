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
