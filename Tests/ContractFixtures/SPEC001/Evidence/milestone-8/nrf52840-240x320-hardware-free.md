# nRF52840 240×320 direct-SPI hardware-free evidence

Date: 2026-09-27

The approved `KMRTM24024-SPI` replacement is represented as a 240×320
portrait surface. The static host and firmware use a 240×4 RGB565 tile,
480-byte rows, 1,920-byte staging and payload bounds, and a separate 120-byte
coverage map. The shared Signal Analyzer view stacks its header at this width
without a target-specific Presentation branch.

The following repository-root checks passed after the replacement:

```sh
scripts/contracts/check-spec-001-spi-tft-transport.sh
scripts/contracts/check-spec-001-nrf-full-layout-native.sh
scripts/contracts/check-spec-001-nrf-production-host.sh
bash scripts/contracts/check-spec-001-nrf-host-native-faults.sh
scripts/contracts/check-spec-001-nrf-touch-input.sh
scripts/contracts/check-spec-001-nrf-static-touch-pipeline.sh
scripts/contracts/check-spec-001-host-native-rasters.sh --profile nrf52840-embedded --candidate-only
scripts/nrf52840/doctor.sh --probe
scripts/nrf52840/build.sh --application signal-analyzer-static
```

The direct-SPI native transport test covers command/data transactions, RGB565
window and byte bounds, failures, and shutdown. The host-native production
rehearsal covers 120 frame opportunities and 12 control actions. The raster
candidate set captures normal and diagnostic states and passes its semantic,
behavior, and candidate hash checks. It is **not** a reviewed pixel reference;
the independently reviewed `PixelReferences` gate remains open.

The linked firmware uses ARMv7E-M/VFP register arguments, 194,236 bytes RAM,
and 241,460 bytes flash in the four-preset report. The Zephyr overlay and
binding compile, and the hardware-free board probe passes. The SPI
initialization is a DCS-compatible candidate. The actual controller, pin map,
electrical limits, backlight, orientation, touch controller/calibration, and
connected display/input behavior remain unverified. No board was flashed.

The [240×320 SPEC-014 cross-build](../../../SPEC014/Evidence/milestone-8/nrf52840-240x320-cross-build.md)
and [four-preset comparison](../../../SPEC015/Evidence/milestone-6/240x320-four-preset-comparison.md)
provide the backend and host configuration resource evidence. The
[implementation plan](../../../../../docs/implementation-plans/spec-001-implementation-plan.md)
keeps the connected diagnostic and sustained on-board validation open.
