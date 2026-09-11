# T8.4 nRF52840 Render Inspection

The exact nRF52840 SPEC-008 driver passed from clean revision
`ee8645f17d9e30d3cd67a0b9a07b35f1e91fe978` with input-set digest
`93d8efe80a3707ac3d9cd90be694b6eb02089c6522c018ad8ad7859f778240e8` and
run ID
`ee8645f17d9e30d3cd67a0b9a07b35f1e91fe978-93d8efe80a3707ac`.

The independent report auditor verified:

- all 17 public/negative declaration fixtures passed;
- all 13 target-derived value layouts meet their exact or maximum bounds;
- the complete five-case canonical corpus and capacity/failure matrix passed;
- optimized target SIL for the concrete production entry contains zero heap-
  allocation instructions;
- the concrete finite one-slot production workspace is 22 bytes with stride
  22 and alignment 2, including a three-byte foreground slot;
- baseline and candidate Zephyr ELFs and linker maps are non-empty;
- the candidate adds 240 code bytes, 112 read-only bytes, zero initialized
  bytes, and zero zero-initialized bytes over the baseline;
- the linked symbols include `spec008StaticRenderProductionEntry` and
  `giftui_spec008_render_probe`; and
- ELF attributes include ARMv7E-M, VFPv4-D16, single-precision hard-float use,
  and VFP-register argument passing.

Reproduce with:

```console
scripts/contracts/run-spec-008.sh --profile nrf52840-embedded
scripts/contracts/check-spec-008-nrf-render-report.rb \
  .build/contract-reports/spec-008/ee8645f17d9e30d3cd67a0b9a07b35f1e91fe978-93d8efe80a3707ac/nrf52840-embedded \
  /tmp/spec008-t84-nrf.tsv
```

This is cross-build and linked-image inspection only. The run records
`connected_target_execution=false`, `flashing=false`, and no remote access,
deployment, service restart, display, or input claim.
