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

The four SPEC-014 drivers remain fail-closed because their module-contract
registry has not incorporated SPEC-015's later approved
`GiftUIHostConfiguration` reverse edges to Backend Integration, Display Core,
Raster Core, and Surface Core. SPEC-013 production admission/opportunity
coordinators are still required for allocation, dynamic queue/workspace
high-water, and complete runtime-image evidence. Consequently T8.4 and T8.5
remain unchecked; the missing backend owner is no longer their blocker.
