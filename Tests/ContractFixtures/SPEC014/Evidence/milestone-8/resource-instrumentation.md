# SPEC-014 T8.2 Resource Instrumentation

Date: 2026-09-13

The canonical resource fixture requires separate surface, tile, glyph,
stroke, region-record, payload, in-flight, and display/transport bytes; tile,
region, and payload counts; stack high-water; heap calls; and raster/submit
timings. It also records the exact header, damage, resources, region geometry,
compiler, SDK, target, optimization, warm-up, nine-sample timing method,
sections, linked symbols, and link map.

`BackendResourceSnapshot` is caller-owned fixed-width instrumentation with
saturating counters and no collection, closure, existential, or reference
field. The four profile compilers accept it. The static measurement contract
requires zero heap calls from construction through one worst-case frame;
T8.3-T8.5 must supply that measurement before final evidence can pass.

Run from the repository root:

```sh
scripts/contracts/check-spec-014-fixtures.rb
scripts/contracts/check-spec-014-resources.rb
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

All schema checks and four profile compilations pass.
