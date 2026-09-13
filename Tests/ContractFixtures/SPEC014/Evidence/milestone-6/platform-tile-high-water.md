# SPEC-014 T6.5 Platform Tile High-Water Evidence

Date: 2026-09-13

Hardware-free host execution uses the exact selected platform descriptors and
fills the complete logical surface at every admitted equality bound.

| Profile fixture | Region | Tile bytes | Tiles/payloads | Regions | In-flight slots |
| --- | ---: | ---: | ---: | ---: | ---: |
| Raspberry Pi | 240 x 16 | 7,680 | 15 | 240 | 1 |
| nRF52840 | 480 x 4 | 3,840 | 80 | 320 | 1 |

Each tile produces one full-width maximal run per row and one synchronous
payload. Raster, maximum payload, and maximum in-flight byte high-water equal
the selected tile byte value. Every emitted byte pair is the canonical green
RGB565 encoding `07 E0`.

The nRF workspace is exactly 3,840 bytes, compared with 307,200 bytes for a
complete 480 x 320 RGB565 framebuffer. Production tiled sources contain no
owned array, collection, unsafe pointer, class workspace, producer field, or
complete-frame storage. The recording target's arrays exist only in host test
code to preserve an evidence transcript.

Run from the repository root:

```sh
swift test --filter exactPlatformTilesMeetWorstCaseHighWater
scripts/contracts/check-spec-014-storage.rb
scripts/contracts/check-spec-014-fixtures.rb
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

No device, framebuffer, remote service, or connected board was accessed.
