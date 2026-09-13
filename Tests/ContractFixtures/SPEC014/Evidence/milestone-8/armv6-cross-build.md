# SPEC-014 T8.4 ARMv6 Cross-Build Evidence

Date: 2026-09-13

The Raspberry Pi toolchain preflight and hardware-free probe passed with the
repository-local Swift 6.3.2 host tools, Bookworm ARMv6 SDK, and exact
`armv6-unknown-linux-gnueabihf` destination. The probe produced a verified ARM
EABI5 hard-float executable.

The SPEC-014 collector compiled the complete Backend Integration module graph
with whole-module optimization and linked a static 32-bit ARM image. It
records the link map, section deltas, defined-symbol inventory, all eight
normative layouts, and zero allocator references in optimized resource-probe
IR. Its exact selected high-water is a 240 x 16 tile, 7,680 raster/payload/
in-flight bytes, 15 tile visits, 240 submitted regions, and 15 payloads.
Timing is explicitly `cross-build-not-executed`.

Run from the repository root:

```sh
scripts/raspberry-pi/doctor.sh
scripts/raspberry-pi/doctor.sh --probe
scripts/contracts/collect-spec-014-armv6-evidence.sh .build/spec-014/t8.4/raspberry-pi-armv6
```

All commands passed. This is hardware-free compile/link evidence only; it did
not access or deploy to a Pi and does not claim `armv6l` or PiScreen behavior.
