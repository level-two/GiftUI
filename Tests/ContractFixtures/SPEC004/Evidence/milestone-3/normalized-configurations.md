# SPEC-004 T3.1 Normalized Configuration and Field Evidence

The pure semantic corpus constructs all four supported configurations from
the public bounded declarations and compares complete effective results by
value. No fixture probes a concrete backend, display, device, or runtime
profile identity.

## Normalized results

| Configuration | Effective result |
| --- | --- |
| macOS dynamic | 640 x 480 full-surface RGBA8888; 2,560-byte row; 1,228,800 raster, payload, and in-flight bytes |
| macOS static | Exactly equal to the macOS dynamic effective value |
| Raspberry Pi 1 + PiScreen | 240 x 240 logical surface; 240 x 16 RGB565 tile; 480-byte row; 7,680 raster, payload, and in-flight bytes |
| nRF52840 + TFT | 480 x 320 logical surface; 480 x 4 RGB565 tile; 960-byte row; exactly 3,840 raster, payload, and in-flight bytes |
| nRF full-surface control | 480 x 320 RGBA8888 requires 614,400 bytes and is unavailable against the 3,840-byte raster ceiling |

## Fixture-to-field assertion report

| Admitted field or field group | Named assertion |
| --- | --- |
| Requirement `operations` | Every positive effective value equals raw operation bits `31`, covering opaque rectangles, positioned text, straight-line strokes, clipping, and damage |
| Requirement `extent` | Desktop is 640 x 480, PiScreen is 240 x 240, and TFT is 480 x 320; each realization and surface maximum extent equals its initialized logical surface |
| Requirement, producer, and realization `operationStream` | Every positive path equals `synchronousBorrowedOneShot` |
| Requirement accepted, realization produced, surface accepted encodings | Desktop intersection is RGBA8888; Pi and nRF intersections are RGB565 big-endian |
| Requirement accepted and realization produced submission lifetimes | Every normalized path intersects at synchronous borrow |
| Surface handoffs | Pi and nRF, as well as the equal desktop controls, select synchronous handoff |
| Realization `kind` and policy allowed/preferred realization | Desktop selects full surface; Pi and nRF select tiled; each policy permits and prefers only the asserted kind |
| Realization and surface maximum region width/height | Width always equals the complete logical row; desktop admits full height, Pi selects 16 rows, and nRF selects 4 rows |
| Realization and surface row alignment | All normalized fixtures contribute alignment 2; effective rows are exactly 2,560, 480, and 960 bytes |
| Requirement, realization, and policy raster ceilings | Each positive exact usage fits all three owners; the nRF RGBA control proves the 3,840-byte minimum rejects 614,400 bytes |
| Requirement, realization, and policy payload ceilings | Positive effective payload usage equals raster usage for each fixture and fits all three owners |
| Requirement, surface, and policy in-flight byte ceilings | Positive effective in-flight usage equals payload usage and fits all three owners |
| Surface `maximumInFlightCount` | Every normalized fixture admits exactly one active payload and every effective value records `inFlightCount = 1` |
| Requirement `absence` | Every claimed supported configuration is required; the separate optional-absence fixture remains the negative/control evidence |
| Policy allowed/preferred encoding | Desktop permits and prefers RGBA8888; Pi and nRF permit and prefer RGB565; selection remains within the technical intersection |
| Effective geometry and usage fields | Every result asserts extent, region extent, row bytes, encoding, lifetime, handoff, realization, raster bytes, payload bytes, count, and in-flight bytes individually |

Validated on 2026-08-30 with all four
`scripts/contracts/run-spec-004.sh --profile ...` commands. The same 34-row
semantic transcript passed under macOS dynamic/static, ARMv6, and nRF52840
profiles. Cross-target results are hardware-free evidence only.
