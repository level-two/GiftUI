# SPEC-004 Milestone 1 Fixed Contribution Storage Evidence

Plan task: `T1.2`

Date: 2026-08-30

## Fixed role-addressed buffer

`RasterPresentationContributions` owns four typed optional slots and one
`UInt8` duplicate mask. It contains no collection or insertion-order field.
The focused tests prove capacity `4`, first-value preservation, the fifth
insertion's necessarily duplicate result, per-role duplicate bits, and
lowest-raw-value duplicate precedence over missing-role selection.

Equality tests insert the same four roles in opposing orders. They also prove
that buffers compare the duplicate mask and nonduplicated slots while ignoring
the preserved value in any duplicated slot. A different nonduplicated slot
still makes the buffers unequal.

## Caller-owned workspace

`RasterPresentationResolverWorkspace` owns exactly two inline optional
candidate slots and a public usable-capacity value. Construction accepts
`0...2` and rejects `3`; append tests prove the declared usable boundary for
each accepted capacity. Reset empties both slots, after which the same
workspace accepts two candidates again in the opposite order.

The macOS layout assertions enforce the approved ceilings of 192 bytes for
the contribution buffer and 96 bytes for the resolver workspace. The emitted
interface audit reports exactly 30 public types and verifies every T1.2 case,
constant, property, initializer, and insertion signature.

## Validation

Twelve focused `GiftUICapabilitiesTests` pass. The exact standalone driver
also passes its macOS dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840
Embedded Swift profiles with the same production source. The cross-builds are
hardware-free; no remote access, deployment, service restart, or flashing
occurred.
