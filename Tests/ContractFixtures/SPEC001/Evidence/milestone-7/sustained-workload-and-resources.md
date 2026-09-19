# SPEC-001 T7.4 Sustained Workload and Preset Evidence

- Workload: 80 events/second for 30 logical seconds (2,400 events)
- Publication cadence: four frames/second (120 frames)
- Capacity corpus: producer high-water 28, physical high-water 32, fact 33 rejected
- Result: pass

The two macOS executables and the Pi/nRF host-native preset fixtures execute
the same 120-window workload through the concrete Dynamic or Static admission
endpoint and emit one normalized checksum. Existing data-layer oracle evidence
additionally proves exact timestamps, 2,404 retained transitions including
four initial lows, replay, and no loss or duplication.

All four normalized reports preserve the exact SPEC-015 manifest, runtime
limits, physical extent, raster region, storage, Drawing, and assembly values.
Pi and nRF timing and connected-runtime fields remain explicitly
`not-collected`; their compiler, ABI, map, ELF, RAM, flash, workspace, and
forbidden-symbol evidence remains in the immutable SPEC-015 Milestone 6
reports consumed by the SPEC-001 driver.
