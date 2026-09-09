# SPEC-009 T8.4/T8.5 Four-Profile Checkpoint

The complete 35-case canonical corpus and 31-value layout surface compile with
the exact macOS dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840
Embedded Swift profiles. The project-local Swift 6.3.2 ARMv6 probe produced a
32-bit EABI5 hard-float artifact for `armv6-unknown-linux-gnueabihf`. The nRF
probe built `nrf52840dk/nrf52840` with the `armv7em-none-none-eabi` Swift module
and produced ELF, HEX, map, devicetree, and inspection reports without flashing.

All four standalone SPEC-009 drivers pass with one input identity and now
report `fixture_corpus=complete`. They remain fail-closed overall:
SPEC-013 production profile targets are required for allocation and dynamic
queue/workspace high-water evidence, and SPEC-014 is required for backend
target inspection. Consequently T8.4 and T8.5 are not marked complete.
