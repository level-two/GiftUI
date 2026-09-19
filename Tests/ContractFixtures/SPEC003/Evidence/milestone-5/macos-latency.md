# SPEC-003 macOS Reference Latency

**Task:** `T5.5` complete

**Recorded:** 2026-09-19

The registered SPEC-003 macOS dynamic and static drivers now compile and run a
dedicated optimized latency probe. Each run performs 1,000 warm-up iterations,
then times and preserves 10,000 individual production-path samples. The driver
fails if the p99 exceeds 100 microseconds or if any required sample is absent.

Both profiles passed after T5.4 completed. The clean-revision immutable report
root records revision `f42e2f611f0d2705601d00e42421a88a799fb8cc`
and input digest `afbba3d1f79503da` at
`.build/contract-reports/spec-003/f42e2f611f0d2705601d00e42421a88a799fb8cc-afbba3d1f79503da/`:

| Profile | Warm-up | Samples | p99 |
| --- | ---: | ---: | ---: |
| macOS dynamic | 1,000 | 10,000 | 167 ns |
| macOS static | 1,000 | 10,000 | 125 ns |

The runner is a `Mac15,7` MacBook Pro with Apple M3 Pro, 12 cores, and 36 GB
RAM using Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`). It runs the deliberately
reapproved macOS 26.6.2 build 25G83 reference environment. Both driver reports
record `reference_runner_match=true`.

T5.4's matched candidate/call-graph proof is complete. The raw samples and
runner metadata remain in the immutable `.build` report; this checked-in
record preserves the reproduction commands and conformance classification:

```sh
scripts/contracts/run-spec-003.sh --profile macos-dynamic
scripts/contracts/run-spec-003.sh --profile macos-static
```
