# SPEC-005 T5.2 Static-Path Allocation Evidence

**Task:** T5.2 (complete)

The optimized macOS dynamic and static probes execute validation, scalar
mapping, metric lookup, raster-record lookup, payload borrowing, and the
contract-local synchronous positioned-glyph offer inside one repeated measured
transaction. The aggregate reports zero heap allocations after warmup; because
the allocation counter is monotonic during the transaction, every named path
has a zero contribution. Named zero rows make that coverage fail-closed.

The production-source check rejects Foundation, Objective-C interoperation,
`Task`, `MainActor`, reflection, runtime discovery, desktop concurrency, and
unrestricted metrics/raster existential storage. The synchronous-offer probe
carries only nominal `FontInstanceID`, `GlyphID`, and explicit `Point`, and
performs nested metric, record, and payload lookup before the offer returns.

Reproduce with:

```text
scripts/contracts/run-spec-005.sh --profile macos-dynamic
scripts/contracts/run-spec-005.sh --profile macos-static
```

The generated `semantics/allocation-probe.txt` files contain the six named
operation rows, their zero aggregate, and a retained checksum. This is optimized
hardware-free host evidence; it is not a target runtime-allocation claim.
