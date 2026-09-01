# SPEC-005 T3.3 Payload-Subset Composition Evidence

T3.3 keeps one generated catalogue, one `FontResourceID`, and the same nominal
metric/raster view types across three compiler-visible compositions:

| Composition | Linked payload source | Available | Required result |
| --- | --- | --- | --- |
| complete | bitmap + outline | `0, 1` | both `.valid` |
| bitmap-only | bitmap | `0` | bitmap `.valid`; outline `.incompatibleViews` |
| outline-only | outline | `1` | outline `.valid`; bitmap `.incompatibleViews` |

The checked composition manifest maps `nrf52840-embedded` to bitmap-only with
realization `0` selected. Its exact source list contains the common catalogue,
the bitmap payload provider, and the common view implementation; it contains
neither the outline payload provider nor a second manifest/catalogue source.
The outline-only composition is a contract fixture and is not selected as an
MVP target profile.

## Reproduction

```text
scripts/contracts/check-spec-005-reference-compositions.sh /tmp/spec-005-compositions
swift test --filter GiftUIReferenceTextResourcesTests
swift test --filter ValidatorCoreTests.testCompleteSyntheticPackageValidates
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```

The composition driver builds the same concrete module name three times from
explicit source lists, links a probe against each image, and compares exact
normalized transcripts for the adopted identity, catalogue counts,
availability, and required-realization validation. It also rejects inclusion
of the omitted provider source in either subset composition. The existing
single-realization synthetic package remains `.valid` and is rerun here as the
required one-realization control.

The committed result is macOS compiler/link and source-list evidence. The nRF
mapping is fail-closed configuration for later cross-build and link-map tasks;
this step does not claim an nRF build, connected hardware, flashing, or runtime
resource measurements.
