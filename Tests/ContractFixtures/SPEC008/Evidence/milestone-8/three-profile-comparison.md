# T8.3 Three-Profile Comparison

macOS dynamic, macOS static, and Raspberry Pi ARMv6 reports passed from clean
revision `7b4eb21a68eb6240824c155f8eec0c22e1ed6aa4` with shared input-set digest
`01d653bd40508bb806ee6db5d1613c3528db0dae0ca40008d4efb0332fc9919e` and
run ID
`7b4eb21a68eb6240824c155f8eec0c22e1ed6aa4-01d653bd40508bb8`.

The checked-in comparator requires all three immutable reports to have the
same clean revision and input digest. It then verifies identical SHA-256
digests for:

- the complete canonical fixture and Signal Analyzer manifest;
- the executable recording/dynamic/static equivalence corpus;
- the canonical success/failure and owner-mapping checks;
- the recording-value and text-resource verification checks;
- all 17 public/negative declaration results;
- all 13 target-derived value-layout rows; and
- Signal Analyzer high-water, logical workspace, and call-stack reports.

Every profile log must also prove that the five field-by-field canonical cases,
the complete capacity/failure/snapshot/lifecycle/mapping matrix, typed ordered
recording values, exact text-resource compatibility, and the shared one-
producer equivalence corpus passed. The comparison therefore covers complete
normalized results, owner mappings, headers and ordered values, identity
relations, resource tokens, render/structural limits, and observed high-water.

Reproduce with:

```console
scripts/contracts/run-spec-008.sh --profile macos-dynamic
scripts/contracts/run-spec-008.sh --profile macos-static
scripts/contracts/run-spec-008.sh --profile raspberry-pi-armv6
scripts/contracts/compare-spec-008-render-profiles.rb \
  .build/contract-reports/spec-008/7b4eb21a68eb6240824c155f8eec0c22e1ed6aa4-01d653bd40508bb8 \
  /tmp/spec008-t83-comparison.tsv
```

The macOS profiles provide host execution. Raspberry Pi evidence is cross-build
and inspection only: it does not claim `armv6l` execution, framebuffer
presentation, input, deployment, service restart, or hardware validation.
