# SPEC-004 T2.3 Public Resolver Orchestration Evidence

The public `RasterPresentationResolver.resolve` entry point now orchestrates
the completed T2.1 arithmetic and T2.2 compatibility seams without importing
another module or allocating storage.

Focused tests prove:

- duplicate and missing roles precede workspace and semantic evaluation;
- one- and two-candidate workspace capacities are checked before partial
  normalization, and both inline slots are reset after every result;
- candidate declarations are canonicalized by realization raw value;
- all 24 role permutations return equal positive results and equal
  stream-mismatch negative reasons;
- reversed primary/alternate declarations select the same preferred complete
  path;
- the exact nRF-style result contains a 480-by-4 region, 960-byte row, and
  3,840 raster/payload/in-flight bytes; and
- optional unavailability constructs a snapshot with nil presentation while
  required unavailability prevents snapshot construction.

The semantic probe repeats the two 24-permutation fixtures and appends stable
normalized rows to `SemanticCorpus/cases.tsv`. Both macOS drivers compare the
complete 24-row transcript byte-for-byte.

Validated commands on 2026-08-30:

```text
swift test
scripts/contracts/run-spec-004.sh --profile macos-dynamic
scripts/contracts/run-spec-004.sh --profile macos-static
scripts/contracts/run-spec-004.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-004.sh --profile nrf52840-embedded
```

All commands passed; the package executed 105 tests. Both optimized macOS
allocation probes report `allocation_count=0` while invoking the public
resolver. ARMv6 and nRF52840 results are hardware-free compile evidence and
claim no connected-board execution.
