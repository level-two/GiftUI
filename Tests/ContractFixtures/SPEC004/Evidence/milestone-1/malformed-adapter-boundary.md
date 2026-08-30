# SPEC-004 Milestone 1 Malformed Adapter Boundary Evidence

Plan task: `T1.3`

Date: 2026-08-30

## Typed construction boundary

Fourteen focused `GiftUICapabilitiesTests` exercise every approved failable
construction class: exact requirement operations; empty and unknown encoding,
lifetime, handoff, operation, and realization bits; zero/nonzero extent,
region, alignment, and in-flight bounds; region-to-extent bounds; distinct
alternate realizations; valid policy preferences; and a complete aligned
tiled row for every advertised encoding. Zero byte ceilings remain valid.

These tests pass only constructible records to the typed contribution buffer.
They do not manufacture malformed stored values or claim that the future
resolver received an input rejected by a constructor.

## Downstream raw adapter fixture

`GiftUICapabilityAdapterTests` is a test-only downstream target importing both
the SPEC-002 portable `GiftUI.Size` declaration and `GiftUICapabilities`. It
adds no dependency to the production capability leaf.

Four adapter tests prove:

- zero `Size` dimensions map to `malformedRequirement(.extent)`;
- positive dimensions above `UInt16.max` map to
  `logicalExtentOverflow`;
- raw requirement validation selects operation, encoding, submission
  lifetime, extent, extent overflow, then byte-count failures in the approved
  staged order;
- negative and greater-than-`UInt32.max` raw byte counts are rejected, while
  zero ceilings are admitted;
- contribution failures select the lowest contributor role and then the
  lowest malformed-field raw value; and
- every one of the eleven malformed fields is preserved for every one of the
  four contributor roles.

The exact package graph is now ten targets and nine direct edges. The
production `GiftUICapabilities` target still has zero dependencies, while its
focused test target still depends only on `GiftUICapabilities`.

## Validation scope

The same unchanged production source passes the macOS dynamic/static,
Raspberry Pi ARMv6, and nRF52840 Embedded Swift contract profiles. Cross-build
claims are hardware-free; no remote access, deployment, restart, or flashing
occurred.
