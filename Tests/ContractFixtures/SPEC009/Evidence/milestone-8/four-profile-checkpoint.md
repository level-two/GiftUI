# SPEC-009 T8.4/T8.5 Four-Profile Checkpoint

The complete 35-case canonical corpus and 31-value layout surface compile with
the exact macOS dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840
Embedded Swift profiles. The project-local Swift 6.3.2 ARMv6 probe produced a
32-bit EABI5 hard-float artifact for `armv6-unknown-linux-gnueabihf`. The nRF
probe built `nrf52840dk/nrf52840` with the `armv7em-none-none-eabi` Swift module
and produced ELF, HEX, map, devicetree, and inspection reports without flashing.

All four standalone SPEC-009 drivers pass with one input identity and report
`fixture_corpus=complete`. The required SPEC-014 production-backend collectors
were run at repository revision `11fd3463fb65e31ac6fa6613e61b2c8f470ce5fc`
under run ID
`11fd3463fb65e31ac6fa6613e61b2c8f470ce5fc-7b14b09da972d0c8`.
Their substantive profile work passed:

- macOS dynamic and static each passed the four production-owner suites,
  normalized shared corpus, and eight-layout declaration audit;
- Raspberry Pi produced and inspected the static
  `armv6-unknown-linux-gnueabihf` backend image with zero allocator references,
  linked sections/symbols/map evidence, and exact 240 x 16 bounds; and
- nRF52840 produced and inspected the `nrf52840dk/nrf52840` backend ELF with
  ARMv7E-M, VFPv4-D16, VFP-register arguments, zero allocation instructions,
  no retained framebuffer/display list, and exact 480 x 4 bounds. No target
  was connected or flashed.

This historical checkpoint's blockers are resolved. SPEC-014 now records the
SPEC-015 `GiftUIHostConfiguration` reverse edges as downstream consumers, and
SPEC-013 supplies the production admission/opportunity coordinators, exact
dynamic queue/workspace high-water, Static zero-heap, and runtime-image
evidence. T8.4 and T8.5 are closed by `production-resources.md` and
`four-profile-drivers.md`; this file remains the earlier checkpoint record.
