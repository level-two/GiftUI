# SPEC-015 320×240 nRF preset comparison

Date: 2026-09-27.

The generated workload freshness check passed for all four profiles. The
registered `nrf52840-embedded` driver completed its hardware-free cross-build
and published immutable report
`.build/contract-reports/spec-015/29345aa610b84b09bc2dc545fc3f93d797bc5335-8f5b18eef305a8f5/nrf52840-embedded/`.
`scripts/contracts/compare-spec-015-presets.rb` then passed against the four
latest immutable profile reports. They have equal semantic checksum
`360515885`, one startup resolver call, and no post-startup resolver calls.
The nRF preset is Static, 320×240, with a 320×4 RGB565 region, 640-byte row,
and 2,560-byte raster/payload/in-flight bound. The comparison measured
157,648 bytes of named nRF application storage and verified the hard-float
Cortex-M4F ABI and zero heap allocation in the linked image.

This is a cross-build and host comparison. Connected display, input, cadence,
and stack high-water remain under the SPEC-001 physical test.
