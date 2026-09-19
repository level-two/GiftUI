# SPEC-003 Informative macOS Latency

**Task:** `T5.5` preparation; informative only

**Recorded:** 2026-09-19

The registered SPEC-003 macOS dynamic and static drivers now compile and run a
dedicated optimized latency probe. Each run performs 1,000 warm-up iterations,
then times and preserves 10,000 individual production-path samples. The driver
fails if the p99 exceeds 100 microseconds or if any required sample is absent.

Both profiles passed under immutable run ID
`ed964f77b716777b300ff461db49ed02e542ac2d-73f3522a03c58738`:

| Profile | Warm-up | Samples | p99 |
| --- | ---: | ---: | ---: |
| macOS dynamic | 1,000 | 10,000 | 167 ns |
| macOS static | 1,000 | 10,000 | 167 ns |

The runner is a `Mac15,7` MacBook Pro with Apple M3 Pro, 12 cores, and 36 GB
RAM using Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`). It runs macOS 26.6.2 build
25G83. SPEC-003 freezes macOS 26.3 build 25D125, so the driver's
`reference_runner_match` is `false` and these samples are informative only.

T5.5 remains open because T5.4's matched candidate/call-graph proof must precede
latency evidence and because the exact frozen OS build was not used. The raw
samples and runner metadata remain in the immutable `.build` report; this
checked-in record preserves the reproduction command and classification:

```sh
scripts/contracts/run-spec-003.sh --profile macos-dynamic
scripts/contracts/run-spec-003.sh --profile macos-static
```
