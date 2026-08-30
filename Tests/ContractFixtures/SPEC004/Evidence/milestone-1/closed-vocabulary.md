# SPEC-004 Milestone 1 Closed Vocabulary Evidence

Plan task: `T1.1`

Date: 2026-08-30

## Implemented surface

`GiftUICapabilities` now contains the approved common extent and byte-count
values, four finite option sets, all raw enums, requirement and contributor
records, host policy, effective result, resolution, immutable snapshot,
malformed-field/capacity/role tags, and the complete bounded unavailable
vocabulary. Resolver storage, contribution buffering, and resolution behavior
remain outside this task.

The emitted-interface check reports exactly 26 public types and exactly one
catalogue field, `CapabilitySnapshot.rasterPresentation`. `GiftUI` does not
re-export the capability module, and the capability leaf retains zero package
dependencies or forbidden compiled imports/product links.

## Constructor and representation evidence

Eight focused tests prove:

- every declared bit and raw enum value;
- nonzero `CapabilityExtent` and zero-valid byte ceilings;
- the exact five-operation requirement set;
- rejection of empty and unknown option bits;
- nonzero region, alignment, and in-flight structural bounds;
- region bounds no larger than their owning extent;
- distinct primary/alternate realization kinds;
- a tiled payload large enough for one complete aligned row for every
  advertised encoding;
- valid allowed/preferred realization and single-encoding policy choices;
- bounded unavailable associated payloads;
- `Equatable`/`Comparable`/`Sendable` value behavior; and
- every T1.1 record ceiling, including the 16-byte unavailable and 56-byte
  snapshot maxima.

Production storage uses only fixed-width values and finite value records. The
tiled-row construction check performs direct fixed-case arithmetic and owns no
collection.

## Four-profile validation

All exact driver profiles passed:

- Apple Swift 6.3.3 macOS dynamic, `-O` WMO;
- Apple Swift 6.3.3 macOS static, `-O` WMO;
- project-local Swift 6.3.2 ARMv6 Bookworm cross-build; and
- project-local Swift 6.3.2 nRF Embedded Swift `-Osize` WMO with Cortex-M4F
  hard-float flags.

These are host and hardware-free cross-build claims only. No remote access,
deployment, service restart, or flashing occurred.
