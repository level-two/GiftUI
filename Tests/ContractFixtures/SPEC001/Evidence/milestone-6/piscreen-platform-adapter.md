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

## Connected device-readiness result

The separately authorized repository deployment workflow reverified the
selected machine as `armv6l` and atomically deployed the exact artifact, whose
SHA-256 is
`9a3b5e626da31fc1371e8bd0ac04a29fdeb4ba5e22b0818c95e6eec7eeaa315d`.
No service was restarted. Running

```text
giftui/bin/SignalAnalyzerRaspberryPiARMv6 --inspect-piscreen
```

as the unprivileged `giftui` user produced:

```text
status=ready framebuffer=480x320 bpp=16 stride=960 touch=/dev/input/event0
```

This proves that the current target-owned adapters can open and validate both
selected device nodes with the required account. It does not render an
analyzer frame, ingest a physical touch, or establish application-level
display/input behavior.

## Connected bounded-transport result

The next separately committed adapter slice added a finite
`--exercise-piscreen` mode. It reserves the exact 240 x 240 / 240 x 16 tiled
surface, produces fifteen 7,680-byte payloads, synchronously flushes the mapped
framebuffer after every payload, and polls the normalized input path for two
seconds. The rebuilt ARMv6 artifact has build ID
`cedb75d6279ff77454c7cda7d82c190000c6265f` and SHA-256
`47b2a7f8775124a3bab67d9ec9a220e3f7eac88cac20c3c3fe2929cd617e579d`.
It was deployed without a service restart. The connected command returned:

```text
status=completed payloads=15 regions=240 bytes=115200 contact-events=0
```

This proves that all 115,200 canonical RGB565 bytes for one logical surface
were accepted through the production display target and Linux framebuffer
sink on the selected Pi. The input descriptor remained readable throughout
the bounded poll, but no physical touch occurred; therefore this result does
not prove touch calibration, action routing, or any of the six controls.

The user subsequently confirmed that the gradient was physically visible on
the PiScreen. They also observed a blinking underscore over the image. That
underscore is consistent with the Linux framebuffer console cursor after the
finite validation process returns; it is not application output. This adds
human-observed display evidence for the bounded transfer, while exposing a
remaining platform-lifecycle requirement: the production host must own
graphics-console mode (or an equivalent cursor suppression mechanism) and
restore the prior console state during teardown. The unprivileged `giftui`
account can access framebuffer and input devices but is not a member of the
`tty` group, so this cannot be hidden by silently assuming `/dev/tty0` access.

The implementation and cross-build evidence remains distinct from these
connected adapter results. No Signal Analyzer composition root or physical
control scenario executed, so application-level portions of T6.7 and all of
T8.1 remain open.
