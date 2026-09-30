# Pi semantic layout lookup measurement — 2026-09-28

SPEC-001 T8.1 is still blocked by frame cadence. This record covers the
published semantic layout lookup change in `0d524d25`, the regression check in
`68c7b523`, and the [connected raw trace](pi-performance-layout-lookup-connected-20260928.log).

## Implementation and verification

`DynamicSemanticHostStorage` now forms child and modifier lists once for each
bounded structural identity after publishing a semantic result. Layout queries
reuse those lists. The cache is cleared at the next expansion attempt; its
outer count is bounded by `maximumStructuralOccurrences`, and each list is
derived from the existing bounded semantic and modifier records. The
regression test exercises a second, different expansion and checks that the
old modifier result does not survive. Three focused semantic storage tests and
the exact SPEC-001 Pi host-native raster gate passed.

The first incremental ARMv6 build (`3e5c5f3145dcfcec45249fa36b11b83ef50e2658`)
segfaulted after its initial presentation. The [GDB trace](pi-performance-layout-lookup-incremental-gdb-20260928.log)
landed in `HostSequencedFactAdmission.quiesce` during teardown and does not
establish the cause. A clean cross-build through
`scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6 --clean`
passed the ARMv6 hard-float check. Its build ID is
`14a37b9585cd9d38dab187cbc788a56426833379`; both the local and deployed
artifact SHA-256 are
`fd4b77e3d282331863dffc046ef8418127c4ac8f21eaa2e26a3b533742fc865e`.
The deploy script verified `armv6l` and did not restart a service. A 10-second
foreground smoke run then completed normally. The 60-second foreground run
completed normally and produced 30 complete steady frames. The clean build
resolved the observed crash in these runs; the reason for the incremental
build's failure has not been proven.

## Connected timing

The previous candidate's 25 steady frames and the first 25 frames of this
run have identical payload, region, and byte counts in the same order. Each
`pi-frame-duration-us` closes the preceding `pi-present-us` and `pi-target-us`
pair. Offer excluding sink is `offer - sink`; other service time is
`frame - derive - offer`. All times below are milliseconds.

| Non-overlapping phase | Previous matched 25 mean | New matched 25 mean | Change |
| --- | ---: | ---: | ---: |
| **Total frame service** | **2,322.267** | **1,925.341** | **−396.925 (−17.1%)** |
| Presentation derivation | 651.328 | 265.229 | −386.099 |
| Offer excluding framebuffer sink | 828.172 | 821.628 | −6.544 |
| Framebuffer sink | 840.534 | 835.677 | −4.856 |
| Other service time | 2.233 | 2.807 | +0.574 |

Across all 30 new steady frames, mean frame service was **1,932.626 ms**
(median 1,940.144; range 1,764.107–2,114.765). Derivation averaged
265.782 ms, offer excluding sink 825.644 ms, and sink 838.398 ms. Mean
workload was 338.93 payloads, 3,927.57 regions, and 220,616.6 RGB565
payload bytes per frame. The application frame-service cadence is
**0.517 frames/s**, 7.73 times the required 250 ms period.

The matched reduction is concentrated in derivation, consistent with removal
of repeated layout lookups. This comparison spans separate hardware runs and
does not assign the entire difference solely to the code change. Frame service
does not measure physical SPI completion, panel-visible latency, or touch
response. No touch input was supplied in this run. The full-screen,
operation-major pipeline still submits about 220 KB and roughly 3,900
regions per frame, so T8.1 remains blocked.

## Packed framebuffer write experiment

The [packed-write candidate](pi-packed-projection-candidate-20260928.md) was
measured separately before this lookup change. Its first 25 steady frames
matched the prior candidate's workload counts. Mean total frame service was
2,320.940 ms versus 2,322.267 ms prior, while mean sink time was
858.029 ms versus 840.534 ms. It provided no measured improvement and was
reverted in `6802154f`. The current deployed binary contains the original
bytewise projection loop.
