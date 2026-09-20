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
- Linux-only ownership of framebuffer metadata validation, mmap lifetime,
  native RGB565 writes, nonblocking evdev ingestion, and descriptor teardown.

The focused command

```text
swift test --filter GiftUIPlatformRaspberryPiTests
```

passes five tests covering accepted and rejected framebuffer layouts,
aspect-fit/touch mapping, contact cancellation, exact canonical-byte and
physical-bound projection, invalid descriptors, and transport refusal.
`swift package dump-package | ruby scripts/contracts/check-target-dependencies.rb`
also passes with 83 targets, 335 direct edges, and no cycle.

The project-local Raspberry Pi doctor reports Apple Swift 6.3.2 and exact
target `armv6-unknown-linux-gnueabihf`. The command

```text
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
```

passes and emits a stripped 32-bit ARM EABI5 hard-float executable with build
ID `4faf112ea04f8a2a9bdc8acd98cdfa790cdf6ea6`. The executable exposes an
explicit `--inspect-piscreen` mode that opens and validates `/dev/fb0` and
`/dev/input/event0` without claiming application execution.

This is hardware-free implementation and cross-build evidence only. It does
not open a Linux device, execute the Signal Analyzer composition root, deploy
to a Raspberry Pi, or claim PiScreen display/input behavior. Those parts of
T6.7 and T8.1 remain open.
