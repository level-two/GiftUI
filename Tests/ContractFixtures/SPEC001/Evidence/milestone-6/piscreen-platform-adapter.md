# SPEC-001 T6.7 PiScreen Platform-Adapter Slice

The first T6.7 slice establishes a current-contract Raspberry Pi platform
boundary without restoring legacy renderer or runtime architecture.

`GiftUIPlatformRaspberryPi` owns:

- validation of a nonempty 16-bit framebuffer layout, row stride, and mapped
  byte extent;
- the exact 240 x 240 logical to 480 x 320 physical aspect-fit transform;
- the exact 240 x 16 RGB565 big-endian synchronous-borrow display-target
  contract with one in-flight payload and a 7,680-byte ceiling;
- bounded region metadata and canonical payload-byte preservation; and
- calibrated raw-touch mapping, letterbox rejection, and one ordered
  down/move/up contact sequence.

The focused command

```text
swift test --filter GiftUIPlatformRaspberryPiTests
```

passes five tests covering accepted and rejected framebuffer layouts,
aspect-fit/touch mapping, contact cancellation, exact canonical-byte and
physical-bound projection, invalid descriptors, and transport refusal.
`swift package dump-package | ruby scripts/contracts/check-target-dependencies.rb`
also passes with 83 targets, 335 direct edges, and no cycle.

This is hardware-free implementation evidence only. It does not open a Linux
device, execute the Signal Analyzer composition root, cross-build for ARMv6,
deploy to a Raspberry Pi, or claim PiScreen display/input behavior. Those
parts of T6.7 and T8.1 remain open.
