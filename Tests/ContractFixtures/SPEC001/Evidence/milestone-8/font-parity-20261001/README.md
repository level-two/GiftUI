# Signal Analyzer shared-font evidence — 2026-10-01

Pi previously selected a separate 7×14 Terminus package while nRF selected the
approved 20-point Inter reference font. SPEC-005 requires the shared analyzer
fixtures to use one compatible reference identity/catalogue. Pi now selects
Inter through its assembly-owned package for validation, layout, and rasterization.
No font payload, resource identity, nRF firmware, or resource limit was changed.

These PNGs are native-host captures of production rendering. Pi uses a 240×240
logical surface mapped onto PiScreen; nRF uses a 320×240 surface. Neither was
captured from connected hardware. The plot remains between the label columns.

- [Pi running](pi-running-four-traces.png), [nRF running](nrf-running-four-traces.png).
- [Pi diagnostic](pi-diagnostic.png), [nRF diagnostic](nrf-diagnostic.png).
- `pixel-font-parity.txt`: exact RGB565 equality for title/subtitle, status,
  channel/state labels and controls across seven normal states. Diagnostic
  acquisition states differ between fault injectors; its common title/subtitle
  and channel labels are compared.
- `pi-raster-hashes.tsv`: all eight fresh Pi raster captures passed geometry
  and invariant checks. nRF captures reuse the unchanged validated layout run.
- `pi-build.log`: verified ARMv6 hard-float application build.
- Both behavior comparisons and fault-result files passed.

Reproduce pixel equality after running both candidate host raster scripts:

```sh
python3 scripts/contracts/check-spec-001-font-parity.py \
  --pi .build/contract-generated/spec-001/pi-raster-gate/captures \
  --nrf .build/contract-generated/spec-001/nrf-raster-gate/captures
```

T7.7 remains blocked on reviewed pixel references; T8.2 retains its connected
hardware gate. No lifecycle approval or completion status changed.

The final unit-suite retry passed **1,140 tests in 17 suites**, including font
identity and full diagnostics (`unit-test-summary.txt`). The initial repository
run exposed an obsolete 23-line expectation for a 96-character W diagnostic;
Inter wraps it to 27 lines while remaining within the 128-line capacity. The
expectation was corrected in `9ea00226` after implementation commit `a9f5f7e8`.

The repository gate recorded 11 failures before the diagnostic expectation
correction: `root-tests` plus the same 10 broader audit/evidence failures from
the preceding layout validation. The complete 1,140-test retry supersedes that
root-test failure. SPEC-001, SPEC-002, SPEC-007, SPEC-010 and SPEC-015 passed,
as did governance, formatting, profile storage, and diagnostic-buffer checks.
The remaining failures belong to SPEC-003/004/005/006/008/009/011/012/013/014;
this font correction does not repair those wider audit and evidence gaps.
Raw gate results are preserved in `repository-gate-results.tsv` and
`repository-gate.log`; the passing retry is in `unit-test-summary.txt`.
